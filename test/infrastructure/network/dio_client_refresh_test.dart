import 'dart:convert';
import 'dart:io';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:rekanara_getx/infrastructure/network/dio_client.dart';
import 'package:rekanara_getx/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart';
import 'package:rekanara_getx/infrastructure/platform/secure_storage/secure_storage.dart';

import 'dio_client_refresh_test.mocks.dart';

/// Fake [HttpClientAdapter] — maps request to static response
/// without network call. Allows end-to-end testing of interceptor chain
/// (401 → refresh → retry).
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.handler);

  int requestCount = 0;
  final Future<(int, Map<String, dynamic>)> Function(RequestOptions options)
  handler;

  void reset() => requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final (status, body) = await handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

@GenerateMocks([SecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const beBaseUrl = 'https://api.test.dev';
  const meUrl = '$beBaseUrl/api/v1/me';
  const me2Url = '$beBaseUrl/api/v1/me2';

  late MockSecureStorage secureStorage;
  late FakeHttpClientAdapter authAdapter;
  late FakeHttpClientAdapter noAuthAdapter;

  int refreshCalls = 0;
  dynamic capturedRefreshBody;

  setUpAll(() async {
    Get.testMode = true;

    // GetStorage (used by EnvironmentController via ConfigEnvironments)
    // needs path_provider — mock its channel so init() runs in test.
    final tmpDir = await Directory.systemTemp.createTemp('get_storage_test');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => tmpDir.path);
    await GetStorage.init();

    // All `.env` keys must be filled — `ConfigEnvironments._configs`
    // builds DEV/STAGING/PROD all at once with null-assert (`!`).
    dotenv.loadFromString(
      envString: [
        'JWT_SECRET=test',
        'NEX_APP_NAME=Test',
        'URL_APPCAST_ANDROID=https://example.com/a.xml',
        'URL_APPCAST_IOS=https://example.com/i.xml',
        for (final suffix in ['_DEV', '_STAGING', '_PROD']) ...[
          'NEX_BE$suffix=$beBaseUrl',
          'NEX_FE$suffix=https://fe.test.dev',
          'CDN$suffix=https://cdn.test.dev',
          'MQTT_BROKER_URL$suffix=localhost',
          'MQTT_BROKER_PORT$suffix=1883',
          'MQTT_CLIENT_ID$suffix=test',
          'MQTT_USERNAME$suffix=',
          'MQTT_PASSWORD$suffix=',
          'FIREBASE_PROJECT_ID$suffix=x',
          'FIREBASE_STORAGE_BUCKET$suffix=x',
          'FIREBASE_BUNDLE_ID$suffix=x',
          'FIREBASE_MESSAGING_SENDER_ID$suffix=x',
          'ANDROID_FIREBASE_API_KEY$suffix=x',
          'ANDROID_FIREBASE_APPID$suffix=x',
          'IOS_FIREBASE_API_KEY$suffix=x',
          'IOS_FIREBASE_APPID$suffix=x',
        ],
        // Prod keys use names without suffix.
        'FIREBASE_PROJECT_ID=x',
        'FIREBASE_STORAGE_BUCKET=x',
        'FIREBASE_BUNDLE_ID=x',
        'FIREBASE_MESSAGING_SENDER_ID=x',
        'ANDROID_FIREBASE_API_KEY=x',
        'ANDROID_FIREBASE_APPID=x',
        'IOS_FIREBASE_API_KEY=x',
        'IOS_FIREBASE_APPID=x',
      ].join('\n'),
    );

    secureStorage = MockSecureStorage();

    // Handler for AUTH client: always 401 (token expired).
    authAdapter = FakeHttpClientAdapter(
      (options) async => (401, {'message': 'unauthorized'}),
    );

    // Handler for NO-AUTH client: serves refresh POST + retry request.
    noAuthAdapter = FakeHttpClientAdapter((options) async {
      if (options.method == 'POST' &&
          options.uri.path.endsWith('/auth/refresh')) {
        refreshCalls++;
        capturedRefreshBody = options.data;
        // Small delay widens race window — guarantees parallel 401s
        // sit at the same single-flight gate.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return (
          200,
          {
            'data': {
              'access_token': 'new-access',
              'refresh_token': 'new-refresh',
            },
          },
        );
      }
      // Retry original request post-refresh → success.
      return (200, {'ok': true, 'path': options.uri.path});
    });

    final authDio = DioClient.authClient(secureStorage);

    // Chucker interceptor backed by sqflite — not available in
    // flutter_test. Removed so pure adapter path is tested.
    authDio.interceptors.removeWhere((i) => i is ChuckerDioInterceptor);
    DioClient.noAuthClient.interceptors.removeWhere(
      (i) => i is ChuckerDioInterceptor,
    );

    authDio.httpClientAdapter = authAdapter;
    DioClient.noAuthClient.httpClientAdapter = noAuthAdapter;
  });

  setUp(() {
    reset(secureStorage);
    authAdapter.reset();
    noAuthAdapter.reset();
    refreshCalls = 0;
    capturedRefreshBody = null;
  });

  group('DioClient.authClient refresh-token flow', () {
    test(
      '401 triggers refresh, persists new tokens, then retries successfully',
      () async {
        when(secureStorage.read(SecureStorageKey.accessToken))
            .thenAnswer((_) async => 'expired-access');
        when(secureStorage.read(SecureStorageKey.refreshToken))
            .thenAnswer((_) async => 'valid-refresh');
        when(secureStorage.write(any, any)).thenAnswer((_) async {});

        final authDio = DioClient.authClient(secureStorage);
        final response = await authDio.get(meUrl);

        expect(response.statusCode, 200);
        expect(response.data['ok'], isTrue);
        expect(refreshCalls, 1);
        expect(
          capturedRefreshBody,
          containsPair('refresh_token', 'valid-refresh'),
        );
        verify(secureStorage.write(SecureStorageKey.accessToken, 'new-access'))
            .called(1);
        verify(
          secureStorage.write(SecureStorageKey.refreshToken, 'new-refresh'),
        ).called(1);
      },
    );

    test(
      'parallel 401s only trigger a single refresh (single-flight)',
      () async {
        when(secureStorage.read(SecureStorageKey.accessToken))
            .thenAnswer((_) async => 'expired-access');
        when(secureStorage.read(SecureStorageKey.refreshToken))
            .thenAnswer((_) async => 'valid-refresh');
        when(secureStorage.write(any, any)).thenAnswer((_) async {});

        final authDio = DioClient.authClient(secureStorage);
        final results = await Future.wait([
          authDio.get(meUrl),
          authDio.get(me2Url),
        ]);

        expect(results.map((r) => r.statusCode), everyElement(200));
        expect(refreshCalls, 1);
        verify(secureStorage.write(SecureStorageKey.accessToken, 'new-access'))
            .called(1);
      },
    );
  });
}

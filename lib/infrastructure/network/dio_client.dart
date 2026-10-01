import 'dart:async';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:get_storage/get_storage.dart';

import '../platform/secure_storage/flutter_secure_storage_impl.dart';
import '../platform/secure_storage/secure_storage.dart';
import '../navigation/routes.dart';
import '../../utils/helper/logger.dart';
import 'dio_wrapper.dart';
import 'url.dart';

class DioClient {
  /// Single-flight gate for refresh-token — ensures N parallel 401s
  /// only trigger one POST `/auth/refresh`, and all callers receive
  /// the same result. `null` = no refresh in-flight.
  static Completer<String?>? _refreshCompleter;

  /// Single-flight gate for force-logout — prevents N parallel callers
  /// from executing `deleteAll()` + `Get.offAllNamed(login)` simultaneously
  /// when all refreshes fail in a 401 batch.
  static bool _isForceLoggingOut = false;

  /// Cache Dio instance to prevent memory leaks and reuse connection pool.
  static Dio? _noAuthDio;
  static Dio? _authDio;

  /// In-memory access-token future. Avoids disk I/O to SecureStorage
  /// on every auth request. Future is set synchronously by the first
  /// caller (before await) so all concurrent callers share
  /// the same result — preventing thundering herd on app warm-up.
  /// `null` = not yet hydrated; reset on force-logout.
  static Future<String?>? _accessTokenFuture;

  /// Logger + Chucker (debug-only) — Chucker is limited to kDebugMode so
  /// the debug UI drawer doesn't leak into the release APK/IPA.
  static void _addCommonInterceptors(Dio dio) {
    dio.interceptors.add(DioWrapper.dioLog);
    if (kDebugMode) dio.interceptors.add(ChuckerDioInterceptor());
  }

  /// Attach `Authorization: Bearer <token>` if token is non-null/non-empty.
  static void _attachAuthHeader(RequestOptions options, String? token) {
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Client without authentication — for login, register, etc.
  static Dio get noAuthClient {
    if (_noAuthDio != null) return _noAuthDio!;

    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    _addCommonInterceptors(dio);

    _noAuthDio = dio;
    return dio;
  }

  /// Client with authentication — automatically injects Bearer token
  /// from [SecureStorage] and handles refresh token on 401.
  static Dio authClient(SecureStorage secureStorage) {
    if (_authDio != null) return _authDio!;

    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    _addCommonInterceptors(dio);

    /// Auth + Refresh Token Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Hydrate future synchronously before await — concurrent callers
          // share the same future, preventing N duplicate disk reads.
          _accessTokenFuture ??= secureStorage.read(
            SecureStorageKey.accessToken,
          );
          _attachAuthHeader(options, await _accessTokenFuture);
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Only handle 401 — other errors are passed through as is.
          if (e.response?.statusCode != 401) {
            return handler.next(e);
          }

          // Loop guard: if this is a retry post-refresh and still 401,
          // token is considered invalid → force logout, do not refresh again.
          if (e.requestOptions.extra['refreshed'] == true) {
            await _forceLogout(secureStorage);
            return handler.next(e);
          }

          try {
            // Single-flight: N parallel 401s will share one refresh request.
            final newToken = await _refreshTokenSingleFlight(secureStorage);

            if (newToken == null) {
              await _forceLogout(secureStorage);
              return handler.next(e);
            }

            _attachAuthHeader(e.requestOptions, newToken);
            // Mark as retry — if 401 again, the guard above will force logout.
            e.requestOptions.extra['refreshed'] = true;

            final retryResponse = await noAuthClient.fetch(e.requestOptions);

            // Edge case: retry successful HTTP-wise but status is still 401.
            if (retryResponse.statusCode == 401) {
              await _forceLogout(secureStorage);
              return handler.next(e);
            }

            return handler.resolve(retryResponse);
          } catch (retryError) {
            // Retry fetch itself throws (network down, timeout, etc).
            LoggerHelper.e(
              '[DioClient.authClient] Refresh-token retry failed',
              retryError,
            );
            await _forceLogout(secureStorage);
            return handler.next(e);
          }
        },
      ),
    );

    _authDio = dio;
    return dio;
  }

  /// Facilitates the file download process, both with auth and without auth.
  /// - If [secureStorage] is provided, automatically uses token (auth).
  /// - [savePath] to determine the location the file will be saved (required).
  static Future<Response> download({
    required String url,
    required String savePath,
    SecureStorage? secureStorage,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    // ⚠️ NOT USING CACHE (authClient / noAuthClient)
    // Because download requires a specific timeout, if we use a cached client,
    // we would modify the timeout for ALL other requests in the application.
    // Therefore, we always create a new Dio instance specifically for download.
    final dio = Dio();

    // Longer timeout specifically for file download process
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(minutes: 5);

    _addCommonInterceptors(dio);

    if (secureStorage != null) {
      // Manually inject token interceptor specifically for this download instance
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await secureStorage.read(
              SecureStorageKey.accessToken,
            );
            _attachAuthHeader(options, token);
            return handler.next(options);
          },
        ),
      );
    }

    return await dio.download(
      url,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Single-flight wrapper for `_refreshToken`.
  ///
  /// If a refresh is in progress (`_refreshCompleter != null`),
  /// subsequent callers will `await` the same Completer and receive
  /// the identical refreshed token — preventing N parallel POST `/auth/refresh`
  /// which could break the single-use refresh-token state on BE.
  static Future<String?> _refreshTokenSingleFlight(
    SecureStorage secureStorage,
  ) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final token = await _refreshToken(secureStorage);
      completer.complete(token);
      return token;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Attempt to refresh token using the stored refresh_token.
  static Future<String?> _refreshToken(SecureStorage secureStorage) async {
    final refreshToken = await secureStorage.read(
      SecureStorageKey.refreshToken,
    );

    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await noAuthClient.post(
        Endpoint.be.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessToken = response.data['data']?['access_token'];
        final newRefreshToken = response.data['data']?['refresh_token'];

        if (newAccessToken != null) {
          await secureStorage.write(
            SecureStorageKey.accessToken,
            newAccessToken,
          );
          // Replace future so the next request reads the new token, not
          // the result of the old future that is still in-flight.
          _accessTokenFuture = Future.value(newAccessToken);
        }
        if (newRefreshToken != null) {
          await secureStorage.write(
            SecureStorageKey.refreshToken,
            newRefreshToken,
          );
        }

        return newAccessToken;
      }
    } catch (e) {
      LoggerHelper.e(
        '[DioClient._refreshToken] Refresh-token request failed',
        e,
      );
      return null;
    }

    return null;
  }

  /// Force logout — clear all tokens and redirect to login.
  /// Single-flight: if a force-logout is already running (e.g. when
  /// N parallel requests all fail to refresh), other callers skip to
  /// prevent multiple `Get.offAllNamed(login)` which can corrupt nav stack.
  static Future<void> _forceLogout(SecureStorage secureStorage) async {
    if (_isForceLoggingOut) return;
    _isForceLoggingOut = true;

    try {
      // Invalidate in-memory token cache.
      _accessTokenFuture = null;

      await secureStorage.deleteAll();
      await GetStorage().erase();
      // Await navigation so the gate only resets after nav is complete —
      // prevents parallel callers from entering and firing duplicate offAllNamed.
      await Get.offAllNamed(Routes.login);
    } finally {
      _isForceLoggingOut = false;
    }
  }
}

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
  /// Single-flight gate untuk refresh-token — memastikan N parallel 401
  /// hanya memicu satu POST `/auth/refresh`, dan semua caller menerima
  /// hasil yang sama. `null` = tidak ada refresh in-flight.
  static Completer<String?>? _refreshCompleter;

  /// Single-flight gate untuk force-logout — mencegah N caller paralel
  /// menjalankan `deleteAll()` + `Get.offAllNamed(login)` bersamaan
  /// saat semua refresh gagal di batch 401.
  static bool _isForceLoggingOut = false;

  /// Cache instance Dio untuk mencegah memory leak dan reuse connection pool.
  static Dio? _noAuthDio;
  static Dio? _authDio;

  /// In-memory access-token future. Menghindari disk I/O SecureStorage
  /// pada setiap request auth. Future diset synchronous oleh caller
  /// pertama (sebelum await) sehingga semua concurrent caller share
  /// hasil yang sama — mencegah thundering herd pada app warm-up.
  /// `null` = belum dihydrate; di-reset saat force-logout.
  static Future<String?>? _accessTokenFuture;

  /// Logger + Chucker (debug-only) — Chucker dibatasi kDebugMode agar
  /// debug UI drawer tidak bocor ke release APK/IPA.
  static void _addCommonInterceptors(Dio dio) {
    dio.interceptors.add(DioWrapper.dioLog);
    if (kDebugMode) dio.interceptors.add(ChuckerDioInterceptor());
  }

  /// Attach `Authorization: Bearer <token>` bila token non-null/non-empty.
  static void _attachAuthHeader(RequestOptions options, String? token) {
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Client tanpa authentication — untuk login, register, dll.
  static Dio get noAuthClient {
    if (_noAuthDio != null) return _noAuthDio!;

    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    _addCommonInterceptors(dio);

    _noAuthDio = dio;
    return dio;
  }

  /// Client dengan authentication — otomatis inject Bearer token
  /// dari [SecureStorage] dan handle refresh token pada 401.
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
          // Hydrate future synchronous sebelum await — concurrent callers
          // share future yang sama, mencegah N duplicate disk reads.
          _accessTokenFuture ??= secureStorage.read(
            SecureStorageKey.accessToken,
          );
          _attachAuthHeader(options, await _accessTokenFuture);
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Hanya tangani 401 — error lain diteruskan apa adanya.
          if (e.response?.statusCode != 401) {
            return handler.next(e);
          }

          // Loop guard: jika ini sudah retry pasca-refresh dan masih 401,
          // token dianggap tidak valid → force logout, jangan refresh lagi.
          if (e.requestOptions.extra['refreshed'] == true) {
            await _forceLogout(secureStorage);
            return handler.next(e);
          }

          try {
            // Single-flight: N parallel 401 akan share satu refresh request.
            final newToken = await _refreshTokenSingleFlight(secureStorage);

            if (newToken == null) {
              await _forceLogout(secureStorage);
              return handler.next(e);
            }

            _attachAuthHeader(e.requestOptions, newToken);
            // Tandai sebagai retry — bila 401 lagi, guard di atas akan force logout.
            e.requestOptions.extra['refreshed'] = true;

            final retryResponse = await noAuthClient.fetch(e.requestOptions);

            // Edge case: retry sukses HTTP-wise tapi status masih 401.
            if (retryResponse.statusCode == 401) {
              await _forceLogout(secureStorage);
              return handler.next(e);
            }

            return handler.resolve(retryResponse);
          } catch (retryError) {
            // Retry fetch sendiri melempar (network down, timeout, dll).
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

  /// Memfasilitasi proses download file, baik dengan auth maupun tanpa auth.
  /// - Jika [secureStorage] diberikan, otomatis menggunakan token (auth).
  /// - [savePath] untuk menentukan lokasi file akan disimpan (wajib).
  static Future<Response> download({
    required String url,
    required String savePath,
    SecureStorage? secureStorage,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    // ⚠️ TIDAK MENGGUNAKAN CACHE (authClient / noAuthClient)
    // Karena download membutuhkan timeout khusus, jika kita menggunakan client dari cache,
    // kita akan memodifikasi timeout untuk SELURUH request lain di aplikasi.
    // Oleh karena itu, kita selalu membuat instance Dio baru khusus untuk download.
    final dio = Dio();

    // Timeout lebih panjang khusus untuk proses download file
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(minutes: 5);

    _addCommonInterceptors(dio);

    if (secureStorage != null) {
      // Inject token interceptor manual khusus untuk instance download ini
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

  /// Single-flight wrapper untuk `_refreshToken`.
  ///
  /// Bila sebuah refresh sedang berjalan (`_refreshCompleter != null`),
  /// caller berikutnya akan `await` Completer yang sama dan menerima
  /// token hasil refresh yang identik — mencegah N POST `/auth/refresh`
  /// paralel yang dapat merusak state refresh-token single-use di BE.
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

  /// Attempt to refresh token menggunakan refresh_token yang tersimpan.
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
          // Ganti future supaya request berikutnya baca token baru, bukan
          // hasil future lama yang masih in-flight.
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

  /// Force logout — hapus semua token dan redirect ke login.
  /// Single-flight: jika sudah ada force-logout yang berjalan (misal saat
  /// N request paralel semua gagal refresh), caller lain skip untuk
  /// mencegah multiple `Get.offAllNamed(login)` yang dapat corrupt nav stack.
  static Future<void> _forceLogout(SecureStorage secureStorage) async {
    if (_isForceLoggingOut) return;
    _isForceLoggingOut = true;

    try {
      // Invalidate in-memory token cache.
      _accessTokenFuture = null;

      await secureStorage.deleteAll();
      await GetStorage().erase();
      // Await navigasi supaya gate hanya reset setelah nav selesai —
      // mencegah caller paralel masuk dan fire offAllNamed duplikat.
      await Get.offAllNamed(Routes.login);
    } finally {
      _isForceLoggingOut = false;
    }
  }
}

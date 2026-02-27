import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import '../platform/secure_storage/flutter_secure_storage_impl.dart';
import '../platform/secure_storage/secure_storage.dart';
import '../navigation/routes.dart';
import '../platform/storage/storage.dart';
import 'dio_wrapper.dart';
import 'url.dart';

class DioClient {
  /// Client tanpa authentication — untuk login, register, dll.
  static Dio get noAuthClient {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    /// Dio Wrapper Logger
    dio.interceptors.add(DioWrapper.dioLog);

    /// Chucker Flutter Logger
    dio.interceptors.add(ChuckerDioInterceptor());

    return dio;
  }

  /// Client dengan authentication — otomatis inject Bearer token
  /// dari [SecureStorage] dan handle refresh token pada 401.
  static Dio authClient(SecureStorage secureStorage) {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    /// Dio Wrapper Logger
    dio.interceptors.add(DioWrapper.dioLog);

    /// Chucker Flutter Logger
    dio.interceptors.add(ChuckerDioInterceptor());

    /// Auth + Refresh Token Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(SecureStorageKey.accessToken);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              final newToken = await _refreshToken(secureStorage);

              if (newToken != null) {
                // Retry original request dengan token baru
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                final retryResponse = await Dio().fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Refresh gagal — force logout
              await _forceLogout(secureStorage);
              return handler.next(e);
            }

            // Token tidak bisa di-refresh — force logout
            await _forceLogout(secureStorage);
          }

          return handler.next(e);
        },
      ),
    );

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
    // Pilih client berdasarkan ada/tidaknya secureStorage
    final dio = secureStorage != null
        ? authClient(secureStorage)
        : noAuthClient;

    // Timeout lebih panjang khusus untuk proses download file
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(minutes: 5);

    return await dio.download(
      url,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Attempt to refresh token menggunakan refresh_token yang tersimpan.
  static Future<String?> _refreshToken(SecureStorage secureStorage) async {
    final refreshToken = await secureStorage.read(
      SecureStorageKey.refreshToken,
    );

    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await Dio().post(
        Endpoint.sso.refresh,
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
        }
        if (newRefreshToken != null) {
          await secureStorage.write(
            SecureStorageKey.refreshToken,
            newRefreshToken,
          );
        }

        return newAccessToken;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  /// Force logout — hapus semua token dan redirect ke login.
  static Future<void> _forceLogout(SecureStorage secureStorage) async {
    await secureStorage.deleteAll();
    await Get.find<Storage>().clear();
    Get.offAllNamed(Routes.login);
  }
}

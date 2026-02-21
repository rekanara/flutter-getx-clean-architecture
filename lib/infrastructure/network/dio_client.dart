import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import '../platform/storage/get_storage_impl.dart';
import 'dio_wrapper.dart';

class DioClient {
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

  static Dio get authClient {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    /// Dio Wrapper Logger
    dio.interceptors.add(DioWrapper.dioLog);

    /// Chucker Flutter Logger
    dio.interceptors.add(ChuckerDioInterceptor());

    /// Auth Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = GetStorageImpl();
          final token = storage.read<String>(StorageValue.accessToken);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // You can also handle token expiry logic here
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}

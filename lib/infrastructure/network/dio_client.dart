import 'package:dio/dio.dart';
import '../platform/storage/get_storage_impl.dart';

class DioClient {
  static Dio get noAuthClient {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  static Dio get authClient {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

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

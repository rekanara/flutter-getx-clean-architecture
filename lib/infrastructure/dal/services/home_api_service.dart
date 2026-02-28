import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class HomeApiService {
  final SecureStorage secureStorage;

  HomeApiService({required this.secureStorage});

  /// Auth client dibuat lazy agar SecureStorage sudah ter-inject
  // Dio get _authClient => DioClient.authClient(secureStorage);

  Dio get _noAuthClient => DioClient.noAuthClient;

  Future<Response> getBanners() async {
    return await _noAuthClient.get(Endpoint.nexadmin.banners);
  }
}

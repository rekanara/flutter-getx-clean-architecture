import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';

class HomeApiService {
  final Dio _authClient = DioClient.authClient;

  // URL configurations
  final URL _url = URL();

  Future<Response> getBanners() async {
    // Requires auth token
    return await _authClient.get(_url.banners.value);
  }
}

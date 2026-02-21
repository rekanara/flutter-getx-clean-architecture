import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';

class AuthApiService {
  final Dio _noAuthClient = DioClient.noAuthClient;
  final Dio _authClient = DioClient.authClient;

  // URL configurations
  final URL _url = URL();

  Future<Response> login(Map<String, dynamic> data) async {
    return await _noAuthClient.post(_url.login.value, data: data);
  }

  Future<Response> getUserProfile() async {
    // Requires auth token
    return await _authClient.get(_url.customerDetail.value);
  }
}

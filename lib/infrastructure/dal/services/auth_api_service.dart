import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class AuthApiService {
  final SecureStorage secureStorage;

  AuthApiService({required this.secureStorage});

  final Dio _noAuthClient = DioClient.noAuthClient;

  /// Auth client dibuat lazy agar SecureStorage sudah ter-inject
  Dio get _authClient => DioClient.authClient(secureStorage);

  Future<Response> login(Map<String, dynamic> data) async {
    return await _noAuthClient.post(Endpoint.sso.login, data: data);
  }

  Future<Response> getUserProfile() async {
    return await _authClient.get(Endpoint.billing.customerDetail);
  }
}

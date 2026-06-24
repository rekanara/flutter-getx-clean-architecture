import '../platform/secure_storage/flutter_secure_storage_impl.dart';

class Routes {
  static Future<String> get initialRoute async {
    final token = await FlutterSecureStorageImpl()
        .read(SecureStorageKey.accessToken);
    return (token != null && token.isNotEmpty) ? home : login;
  }

  static const home = '/home';
  static const login = '/login';
  static const user = '/user';
}

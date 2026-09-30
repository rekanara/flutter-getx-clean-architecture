/// Abstract interface untuk secure/encrypted storage.
///
/// Digunakan khusus untuk menyimpan data sensitif seperti
/// access token, refresh token, dan credentials lainnya.
///
/// Implementasi default menggunakan FlutterSecureStorage
/// yang memanfaatkan Keychain (iOS) dan EncryptedSharedPreferences (Android).
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

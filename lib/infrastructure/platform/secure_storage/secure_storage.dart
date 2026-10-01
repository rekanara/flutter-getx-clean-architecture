/// Abstract interface for secure/encrypted storage.
///
/// Used specifically for storing sensitive data such as
/// access tokens, refresh tokens, and other credentials.
///
/// Default implementation uses FlutterSecureStorage
/// which utilizes Keychain (iOS) and EncryptedSharedPreferences (Android).
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

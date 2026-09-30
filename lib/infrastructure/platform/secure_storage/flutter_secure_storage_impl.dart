import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage.dart';

/// Implementasi [SecureStorage] menggunakan FlutterSecureStorage.
///
/// Data disimpan di:
/// - **iOS**: Keychain (accessibleWhenUnlockedThisDeviceOnly — tidak ikut
///   iCloud backup, tidak accessible saat device locked, tidak ikut sync
///   ke device lain. Cocok untuk token autentikasi.)
/// - **Android**: EncryptedSharedPreferences (AES)
class FlutterSecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

/// Keys untuk data sensitif yang disimpan di SecureStorage.
class SecureStorageKey {
  static const String accessToken = 'secure_access_token';
  static const String refreshToken = 'secure_refresh_token';
  static const String permissionToken = 'secure_permission_token';

  /// mqtt
  static const String mqttTopic = 'secure_mqtt_topic';
}

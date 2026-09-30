# Skill: SecureStorage (Sensitive Data)

SecureStorage menggunakan enkripsi AES (Android) dan Keychain (iOS) untuk menyimpan data sensitif.

---

## Kapan Menggunakan SecureStorage

| WAJIB di SecureStorage | JANGAN di SecureStorage |
|---|---|
| Access token | Theme preference |
| Refresh token | App version |
| Permission token | Environment selection |
| Password tersimpan | Pengaturan non-sensitif |
| API key | Cache data biasa |
| Private key | |
| MQTT topic subscriptions | |

---

## SecureStorageKey Constants

```dart
// lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart
class SecureStorageKey {
  static const accessToken = 'secure_access_token';
  static const refreshToken = 'secure_refresh_token';
  static const permissionToken = 'secure_permission_token';
  static const mqttTopic = 'secure_mqtt_topic';  // JSON-encoded list of topics
}
```

**Penting:** Selalu tambahkan key baru sebagai constant di `SecureStorageKey`.

---

## SecureStorage Interface

```dart
// lib/infrastructure/platform/secure_storage/secure_storage.dart
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}
```

**Note:** Semua method adalah `async` (berbeda dari GetStorage yang sync).

---

## Cara Pakai di Repository

```dart
// Inject via binding
class AuthRepositoryImpl implements AuthRepository {
  final SecureStorage secureStorage;
  final AuthApiService apiService;

  AuthRepositoryImpl({
    required this.apiService,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final response = await apiService.login({'key': email, 'password': password});
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data']);

        // Simpan token ke SecureStorage setelah login berhasil
        await secureStorage.write(SecureStorageKey.accessToken, user.accessToken);
        await secureStorage.write(SecureStorageKey.refreshToken, user.refreshToken);
        await secureStorage.write(SecureStorageKey.permissionToken, user.permissionToken);

        return Right(user);
      }
      return Left(ServerFailure(response.data['message'] ?? 'Login failed'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network Error'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Hapus semua token
      await secureStorage.deleteAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Logout failed'));
    }
  }
}
```

---

## Cara Pakai di DioClient (auto-inject token)

`DioClient.authClient(secureStorage)` sudah otomatis membaca token dari SecureStorage dan meng-inject ke header:

```dart
// Tidak perlu manual — authClient sudah handle ini
Dio get _authClient => DioClient.authClient(secureStorage);

// Cara kerja internal di DioClient:
// request.headers['Authorization'] = 'Bearer ${await secureStorage.read(SecureStorageKey.accessToken)}';
```

---

## Cara Pakai Langsung (rare case)

```dart
// Di dalam method async
final token = await secureStorage.read(SecureStorageKey.accessToken);
if (token == null) {
  // user belum login
  Get.offAllNamed(Routes.login);
  return;
}

// Simpan data
await secureStorage.write(SecureStorageKey.accessToken, newToken);

// Hapus satu key
await secureStorage.delete(SecureStorageKey.accessToken);

// Hapus semua (logout)
await secureStorage.deleteAll();
```

---

## Tambah Key Baru

1. Buka `lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart`
2. Tambah constant di `SecureStorageKey`:
```dart
class SecureStorageKey {
  // ... existing keys
  static const biometricKey = 'secure_biometric_key'; // ← tambahkan
}
```

---

## FlutterSecureStorageImpl Detail

```dart
// Konfigurasi enkripsi platform-specific:
// Android: AES CBC, menggunakan AndroidOptions(encryptedSharedPreferences: true)
// iOS: Keychain dengan accessibility IOSAccessibility.first_unlock
```

---

## Checklist

```
[ ] Data sensitif → SecureStorage (BUKAN GetStorage)
[ ] Key baru sebagai constant di SecureStorageKey
[ ] Semua method async (await)
[ ] Token disimpan setelah login berhasil di RepositoryImpl
[ ] Token dihapus di deleteAll() saat logout
[ ] Inject FlutterSecureStorageImpl via binding
[ ] Tidak hard-code string key di luar SecureStorageKey class
```

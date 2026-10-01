---
name: SecureStorage (Sensitive Data)
description: AES/Keychain encryption for sensitive data
---
# Skill: SecureStorage (Sensitive Data)

SecureStorage uses AES encryption (Android) and Keychain (iOS) to store sensitive data.

---

## When to Use SecureStorage

| MUST be in SecureStorage | DO NOT store in SecureStorage |
|---|---|
| Access token | Theme preference |
| Refresh token | App version |
| Permission token | Environment selection |
| Saved passwords | Non-sensitive settings |
| API keys | Regular cached data |
| Private keys | |
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

**Important:** Always add new keys as constants in `SecureStorageKey`.

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

**Note:** All methods are `async` (unlike GetStorage which is sync).

---

## Usage in Repository

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

        // Save tokens to SecureStorage after successful login
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
      // Delete all tokens
      await secureStorage.deleteAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Logout failed'));
    }
  }
}
```

---

## Usage in DioClient (auto-inject token)

`DioClient.authClient(secureStorage)` automatically reads the token from SecureStorage and injects it into the header:

```dart
// No need to manually inject — authClient handles this
Dio get _authClient => DioClient.authClient(secureStorage);

// Internal workings of DioClient:
// request.headers['Authorization'] = 'Bearer ${await secureStorage.read(SecureStorageKey.accessToken)}';
```

---

## Direct Usage (rare case)

```dart
// Inside an async method
final token = await secureStorage.read(SecureStorageKey.accessToken);
if (token == null) {
  // user is not logged in
  Get.offAllNamed(Routes.login);
  return;
}

// Save data
await secureStorage.write(SecureStorageKey.accessToken, newToken);

// Delete one key
await secureStorage.delete(SecureStorageKey.accessToken);

// Delete all (logout)
await secureStorage.deleteAll();
```

---

## Adding a New Key

1. Open `lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart`
2. Add a constant in `SecureStorageKey`:
```dart
class SecureStorageKey {
  // ... existing keys
  static const biometricKey = 'secure_biometric_key'; // ← add
}
```

---

## FlutterSecureStorageImpl Details

```dart
// Platform-specific encryption configuration:
// Android: AES CBC, uses AndroidOptions(encryptedSharedPreferences: true)
// iOS: Keychain with IOSAccessibility.first_unlock
```

---

## Checklist

```
[ ] Sensitive data → SecureStorage (NOT GetStorage)
[ ] New keys as constants in SecureStorageKey
[ ] All methods are async (await)
[ ] Tokens are saved after successful login in RepositoryImpl
[ ] Tokens are deleted in deleteAll() during logout
[ ] Inject FlutterSecureStorageImpl via binding
[ ] Do not hard-code string keys outside the SecureStorageKey class
```

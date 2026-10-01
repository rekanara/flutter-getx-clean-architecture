---
name: GetStorage (Non-Sensitive Data)
description: Persistent non-sensitive data storage (key-value)
---
# Skill: GetStorage (Non-Sensitive Data)

GetStorage is used to save non-sensitive data that needs to persist between sessions. Implementation is in `GetStorageImpl`.

---

## When to Use GetStorage

| Save in GetStorage | DO NOT save in GetStorage |
|---|---|
| Theme preference (light/dark) | Access token |
| Environment selection (dev/staging/prod) | Refresh token |
| App version / build number | Passwords |
| User preferences (language, notif toggles) | API keys |
| Last seen timestamp | Permission tokens |
| Non-sensitive caches | Any sensitive data |

For sensitive data → use `SecureStorage`.

---

## StorageValue Keys

```dart
// lib/infrastructure/platform/storage/get_storage_impl.dart
class StorageValue {
  static const appVersion = 'appVersion';
  static const appBuildNumber = 'appBuildNumber';
  static const env = 'env';              // Environment preference
  static const themeIsLight = 'themeIsLight';
  static const accessToken = 'accessToken'; // non-sensitive copy (for display only)
}
```

**Important:** Always add new keys as constants in `StorageValue`. Do not hardcode strings outside this file.

---

## Storage Interface

```dart
// lib/infrastructure/platform/storage/storage.dart
// write/delete/clear are all Future<void> (async) — read remains sync
abstract class Storage {
  Future<void> write(String key, dynamic value);
  T? read<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
}
```

---

## Usage in Repository / Service

```dart
// Inject via binding
class SomeRepositoryImpl implements SomeRepository {
  final Storage storage;

  SomeRepositoryImpl({required this.storage});

  Future<void> saveThemePreference(bool isLight) async {
    await storage.write(StorageValue.themeIsLight, isLight);
  }

  bool getThemePreference() {
    return storage.read<bool>(StorageValue.themeIsLight) ?? true;
  }

  Future<void> saveAppVersion(String version) async {
    await storage.write(StorageValue.appVersion, version);
  }

  String? getAppVersion() {
    return storage.read<String>(StorageValue.appVersion);
  }

  Future<void> clearAll() async {
    await storage.clear();
  }
}
```

---

## Usage in Binding

```dart
// Inject GetStorageImpl as Storage
Get.lazyPut<GetStorageImpl>(() => GetStorageImpl());

// When injecting into a repository, use the abstract Storage type
Get.lazyPut<AuthRepository>(
  () => AuthRepositoryImpl(
    apiService: Get.find(),
    storage: Get.find<GetStorageImpl>(), // or Get.find() if types are sufficient
  ),
);
```

---

## Direct Usage (without inject)

```dart
// GetStorage initialization is already done in main.dart (await GetStorage.init())
// Can be accessed directly from anywhere:
final box = GetStorage();
box.write('myKey', 'myValue');
final value = box.read<String>('myKey');
box.remove('myKey');
box.erase(); // clear all
```

---

## Type Support

```dart
// String
storage.write(StorageValue.appVersion, '1.0.0');
final version = storage.read<String>(StorageValue.appVersion); // String?

// Bool
storage.write(StorageValue.themeIsLight, true);
final isLight = storage.read<bool>(StorageValue.themeIsLight) ?? true; // bool

// Int
storage.write('counter', 42);
final count = storage.read<int>('counter') ?? 0;

// Double
storage.write('score', 99.5);
final score = storage.read<double>('score') ?? 0.0;

// Map (JSON-compatible)
storage.write('user', {'name': 'Alice', 'age': 30});
final user = storage.read<Map>('user');

// List
storage.write('tags', ['flutter', 'dart']);
final tags = storage.read<List>('tags') ?? [];
```

---

## Adding a New Key

1. Open `lib/infrastructure/platform/storage/get_storage_impl.dart`
2. Add a constant in `StorageValue`:
```dart
class StorageValue {
  // ... existing keys
  static const lastSyncTime = 'lastSyncTime'; // ← add
}
```

---

## Checklist

```
[ ] Non-sensitive data → GetStorage
[ ] New keys always as constants in StorageValue
[ ] Inject GetStorageImpl via binding (not direct access from controllers)
[ ] read<T>() always has a default value: ?? true / ?? '' / ?? []
[ ] Do not store tokens/passwords in GetStorage
```

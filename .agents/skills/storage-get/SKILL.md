# Skill: GetStorage (Non-Sensitive Data)

GetStorage digunakan untuk menyimpan data non-sensitif yang perlu persisten antar sesi. Implementasi ada di `GetStorageImpl`.

---

## Kapan Menggunakan GetStorage

| Simpan di GetStorage | JANGAN simpan di GetStorage |
|---|---|
| Theme preference (light/dark) | Access token |
| Environment selection (dev/staging/prod) | Refresh token |
| App version / build number | Password |
| User preferences (bahasa, notif toggle) | API key |
| Last seen timestamp | Permission token |
| Non-sensitive cache | Data sensitif apapun |

Untuk data sensitif → gunakan `SecureStorage`.

---

## StorageValue Keys

```dart
// lib/infrastructure/platform/storage/get_storage_impl.dart
class StorageValue {
  static const appVersion = 'appVersion';
  static const appBuildNumber = 'appBuildNumber';
  static const env = 'env';              // Environment preference
  static const themeIsLight = 'themeIsLight';
  static const accessToken = 'accessToken'; // non-sensitive copy (untuk display saja)
}
```

**Penting:** Selalu tambahkan key baru sebagai constant di `StorageValue`. Jangan hardcode string di luar file ini.

---

## Storage Interface

```dart
// lib/infrastructure/platform/storage/storage.dart
abstract class Storage {
  void write(String key, dynamic value);
  T? read<T>(String key);
  void delete(String key);
  void clear();
}
```

---

## Cara Pakai di Repository / Service

```dart
// Inject via binding
class SomeRepositoryImpl implements SomeRepository {
  final Storage storage;

  SomeRepositoryImpl({required this.storage});

  void saveThemePreference(bool isLight) {
    storage.write(StorageValue.themeIsLight, isLight);
  }

  bool getThemePreference() {
    return storage.read<bool>(StorageValue.themeIsLight) ?? true;
  }

  void saveAppVersion(String version) {
    storage.write(StorageValue.appVersion, version);
  }

  String? getAppVersion() {
    return storage.read<String>(StorageValue.appVersion);
  }

  void clearAll() {
    storage.clear();
  }
}
```

---

## Cara Pakai di Binding

```dart
// Inject GetStorageImpl sebagai Storage
Get.lazyPut<GetStorageImpl>(() => GetStorageImpl());

// Saat inject ke repository, gunakan tipe abstract Storage
Get.lazyPut<AuthRepository>(
  () => AuthRepositoryImpl(
    apiService: Get.find(),
    storage: Get.find<GetStorageImpl>(), // atau Get.find() jika tipenya sudah cukup
  ),
);
```

---

## Cara Pakai Langsung (tanpa inject)

```dart
// Inisialisasi GetStorage sudah dilakukan di main.dart (await GetStorage.init())
// Bisa akses langsung dari manapun:
final box = GetStorage();
box.write('myKey', 'myValue');
final value = box.read<String>('myKey');
box.remove('myKey');
box.erase(); // hapus semua
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

## Tambah Key Baru

1. Buka `lib/infrastructure/platform/storage/get_storage_impl.dart`
2. Tambah constant di `StorageValue`:
```dart
class StorageValue {
  // ... existing keys
  static const lastSyncTime = 'lastSyncTime'; // ← tambahkan
}
```

---

## Checklist

```
[ ] Data non-sensitif → GetStorage
[ ] Key baru selalu sebagai constant di StorageValue
[ ] Inject GetStorageImpl via binding (bukan akses langsung dari controller)
[ ] read<T>() selalu diberi default value: ?? true / ?? '' / ?? []
[ ] Jangan simpan token/password di GetStorage
```

# Environment & URL System

Panduan lengkap alur konfigurasi domain: dari `.env` → `environments.dart` → `url.dart` → penggunaan di CRUD.

---

## Arsitektur

```
.env                          ← Source of truth (domain URLs per env)
  │
  ▼
environments.dart             ← Membaca .env → EnvironmentConfig (typed)
  │
  ▼
url.dart                      ← Domain builder + Endpoint registry
  ├── Domain.sso              ← Base URL lengkap
  └── Endpoint.sso.login      ← Full endpoint URL
        │
        ▼
api_service.dart              ← Dio call pakai Endpoint
  │
  ▼
repository_impl.dart → usecase.dart → controller.dart → UI
```

---

## Step 1: Tambahkan Domain di `.env`

File `.env` menyimpan semua URL per environment (dev/staging/prod):

```env
# ── Service Baru: Inventory ──
NEX_INVENTORY_DEV=https://inventory-dev.example.com
NEX_INVENTORY_STAGING=https://inventory-staging.example.com
NEX_INVENTORY_PROD=https://inventory.example.com
```

> **Naming convention:** `{PREFIX}_{SERVICE}_{ENV}` — e.g. `NEX_INVENTORY_DEV`

---

## Step 2: Tambahkan Field di `EnvironmentConfig`

`lib/infrastructure/network/environments.dart`

### 2a. Tambah property di class:

```dart
class EnvironmentConfig {
  // ... existing fields ...
  
  final String inventory; // ← TAMBAH

  const EnvironmentConfig({
    // ... existing params ...
    required this.inventory, // ← TAMBAH
  });
}
```

### 2b. Isi value dari `.env` di setiap environment config:

```dart
static final List<EnvironmentConfig> _configs = [
  // ── DEV ──
  EnvironmentConfig(
    // ... existing ...
    inventory: dotenv.env['NEX_INVENTORY_DEV']!,  // ← TAMBAH
  ),

  // ── STAGING ──
  EnvironmentConfig(
    // ... existing ...
    inventory: dotenv.env['NEX_INVENTORY_STAGING']!,  // ← TAMBAH
  ),

  // ── PRODUCTION ──
  EnvironmentConfig(
    // ... existing ...
    inventory: dotenv.env['NEX_INVENTORY_PROD']!,  // ← TAMBAH
  ),
];
```

---

## Step 3: Buat Domain Builder & Endpoint di `url.dart`

`lib/infrastructure/network/url.dart`

### 3a. Tambah Domain getter:

```dart
class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  // ... existing domains ...

  // ── Inventory ── (TAMBAH)
  static String get inventory =>
      '${_cfg.inventory}${PathSegment.api}${PathSegment.v1}';
}
```

### 3b. Tambah Endpoint class:

```dart
class Endpoint {
  // ... existing ...
  static final inventory = _InventoryEndpoints();  // ← TAMBAH
}

// ── TAMBAH class endpoint ──
class _InventoryEndpoints {
  String get list       => '${Domain.inventory}/items';
  String get detail     => '${Domain.inventory}/items';     // + /{id}
  String get create     => '${Domain.inventory}/items';
  String get update     => '${Domain.inventory}/items';     // + /{id}
  String get delete     => '${Domain.inventory}/items';     // + /{id}
  String get categories => '${Domain.inventory}/categories';
}
```

---

## Step 4: Buat API Service

`lib/infrastructure/dal/services/inventory_api_service.dart`

```dart
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class InventoryApiService {
  final SecureStorage secureStorage;

  InventoryApiService({required this.secureStorage});

  Dio get _authClient => DioClient.authClient(secureStorage);

  // ── READ (List) ──
  Future<Response> getItems({Map<String, dynamic>? query}) async {
    return await _authClient.get(
      Endpoint.inventory.list,
      queryParameters: query,
    );
  }

  // ── READ (Detail) ──
  Future<Response> getItemById(String id) async {
    return await _authClient.get('${Endpoint.inventory.detail}/$id');
  }

  // ── CREATE ──
  Future<Response> createItem(Map<String, dynamic> data) async {
    return await _authClient.post(Endpoint.inventory.create, data: data);
  }

  // ── UPDATE ──
  Future<Response> updateItem(String id, Map<String, dynamic> data) async {
    return await _authClient.put('${Endpoint.inventory.update}/$id', data: data);
  }

  // ── DELETE ──
  Future<Response> deleteItem(String id) async {
    return await _authClient.delete('${Endpoint.inventory.delete}/$id');
  }
}
```

### Auth vs No-Auth

| Client | Cara Pakai | Kapan |
|---|---|---|
| `DioClient.noAuthClient` | `final client = DioClient.noAuthClient;` | Endpoint publik (login, banner) |
| `DioClient.authClient(secureStorage)` | `Dio get _authClient => DioClient.authClient(secureStorage);` | Endpoint yang butuh token (CRUD) |

> `authClient` otomatis inject Bearer token dan handle 401 → refresh token.

---

## Step 5: Gunakan di Repository → UseCase → Controller

Untuk alur lengkap Clean Architecture setelah API Service dibuat, ikuti pola yang sama seperti module `Home`:

```
Entity → Repository (abstract) → UseCase
                    ↓
            RepositoryImpl (implements Repository, pakai ApiService)
                    ↓
            Binding (inject dependencies)
                    ↓
            Controller (panggil UseCase via callUseCase)
```

---

## Contoh Alur Lengkap yang Sudah Ada

| Layer | File | Contoh |
|---|---|---|
| `.env` | `.env` | `NEX_ADMIN_DEV=https://...` |
| Config | `environments.dart` | `nexadmin: dotenv.env['NEX_ADMIN_DEV']!` |
| Domain | `url.dart` | `Domain.nexadmin` → base URL |
| Endpoint | `url.dart` | `Endpoint.nexadmin.banners` → full URL |
| API Service | `home_api_service.dart` | `_noAuthClient.get(Endpoint.nexadmin.banners)` |
| Repository | `home_repository_impl.dart` | Parse response → `BannerEntity` |
| UseCase | `get_banners_usecase.dart` | `repository.getBanners()` |
| Controller | `home.controller.dart` | `callUseCase(useCase.execute(...))` |

---

## Switch Environment (Runtime)

Environment bisa diganti saat runtime tanpa restart:

```dart
final envCtrl = Get.find<EnvironmentController>();
envCtrl.switchEnvironment(Environment.staging);
```

State disimpan di `GetStorage` — env yang dipilih persist setelah restart app.

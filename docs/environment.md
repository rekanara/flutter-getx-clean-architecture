# Environment & URL System

Complete guide for the domain configuration flow: from `.env` → `environments.dart` → `url.dart` → usage in CRUD.

---

## Architecture

```
.env                          ← Source of truth (domain URLs per env)
  │
  ▼
environments.dart             ← Reads .env → EnvironmentConfig (typed)
  │
  ▼
url.dart                      ← Domain builder + Endpoint registry
  ├── Domain.be               ← Full base URL (current main backend)
  └── Endpoint.be.login       ← Full endpoint URL
        │
        ▼
api_service.dart              ← Dio call using Endpoint
  │
  ▼
repository_impl.dart → usecase.dart → controller.dart → UI
```

---

## Step 1: Add Domain in `.env`

The `.env` file stores all URLs per environment (dev/staging/prod):

```env
# ── New Service: Inventory ──
NEX_INVENTORY_DEV=https://inventory-dev.example.com
NEX_INVENTORY_STAGING=https://inventory-staging.example.com
NEX_INVENTORY_PROD=https://inventory.example.com
```

> **Naming convention:** `{PREFIX}_{SERVICE}_{ENV}` — e.g. `NEX_INVENTORY_DEV`

---

## Step 2: Add Field in `EnvironmentConfig`

`lib/infrastructure/network/environments.dart`

### 2a. Add property to the class:

```dart
class EnvironmentConfig {
  // ... existing fields ...
  
  final String inventory; // ← ADD

  const EnvironmentConfig({
    // ... existing params ...
    required this.inventory, // ← ADD
  });
}
```

### 2b. Assign value from `.env` in each environment config:

```dart
static final List<EnvironmentConfig> _configs = [
  // ── DEV ──
  EnvironmentConfig(
    // ... existing ...
    inventory: dotenv.env['NEX_INVENTORY_DEV']!,  // ← ADD
  ),

  // ── STAGING ──
  EnvironmentConfig(
    // ... existing ...
    inventory: dotenv.env['NEX_INVENTORY_STAGING']!,  // ← ADD
  ),

  // ── PRODUCTION ──
  EnvironmentConfig(
    // ... existing ...
    inventory: dotenv.env['NEX_INVENTORY_PROD']!,  // ← ADD
  ),
];
```

---

## Step 3: Create Domain Builder & Endpoint in `url.dart`

`lib/infrastructure/network/url.dart`

### 3a. Add Domain getter:

```dart
class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  // ... existing domains ...

  // ── Inventory ── (ADD)
  static String get inventory =>
      '${_cfg.inventory}${PathSegment.api}${PathSegment.v1}';
}
```

### 3b. Add Endpoint class:

```dart
class Endpoint {
  // ... existing ...
  static final inventory = _InventoryEndpoints();  // ← ADD
}

// ── ADD endpoint class ──
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

## Step 4: Create API Service

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

| Client | Usage | When |
|---|---|---|
| `DioClient.noAuthClient` | `final client = DioClient.noAuthClient;` | Public endpoints (login, banner) |
| `DioClient.authClient(secureStorage)` | `Dio get _authClient => DioClient.authClient(secureStorage);` | Endpoints requiring a token (CRUD) |

> `authClient` automatically injects the Bearer token and handles 401 → refresh token.

---

## Step 5: Use in Repository → UseCase → Controller

For the complete Clean Architecture flow after creating the API Service, follow the same pattern as the `Home` module:

```
Entity → Repository (abstract) → UseCase
                    ↓
            RepositoryImpl (implements Repository, uses ApiService)
                    ↓
            Binding (inject dependencies)
                    ↓
            Controller (calls UseCase via callUseCase)
```

---

## Complete Flow Example (Existing)

| Layer | File | Example |
|---|---|---|
| `.env` | `.env` | `NEX_BE_DEV=https://...` |
| Config | `environments.dart` | `be: dotenv.env['NEX_BE_DEV']!` |
| Domain | `url.dart` | `Domain.be` → base URL |
| Endpoint | `url.dart` | `Endpoint.be.banners` → full URL |
| API Service | `home_api_service.dart` | `_noAuthClient.get(Endpoint.be.banners)` |
| Repository | `home_repository_impl.dart` | Parse response → `BannerEntity` |
| UseCase | `get_banners_usecase.dart` | `repository.getBanners()` |
| Controller | `home.controller.dart` | `callUseCase(useCase.execute(...))` |

---

## Switch Environment (Runtime)

The environment can be changed at runtime without restarting:

```dart
final envCtrl = Get.find<EnvironmentController>();
envCtrl.switchEnvironment(Environment.staging);
```

The state is saved in `GetStorage` — the selected env persists after an app restart.

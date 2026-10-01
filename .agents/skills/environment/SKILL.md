---
name: Environment & URL
description: Multi-environment setup (dev/staging/prod), domain, and endpoint configurations
---
# Skill: Environment & URL Configuration

Guide to multi-environment (dev/staging/prod) configurations, how to add a new domain service, and how to define endpoints.

---

## Environment Architecture

```
.env
  ↓ read by flutter_dotenv in main.dart
EnvironmentConfig (strongly-typed class)
  ↓ saved in GetStorage (key: 'env')
ConfigEnvironments.current  ←  EnvironmentController
  ↓
ConfigEnvironments.config  (active EnvironmentConfig)
  ↓
Domain.{service}   (base URL per service)
  ↓
Endpoint.{service}.{action}  (full path)
```

---

## Current Structure (Real)

Currently, there is only **one backend service**: `be` (read from `NEX_BE_DEV`/`NEX_BE_STAGING`/`NEX_BE_PROD` in `.env`), accessed via `Domain.be` and `Endpoint.be.{login,refresh,banners,customerDetail}`. The examples below ("SSO", "Nexadmin", "Product") are patterns for **adding a new service** — not what is currently in the code.

## File: .env (example of adding a new "Product" service)

```env
# New service (illustration — adjust the prefix to your convention)
PRODUCT_DEV=https://product-dev.example.com
PRODUCT_STAGING=https://product-staging.example.com
PRODUCT_PROD=https://product.example.com
```

See `.env.example` for the complete list of keys actually used (JWT, NEX_BE/FE, CDN, FIREBASE_*, MQTT_*, URL_APPCAST_*).

---

## File: environments.dart

### Step 1: Add a field in EnvironmentConfig

```dart
// lib/infrastructure/network/environments.dart
class EnvironmentConfig {
  final String be; // ← already exists (main backend)
  final String product; // ← ADD THIS

  const EnvironmentConfig({
    required this.be,
    required this.product, // ← ADD THIS
    // ... other fields (mqtt, firebase, etc. — already exist)
  });
}
```

### Step 2: Fill in the values per environment

`ConfigEnvironments` in the actual code stores the configs as a `List<EnvironmentConfig> _configs` (not separate `_devConfig`/`_stagingConfig`/`_prodConfig` getters) — add the `product` field to each existing `EnvironmentConfig(...)` entry for `Environment.dev`, `.staging`, and `.prod`:

```dart
static final List<EnvironmentConfig> _configs = [
  EnvironmentConfig(
    env: Environment.dev,
    be: dotenv.env['NEX_BE_DEV']!,
    product: dotenv.env['PRODUCT_DEV']!, // ← ADD THIS
    // ... other existing fields
  ),
  EnvironmentConfig(
    env: Environment.staging,
    be: dotenv.env['NEX_BE_STAGING']!,
    product: dotenv.env['PRODUCT_STAGING']!, // ← ADD THIS
    // ...
  ),
  EnvironmentConfig(
    env: Environment.prod,
    be: dotenv.env['NEX_BE_PROD']!,
    product: dotenv.env['PRODUCT_PROD']!, // ← ADD THIS
    // ...
  ),
];

// current + config getters — already exist, no changes needed
static EnvironmentConfig get config =>
    _configs.firstWhere((c) => c.env == current);
```

---

## File: url.dart

### Step 3: Add Domain getter

```dart
// lib/infrastructure/network/url.dart — PathSegment/Domain/Endpoint already exist,
// this is an example of ADDING a new getter to the existing class
class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  static String get be => '${_cfg.be}${PathSegment.api}${PathSegment.v1}'; // ← already exists
  static String get product => '${_cfg.product}${PathSegment.api}${PathSegment.v1}'; // ← ADD THIS
}
```

### Step 4: Add Endpoint class

```dart
class Endpoint {
  Endpoint._();
  static final be = _BeEndpoints(); // ← already exists
  static final product = _ProductEndpoints(); // ← ADD THIS
}

// ← ADD this class
class _ProductEndpoints {
  String get list   => '${Domain.product}/products';
  String get detail => '${Domain.product}/products'; // + /$id in the service
  String get create => '${Domain.product}/products';
  String get update => '${Domain.product}/products'; // + /$id in the service
  String get delete => '${Domain.product}/products'; // + /$id in the service
}

// Currently existing in the code:
class _BeEndpoints {
  String get login          => '${Domain.be}/auth/login';
  String get refresh        => '${Domain.be}/auth/refresh';
  String get banners        => '${Domain.be}/banners/active';
  String get customerDetail => '${Domain.be}/customer-details/me';
}
```

---

## Using Endpoints

```dart
// In ApiService — use Endpoint.{service}.{action}
final response = await _client.get(Endpoint.product.list);
final response = await _client.get('${Endpoint.product.detail}/$id');
final response = await _client.post(Endpoint.product.create, data: data);
```

---

## Switch Environment (for dev)

```dart
// In a controller or settings screen
final envController = Get.find<EnvironmentController>();

// Switch to staging
envController.switchEnvironment(Environment.staging);

// Switch to prod
envController.switchEnvironment(Environment.prod);
```

**Note:** there is only one method — `switchEnvironment()`. There is no `setEnvironment()`.

The environment is stored in `GetStorage` (key `StorageValue.env`), persisting across restarts.

---

## EnvironmentsBadge

The "DEV" / "STAGING" badge appears automatically on all screens via the `EnvironmentsBadge` widget wrapping each `GetPage` in `navigation.dart`. The badge does not appear in production.

---

## Checklist

```
[ ] .env: add keys for each environment (DEV, STAGING, PROD)
[ ] environments.dart: add a field in EnvironmentConfig
[ ] environments.dart: fill in values for _devConfig, _stagingConfig, _prodConfig
[ ] url.dart: add getter in Domain class
[ ] url.dart: add _FeatureEndpoints class and register it in Endpoint
[ ] Endpoint used in ApiService (do not hardcode URLs)
```

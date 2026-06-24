# Skill: Environment & URL Configuration

Panduan multi-environment (dev/staging/prod), cara tambah service domain baru, dan cara define endpoint.

---

## Arsitektur Environment

```
.env
  ↓ dibaca oleh flutter_dotenv di main.dart
EnvironmentConfig (strongly-typed class)
  ↓ disimpan di GetStorage (key: 'env')
ConfigEnvironments.current  ←  EnvironmentController
  ↓
ConfigEnvironments.config  (EnvironmentConfig aktif)
  ↓
Domain.{service}   (base URL per service)
  ↓
Endpoint.{service}.{action}  (full path)
```

---

## File: .env

```env
# SSO Service
SSO_DEV=https://sso-dev.example.com
SSO_STAGING=https://sso-staging.example.com
SSO_PROD=https://sso.example.com

# Nexadmin Service
NEXADMIN_DEV=https://nexadmin-dev.example.com
NEXADMIN_STAGING=https://nexadmin-staging.example.com
NEXADMIN_PROD=https://nexadmin.example.com

# === Tambah service baru ===
PRODUCT_DEV=https://product-dev.example.com
PRODUCT_STAGING=https://product-staging.example.com
PRODUCT_PROD=https://product.example.com

# MQTT
MQTT_BROKER_DEV=mqtt-dev.example.com
MQTT_BROKER_STAGING=mqtt-staging.example.com
MQTT_BROKER_PROD=mqtt.example.com
MQTT_PORT=1883
MQTT_USERNAME=user
MQTT_PASSWORD=pass

# Firebase (per env jika berbeda)
FIREBASE_API_KEY_DEV=...
FIREBASE_PROJECT_ID_DEV=...
```

---

## File: environments.dart

### Step 1: Tambah field di EnvironmentConfig

```dart
// lib/infrastructure/network/environments.dart
class EnvironmentConfig {
  final String sso;
  final String nexadmin;
  final String product; // ← TAMBAHKAN
  // ... field lain (mqtt, firebase, dll)

  const EnvironmentConfig({
    required this.sso,
    required this.nexadmin,
    required this.product, // ← TAMBAHKAN
    // ...
  });
}
```

### Step 2: Isi nilai per environment

```dart
class ConfigEnvironments {
  static EnvironmentConfig get _devConfig => EnvironmentConfig(
    sso: dotenv.env['SSO_DEV']!,
    nexadmin: dotenv.env['NEXADMIN_DEV']!,
    product: dotenv.env['PRODUCT_DEV']!, // ← TAMBAHKAN
  );

  static EnvironmentConfig get _stagingConfig => EnvironmentConfig(
    sso: dotenv.env['SSO_STAGING']!,
    nexadmin: dotenv.env['NEXADMIN_STAGING']!,
    product: dotenv.env['PRODUCT_STAGING']!, // ← TAMBAHKAN
  );

  static EnvironmentConfig get _prodConfig => EnvironmentConfig(
    sso: dotenv.env['SSO_PROD']!,
    nexadmin: dotenv.env['NEXADMIN_PROD']!,
    product: dotenv.env['PRODUCT_PROD']!, // ← TAMBAHKAN
  );

  // getter current + config — sudah ada, tidak perlu diubah
  static EnvironmentConfig get config {
    switch (current) {
      case Environment.dev: return _devConfig;
      case Environment.staging: return _stagingConfig;
      case Environment.prod: return _prodConfig;
    }
  }
}
```

---

## File: url.dart

### Step 3: Tambah Domain getter

```dart
// lib/infrastructure/network/url.dart
class PathSegment {
  static const api = '/api';
  static const v1 = '/v1';
}

class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  static String get sso => '${_cfg.sso}${PathSegment.api}${PathSegment.v1}';
  static String get nexadmin => '${_cfg.nexadmin}${PathSegment.api}${PathSegment.v1}';
  static String get product => '${_cfg.product}${PathSegment.api}${PathSegment.v1}'; // ← TAMBAHKAN
}
```

### Step 4: Tambah Endpoint class

```dart
class Endpoint {
  static final sso = _SsoEndpoints();
  static final nexadmin = _NexadminEndpoints();
  static final product = _ProductEndpoints(); // ← TAMBAHKAN
}

// ← TAMBAHKAN class ini
class _ProductEndpoints {
  String get list   => '${Domain.product}/products';
  String get detail => '${Domain.product}/products'; // + /$id di service
  String get create => '${Domain.product}/products';
  String get update => '${Domain.product}/products'; // + /$id di service
  String get delete => '${Domain.product}/products'; // + /$id di service
}

// Contoh existing:
class _SsoEndpoints {
  String get login   => '${Domain.sso}/auth/login';
  String get refresh => '${Domain.sso}/auth/refresh';
  String get profile => '${Domain.sso}/user/profile';
}

class _NexadminEndpoints {
  String get banners => '${Domain.nexadmin}/banners';
}
```

---

## Menggunakan Endpoint

```dart
// Di ApiService — gunakan Endpoint.{service}.{action}
final response = await _client.get(Endpoint.product.list);
final response = await _client.get('${Endpoint.product.detail}/$id');
final response = await _client.post(Endpoint.product.create, data: data);
```

---

## Switch Environment (untuk dev)

```dart
// Di controller atau settings screen
final envController = Get.find<EnvironmentController>();

// Switch ke staging
envController.switchEnvironment(Environment.staging);

// Switch ke prod
envController.setEnvironment(Environment.prod);
```

Environment disimpan di `GetStorage` (key `StorageValue.env`), persisten saat restart.

---

## EnvironmentsBadge

Badge "DEV" / "STAGING" muncul otomatis di semua screen melalui `EnvironmentsBadge` widget yang wrap setiap `GetPage` di `navigation.dart`. Badge tidak muncul di prod.

---

## Checklist

```
[ ] .env: tambah key untuk tiap environment (DEV, STAGING, PROD)
[ ] environments.dart: tambah field di EnvironmentConfig
[ ] environments.dart: isi nilai untuk _devConfig, _stagingConfig, _prodConfig
[ ] url.dart: tambah getter di Domain class
[ ] url.dart: tambah class _FeatureEndpoints dan daftarkan di Endpoint
[ ] Endpoint digunakan di ApiService (tidak hardcode URL)
```

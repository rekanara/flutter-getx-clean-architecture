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

## Struktur Saat Ini (Real)

Saat ini hanya ada **satu backend service**: `be` (dibaca dari `NEX_BE_DEV`/`NEX_BE_STAGING`/`NEX_BE_PROD` di `.env`), diakses lewat `Domain.be` dan `Endpoint.be.{login,refresh,banners,customerDetail}`. Contoh di bawah ("SSO", "Nexadmin", "Product") adalah ilustrasi pola untuk **menambah service baru** — bukan yang sudah ada di kode.

## File: .env (contoh menambah service baru "Product")

```env
# Service baru (ilustrasi — sesuaikan prefix dengan konvensi kamu)
PRODUCT_DEV=https://product-dev.example.com
PRODUCT_STAGING=https://product-staging.example.com
PRODUCT_PROD=https://product.example.com
```

Lihat `.env.example` untuk daftar lengkap key yang benar-benar dipakai saat ini (JWT, NEX_BE/FE, CDN, FIREBASE_*, MQTT_*, URL_APPCAST_*).

---

## File: environments.dart

### Step 1: Tambah field di EnvironmentConfig

```dart
// lib/infrastructure/network/environments.dart
class EnvironmentConfig {
  final String be; // ← sudah ada (backend utama)
  final String product; // ← TAMBAHKAN

  const EnvironmentConfig({
    required this.be,
    required this.product, // ← TAMBAHKAN
    // ... field lain (mqtt, firebase, dll — sudah ada)
  });
}
```

### Step 2: Isi nilai per environment

`ConfigEnvironments` di kode sebenarnya menyimpan config sebagai `List<EnvironmentConfig> _configs` (bukan getter `_devConfig`/`_stagingConfig`/`_prodConfig` terpisah) — tambahkan field `product` di tiap entry `EnvironmentConfig(...)` yang sudah ada untuk `Environment.dev`, `.staging`, dan `.prod`:

```dart
static final List<EnvironmentConfig> _configs = [
  EnvironmentConfig(
    env: Environment.dev,
    be: dotenv.env['NEX_BE_DEV']!,
    product: dotenv.env['PRODUCT_DEV']!, // ← TAMBAHKAN
    // ... field lain yang sudah ada
  ),
  EnvironmentConfig(
    env: Environment.staging,
    be: dotenv.env['NEX_BE_STAGING']!,
    product: dotenv.env['PRODUCT_STAGING']!, // ← TAMBAHKAN
    // ...
  ),
  EnvironmentConfig(
    env: Environment.prod,
    be: dotenv.env['NEX_BE_PROD']!,
    product: dotenv.env['PRODUCT_PROD']!, // ← TAMBAHKAN
    // ...
  ),
];

// getter current + config — sudah ada, tidak perlu diubah
static EnvironmentConfig get config =>
    _configs.firstWhere((c) => c.env == current);
```

---

## File: url.dart

### Step 3: Tambah Domain getter

```dart
// lib/infrastructure/network/url.dart — PathSegment/Domain/Endpoint sudah ada,
// ini contoh MENAMBAH getter baru di class yang sudah ada
class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  static String get be => '${_cfg.be}${PathSegment.api}${PathSegment.v1}'; // ← sudah ada
  static String get product => '${_cfg.product}${PathSegment.api}${PathSegment.v1}'; // ← TAMBAHKAN
}
```

### Step 4: Tambah Endpoint class

```dart
class Endpoint {
  Endpoint._();
  static final be = _BeEndpoints(); // ← sudah ada
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

// Yang sudah ada di kode saat ini:
class _BeEndpoints {
  String get login          => '${Domain.be}/auth/login';
  String get refresh        => '${Domain.be}/auth/refresh';
  String get banners        => '${Domain.be}/banners/active';
  String get customerDetail => '${Domain.be}/customer-details/me';
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
envController.switchEnvironment(Environment.prod);
```

**Catatan:** hanya ada satu method — `switchEnvironment()`. Tidak ada `setEnvironment()`.

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

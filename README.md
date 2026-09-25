# Zidanfath Codebase

Flutter project boilerplate menggunakan **Clean Architecture** dengan **GetX** sebagai state management, dependency injection, dan routing.

## Tech Stack

| Kategori | Library |
|---|---|
| State Management & DI | [GetX](https://pub.dev/packages/get) |
| HTTP Client | [Dio](https://pub.dev/packages/dio) |
| Functional Error Handling | [Dartz](https://pub.dev/packages/dartz) (`Either<Failure, T>`) |
| Local Storage | [GetStorage](https://pub.dev/packages/get_storage) |
| Secure Storage | [FlutterSecureStorage](https://pub.dev/packages/flutter_secure_storage) (tokens) |
| Environment Variables | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) |
| Network Inspector | [Chucker Flutter](https://pub.dev/packages/chucker_flutter) + [Talker Dio Logger](https://pub.dev/packages/talker_dio_logger) |
| Theming | [Flex Color Scheme](https://pub.dev/packages/flex_color_scheme) + [Google Fonts](https://pub.dev/packages/google_fonts) |
| Notifications | [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) |
| File Paths | [Path Provider](https://pub.dev/packages/path_provider) |
| Permissions | [Permission Handler](https://pub.dev/packages/permission_handler) |
| Logging | [Logger](https://pub.dev/packages/logger) |
| Testing | [Mockito](https://pub.dev/packages/mockito) + [build_runner](https://pub.dev/packages/build_runner) |

## Arsitektur

Project ini mengikuti prinsip **Clean Architecture** yang membagi codebase menjadi 3 layer utama:

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│       (Screens, Controllers / GetX)         │
├─────────────────────────────────────────────┤
│               Domain Layer                  │
│      (Entities, Repositories, UseCases)     │
├─────────────────────────────────────────────┤
│           Infrastructure Layer              │
│   (DAL, Network, Navigation, Platform)      │
└─────────────────────────────────────────────┘
```

### Dependency Rule

> Domain layer **tidak boleh** bergantung pada layer lain. Infrastructure dan Presentation **bergantung ke** Domain.

## Struktur Folder

```
lib/
├── main.dart                          # Entry point + Global Error Handler + init semua service
│
├── domain/                            # 🧠 DOMAIN LAYER (Business Logic) — pure Dart, no Flutter/Dio/GetX
│   ├── core/
│   │   ├── errors/
│   │   │   └── failures.dart          # Failure, ServerFailure, TimeoutFailure, NoConnectionFailure, dst.
│   │   └── usecases/
│   │       └── usecase.dart           # Generic UseCase<T, Params> + NoParams
│   ├── auth/
│   │   ├── entities/user_entity.dart
│   │   ├── repositories/auth_repository.dart   # Abstract repository (contract)
│   │   └── usecases/login_usecase.dart
│   └── home/
│       ├── entities/banner_entity.dart
│       ├── repositories/home_repository.dart
│       └── usecases/get_banners_usecase.dart
│
├── infrastructure/                    # 🔧 INFRASTRUCTURE LAYER (Implementasi Domain)
│   ├── dal/                           # Data Access Layer
│   │   ├── models/
│   │   │   ├── api_response.dart      # Generic ApiResponse<T> + PaginationMeta
│   │   │   └── pagination_filter.dart # PaginationFilter (page, limit, search)
│   │   ├── services/
│   │   │   ├── auth_api_service.dart  # HTTP calls (Dio) untuk auth
│   │   │   └── home_api_service.dart  # HTTP calls (Dio) untuk home
│   │   ├── auth/
│   │   │   ├── models/user_model.dart          # fromJson/toJson
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── home/
│   │       ├── models/banner_model.dart
│   │       └── repositories/home_repository_impl.dart
│   │
│   ├── network/                       # Konfigurasi Network
│   │   ├── dio_client.dart            # noAuthClient / authClient (cached) + refresh-token interceptor
│   │   ├── dio_wrapper.dart           # Talker logger interceptor
│   │   ├── environments.dart          # EnvironmentConfig, EnvironmentController, ConfigEnvironments
│   │   └── url.dart                   # PathSegment, Domain, Endpoint (URL builder reaktif)
│   │
│   ├── navigation/                    # Routing & DI Bindings
│   │   ├── routes.dart                # Route constants & initial route
│   │   ├── navigation.dart            # Nav.routes (GetPage) + EnvironmentsBadge
│   │   └── bindings/controllers/
│   │       ├── controllers_bindings.dart
│   │       ├── login.controller.binding.dart
│   │       ├── home.controller.binding.dart
│   │       └── user.controller.binding.dart
│   │
│   ├── platform/                      # Platform Services
│   │   ├── storage/
│   │   │   ├── storage.dart           # Abstract Storage interface
│   │   │   └── get_storage_impl.dart  # GetStorage (non-sensitif) + StorageValue keys
│   │   └── secure_storage/
│   │       ├── secure_storage.dart    # Abstract SecureStorage interface
│   │       └── flutter_secure_storage_impl.dart  # Encrypted storage + SecureStorageKey keys
│   │
│   └── theme/
│       └── theme.dart                 # RkTheme (light + dark + changeTheme)
│
├── presentation/                      # 🎨 PRESENTATION LAYER (UI)
│   ├── core/
│   │   ├── base_controller.dart           # BaseController (.obs) + callUseCase()
│   │   ├── base_builder_controller.dart   # BaseBuilderController (manual update())
│   │   └── base_pagination_controller.dart # BasePaginationController<T>
│   ├── screens.dart                   # Barrel export untuk semua screens
│   ├── login/
│   │   ├── login.screen.dart
│   │   └── controllers/login.controller.dart
│   ├── home/
│   │   ├── home.screen.dart
│   │   ├── controllers/home.controller.dart
│   │   └── widgets/banner_carousel.dart
│   └── user/                          # Contoh pola BaseBuilderController + GetBuilder
│       ├── user.screen.dart
│       └── controllers/user.controller.dart
│
├── components/                        # 🧩 Reusable UI Components
│   ├── atoms/
│   │   ├── custom_button.dart         # CustomButton (filled/outline)
│   │   └── custom_text.dart           # CustomText (theme-aware)
│   └── molecules/
│       ├── custom_cached_image.dart   # CustomCachedImage
│       └── pagination_list_view.dart  # PaginationListView<T>
│
├── config/                            # ⚙️ Platform & App Services (global, permanent)
│   ├── device/
│   │   ├── config.dart
│   │   └── device_config.dart         # DeviceConfig singleton
│   ├── error/
│   │   └── global_error_handler.dart  # runZonedGuarded + Flutter/Platform/Zone error handler
│   ├── firebase/
│   │   ├── firebase_service.dart
│   │   ├── firebase_options.dart
│   │   ├── firebase_messaging_service.dart   # FCM foreground/background/tap handler
│   │   └── remote_config_service.dart
│   ├── lifecycle/
│   │   └── app_lifecycle_service.dart # MQTT reconnect + refresh hooks saat app resume
│   ├── mqtt/
│   │   └── mqtt_service.dart          # MQTT client (pub/sub) global singleton
│   ├── notifications/
│   │   └── notifications.dart         # Local notifications + FCM notification renderer
│   └── permissions/
│       └── permissions.dart           # Camera/location/notification permission handler
│
└── utils/                             # 🛠️ Utilities & Helpers
    ├── config.dart                    # Enums, ColorData, FontType
    ├── json_parser.dart               # JsonParser (pakai Isolate untuk list > 50 item)
    ├── responsive.dart                # Responsive widget + ResponsiveExtension
    └── helper/
        ├── date_time.dart             # Date formatting helper
        ├── dialog.dart                # Dialog helper
        ├── logger.dart                # LoggerHelper (static: d, i, w, e, t, f)
        ├── open_setting.dart          # Dialog buka native app settings
        ├── rupiah.dart                # Currency formatting (IDR)
        └── snackbar.dart              # SnackbarHelper
```

## Alur Data (Data Flow)

Berikut alur data saat user melakukan login:

```
LoginScreen (UI)
    │
    ▼
LoginController.doLogin()          ← extends BaseController
    │
    ▼
BaseController.callUseCase()       ← Auto loading & error handling
    │
    ▼
LoginUseCase.execute(LoginParams)  ← extends UseCase<UserEntity, LoginParams>
    │
    ▼
AuthRepository.login()             ← Domain Layer (abstract contract)
    │
    ▼
AuthRepositoryImpl.login()         ← Infrastructure Layer
    │  ├─ Token → SecureStorage (encrypted)
    │  └─ User data → GetStorage
    ▼
AuthApiService.login()             ← HTTP call via Dio (noAuthClient)
    │
    ▼
Either<Failure, UserEntity>        ← Response di-wrap dengan Dartz
    │
    ▼
BaseController.callUseCase()       ← fold: Left(error) / Right(success)
```

## Dependency Injection (GetX Bindings)

DI di-wire melalui **GetX Bindings** di setiap route. Contoh `LoginControllerBinding`:

```dart
class LoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());
    Get.lazyPut<AuthApiService>(
      () => AuthApiService(secureStorage: Get.find<FlutterSecureStorageImpl>()),
    );
    Get.lazyPut<GetStorageImpl>(() => GetStorageImpl());
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        apiService: Get.find(),
        storage: Get.find(),
        secureStorage: Get.find<FlutterSecureStorageImpl>(),
      ),
    );
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find()));
    Get.lazyPut<LoginController>(
      () => LoginController(loginUseCase: Get.find()),
    );
  }
}
```

## Network Layer

### Dio Client

Project ini menyediakan 3 utilitas HTTP request utama:

| Client | Deskripsi |
|---|---|
| `DioClient.noAuthClient` | Untuk request tanpa token (login, register) |
| `DioClient.authClient(secureStorage)` | Otomatis inject `Bearer` token + refresh token interceptor |
| `DioClient.download()` | Utility khusus untuk mempermudah download file ke direktori lokal (mendukung request dengan maupun tanpa auth). |

### Refresh Token Flow

```
Request gagal 401
    │
    ▼
Baca refreshToken dari SecureStorage
    │
    ▼
Hit /auth/refresh endpoint
    ├─ Berhasil → Simpan token baru → Retry request asli
    └─ Gagal → Hapus semua token → Redirect ke Login
```

### Multi-Environment

Mendukung 3 environment reaktif yang terintegrasi dengan `GetStorage` untuk menyimpan preferensi environment saat aplikasi di-restart:

| Environment | Keterangan |
|---|---|
| `Environment.dev` | Development |
| `Environment.staging` | Staging / QA |
| `Environment.prod` | Production |

Konfigurasi ditangani menggunakan class bawa tipe (*strongly-typed*) `EnvironmentConfig` agar *compile-time safe* dan anti-typo.

#### URL Endpoints

Endpoint API dan URL sudah terdefinisi secara statik agar memudahkan pemanggilan fungsi tanpa menebak string manual:
Rantai pengambilan: `ConfigEnvironments.config` → `Domain` → `Endpoint`.

Contoh pemanggilan endpoint:
```dart
// Lebih bersih dan tanpa khawatir adanya string typo ".obs" atau ".value"
final response = await dio.post(Endpoint.sso.login, data: data);
```

## Storage Strategy

| Data | Storage | Alasan |
|---|---|---|
| Access Token | `SecureStorage` (encrypted) | Data sensitif |
| Refresh Token | `SecureStorage` (encrypted) | Data sensitif |
| Theme preference | `GetStorage` | Non-sensitif |
| App version | `GetStorage` | Non-sensitif |

## Base Classes

### `UseCase<T, Params>`

Setiap use case extend base class ini:

```dart
// Dengan parameter:
class LoginUseCase extends UseCase<UserEntity, LoginParams> { ... }

// Tanpa parameter:
class GetBannersUseCase extends UseCase<List<BannerEntity>, NoParams> { ... }
```

### `BaseController`

Setiap controller extend base class ini untuk menghindari boilerplate:

```dart
class LoginController extends BaseController {
  Future<void> doLogin() async {
    await callUseCase(
      loginUseCase.execute(params),
      onSuccess: (user) => Get.offAllNamed(Routes.home),
          // onFailure opsional — default: SnackbarHelper.showError()
    );
  }
}
```

`callUseCase()` otomatis handle: `isLoading`, `errorMessage`, dan `Either fold`.

### `BasePaginationController`

Digunakan untuk list API yang memiliki pagination (contoh: infinite scroll, load more). Otomatis menangani state halaman dan scroll listener.

```dart
class UsersController extends BasePaginationController<UserEntity> {
  final GetUsersUseCase useCase;

  @override
  void onInit() {
    super.onInit();
    fetchPage(1); // Auto-fetch saat init
  }

  @override
  Future<void> fetchPage(int page) async {
    final filter = PaginationFilter(page: page, limit: limit);

    await callUseCase(
      useCase.execute(filter),
      onSuccess: (response) { 
        appendData(
          newItems: response.data ?? [], 
          lastPage: response.meta?.lastPage ?? 1,
        );
      },
    );
  }
}
```

Di UI, hubungkan ke `ListView` atau Widget sejenis:
```dart
ListView.builder(
  controller: controller.scrollController, // Otomatis trigger fetchPage
  itemCount: controller.items.length + (controller.isLoadMore.value ? 1 : 0),
  itemBuilder: (context, index) { ... },
)
```

### `ApiResponse<T>`

Generic wrapper untuk standarisasi parsing API response:

```dart
final response = ApiResponse.fromJson(json, (data) => UserModel.fromJson(data));

// Atau untuk list:
final listResponse = ApiResponse.fromJsonList(json, (data) => BannerModel.fromJson(data));
```

## Global Error Handler

Error yang tidak tertangkap di level Flutter maupun async akan otomatis di-log:

- `FlutterError.onError` — Flutter framework errors
- `PlatformDispatcher.instance.onError` — Uncaught async errors

Semua error di-log melalui `LoggerHelper.e()`.

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.0`
- [FVM](https://fvm.app/) (disarankan, menggunakan channel `stable`)

### Setup

```bash
# 1. Clone repository
git clone <repository-url>
cd flutter

# 2. Install dependencies
flutter pub get

# 3. Setup environment variables
# Buat file .env di root project berdasarkan template yang ada

# 4. Generate mock files untuk testing
dart run build_runner build --delete-conflicting-outputs

# 5. Jalankan aplikasi
flutter run

# 6. Generate app icon (opsional)
dart run flutter_launcher_icons
```

## Rebranding — Mengganti Namespace & Identitas App

Boilerplate ini di-publish dengan identitas generik (`com.zidanfath.codebase`, "Zidanfath Codebase"). Sebelum dipakai untuk project baru, ganti dulu bagian-bagian berikut:

### 1. Android — `applicationId` & package

```bash
# a. Rename folder package (sesuaikan com/namamu/appmu)
mkdir -p android/app/src/main/kotlin/com/namamu/appmu
mv android/app/src/main/kotlin/com/zidanfath/codebase/MainActivity.kt \
   android/app/src/main/kotlin/com/namamu/appmu/MainActivity.kt
```

- Edit `MainActivity.kt` → ganti baris `package com.zidanfath.codebase` jadi `package com.namamu.appmu`.
- Edit `android/app/build.gradle.kts` → ganti `namespace` dan `applicationId` ke `"com.namamu.appmu"`.
- Edit `android/app/src/main/AndroidManifest.xml` → ganti `android:label` ke nama app kamu.

### 2. iOS — Bundle Identifier & Display Name

- Buka `ios/Runner.xcworkspace` di Xcode → tab **Signing & Capabilities** → ganti **Bundle Identifier**.
  (Atau cari-ganti manual semua `PRODUCT_BUNDLE_IDENTIFIER = com.zidanfath.codebase*` di `ios/Runner.xcodeproj/project.pbxproj`.)
- Edit `ios/Runner/Info.plist` → ganti `CFBundleDisplayName`.
- Kalau butuh Universal Links/deep link, isi `AssociatedDomains` di `Info.plist` (sudah di-comment secara default) dengan domain milikmu sendiri, plus setup App Links `intent-filter` di `AndroidManifest.xml` untuk Android.

### 3. Nama App di Flutter

- `lib/main.dart` → `GetMaterialApp(title: 'Zidanfath Codebase')` ganti sesuai nama app.
- `pubspec.yaml` → `name:` (opsional, lebih invasif karena mempengaruhi semua import path `package:zidanfath_codebase/...` di seluruh `lib/` & `test/`).

### 4. Firebase

- Buat project Firebase baru sesuai `applicationId`/Bundle ID baru kamu.
- Download `google-services.json` (Android) → taruh di `android/app/src/`.
- Download `GoogleService-Info.plist` (iOS) → taruh di `ios/Runner/`.
- Kedua file ini sudah di-`.gitignore` — **jangan commit**, provision manual/lewat CI di tiap environment.

### 5. Environment Variables

```bash
cp .env.example .env
# lalu isi semua value sesuai backend/MQTT/Firebase project kamu
```

### 6. App Icon

- Ganti `assets/icons/app_icon.png` dengan icon app kamu, lalu jalankan `dart run flutter_launcher_icons`.

### Kompatibel dengan `get_cli`

Project ini mendukung generate module baru menggunakan [get_cli](https://pub.dev/packages/get_cli):

```bash
# Install get_cli
dart pub global activate get_cli

# Generate module baru
get create page:nama_module
```

## Menambah Feature Baru

Ikuti langkah berikut saat menambah feature baru agar tetap konsisten:

1. **Domain** — Buat `entity`, `repository` (abstract), dan `usecase` (extend `UseCase<T, Params>`)
2. **Infrastructure/DAL** — Buat `model` (fromJson), `api_service`, dan `repository_impl`
3. **Presentation** — Buat `screen` dan `controller` (extend `BaseController`)
4. **Navigation** — Tambahkan route di `routes.dart`, halaman di `navigation.dart`, dan binding di `bindings/`
5. **Tests** — Buat unit test untuk usecase (mock repository)

## Testing

```bash
# Jalankan semua test
flutter test

# Jalankan test spesifik
flutter test test/domain/auth/usecases/login_usecase_test.dart

# Generate mocks (setelah menambah @GenerateMocks)
dart run build_runner build --delete-conflicting-outputs
```

## Error Handling

Menggunakan `Either<Failure, T>` dari **Dartz** untuk functional error handling:

```dart
// Domain Layer — Abstract error types
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure { ... }
class CacheFailure extends Failure { ... }

// Presentation Layer — Via BaseController
await callUseCase(
  useCase.execute(params),
  onSuccess: (data) => /* handle success */,
  onFailure: (failure) => /* custom error handler (opsional) */,
);
```

## License

[MIT](LICENSE)

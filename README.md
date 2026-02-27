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
├── main.dart                          # Entry point + Global Error Handler
│
├── domain/                            # 🧠 DOMAIN LAYER (Business Logic)
│   ├── core/
│   │   ├── errors/
│   │   │   └── failures.dart          # Base Failure class (ServerFailure, CacheFailure)
│   │   └── usecases/
│   │       └── usecase.dart           # Generic UseCase<T, Params> + NoParams
│   ├── auth/
│   │   ├── entities/
│   │   │   └── user_entity.dart       # Entity murni tanpa dependency
│   │   ├── repositories/
│   │   │   └── auth_repository.dart   # Abstract repository (contract)
│   │   └── usecases/
│   │       └── login_usecase.dart     # UseCase<UserEntity, LoginParams>
│   └── home/
│       ├── entities/
│       │   └── banner_entity.dart
│       ├── repositories/
│       │   └── home_repository.dart
│       └── usecases/
│           └── get_banners_usecase.dart # UseCase<List<BannerEntity>, NoParams>
│
├── infrastructure/                    # 🔧 INFRASTRUCTURE LAYER (Implementasi)
│   ├── dal/                           # Data Access Layer
│   │   ├── models/
│   │   │   └── api_response.dart      # Generic ApiResponse<T> wrapper
│   │   ├── services/
│   │   │   ├── auth_api_service.dart  # HTTP calls (Dio) untuk auth
│   │   │   └── home_api_service.dart  # HTTP calls (Dio) untuk home
│   │   ├── auth/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart    # JSON serialization (fromJson/toJson)
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart  # Implementasi AuthRepository
│   │   └── home/
│   │       ├── models/
│   │       │   └── banner_model.dart
│   │       └── repositories/
│   │           └── home_repository_impl.dart
│   │
│   ├── network/                       # Konfigurasi Network
│   │   ├── dio_client.dart            # Dio instances + Refresh Token Interceptor
│   │   ├── dio_wrapper.dart           # Talker logger interceptor
│   │   ├── environments.dart          # Multi-environment config (dev/staging/prod)
│   │   └── url.dart                   # URL endpoints builder (reactive via GetX)
│   │
│   ├── navigation/                    # Routing & DI Bindings
│   │   ├── routes.dart                # Route constants & initial route
│   │   ├── navigation.dart            # GetPage routes + EnvironmentsBadge
│   │   └── bindings/controllers/
│   │       ├── controllers_bindings.dart
│   │       ├── login.controller.binding.dart   # DI wiring untuk Login
│   │       └── home.controller.binding.dart    # DI wiring untuk Home
│   │
│   ├── platform/                      # Platform Services
│   │   ├── storage/
│   │   │   ├── storage.dart           # Abstract Storage interface
│   │   │   └── get_storage_impl.dart  # GetStorage (non-sensitive data)
│   │   └── secure_storage/
│   │       ├── secure_storage.dart    # Abstract SecureStorage interface
│   │       └── flutter_secure_storage_impl.dart  # Encrypted storage (tokens)
│   │
│   └── theme/
│       └── theme.dart                 # App theme configuration
│
├── presentation/                      # 🎨 PRESENTATION LAYER (UI)
│   ├── core/
│   │   └── base_controller.dart       # BaseController + callUseCase() helper
│   ├── screens.dart                   # Barrel export untuk semua screens
│   ├── login/
│   │   ├── login.screen.dart          # Login UI
│   │   └── controllers/
│   │       └── login.controller.dart  # extends BaseController
│   └── home/
│       ├── home.screen.dart           # Home UI
│       └── controllers/
│           └── home.controller.dart   # extends BaseController
│
├── components/                        # 🧩 Reusable UI Components
│   └── atoms/
│       ├── custom_button.dart
│       └── custom_text.dart
│
├── config/                            # ⚙️ Device & Platform Config
│   ├── device/
│   │   ├── config.dart
│   │   └── device_config.dart
│   ├── notifications/
│   │   └── notifications.dart
│   └── permissions/
│       └── permissions.dart
│
└── utils/                             # 🛠️ Utilities & Helpers
    ├── config.dart                    # Global config
    └── helper/
        ├── date_time.dart             # Date formatting helper
        ├── dialog.dart                # Dialog helper
        ├── logger.dart                # Logger wrapper (static methods)
        ├── open_setting.dart          # Open native settings helper
        ├── rupiah.dart                # Currency formatting (IDR)
        └── snackbar.dart              # Snackbar helper
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

Private project — Tidak untuk distribusi publik.

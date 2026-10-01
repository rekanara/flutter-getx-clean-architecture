# flutter getx clean architecture

![CI](https://github.com/zidanfath/flutter-getx-clean-architecture/workflows/CI/badge.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.47.5-blue.svg)
![Style](https://img.shields.io/badge/style-flutter_lints-blue.svg)

Flutter project boilerplate using **Clean Architecture** with **GetX** as state management, dependency injection, and routing.

## Tech Stack

| Category                  | Library                                                                                                                       |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| State Management & DI     | [GetX](https://pub.dev/packages/get)                                                                                          |
| HTTP Client               | [Dio](https://pub.dev/packages/dio)                                                                                           |
| Functional Error Handling | [Dartz](https://pub.dev/packages/dartz) (`Either<Failure, T>`)                                                                |
| Local Storage             | [GetStorage](https://pub.dev/packages/get_storage)                                                                            |
| Secure Storage            | [FlutterSecureStorage](https://pub.dev/packages/flutter_secure_storage) (tokens)                                              |
| Environment Variables     | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)                                                                     |
| Network Inspector         | [Chucker Flutter](https://pub.dev/packages/chucker_flutter) + [Talker Dio Logger](https://pub.dev/packages/talker_dio_logger) |
| Theming                   | [Flex Color Scheme](https://pub.dev/packages/flex_color_scheme) + [Google Fonts](https://pub.dev/packages/google_fonts)       |
| Notifications             | [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)                                           |
| File Paths                | [Path Provider](https://pub.dev/packages/path_provider)                                                                       |
| Permissions               | [Permission Handler](https://pub.dev/packages/permission_handler)                                                             |
| Logging                   | [Logger](https://pub.dev/packages/logger)                                                                                     |
| Testing                   | [Mockito](https://pub.dev/packages/mockito) + [build_runner](https://pub.dev/packages/build_runner)                           |

## Architecture

This project follows **Clean Architecture** principles, dividing the codebase into 3 main layers:

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

> The Domain layer **must not** depend on any other layer. Infrastructure and Presentation **depend on** the Domain.

## Folder Structure

```
lib/
├── main.dart                          # Entry point + Global Error Handler + init all services
│
├── domain/                            # 🧠 DOMAIN LAYER (Business Logic) — pure Dart, no Flutter/Dio/GetX
│   ├── core/
│   │   ├── errors/
│   │   │   └── failures.dart          # Failure, ServerFailure, TimeoutFailure, NoConnectionFailure, etc.
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
├── infrastructure/                    # 🔧 INFRASTRUCTURE LAYER (Domain Implementation)
│   ├── dal/                           # Data Access Layer
│   │   ├── models/
│   │   │   ├── api_response.dart      # Generic ApiResponse<T> + PaginationMeta
│   │   │   └── pagination_filter.dart # PaginationFilter (page, limit, search)
│   │   ├── services/
│   │   │   ├── auth_api_service.dart  # HTTP calls (Dio) for auth
│   │   │   └── home_api_service.dart  # HTTP calls (Dio) for home
│   │   ├── auth/
│   │   │   ├── models/user_model.dart          # fromJson/toJson
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── home/
│   │       ├── models/banner_model.dart
│   │       └── repositories/home_repository_impl.dart
│   │
│   ├── network/                       # Network Configuration
│   │   ├── dio_client.dart            # noAuthClient / authClient (cached) + refresh-token interceptor
│   │   ├── dio_wrapper.dart           # Talker logger interceptor
│   │   ├── environments.dart          # EnvironmentConfig, EnvironmentController, ConfigEnvironments
│   │   └── url.dart                   # PathSegment, Domain, Endpoint (reactive URL builder)
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
│   │   │   └── get_storage_impl.dart  # GetStorage (non-sensitive) + StorageValue keys
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
│   ├── screens.dart                   # Barrel export for all screens
│   ├── login/
│   │   ├── login.screen.dart
│   │   └── controllers/login.controller.dart
│   ├── home/
│   │   ├── home.screen.dart
│   │   ├── controllers/home.controller.dart
│   │   └── widgets/banner_carousel.dart
│   └── user/                          # Example of BaseBuilderController + GetBuilder pattern
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
│   │   └── app_lifecycle_service.dart # MQTT reconnect + refresh hooks when app resumes
│   ├── mqtt/
│   │   └── mqtt_service.dart          # MQTT client (pub/sub) global singleton
│   ├── notifications/
│   │   └── notifications.dart         # Local notifications + FCM notification renderer
│   └── permissions/
│       └── permissions.dart           # Camera/location/notification permission handler
│
└── utils/                             # 🛠️ Utilities & Helpers
    ├── config.dart                    # Enums, ColorData, FontType
    ├── json_parser.dart               # JsonParser (uses Isolate for list > 50 items)
    ├── responsive.dart                # Responsive widget + ResponsiveExtension
    └── helper/
        ├── date_time.dart             # Date formatting helper
        ├── dialog.dart                # Dialog helper
        ├── logger.dart                # LoggerHelper (static: d, i, w, e, t, f)
        ├── open_setting.dart          # Dialog to open native app settings
        ├── rupiah.dart                # Currency formatting (IDR)
        └── snackbar.dart              # SnackbarHelper
```

## Data Flow

Here is the data flow when a user logs in:

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
Either<Failure, UserEntity>        ← Response wrapped with Dartz
    │
    ▼
BaseController.callUseCase()       ← fold: Left(error) / Right(success)
```

## Dependency Injection (GetX Bindings)

DI is wired via **GetX Bindings** on every route. Example `LoginControllerBinding`:

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

This project provides 3 main HTTP request utilities:

| Client                                | Description                                                                                               |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `DioClient.noAuthClient`              | For requests without a token (login, register)                                                            |
| `DioClient.authClient(secureStorage)` | Automatically injects the `Bearer` token + refresh token interceptor                                      |
| `DioClient.download()`                | Special utility to simplify file downloads to a local directory (supports both auth and noAuth requests). |

### Refresh Token Flow

```
Request fails with 401
    │
    ▼
Read refreshToken from SecureStorage
    │
    ▼
Hit /auth/refresh endpoint
    ├─ Success → Save new token → Retry original request
    └─ Failed → Delete all tokens → Redirect to Login
```

### Multi-Environment

Supports 3 reactive environments integrated with `GetStorage` to persist the environment preference across app restarts:

| Environment           | Description  |
| --------------------- | ------------ |
| `Environment.dev`     | Development  |
| `Environment.staging` | Staging / QA |
| `Environment.prod`    | Production   |

Configurations are managed using a strongly-typed `EnvironmentConfig` class to ensure compile-time safety and prevent typos.

#### URL Endpoints

API endpoints and URLs are statically defined to make function calls easier without manually typing strings:
Retrieval chain: `ConfigEnvironments.config` → `Domain` → `Endpoint`.

Example endpoint call:

```dart
// Cleaner and without worrying about string typos, ".obs" or ".value"
final response = await dio.post(Endpoint.sso.login, data: data);
```

## Storage Strategy

| Data             | Storage                     | Reason         |
| ---------------- | --------------------------- | -------------- |
| Access Token     | `SecureStorage` (encrypted) | Sensitive data |
| Refresh Token    | `SecureStorage` (encrypted) | Sensitive data |
| Theme preference | `GetStorage`                | Non-sensitive  |
| App version      | `GetStorage`                | Non-sensitive  |

## Base Classes

### `UseCase<T, Params>`

Every use case extends this base class:

```dart
// With parameters:
class LoginUseCase extends UseCase<UserEntity, LoginParams> { ... }

// Without parameters:
class GetBannersUseCase extends UseCase<List<BannerEntity>, NoParams> { ... }
```

### `BaseController`

Every controller extends this base class to avoid boilerplate:

```dart
class LoginController extends BaseController {
  Future<void> doLogin() async {
    await callUseCase(
      loginUseCase.execute(params),
      onSuccess: (user) => Get.offAllNamed(Routes.home),
          // onFailure is optional — default: SnackbarHelper.showError()
    );
  }
}
```

`callUseCase()` automatically handles: `isLoading`, `errorMessage`, and `Either fold`.

### `BasePaginationController`

Used for API lists that have pagination (e.g., infinite scroll, load more). Automatically handles page state and scroll listener.

```dart
class UsersController extends BasePaginationController<UserEntity> {
  final GetUsersUseCase useCase;

  @override
  void onInit() {
    super.onInit();
    fetchPage(1); // Auto-fetch on init
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

In the UI, link it to a `ListView` or similar Widget:

```dart
ListView.builder(
  controller: controller.scrollController, // Automatically triggers fetchPage
  itemCount: controller.items.length + (controller.isLoadMore.value ? 1 : 0),
  itemBuilder: (context, index) { ... },
)
```

### `ApiResponse<T>`

Generic wrapper to standardize API response parsing:

```dart
final response = ApiResponse.fromJson(json, (data) => UserModel.fromJson(data));

// Or for a list:
final listResponse = ApiResponse.fromJsonList(json, (data) => BannerModel.fromJson(data));
```

## Global Error Handler

Errors not caught at the Flutter level or async level are automatically logged:

- `FlutterError.onError` — Flutter framework errors
- `PlatformDispatcher.instance.onError` — Uncaught async errors

All errors are logged via `LoggerHelper.e()`.

## Getting Started

### Prerequisites

- Flutter SDK `^3.13.0` (pinned `3.47.5` via `.fvmrc`)
- [FVM](https://fvm.app/) (recommended, using the `stable` channel)

### Setup

```bash
# 1. Clone repository
git clone <repository-url>
cd flutter

# 2. Install dependencies
flutter pub get

# 3. Setup environment variables
# Create a .env file in the project root based on the existing template

# 4. Generate mock files for testing
dart run build_runner build --delete-conflicting-outputs

# 5. Install Git Hooks (Husky)
dart run husky install

# 6. Run the application
flutter run

# 6. Generate app icon (optional)
dart run flutter_launcher_icons
```

## Rebranding — Changing Namespace & App Identity

This boilerplate is published with a generic identity (`com.rekanara.getx`, "rekanara getx"). Before using it for a new project, change the following parts:

### 1. Android — `applicationId` & package

```bash
# a. Rename package folder (adjust to com/yourname/yourapp)
mkdir -p android/app/src/main/kotlin/com/yourname/yourapp
mv android/app/src/main/kotlin/com/zidanfath/codebase/MainActivity.kt \
   android/app/src/main/kotlin/com/yourname/yourapp/MainActivity.kt
```

- Edit `MainActivity.kt` → change the line `package com.rekanara.getx` to `package com.yourname.yourapp`.
- Edit `android/app/build.gradle.kts` → change `namespace` and `applicationId` to `"com.yourname.yourapp"`.
- Edit `android/app/src/main/AndroidManifest.xml` → change `android:label` to your app name.

### 2. iOS — Bundle Identifier & Display Name

- Open `ios/Runner.xcworkspace` in Xcode → **Signing & Capabilities** tab → change **Bundle Identifier**.
  (Or manually search-and-replace all `PRODUCT_BUNDLE_IDENTIFIER = com.rekanara.getx*` in `ios/Runner.xcodeproj/project.pbxproj`.)
- Edit `ios/Runner/Info.plist` → change `CFBundleDisplayName`.
- If you need Universal Links/deep linking, fill in `AssociatedDomains` in `Info.plist` (commented out by default) with your own domain, plus setup App Links `intent-filter` in `AndroidManifest.xml` for Android.

### 3. App Name in Flutter

- `lib/main.dart` → change `GetMaterialApp(title: 'rekanara getx')` to your app name.
- `pubspec.yaml` → `name:` (optional, more invasive as it affects all `package:rekanara_getx/...` import paths throughout `lib/` & `test/`).

### 4. Firebase

- Create a new Firebase project matching your new `applicationId`/Bundle ID.
- Download `google-services.json` (Android) → place in `android/app/src/`.
- Download `GoogleService-Info.plist` (iOS) → place in `ios/Runner/`.
- Both files are already in `.gitignore` — **do not commit**, provision manually/via CI in each environment.

### 5. Environment Variables

```bash
cp .env.example .env
# then fill in all values according to your backend/MQTT/Firebase project
```

### 6. App Icon

- Replace `assets/icons/app_icon.png` with your app icon, then run `dart run flutter_launcher_icons`.

### Compatible with `get_cli`

This project supports generating new modules using [get_cli](https://pub.dev/packages/get_cli):

```bash
# Install get_cli
dart pub global activate get_cli

# Generate new module
get create page:module_name
```

## Adding a New Feature

Follow these steps when adding a new feature to maintain consistency:

1. **Domain** — Create `entity`, `repository` (abstract), and `usecase` (extends `UseCase<T, Params>`)
2. **Infrastructure/DAL** — Create `model` (fromJson), `api_service`, and `repository_impl`
3. **Presentation** — Create `screen` and `controller` (extends `BaseController`)
4. **Navigation** — Add route in `routes.dart`, page in `navigation.dart`, and binding in `bindings/`
5. **Tests** — Create unit tests for usecase (mock repository)

## Testing

```bash
# Run all tests
flutter test

# Run a specific test
flutter test test/domain/auth/usecases/login_usecase_test.dart

# Generate mocks (after adding @GenerateMocks)
dart run build_runner build --delete-conflicting-outputs
```

## Error Handling

Uses `Either<Failure, T>` from **Dartz** for functional error handling:

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
  onFailure: (failure) => /* custom error handler (optional) */,
);
```

## License

[MIT](LICENSE)

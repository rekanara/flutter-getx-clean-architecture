# Skill: Project Structure

Panduan struktur folder, naming convention, dan organisasi file di codebase ini.

---

## Struktur Folder Utama

```
lib/
├── main.dart                          # Entry point + GlobalErrorHandler + inisialisasi semua service
│
├── domain/                            # DOMAIN LAYER — Pure Dart, tidak import Flutter/Dio/GetX
│   ├── core/
│   │   ├── errors/failures.dart       # Failure, ServerFailure, CacheFailure
│   │   └── usecases/usecase.dart      # UseCase<T, Params> base class + NoParams
│   └── {feature}/
│       ├── entities/{feature}_entity.dart
│       ├── repositories/{feature}_repository.dart   # abstract class
│       └── usecases/{action}_{feature}_usecase.dart
│
├── infrastructure/                    # INFRASTRUCTURE LAYER — Implementasi Domain
│   ├── dal/                           # Data Access Layer
│   │   ├── models/
│   │   │   ├── api_response.dart      # ApiResponse<T> + PaginationMeta
│   │   │   └── pagination_filter.dart # PaginationFilter (page, limit, search)
│   │   ├── services/
│   │   │   └── {feature}_api_service.dart   # Dio HTTP calls
│   │   └── {feature}/
│   │       ├── models/{feature}_model.dart  # extends Entity + fromJson/toJson
│   │       └── repositories/{feature}_repository_impl.dart
│   ├── navigation/
│   │   ├── routes.dart                # Route constants + initialRoute
│   │   ├── navigation.dart            # Nav.routes (GetPage list) + EnvironmentsBadge
│   │   └── bindings/controllers/
│   │       ├── controllers_bindings.dart    # barrel export
│   │       └── {feature}.controller.binding.dart
│   ├── network/
│   │   ├── dio_client.dart            # noAuthClient, authClient, download
│   │   ├── dio_wrapper.dart           # TalkerDioLogger interceptor
│   │   ├── environments.dart          # EnvironmentConfig, EnvironmentController, ConfigEnvironments
│   │   └── url.dart                   # PathSegment, Domain, Endpoint
│   ├── platform/
│   │   ├── storage/
│   │   │   ├── storage.dart           # abstract Storage
│   │   │   └── get_storage_impl.dart  # GetStorageImpl + StorageValue keys
│   │   └── secure_storage/
│   │       ├── secure_storage.dart    # abstract SecureStorage
│   │       └── flutter_secure_storage_impl.dart  # + SecureStorageKey keys
│   └── theme/theme.dart               # RkTheme (light + dark + changeTheme)
│
├── presentation/                      # PRESENTATION LAYER — UI
│   ├── core/
│   │   ├── base_controller.dart       # BaseController (reactive, .obs)
│   │   ├── base_builder_controller.dart  # BaseBuilderController (manual, update())
│   │   └── base_pagination_controller.dart  # BasePaginationController<T>
│   ├── screens.dart                   # barrel export semua screens
│   └── {feature}/
│       ├── {feature}.screen.dart
│       ├── controllers/{feature}.controller.dart
│       └── widgets/                   # (opsional) widget spesifik fitur
│
├── components/                        # Reusable UI Components
│   ├── atoms/
│   │   ├── custom_button.dart         # CustomButton (filled/outline)
│   │   └── custom_text.dart           # CustomText (theme-aware)
│   └── molecules/
│       ├── custom_cached_image.dart   # CustomCachedImage
│       └── pagination_list_view.dart  # PaginationListView<T>
│
├── config/                            # Platform & App Services (global, permanent)
│   ├── device/device_config.dart      # DeviceConfig singleton
│   ├── error/global_error_handler.dart
│   ├── firebase/
│   │   ├── firebase_service.dart
│   │   ├── firebase_options.dart
│   │   ├── firebase_messaging_service.dart
│   │   └── remote_config_service.dart
│   ├── lifecycle/app_lifecycle_service.dart
│   ├── mqtt/mqtt_service.dart
│   ├── notifications/notifications.dart
│   └── permissions/permissions.dart
│
└── utils/                             # Utilities & Helpers
    ├── config.dart                    # Enums, ColorData, OtherColors, FontFamilyType, PlaceHolderImage
    ├── json_parser.dart               # JsonParser (isolate untuk data > 50 items)
    ├── responsive.dart                # Responsive widget + ResponsiveExtension on BuildContext
    └── helper/
        ├── logger.dart               # LoggerHelper (static: d, i, w, e, t, f)
        ├── snackbar.dart             # SnackbarHelper + CustomSnackBar
        ├── dialog.dart               # DialogHelper
        ├── date_time.dart            # DateTimeHelper
        ├── rupiah.dart               # RupiahHelper (IDR formatting)
        └── open_setting.dart         # OpenSetting (dialog buka app settings)
```

---

## Naming Convention

### File
| Tipe | Format | Contoh |
|---|---|---|
| Entity | `{feature}_entity.dart` | `user_entity.dart` |
| Repository (abstract) | `{feature}_repository.dart` | `auth_repository.dart` |
| Repository (impl) | `{feature}_repository_impl.dart` | `auth_repository_impl.dart` |
| UseCase | `{action}_{feature}_usecase.dart` | `login_usecase.dart`, `get_banners_usecase.dart` |
| Model | `{feature}_model.dart` | `user_model.dart` |
| API Service | `{feature}_api_service.dart` | `auth_api_service.dart` |
| Binding | `{feature}.controller.binding.dart` | `home.controller.binding.dart` |
| Controller | `{feature}.controller.dart` | `home.controller.dart` |
| Screen | `{feature}.screen.dart` | `home.screen.dart` |
| Widget | `{widget_name}.dart` | `banner_carousel.dart` |
| Test | `{file_tested}_test.dart` | `login_usecase_test.dart` |

### Class
| Tipe | Format | Contoh |
|---|---|---|
| Entity | `{Feature}Entity` | `UserEntity` |
| Repository | `{Feature}Repository` | `AuthRepository` |
| RepositoryImpl | `{Feature}RepositoryImpl` | `AuthRepositoryImpl` |
| UseCase | `{Action}{Feature}UseCase` | `LoginUseCase`, `GetBannersUseCase` |
| Model | `{Feature}Model` | `UserModel` |
| API Service | `{Feature}ApiService` | `AuthApiService` |
| Binding | `{Feature}ControllerBinding` | `HomeControllerBinding` |
| Controller | `{Feature}Controller` | `HomeController` |
| Screen | `{Feature}Screen` | `HomeScreen` |

---

## Dependency Rule

```
Domain ← tidak boleh import layer lain
Infrastructure ← import Domain (implements)
Presentation ← import Domain (use cases) + utils
```

Domain layer **tidak boleh** import: Flutter widgets, Dio, GetX, package storage apapun.

---

## Test Structure

```
test/
└── {layer}/
    └── {feature}/
        └── {file}_test.dart
        └── {file}_test.mocks.dart   # generated by build_runner
```

Generate mocks:
```bash
dart run build_runner build --delete-conflicting-outputs
```

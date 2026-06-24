# AGENTS.md — Instruksi untuk AI Agents

Project ini adalah Flutter boilerplate **zidanfath_codebase** menggunakan **Clean Architecture + GetX**.

---

## Skills Directory

Semua panduan teknis tersedia di `.agents/skills/`. **Selalu baca skill yang relevan sebelum mengerjakan task.**

```
.agents/skills/
├── project-structure/     # Folder structure, naming convention
├── clean-architecture/    # Layer diagram, dependency rule, Either<Failure,T>
├── new-feature/           # Step-by-step membuat fitur baru (12 langkah)
│
├── entity/                # Domain: pure Dart entity class
├── repository/            # Abstract interface + implementation
├── usecase/               # UseCase<T, Params>, NoParams
├── model/                 # extends Entity + fromJson/toJson
├── api-service/           # DioClient: noAuthClient vs authClient
├── binding/               # Dependency Injection order & pattern
│
├── controller-reactive/   # BaseController + .obs + Obx
├── controller-builder/    # BaseBuilderController + update() + GetBuilder
├── controller-pagination/ # BasePaginationController<T> + infinite scroll
├── screen/                # GetView<T>, widget reactive patterns
├── routing/               # routes.dart, navigation.dart, navigasi
│
├── environment/           # .env → EnvironmentConfig → Domain → Endpoint
├── networking/            # DioClient, refresh token, error handling
├── storage-get/           # GetStorage (non-sensitive, StorageValue keys)
├── storage-secure/        # SecureStorage (tokens, SecureStorageKey keys)
│
├── state-management/      # Obx vs GetBuilder, Rx types, debounce
├── components-atoms/      # CustomButton, CustomText
├── components-molecules/  # CustomCachedImage, PaginationListView<T>
├── theme/                 # RkTheme, colorScheme, changeTheme
├── responsive/            # Responsive widget, context.isMobile
├── json-parser/           # JsonParser (isolate untuk >=50 items)
│
├── firebase/              # FCM, RemoteConfig
├── mqtt/                  # subscribe, publish, addTopicListener
├── lifecycle/             # addOnResumeCallback, app pause/resume
├── notifications/         # ShowNotificationHelper, NotificationType
├── permissions/           # PermissionHandler, manifest setup
│
├── error-handling/        # GlobalErrorHandler, Failure, DioException
├── testing/               # Mockito, @GenerateMocks, unit test patterns
└── helpers/               # Logger, Snackbar, Dialog, DateTime, Rupiah
```

---

## Cara Membaca Skill

Baca file dengan path: `.agents/skills/{folder}/SKILL.md`

Contoh untuk task membuat fitur baru:
```
Baca: .agents/skills/new-feature/SKILL.md
Baca: .agents/skills/clean-architecture/SKILL.md
```

---

## Prinsip Arsitektur

### Dependency Rule (TIDAK BOLEH DILANGGAR)
```
Domain  ← pure Dart, tidak import Flutter/Dio/GetX/storage
    ↑ implements
Infrastructure ← import Domain
    ↑ injected via Binding
Presentation ← import Domain (usecases, entities)
```

### Urutan Implementasi Fitur Baru
```
Entity → Repository → UseCase → Model → ApiService → RepositoryImpl
→ Endpoint → Binding → Controller → Screen → Route → Test
```

### DI Injection Order (di Binding)
```
Storage → ApiService → Repository(abstract) → UseCase → Controller
```

---

## Aturan Kode

### Controller
- Default: `extends BaseController` (reactive, `.obs` state)
- Alternatif targeted update: `extends BaseBuilderController`
- Pagination: `extends BasePaginationController<T>`
- Selalu gunakan `callUseCase()` — tidak manual try/catch
- `onInit()` → `super.onInit()` + fetch awal
- `onClose()` → `super.onClose()` + hapus callbacks

### HTTP
- Endpoint publik → `DioClient.noAuthClient`
- Endpoint private → `DioClient.authClient(secureStorage)`
- URL dari `Endpoint.{service}.{action}` (TIDAK hardcode)

### Storage
- Token/sensitif → `SecureStorage`, key di `SecureStorageKey`
- Preferensi/non-sensitif → `GetStorage`, key di `StorageValue`

### UI
- Text → `CustomText(fontType: FontType.xxx)`
- Button → `CustomButton(title, onPressed)`
- Image → `CustomCachedImage(imageUrl, width, height)`
- List paginasi → `PaginationListView<T>(controller, itemBuilder)`

### Error
- Repository: `return Left(ServerFailure(e.response?.data?['message'] ?? e.message))`
- Controller: gunakan `callUseCase(onSuccess: ..., onFailure: ...)` — auto snackbar
- Failure types: `ServerFailure`, `CacheFailure`

---

## Commands

```bash
# Setup
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run
flutter run

# Test
flutter test
flutter test test/domain/{feature}/usecases/{name}_test.dart
```

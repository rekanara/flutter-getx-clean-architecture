# AGENTS.md — Instruksi untuk AI Agents

Flutter boilerplate **zidanfath_codebase** — Clean Architecture + GetX + Dio.
CI berjalan di branch `master` (`.github/workflows/ci.yml`).

File instruksi paralel (CLAUDE.md, GEMINI.md, .cursorrules, .github/copilot-instructions.md)
memiliki konten serupa — jika konvensi berubah, update semuanya agar tidak drift.

---

## Skills — Baca Sebelum Mengerjakan Task

Panduan teknis ada di `.agents/skills/{folder}/SKILL.md`. Mapping task yang paling sering:

| Task | Skill |
|---|---|
| Fitur baru (end-to-end, 12 langkah) | `new-feature` + `clean-architecture` |
| Struktur folder / naming | `project-structure` |
| Entity / Repository / UseCase / Model | `entity` / `repository` / `usecase` / `model` |
| ApiService / Binding / Endpoint baru | `api-service` / `binding` / `environment` |
| Controller (reactive / builder / pagination) | `controller-reactive` / `controller-builder` / `controller-pagination` |
| Screen / Route | `screen` / `routing` |
| HTTP / storage / state / UI components | `networking` / `storage-get` / `storage-secure` / `state-management` / `components-atoms` / `components-molecules` |
| Unit test (Mockito) | `testing` |

---

## Commands

```bash
# Setup awal
flutter pub get
cp .env.example .env          # WAJIB sebelum flutter run (lihat Environment)
dart run build_runner build --delete-conflicting-outputs

# Verifikasi sebelum commit — urutan sama dengan CI
dart format .                  # CI menjalankan --set-exit-if-changed, format gate GAGAL jika ada diff
flutter analyze
flutter test

# Test tunggal
flutter test test/domain/auth/usecases/login_usecase_test.dart

# Generate ulang mocks setelah menambah/mengubah @GenerateMocks
dart run build_runner build --delete-conflicting-outputs

# App icon (setelah ganti assets/icons/app_icon.png)
dart run flutter_launcher_icons
```

CI gates persis: `dart format --output=none --set-exit-if-changed .` → `flutter analyze` → `flutter test`. Semua harus lolos.

---

## Environment & Quirks

- **`.env` wajib untuk run app** — dimuat di `lib/main.dart` via `dotenv.load()`; gitignored, template di `.env.example`. Unit test TIDAK butuh `.env` (pure mock, tidak touch dotenv).
- **Pemilihan environment adalah runtime, bukan build flavor** — tidak ada `--flavor` / `dart-define`. `EnvironmentController.switchEnvironment()` (persist via GetStorage) memilih dev/staging/prod; semua value dari SATU file `.env` dengan suffix `_DEV` / `_STAGING` / `_PROD` (key prod tanpa suffix).
- **File Firebase gitignored** — `android/app/src/google-services.json` dan `ios/Runner/GoogleService-Info.plist` harus di-provision manual, jangan commit.
- **FVM opsional** — `.fvmrc` pinned `stable`; plain `flutter` / `dart` commands bekerja normal (CI pakai stable channel).
- **Chucker (HTTP inspector) hanya tampil di debug mode** — jangan nonaktifkan `kDebugMode` guard-nya.
- Endpoint URL menghasilkan crash jika env var kosong (`dotenv.env[...]!`) — jangan hapus key dari `.env`.

---

## Arsitektur

### Dependency Rule (TIDAK BOLEH DILANGGAR)
```
Domain  ← pure Dart, tidak import Flutter/Dio/GetX/storage
    ↑ implements
Infrastructure ← import Domain
    ↑ injected via Binding
Presentation ← import Domain (usecases, entities), TIDAK import infrastructure detail
```

### Urutan Implementasi Fitur Baru
```
Entity → Repository (abstract) → UseCase → Model → ApiService → RepositoryImpl
→ Endpoint (url.dart) → Binding → Controller → Screen → Route → Test
```

### DI Injection Order (di Binding)
```
Storage → ApiService → Repository (abstract) → UseCase → Controller
```

### Naming Convention
| Tipe | File | Class |
|---|---|---|
| Entity | `{feature}_entity.dart` | `{Feature}Entity` |
| Repository / Impl | `{feature}_repository(_impl).dart` | `{Feature}Repository(Impl)` |
| UseCase | `{action}_{feature}_usecase.dart` | `{Action}{Feature}UseCase` |
| Model | `{feature}_model.dart` | `{Feature}Model` |
| ApiService | `{feature}_api_service.dart` | `{Feature}ApiService` |
| Binding | `{feature}.controller.binding.dart` | `{Feature}ControllerBinding` |
| Controller | `{feature}.controller.dart` | `{Feature}Controller` |
| Screen | `{feature}.screen.dart` | `{Feature}Screen` |

### File Konfigurasi Penting
| File | Isi |
|---|---|
| `lib/infrastructure/network/url.dart` | `Endpoint.{service}.{action}` — semua URL API |
| `lib/infrastructure/network/environments.dart` | `EnvironmentConfig`, switch env runtime |
| `lib/infrastructure/platform/storage/get_storage_impl.dart` | `StorageValue` keys |
| `lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart` | `SecureStorageKey` keys |
| `lib/infrastructure/navigation/routes.dart` + `navigation.dart` | Route constants + GetPage |
| `lib/utils/config.dart` | Enums, ColorData, FontType |

---

## Aturan Kode

### Controller
- Default: `extends BaseController` (reactive, `.obs` + `Obx`)
- Targeted update: `extends BaseBuilderController` (`update([ids])` + `GetBuilder`)
- Pagination: `extends BasePaginationController<T>` + `PaginationListView<T>`
- Selalu `callUseCase()` — tidak manual try/catch / loading toggle
- `onInit()` → `super.onInit()` + fetch awal; `onClose()` → `super.onClose()` + hapus callback

### HTTP
- Endpoint publik → `DioClient.noAuthClient`; private → `DioClient.authClient(secureStorage)` (Bearer otomatis + refresh token retry)
- URL selalu dari `Endpoint.{service}.{action}` — TIDAK hardcode

### Storage
- Sensitif (token) → `SecureStorage`, key di `SecureStorageKey`; non-sensitif → `GetStorage`, key di `StorageValue`

### UI
- Text → `CustomText(fontType: FontType.xxx)`; Button → `CustomButton()`; Image URL → `CustomCachedImage()` — bukan widget Material default

### Error
- Repository catch: `return Left(ServerFailure(e.response?.data?['message'] ?? e.message))`
- Controller: `callUseCase(onSuccess: ..., onFailure: ...)` — auto snackbar

### Lint (analysis_options.yaml, di luar flutter_lints default)
`avoid_print` (pakai `LoggerHelper`, `print()` gagal analyze), `unawaited_futures`, `cancel_subscriptions`, `close_sinks` — stream/sink di controller MQTT/FCM wajib di-cancel di `onClose()`.

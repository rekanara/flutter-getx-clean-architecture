# AGENTS.md — Instructions for AI Agents

Flutter boilerplate **rekanara_getx** — Clean Architecture + GetX + Dio.
CI runs on the `main` branch (`.github/workflows/ci.yml`): a `secret-guard` job (fails if
`.env`, `google-services.json`, `GoogleService-Info.plist`, `key.properties`, or `*.jks`
are tracked in git) + an `analyze-and-test` job.

Parallel instruction files (CLAUDE.md, GEMINI.md, .cursorrules, .github/copilot-instructions.md)
have similar content — if conventions change, update all of them to avoid drift.

---

## Skills — Read Before Working on a Task

Technical guides live in `.agents/skills/{folder}/SKILL.md`. Mapping for the most common tasks:

| Task                                         | Skill                                                                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| New feature (end-to-end, 12 steps)           | `new-feature` + `clean-architecture`                                                                               |
| Folder structure / naming                    | `project-structure`                                                                                                |
| Entity / Repository / UseCase / Model        | `entity` / `repository` / `usecase` / `model`                                                                      |
| ApiService / Binding / new Endpoint          | `api-service` / `binding` / `environment`                                                                          |
| Controller (reactive / builder / pagination) | `controller-reactive` / `controller-builder` / `controller-pagination`                                             |
| Screen / Route                               | `screen` / `routing`                                                                                               |
| HTTP / storage / state / UI components       | `networking` / `storage-get` / `storage-secure` / `state-management` / `components-atoms` / `components-molecules` |
| Unit test (Mockito)                          | `testing`                                                                                                          |

---

## Commands

```bash
# Initial setup
flutter pub get
cp .env.example .env          # REQUIRED before flutter run (see Environment)
dart run build_runner build --delete-conflicting-outputs

# Verify before commit — same order as CI
dart format .                  # CI runs --set-exit-if-changed, the format gate FAILS if there is a diff
flutter analyze
flutter test

# Single test
flutter test test/domain/auth/usecases/login_usecase_test.dart

# Regenerate mocks after adding/changing @GenerateMocks
dart run build_runner build --delete-conflicting-outputs

# App icon (after replacing assets/icons/app_icon.png)
dart run flutter_launcher_icons
```

Exact CI gates: `dart format --output=none --set-exit-if-changed .` → `flutter analyze` → `flutter test`. All must pass.

---

## Environment & Quirks

- **`.env` is required to run/build the app** — declared as a Flutter asset in `pubspec.yaml` and loaded via `dotenv.load()` in `lib/main.dart`; gitignored, template in `.env.example`. Without `.env`, both `flutter run` and builds fail. Unit tests do NOT need `.env` (pure mocks, never touch dotenv).
- **Environment selection is runtime, not build flavor** — no `--flavor` / `dart-define`. `EnvironmentController.switchEnvironment()` (persisted via GetStorage) picks dev/staging/prod; all values come from ONE `.env` file with `_DEV` / `_STAGING` / `_PROD` suffixes (prod keys have no suffix).
- **Firebase files are gitignored** — `android/app/src/google-services.json` and `ios/Runner/GoogleService-Info.plist` must be provisioned manually; do not commit them.
- **FVM is optional** — `.fvmrc` pins `stable`; plain `flutter` / `dart` commands work fine (CI uses the stable channel).
- **Chucker (HTTP inspector) only appears in debug mode** — do not disable its `kDebugMode` guard.
- Endpoint URLs crash if the env var is empty (`dotenv.env[...]!`) — do not remove keys from `.env`.

---

## Architecture

### Dependency Rule (MUST NOT BE VIOLATED)

```
Domain  ← pure Dart, no Flutter/Dio/GetX/storage imports
    ↑ implements
Infrastructure ← imports Domain
    ↑ injected via Binding
Presentation ← imports Domain (usecases, entities), NO infrastructure detail imports
```

### Order for Implementing a New Feature

```
Entity → Repository (abstract) → UseCase → Model → ApiService → RepositoryImpl
→ Endpoint (url.dart) → Binding → Controller → Screen → Route → Test
```

### DI Injection Order (in the Binding)

```
Storage → ApiService → Repository (abstract) → UseCase → Controller
```

### Naming Convention

| Type              | File                                | Class                        |
| ----------------- | ----------------------------------- | ---------------------------- |
| Entity            | `{feature}_entity.dart`             | `{Feature}Entity`            |
| Repository / Impl | `{feature}_repository(_impl).dart`  | `{Feature}Repository(Impl)`  |
| UseCase           | `{action}_{feature}_usecase.dart`   | `{Action}{Feature}UseCase`   |
| Model             | `{feature}_model.dart`              | `{Feature}Model`             |
| ApiService        | `{feature}_api_service.dart`        | `{Feature}ApiService`        |
| Binding           | `{feature}.controller.binding.dart` | `{Feature}ControllerBinding` |
| Controller        | `{feature}.controller.dart`         | `{Feature}Controller`        |
| Screen            | `{feature}.screen.dart`             | `{Feature}Screen`            |

### Important Config Files

| File                                                                          | Content                                       |
| ----------------------------------------------------------------------------- | --------------------------------------------- |
| `lib/infrastructure/network/url.dart`                                         | `Endpoint.{service}.{action}` — all API URLs  |
| `lib/infrastructure/network/environments.dart`                                | `EnvironmentConfig`, runtime env switch       |
| `lib/infrastructure/platform/storage/get_storage_impl.dart`                   | `StorageValue` keys                           |
| `lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart` | `SecureStorageKey` keys                       |
| `lib/infrastructure/navigation/routes.dart` + `navigation.dart`               | Route constants + GetPage                     |
| `lib/utils/config.dart`                                                       | Enums, ColorData, FontType                    |

---

## Code Rules

### Controller

- Default: `extends BaseController` (reactive, `.obs` + `Obx`)
- Targeted update: `extends BaseBuilderController` (`update([ids])` + `GetBuilder`)
- Pagination: `extends BasePaginationController<T>` + `PaginationListView<T>`
- Always use `callUseCase()` — no manual try/catch / loading toggles
- `onInit()` → `super.onInit()` + initial fetch; `onClose()` → `super.onClose()` + remove callbacks

### HTTP

- Public endpoints → `DioClient.noAuthClient`; private → `DioClient.authClient(secureStorage)` (automatic Bearer + refresh-token retry)
- URLs always come from `Endpoint.{service}.{action}` — NO hardcoding

### Storage

- Sensitive (tokens) → `SecureStorage`, keys in `SecureStorageKey`; non-sensitive → `GetStorage`, keys in `StorageValue`

### UI

- Text → `CustomText(fontType: FontType.xxx)`; Button → `CustomButton()`; Image URL → `CustomCachedImage()` — not default Material widgets

### Error

- Repository catch: `return Left(ServerFailure(e.response?.data?['message'] ?? e.message))`
- Controller: `callUseCase(onSuccess: ..., onFailure: ...)` — automatic snackbar

### Lint (analysis_options.yaml, beyond flutter_lints defaults)

`avoid_print` (use `LoggerHelper`; `print()` fails analyze), `unawaited_futures`, `cancel_subscriptions`, `close_sinks` — streams/sinks in MQTT/FCM controllers must be cancelled in `onClose()`.

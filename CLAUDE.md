# CLAUDE.md — Instructions for [CC]

This project is the Flutter boilerplate **rekanara_getx** with **Clean Architecture + GetX**.

---

## REQUIRED: Read the Relevant Skill Before Working on a Task

Before working on any code-related task, read the relevant SKILL.md using the Read tool.

**Skill location:** `.agents/skills/{folder}/SKILL.md`

### Task → Skill Mapping to Read

| Task                                         | Skill to Read                                          |
| -------------------------------------------- | ------------------------------------------------------ |
| Creating a new feature (end-to-end)          | `new-feature/SKILL.md` + `clean-architecture/SKILL.md` |
| Understanding the project structure          | `project-structure/SKILL.md`                           |
| Creating an Entity                           | `entity/SKILL.md`                                      |
| Creating a Repository (abstract/impl)        | `repository/SKILL.md`                                  |
| Creating a UseCase                           | `usecase/SKILL.md`                                     |
| Creating a Model (JSON parsing)              | `model/SKILL.md`                                       |
| Creating an API Service (Dio)                | `api-service/SKILL.md`                                 |
| Creating a Binding (DI)                      | `binding/SKILL.md`                                     |
| Creating a Controller (reactive state)       | `controller-reactive/SKILL.md`                         |
| Creating a Controller (manual update)        | `controller-builder/SKILL.md`                          |
| Creating a Controller (pagination)           | `controller-pagination/SKILL.md`                       |
| Creating a Screen (UI)                       | `screen/SKILL.md`                                      |
| Adding a Route                               | `routing/SKILL.md`                                     |
| Adding a domain service / endpoint           | `environment/SKILL.md`                                 |
| HTTP call / Dio / auth token                 | `networking/SKILL.md`                                  |
| Storing non-sensitive data                   | `storage-get/SKILL.md`                                 |
| Storing sensitive data (tokens)              | `storage-secure/SKILL.md`                              |
| GetX state management                        | `state-management/SKILL.md`                            |
| Using CustomButton / CustomText              | `components-atoms/SKILL.md`                            |
| Using CustomCachedImage / PaginationListView | `components-molecules/SKILL.md`                        |
| Theming / colors / fonts                     | `theme/SKILL.md`                                       |
| Responsive layout                            | `responsive/SKILL.md`                                  |
| Parsing large JSON lists                     | `json-parser/SKILL.md`                                 |
| Firebase FCM / Remote Config                 | `firebase/SKILL.md`                                    |
| MQTT pub/sub                                 | `mqtt/SKILL.md`                                        |
| App lifecycle (resume/pause)                 | `lifecycle/SKILL.md`                                   |
| Local notifications                          | `notifications/SKILL.md`                               |
| Permissions (camera, location, etc.)         | `permissions/SKILL.md`                                 |
| Error handling / Failure types               | `error-handling/SKILL.md`                              |
| Unit test / Mockito                          | `testing/SKILL.md`                                     |
| Logger / Snackbar / Dialog / Rupiah          | `helpers/SKILL.md`                                     |

---

## Core Rules

### Architecture

- **Domain layer** (`lib/domain/`) → MUST NOT import Flutter, Dio, GetX, or storage
- **Infrastructure layer** → implements Domain, may import Dio/GetX/storage
- **Presentation layer** → imports Domain (usecases/entities) + utils, MUST NOT import infrastructure details
- Injection order: `Storage → ApiService → Repository → UseCase → Controller`

### State Management

- Default: `BaseController` + `.obs` + `Obx()` — for almost all screens
- Alternative: `BaseBuilderController` + `update([ids])` + `GetBuilder` — only when targeted updates are needed

### Controller

- Always use `callUseCase()` — no manual try/catch or loading toggles
- `onInit()`: call `super.onInit()` + initial fetch
- `onClose()`: call `super.onClose()` + remove lifecycle callbacks

### Network

- Public endpoints → `DioClient.noAuthClient`
- Private endpoints → `DioClient.authClient(secureStorage)` (automatic Bearer token)
- NO hardcoded URLs — always use `Endpoint.{service}.{action}`

### Storage

- Sensitive data (tokens) → `SecureStorage` (`FlutterSecureStorageImpl`)
- Non-sensitive data → `GetStorage` (`GetStorageImpl`)
- Keys are always constants in `SecureStorageKey` / `StorageValue`

### UI Components

- Text → `CustomText(fontType: FontType.xxx)` (not `Text()`)
- Buttons → `CustomButton()` (not `ElevatedButton()`)
- Images → `CustomCachedImage()` (not `Image.network()`)
- Pagination lists → `PaginationListView<T>()` + `BasePaginationController<T>`

### Error Handling

- Repository: return `Left(ServerFailure(...))` in catch blocks
- `DioException`: check `e.response?.data?['message']` for the server-provided message
- Controller: use `callUseCase()` — errors are automatically shown via snackbar

### Testing

- Every UseCase must have a test in `test/domain/{feature}/usecases/`
- Use `@GenerateMocks([Repository])` + `build_runner`
- Generate: `dart run build_runner build --delete-conflicting-outputs`

---

## Order for Creating a New Feature

```
1. Entity          → lib/domain/{feature}/entities/
2. Repository      → lib/domain/{feature}/repositories/ (abstract)
3. UseCase         → lib/domain/{feature}/usecases/
4. Model           → lib/infrastructure/dal/{feature}/models/
5. ApiService      → lib/infrastructure/dal/services/
6. RepositoryImpl  → lib/infrastructure/dal/{feature}/repositories/
7. Endpoint        → lib/infrastructure/network/url.dart
8. Binding         → lib/infrastructure/navigation/bindings/controllers/
9. Controller      → lib/presentation/{feature}/controllers/
10. Screen         → lib/presentation/{feature}/
11. Route          → routes.dart + navigation.dart
12. Test           → test/domain/{feature}/usecases/
```

---

## Naming Convention

| Type           | File Format                         | Class Format                 |
| -------------- | ----------------------------------- | ---------------------------- |
| Entity         | `{feature}_entity.dart`             | `{Feature}Entity`            |
| Repository     | `{feature}_repository.dart`         | `{Feature}Repository`        |
| RepositoryImpl | `{feature}_repository_impl.dart`    | `{Feature}RepositoryImpl`    |
| UseCase        | `{action}_{feature}_usecase.dart`   | `{Action}{Feature}UseCase`   |
| Model          | `{feature}_model.dart`              | `{Feature}Model`             |
| API Service    | `{feature}_api_service.dart`        | `{Feature}ApiService`        |
| Binding        | `{feature}.controller.binding.dart` | `{Feature}ControllerBinding` |
| Controller     | `{feature}.controller.dart`         | `{Feature}Controller`        |
| Screen         | `{feature}.screen.dart`             | `{Feature}Screen`            |

---

## Important Config Files

| File                                                                          | Purpose                    |
| ----------------------------------------------------------------------------- | -------------------------- |
| `lib/infrastructure/network/url.dart`                                         | Endpoint URL               |
| `lib/infrastructure/network/environments.dart`                                | Multi-env config           |
| `lib/infrastructure/platform/storage/get_storage_impl.dart`                   | `StorageValue` keys        |
| `lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart` | `SecureStorageKey` keys    |
| `lib/infrastructure/navigation/routes.dart`                                   | Route constants            |
| `lib/infrastructure/navigation/navigation.dart`                               | GetPage routes + bindings  |
| `lib/utils/config.dart`                                                       | Enums, ColorData, FontType |

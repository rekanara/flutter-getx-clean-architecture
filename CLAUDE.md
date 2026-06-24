# CLAUDE.md — Instruksi untuk Claude Code

Project ini adalah Flutter boilerplate **zidanfath_codebase** dengan **Clean Architecture + GetX**.

---

## WAJIB: Baca Skill Sebelum Mengerjakan Task

Sebelum mengerjakan task apapun yang berkaitan dengan kode, baca SKILL.md yang relevan menggunakan Read tool.

**Lokasi skills:** `.agents/skills/{folder}/SKILL.md`

### Mapping Task → Skill yang Harus Dibaca

| Task | Skill yang Dibaca |
|---|---|
| Membuat fitur baru (end-to-end) | `new-feature/SKILL.md` + `clean-architecture/SKILL.md` |
| Memahami struktur project | `project-structure/SKILL.md` |
| Membuat Entity | `entity/SKILL.md` |
| Membuat Repository (abstract/impl) | `repository/SKILL.md` |
| Membuat UseCase | `usecase/SKILL.md` |
| Membuat Model (JSON parsing) | `model/SKILL.md` |
| Membuat API Service (Dio) | `api-service/SKILL.md` |
| Membuat Binding (DI) | `binding/SKILL.md` |
| Membuat Controller (reactive state) | `controller-reactive/SKILL.md` |
| Membuat Controller (manual update) | `controller-builder/SKILL.md` |
| Membuat Controller (pagination) | `controller-pagination/SKILL.md` |
| Membuat Screen (UI) | `screen/SKILL.md` |
| Menambah Route | `routing/SKILL.md` |
| Menambah service domain / endpoint | `environment/SKILL.md` |
| HTTP call / Dio / auth token | `networking/SKILL.md` |
| Simpan data non-sensitif | `storage-get/SKILL.md` |
| Simpan data sensitif (token) | `storage-secure/SKILL.md` |
| GetX state management | `state-management/SKILL.md` |
| Pakai CustomButton / CustomText | `components-atoms/SKILL.md` |
| Pakai CustomCachedImage / PaginationListView | `components-molecules/SKILL.md` |
| Theming / warna / font | `theme/SKILL.md` |
| Responsive layout | `responsive/SKILL.md` |
| Parse JSON list besar | `json-parser/SKILL.md` |
| Firebase FCM / Remote Config | `firebase/SKILL.md` |
| MQTT pub/sub | `mqtt/SKILL.md` |
| Lifecycle app (resume/pause) | `lifecycle/SKILL.md` |
| Local notifications | `notifications/SKILL.md` |
| Permission (kamera, lokasi, dll) | `permissions/SKILL.md` |
| Error handling / Failure types | `error-handling/SKILL.md` |
| Unit test / Mockito | `testing/SKILL.md` |
| Logger / Snackbar / Dialog / Rupiah | `helpers/SKILL.md` |

---

## Aturan Utama

### Architecture
- **Domain layer** (`lib/domain/`) → TIDAK boleh import Flutter, Dio, GetX, storage
- **Infrastructure layer** → implements Domain, boleh import Dio/GetX/storage
- **Presentation layer** → import Domain (usecases/entities) + utils, TIDAK import infrastructure detail
- Urutan inject: `Storage → ApiService → Repository → UseCase → Controller`

### State Management
- Default: `BaseController` + `.obs` + `Obx()` — untuk hampir semua screen
- Alternatif: `BaseBuilderController` + `update([ids])` + `GetBuilder` — hanya jika perlu update targeted

### Controller
- Selalu gunakan `callUseCase()` — tidak perlu manual try/catch atau loading toggle
- `onInit()`: panggil `super.onInit()` + fetch awal
- `onClose()`: panggil `super.onClose()` + hapus lifecycle callback

### Network
- Endpoint publik → `DioClient.noAuthClient`
- Endpoint private → `DioClient.authClient(secureStorage)` (Bearer token otomatis)
- TIDAK hardcode URL — selalu gunakan `Endpoint.{service}.{action}`

### Storage
- Data sensitif (token) → `SecureStorage` (`FlutterSecureStorageImpl`)
- Data non-sensitif → `GetStorage` (`GetStorageImpl`)
- Key selalu sebagai constant di `SecureStorageKey` / `StorageValue`

### Komponen UI
- Teks → `CustomText(fontType: FontType.xxx)` (bukan `Text()`)
- Tombol → `CustomButton()` (bukan `ElevatedButton()`)
- Gambar → `CustomCachedImage()` (bukan `Image.network()`)
- List pagination → `PaginationListView<T>()` + `BasePaginationController<T>`

### Error Handling
- Repository: return `Left(ServerFailure(...))` di catch block
- `DioException`: cek `e.response?.data?['message']` untuk pesan dari server
- Controller: gunakan `callUseCase()` — auto handle error ke snackbar

### Testing
- Setiap UseCase harus ada test di `test/domain/{feature}/usecases/`
- Gunakan `@GenerateMocks([Repository])` + `build_runner`
- Generate: `dart run build_runner build --delete-conflicting-outputs`

---

## Urutan Membuat Fitur Baru

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

| Tipe | Format File | Format Class |
|---|---|---|
| Entity | `{feature}_entity.dart` | `{Feature}Entity` |
| Repository | `{feature}_repository.dart` | `{Feature}Repository` |
| RepositoryImpl | `{feature}_repository_impl.dart` | `{Feature}RepositoryImpl` |
| UseCase | `{action}_{feature}_usecase.dart` | `{Action}{Feature}UseCase` |
| Model | `{feature}_model.dart` | `{Feature}Model` |
| API Service | `{feature}_api_service.dart` | `{Feature}ApiService` |
| Binding | `{feature}.controller.binding.dart` | `{Feature}ControllerBinding` |
| Controller | `{feature}.controller.dart` | `{Feature}Controller` |
| Screen | `{feature}.screen.dart` | `{Feature}Screen` |

---

## File Konfigurasi Penting

| File | Fungsi |
|---|---|
| `lib/infrastructure/network/url.dart` | Endpoint URL |
| `lib/infrastructure/network/environments.dart` | Multi-env config |
| `lib/infrastructure/platform/storage/get_storage_impl.dart` | `StorageValue` keys |
| `lib/infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart` | `SecureStorageKey` keys |
| `lib/infrastructure/navigation/routes.dart` | Route constants |
| `lib/infrastructure/navigation/navigation.dart` | GetPage routes + bindings |
| `lib/utils/config.dart` | Enums, ColorData, FontType |

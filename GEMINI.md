# GEMINI.md — Instruksi untuk Gemini CLI

Project ini adalah Flutter boilerplate **zidanfath_codebase** menggunakan **Clean Architecture + GetX**.

---

## Skills — Panduan Teknis

Sebelum mengerjakan task, baca skill yang relevan di `.agents/skills/{folder}/SKILL.md`.

### Mapping Task → Skill

| Task | Baca File |
|---|---|
| Fitur baru (end-to-end) | `.agents/skills/new-feature/SKILL.md` |
| Struktur project | `.agents/skills/project-structure/SKILL.md` |
| Clean Architecture overview | `.agents/skills/clean-architecture/SKILL.md` |
| Buat Entity | `.agents/skills/entity/SKILL.md` |
| Buat Repository | `.agents/skills/repository/SKILL.md` |
| Buat UseCase | `.agents/skills/usecase/SKILL.md` |
| Buat Model (JSON) | `.agents/skills/model/SKILL.md` |
| Buat API Service | `.agents/skills/api-service/SKILL.md` |
| Buat Binding (DI) | `.agents/skills/binding/SKILL.md` |
| Controller reaktif | `.agents/skills/controller-reactive/SKILL.md` |
| Controller manual update | `.agents/skills/controller-builder/SKILL.md` |
| Controller pagination | `.agents/skills/controller-pagination/SKILL.md` |
| Buat Screen (UI) | `.agents/skills/screen/SKILL.md` |
| Routing / navigasi | `.agents/skills/routing/SKILL.md` |
| Environment / Endpoint baru | `.agents/skills/environment/SKILL.md` |
| HTTP / DioClient | `.agents/skills/networking/SKILL.md` |
| GetStorage | `.agents/skills/storage-get/SKILL.md` |
| SecureStorage | `.agents/skills/storage-secure/SKILL.md` |
| GetX state management | `.agents/skills/state-management/SKILL.md` |
| CustomButton / CustomText | `.agents/skills/components-atoms/SKILL.md` |
| CustomCachedImage / PaginationListView | `.agents/skills/components-molecules/SKILL.md` |
| Theme / warna | `.agents/skills/theme/SKILL.md` |
| Responsive UI | `.agents/skills/responsive/SKILL.md` |
| Parse JSON besar | `.agents/skills/json-parser/SKILL.md` |
| Firebase FCM / Remote Config | `.agents/skills/firebase/SKILL.md` |
| MQTT | `.agents/skills/mqtt/SKILL.md` |
| App lifecycle | `.agents/skills/lifecycle/SKILL.md` |
| Local notifications | `.agents/skills/notifications/SKILL.md` |
| Permission | `.agents/skills/permissions/SKILL.md` |
| Error handling | `.agents/skills/error-handling/SKILL.md` |
| Unit testing | `.agents/skills/testing/SKILL.md` |
| Helpers (Logger/Dialog/dll) | `.agents/skills/helpers/SKILL.md` |

---

## Arsitektur

```
lib/
├── domain/           # Pure Dart — entity, repository (abstract), usecase
├── infrastructure/   # impl, model, api service, network, navigation, platform
├── presentation/     # controller, screen, widget
├── components/       # atoms (button, text), molecules (image, pagination)
├── config/           # firebase, mqtt, lifecycle, notifications, error, permissions
└── utils/            # config, json_parser, responsive, helpers
```

**Dependency Rule:**
- `domain/` → tidak import siapapun (pure Dart)
- `infrastructure/` → import `domain/`
- `presentation/` → import `domain/` dan `utils/`

---

## Urutan Implementasi Fitur

```
1.  Entity          lib/domain/{feature}/entities/
2.  Repository      lib/domain/{feature}/repositories/
3.  UseCase         lib/domain/{feature}/usecases/
4.  Model           lib/infrastructure/dal/{feature}/models/
5.  ApiService      lib/infrastructure/dal/services/
6.  RepoImpl        lib/infrastructure/dal/{feature}/repositories/
7.  Endpoint        lib/infrastructure/network/url.dart
8.  Binding         lib/infrastructure/navigation/bindings/controllers/
9.  Controller      lib/presentation/{feature}/controllers/
10. Screen          lib/presentation/{feature}/
11. Route           routes.dart + navigation.dart
12. Test            test/domain/{feature}/usecases/
```

---

## Aturan Penting

- Tidak hardcode URL → gunakan `Endpoint.{service}.{action}`
- Token/sensitif → `SecureStorage` (`SecureStorageKey`)
- Non-sensitif → `GetStorage` (`StorageValue`)
- Text → `CustomText`, Button → `CustomButton`, Image → `CustomCachedImage`
- Error di controller → `callUseCase()`, bukan try/catch manual
- Mock untuk test → `@GenerateMocks([Repo])` + `build_runner`

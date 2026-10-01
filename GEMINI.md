# GEMINI.md — Instructions for Gemini CLI

This project is the Flutter boilerplate **rekanara_getx** using **Clean Architecture + GetX**.

---

## Skills — Technical Guides

Before working on a task, read the relevant skill in `.agents/skills/{folder}/SKILL.md`.

### Task → Skill Mapping

| Task                                   | File to Read                                    |
| -------------------------------------- | ----------------------------------------------- |
| New feature (end-to-end)               | `.agents/skills/new-feature/SKILL.md`           |
| Project structure                      | `.agents/skills/project-structure/SKILL.md`     |
| Clean Architecture overview            | `.agents/skills/clean-architecture/SKILL.md`    |
| Create an Entity                       | `.agents/skills/entity/SKILL.md`                |
| Create a Repository                    | `.agents/skills/repository/SKILL.md`            |
| Create a UseCase                       | `.agents/skills/usecase/SKILL.md`               |
| Create a Model (JSON)                  | `.agents/skills/model/SKILL.md`                 |
| Create an API Service                  | `.agents/skills/api-service/SKILL.md`           |
| Create a Binding (DI)                  | `.agents/skills/binding/SKILL.md`               |
| Reactive controller                    | `.agents/skills/controller-reactive/SKILL.md`   |
| Manual-update controller               | `.agents/skills/controller-builder/SKILL.md`    |
| Pagination controller                  | `.agents/skills/controller-pagination/SKILL.md` |
| Create a Screen (UI)                   | `.agents/skills/screen/SKILL.md`                |
| Routing / navigation                   | `.agents/skills/routing/SKILL.md`               |
| Environment / new Endpoint             | `.agents/skills/environment/SKILL.md`           |
| HTTP / DioClient                       | `.agents/skills/networking/SKILL.md`            |
| GetStorage                             | `.agents/skills/storage-get/SKILL.md`           |
| SecureStorage                          | `.agents/skills/storage-secure/SKILL.md`        |
| GetX state management                  | `.agents/skills/state-management/SKILL.md`      |
| CustomButton / CustomText              | `.agents/skills/components-atoms/SKILL.md`      |
| CustomCachedImage / PaginationListView | `.agents/skills/components-molecules/SKILL.md`  |
| Theme / colors                         | `.agents/skills/theme/SKILL.md`                 |
| Responsive UI                          | `.agents/skills/responsive/SKILL.md`            |
| Parsing large JSON                     | `.agents/skills/json-parser/SKILL.md`           |
| Firebase FCM / Remote Config           | `.agents/skills/firebase/SKILL.md`              |
| MQTT                                   | `.agents/skills/mqtt/SKILL.md`                  |
| App lifecycle                          | `.agents/skills/lifecycle/SKILL.md`             |
| Local notifications                    | `.agents/skills/notifications/SKILL.md`         |
| Permissions                            | `.agents/skills/permissions/SKILL.md`           |
| Error handling                         | `.agents/skills/error-handling/SKILL.md`        |
| Unit testing                           | `.agents/skills/testing/SKILL.md`               |
| Helpers (Logger/Dialog/etc.)           | `.agents/skills/helpers/SKILL.md`               |

---

## Architecture

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

- `domain/` → imports nothing (pure Dart)
- `infrastructure/` → imports `domain/`
- `presentation/` → imports `domain/` and `utils/`

---

## Feature Implementation Order

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

## Key Rules

- No hardcoded URLs → use `Endpoint.{service}.{action}`
- Tokens/sensitive data → `SecureStorage` (`SecureStorageKey`)
- Non-sensitive data → `GetStorage` (`StorageValue`)
- Text → `CustomText`, Button → `CustomButton`, Image → `CustomCachedImage`
- Errors in controllers → `callUseCase()`, not manual try/catch
- Test mocks → `@GenerateMocks([Repo])` + `build_runner`

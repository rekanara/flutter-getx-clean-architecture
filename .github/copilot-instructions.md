# GitHub Copilot Instructions — rekanara_getx

Flutter project: **Clean Architecture + GetX + Dio + Firebase + MQTT**

## Skills Library

Technical guides are in `.agents/skills/{folder}/SKILL.md`. Read before creating code.

### Skill Index

| Folder                   | Topic                                                                |
| ------------------------ | -------------------------------------------------------------------- |
| `new-feature/`           | Step-by-step for creating a new feature (12 steps) — **read first** |
| `project-structure/`     | Folder structure, naming convention                                  |
| `clean-architecture/`    | Layers, dependency rule, Either pattern                               |
| `entity/`                | Domain entity class (pure Dart)                                      |
| `repository/`            | Abstract interface + RepositoryImpl                                  |
| `usecase/`               | UseCase\<T, Params\>, NoParams                                       |
| `model/`                 | extends Entity + fromJson/toJson                                     |
| `api-service/`           | DioClient.noAuthClient vs authClient                                 |
| `binding/`               | DI injection: Storage→Api→Repo→UseCase→Controller                    |
| `controller-reactive/`   | BaseController + .obs + Obx                                          |
| `controller-builder/`    | BaseBuilderController + update([id]) + GetBuilder                    |
| `controller-pagination/` | BasePaginationController\<T\> + appendData                           |
| `screen/`                | GetView\<T\>, Obx vs GetBuilder in UI                                |
| `routing/`               | routes.dart + navigation.dart                                        |
| `environment/`           | .env → EnvironmentConfig → Domain → Endpoint                         |
| `networking/`            | authClient, noAuthClient, refresh token                              |
| `storage-get/`           | GetStorage + StorageValue keys                                       |
| `storage-secure/`        | SecureStorage + SecureStorageKey keys                                |
| `state-management/`      | .obs, Rx types, Obx, GetBuilder, debounce                            |
| `components-atoms/`      | CustomButton, CustomText                                             |
| `components-molecules/`  | CustomCachedImage, PaginationListView\<T\>                           |
| `theme/`                 | RkTheme, colorScheme, changeTheme                                    |
| `responsive/`            | Responsive widget, context.isMobile                                  |
| `json-parser/`           | JsonParser.parseList (isolate >=50 items)                            |
| `firebase/`              | FirebaseMessagingService, RemoteConfigService                        |
| `mqtt/`                  | subscribe, publish, addTopicListener, wildcard                       |
| `lifecycle/`             | addOnResumeCallback, onClose cleanup                                 |
| `notifications/`         | ShowNotificationHelper, NotificationType                             |
| `permissions/`           | PermissionHandler.requestXxx()                                       |
| `error-handling/`        | Failure types, callUseCase, DioException                             |
| `testing/`               | @GenerateMocks, MockRepository, unit test                            |
| `helpers/`               | LoggerHelper, SnackbarHelper, DialogHelper, RupiahHelper             |

---

## Code Rules — Do Not Violate

```dart
// ✅ CORRECT: Endpoint from Endpoint class
final resp = await _client.get(Endpoint.product.list);

// ❌ WRONG: hardcoded URL
final resp = await _client.get('https://api.example.com/products');
```

```dart
// ✅ CORRECT: use callUseCase in controller
await callUseCase(useCase.execute(params), onSuccess: (d) => items.assignAll(d));

// ❌ WRONG: manual try/catch in controller
try {
  final result = await useCase.execute(params);
} catch (e) { /* manual handling */ }
```

```dart
// ✅ CORRECT: Domain entity is pure Dart
class ProductEntity {
  final String id;
  ProductEntity({required this.id});
}

// ❌ WRONG: domain imports Flutter/Dio
import 'package:flutter/material.dart'; // NOT ALLOWED in domain/
```

```dart
// ✅ CORRECT: token in SecureStorage
await secureStorage.write(SecureStorageKey.accessToken, token);

// ❌ WRONG: token in GetStorage (not encrypted)
storage.write('accessToken', token);
```

---

## Layer Structure

```
lib/
├── domain/         ← pure Dart (entity, abstract repo, usecase)
├── infrastructure/ ← impl (model, apiService, repoImpl, network, nav)
├── presentation/   ← UI (controller, screen)
├── components/     ← atoms (button, text), molecules (image, list)
├── config/         ← firebase, mqtt, lifecycle, notifications, error
└── utils/          ← helpers, json_parser, responsive, config enums
```

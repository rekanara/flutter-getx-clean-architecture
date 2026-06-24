# GitHub Copilot Instructions — zidanfath_codebase

Flutter project: **Clean Architecture + GetX + Dio + Firebase + MQTT**

## Skills Library

Panduan teknis ada di `.agents/skills/{folder}/SKILL.md`. Baca sebelum membuat kode.

### Skill Index

| Folder | Topik |
|---|---|
| `new-feature/` | Step-by-step membuat fitur baru (12 langkah) — **baca pertama kali** |
| `project-structure/` | Folder structure, naming convention |
| `clean-architecture/` | Layer, dependency rule, Either pattern |
| `entity/` | Domain entity class (pure Dart) |
| `repository/` | Abstract interface + RepositoryImpl |
| `usecase/` | UseCase\<T, Params\>, NoParams |
| `model/` | extends Entity + fromJson/toJson |
| `api-service/` | DioClient.noAuthClient vs authClient |
| `binding/` | DI injection: Storage→Api→Repo→UseCase→Controller |
| `controller-reactive/` | BaseController + .obs + Obx |
| `controller-builder/` | BaseBuilderController + update([id]) + GetBuilder |
| `controller-pagination/` | BasePaginationController\<T\> + appendData |
| `screen/` | GetView\<T\>, Obx vs GetBuilder di UI |
| `routing/` | routes.dart + navigation.dart |
| `environment/` | .env → EnvironmentConfig → Domain → Endpoint |
| `networking/` | authClient, noAuthClient, refresh token |
| `storage-get/` | GetStorage + StorageValue keys |
| `storage-secure/` | SecureStorage + SecureStorageKey keys |
| `state-management/` | .obs, Rx types, Obx, GetBuilder, debounce |
| `components-atoms/` | CustomButton, CustomText |
| `components-molecules/` | CustomCachedImage, PaginationListView\<T\> |
| `theme/` | RkTheme, colorScheme, changeTheme |
| `responsive/` | Responsive widget, context.isMobile |
| `json-parser/` | JsonParser.parseList (isolate >=50 items) |
| `firebase/` | FirebaseMessagingService, RemoteConfigService |
| `mqtt/` | subscribe, publish, addTopicListener, wildcard |
| `lifecycle/` | addOnResumeCallback, onClose cleanup |
| `notifications/` | ShowNotificationHelper, NotificationType |
| `permissions/` | PermissionHandler.requestXxx() |
| `error-handling/` | Failure types, callUseCase, DioException |
| `testing/` | @GenerateMocks, MockRepository, unit test |
| `helpers/` | LoggerHelper, SnackbarHelper, DialogHelper, RupiahHelper |

---

## Aturan Kode — Jangan Dilanggar

```dart
// ✅ BENAR: Endpoint dari Endpoint class
final resp = await _client.get(Endpoint.product.list);

// ❌ SALAH: hardcode URL
final resp = await _client.get('https://api.example.com/products');
```

```dart
// ✅ BENAR: gunakan callUseCase di controller
await callUseCase(useCase.execute(params), onSuccess: (d) => items.assignAll(d));

// ❌ SALAH: manual try/catch di controller
try {
  final result = await useCase.execute(params);
} catch (e) { /* manual handling */ }
```

```dart
// ✅ BENAR: Domain entity pure Dart
class ProductEntity {
  final String id;
  ProductEntity({required this.id});
}

// ❌ SALAH: domain import Flutter/Dio
import 'package:flutter/material.dart'; // TIDAK BOLEH di domain/
```

```dart
// ✅ BENAR: token di SecureStorage
await secureStorage.write(SecureStorageKey.accessToken, token);

// ❌ SALAH: token di GetStorage (tidak terenkripsi)
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

---
name: Clean Architecture
description: Understanding the layers, dependency rule, and Either<Failure, T> pattern
---
# Skill: Clean Architecture

Guide to principles, flow diagrams, and dependency rules of Clean Architecture in this codebase.

---

## Layer Diagram

```
┌───────────────────────────────────────────────────────────────┐
│  DOMAIN (Pure Dart — no Flutter/Dio/GetX imports)             │
│                                                               │
│  Entity ← Repository (abstract) ← UseCase                     │
└───────────────────────────┬───────────────────────────────────┘
                            │ implements
┌───────────────────────────▼───────────────────────────────────┐
│  INFRASTRUCTURE                                               │
│                                                               │
│  Model (extends Entity) → RepositoryImpl → ApiService → Dio   │
└───────────────────────────┬───────────────────────────────────┘
                            │ injected via Binding
┌───────────────────────────▼───────────────────────────────────┐
│  PRESENTATION                                                 │
│                                                               │
│  Binding → Controller (callUseCase) → Screen (Obx/GetBuilder) │
└───────────────────────────────────────────────────────────────┘
```

---

## Data Flow (Login Example)

```
LoginScreen (UI)
    │
    ▼
LoginController.doLogin()          ← extends BaseController
    │
    ▼
BaseController.callUseCase()       ← Auto loading & error handling
    │
    ▼
LoginUseCase.execute(LoginParams)  ← extends UseCase<UserEntity, LoginParams>
    │
    ▼
AuthRepository.login()             ← Domain Layer (abstract contract)
    │
    ▼
AuthRepositoryImpl.login()         ← Infrastructure Layer
    │  ├─ Token → SecureStorage (encrypted)
    │  └─ User data → call API
    ▼
AuthApiService.login()             ← HTTP call via Dio (noAuthClient)
    │
    ▼
Either<Failure, UserEntity>        ← Response wrapped with Dartz
    │
    ▼
BaseController.callUseCase()       ← fold: Left(error) / Right(success)
```

---

## Dependency Rule

| Layer | Can import | Cannot import |
|---|---|---|
| Domain | Dart core, dartz | Flutter, Dio, GetX, storage, etc. |
| Infrastructure | Domain, Dio, GetX, storage | Presentation |
| Presentation | Domain (usecases/entities), GetX, utils | Infrastructure detail (repository impl) |

---

## Either<Failure, T> Pattern

All use cases and repositories use `Either` from the `dartz` package:

```dart
// Repository (abstract) — domain layer
Future<Either<Failure, UserEntity>> login(String email, String password);

// Repository Impl — infrastructure layer
@override
Future<Either<Failure, UserEntity>> login(String email, String password) async {
  try {
    final response = await apiService.login({'key': email, 'password': password});
    if (response.statusCode == 200) {
      return Right(UserModel.fromJson(response.data['data']));
    }
    return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
  } on DioException catch (e) {
    return Left(ServerFailure(e.message ?? 'Network Error'));
  } catch (e) {
    return Left(ServerFailure('Unexpected Error'));
  }
}

// Controller — presentation layer
await callUseCase(
  loginUseCase.execute(params),
  onSuccess: (user) => Get.offAllNamed(Routes.home),
  // onFailure optional — default: SnackbarHelper.showError()
);
```

---

## Failure Types

```dart
// lib/domain/core/errors/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure([super.message = 'Connection timeout']);
}

class NoConnectionFailure extends Failure {
  NoConnectionFailure([super.message = 'No internet connection']);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([super.message = 'Unauthorized session']);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
```

Add a new failure type if needed by extending `Failure`.

---

## New Feature Checklist

```
[ ] Domain:
    [ ] Entity (lib/domain/{feature}/entities/{feature}_entity.dart)
    [ ] Abstract Repository (lib/domain/{feature}/repositories/{feature}_repository.dart)
    [ ] UseCase (lib/domain/{feature}/usecases/{action}_{feature}_usecase.dart)

[ ] Infrastructure:
    [ ] Model extends Entity (lib/infrastructure/dal/{feature}/models/{feature}_model.dart)
    [ ] API Service (lib/infrastructure/dal/services/{feature}_api_service.dart)
    [ ] Repository Impl (lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart)
    [ ] Endpoint in url.dart
    [ ] .env entry if new service

[ ] Presentation:
    [ ] Controller extends BaseController (lib/presentation/{feature}/controllers/{feature}.controller.dart)
    [ ] Screen extends GetView (lib/presentation/{feature}/{feature}.screen.dart)
    [ ] Binding (lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart)

[ ] Navigation:
    [ ] Route constant in routes.dart
    [ ] GetPage in navigation.dart + binding

[ ] Tests:
    [ ] UseCase test with mock repository
    [ ] (optional) Controller test
```

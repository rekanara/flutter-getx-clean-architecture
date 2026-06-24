# Skill: Clean Architecture

Panduan prinsip, diagram alur, dan dependency rule Clean Architecture di codebase ini.

---

## Diagram Layer

```
┌───────────────────────────────────────────────────────────────┐
│  DOMAIN (Pure Dart — tidak import Flutter/Dio/GetX)           │
│                                                               │
│  Entity ← Repository (abstract) ← UseCase                    │
└───────────────────────────┬───────────────────────────────────┘
                            │ implements
┌───────────────────────────▼───────────────────────────────────┐
│  INFRASTRUCTURE                                               │
│                                                               │
│  Model (extends Entity) → RepositoryImpl → ApiService → Dio  │
└───────────────────────────┬───────────────────────────────────┘
                            │ injected via Binding
┌───────────────────────────▼───────────────────────────────────┐
│  PRESENTATION                                                 │
│                                                               │
│  Binding → Controller (callUseCase) → Screen (Obx/GetBuilder)│
└───────────────────────────────────────────────────────────────┘
```

---

## Alur Data (Login Example)

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
Either<Failure, UserEntity>        ← Response di-wrap dengan Dartz
    │
    ▼
BaseController.callUseCase()       ← fold: Left(error) / Right(success)
```

---

## Dependency Rule

| Layer | Boleh import | Tidak boleh import |
|---|---|---|
| Domain | Dart core, dartz | Flutter, Dio, GetX, storage, dll |
| Infrastructure | Domain, Dio, GetX, storage | Presentation |
| Presentation | Domain (usecases/entities), GetX, utils | Infrastructure detail (repository impl) |

---

## Either<Failure, T> Pattern

Seluruh use case dan repository menggunakan `Either` dari package `dartz`:

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
  // onFailure opsional — default: SnackbarHelper.showError()
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

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
```

Tambahkan failure type baru jika perlu, extend `Failure`.

---

## Checklist Fitur Baru

```
[ ] Domain:
    [ ] Entity (lib/domain/{feature}/entities/{feature}_entity.dart)
    [ ] Repository abstract (lib/domain/{feature}/repositories/{feature}_repository.dart)
    [ ] UseCase (lib/domain/{feature}/usecases/{action}_{feature}_usecase.dart)

[ ] Infrastructure:
    [ ] Model extends Entity (lib/infrastructure/dal/{feature}/models/{feature}_model.dart)
    [ ] API Service (lib/infrastructure/dal/services/{feature}_api_service.dart)
    [ ] Repository Impl (lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart)
    [ ] Endpoint di url.dart
    [ ] .env entry jika service baru

[ ] Presentation:
    [ ] Controller extends BaseController (lib/presentation/{feature}/controllers/{feature}.controller.dart)
    [ ] Screen extends GetView (lib/presentation/{feature}/{feature}.screen.dart)
    [ ] Binding (lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart)

[ ] Navigation:
    [ ] Route constant di routes.dart
    [ ] GetPage di navigation.dart + binding

[ ] Tests:
    [ ] UseCase test dengan mock repository
    [ ] (opsional) Controller test
```

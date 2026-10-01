---
name: UseCase (Domain Layer)
description: Creating UseCases representing single business actions
---
# Skill: UseCase (Domain Layer)

A UseCase represents a single executable business action. It resides in the Domain layer.

---

## UseCase Rules

1. One UseCase = one business action (Single Responsibility)
2. Always extend `UseCase<T, Params>`
3. Only one method: `execute(Params params)`
4. Must not contain parsing, UI, or I/O logic
5. Inject the repository via the constructor

---

## Base Class

```dart
// lib/domain/core/usecases/usecase.dart
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> execute(Params params);
}

class NoParams {}
```

---

## Template: UseCase Without Parameters

Use `NoParams` if there is no input:

```dart
// lib/domain/home/usecases/get_banners_usecase.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/banner_entity.dart';
import '../repositories/home_repository.dart';

class GetBannersUseCase extends UseCase<List<BannerEntity>, NoParams> {
  final HomeRepository repository;
  GetBannersUseCase(this.repository);

  @override
  Future<Either<Failure, List<BannerEntity>>> execute(NoParams params) {
    return repository.getBanners();
  }
}
```

Calling from a controller:
```dart
await callUseCase(
  getBannersUseCase.execute(NoParams()),
  onSuccess: (banners) => this.banners.assignAll(banners),
);
```

---

## Template: UseCase With Parameters

Create a Params class in the same file:

```dart
// lib/domain/auth/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}

class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> execute(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
```

Calling from a controller:
```dart
await callUseCase(
  loginUseCase.execute(LoginParams(email: email, password: password)),
  onSuccess: (user) => Get.offAllNamed(Routes.home),
);
```

---

## Template: UseCase With Complex Params

```dart
class GetProductsParams {
  final int page;
  final int limit;
  final String? search;
  final String? category;

  const GetProductsParams({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.category,
  });
}

class GetProductsUseCase extends UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> execute(GetProductsParams params) {
    return repository.getProducts(
      page: params.page,
      limit: params.limit,
      search: params.search,
      category: params.category,
    );
  }
}
```

---

## Template: UseCase for Pagination

A UseCase that returns `ApiResponse` with metadata:

```dart
class GetProductsParams {
  final PaginationFilter filter;
  GetProductsParams({required this.filter});
}

class GetProductsUseCase extends UseCase<ApiResponse<List<ProductEntity>>, GetProductsParams> {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, ApiResponse<List<ProductEntity>>>> execute(GetProductsParams params) {
    return repository.getProducts(filter: params.filter);
  }
}
```

In a pagination controller:
```dart
@override
Future<void> fetchPage(int page) async {
  final filter = PaginationFilter(page: page, limit: limit);
  await callUseCase(
    getProductsUseCase.execute(GetProductsParams(filter: filter)),
    onSuccess: (response) {
      appendData(
        newItems: response.data ?? [],
        lastPage: response.meta?.lastPage ?? 1,
      );
    },
  );
}
```

---

## File Locations

```
lib/domain/{feature}/usecases/
├── get_{feature}s_usecase.dart      # List
├── get_{feature}_by_id_usecase.dart # Detail
├── create_{feature}_usecase.dart    # Create
├── update_{feature}_usecase.dart    # Update
└── delete_{feature}_usecase.dart    # Delete
```

---

## Checklist

```
[ ] File placed in lib/domain/{feature}/usecases/{action}_{feature}_usecase.dart
[ ] Class extends UseCase<T, Params>
[ ] Params class created in the same file (if parameters are needed)
[ ] Constructor injects only the repository
[ ] execute() method only delegates to the repository
[ ] No try/catch in the UseCase (just delegate)
[ ] Tests written in test/domain/{feature}/usecases/{action}_{feature}_usecase_test.dart
```

# Skill: UseCase (Domain Layer)

UseCase mewakili satu aksi bisnis yang dapat dieksekusi. Berada di Domain layer.

---

## Aturan UseCase

1. Satu UseCase = satu aksi bisnis (Single Responsibility)
2. Selalu extend `UseCase<T, Params>`
3. Hanya satu method: `execute(Params params)`
4. Tidak boleh berisi logic parsing, UI, atau I/O
5. Inject repository melalui constructor

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

## Template: UseCase Tanpa Parameter

Gunakan `NoParams` jika tidak ada input:

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

Dipanggil di controller:
```dart
await callUseCase(
  getBannersUseCase.execute(NoParams()),
  onSuccess: (banners) => this.banners.assignAll(banners),
);
```

---

## Template: UseCase Dengan Parameter

Buat class Params di file yang sama:

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

Dipanggil di controller:
```dart
await callUseCase(
  loginUseCase.execute(LoginParams(email: email, password: password)),
  onSuccess: (user) => Get.offAllNamed(Routes.home),
);
```

---

## Template: UseCase Dengan Params Kompleks

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

## Template: UseCase untuk Pagination

UseCase yang return `ApiResponse` dengan meta:

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

Di controller pagination:
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

## Lokasi File

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
[ ] File di lib/domain/{feature}/usecases/{action}_{feature}_usecase.dart
[ ] Class extends UseCase<T, Params>
[ ] Class Params di file yang sama (jika ada parameter)
[ ] Constructor hanya inject repository
[ ] Method execute() hanya mendelegasikan ke repository
[ ] Tidak ada try/catch di UseCase (cukup delegate)
[ ] Test di test/domain/{feature}/usecases/{action}_{feature}_usecase_test.dart
```

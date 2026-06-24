# Skill: Testing dengan Mockito

Panduan unit test untuk UseCase dan Controller menggunakan Mockito dan build_runner.

---

## Setup

```yaml
# pubspec.yaml — sudah ada
dev_dependencies:
  mockito: ^5.x.x
  build_runner: ^2.x.x
  flutter_test:
    sdk: flutter
```

Generate mocks:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Unit Test UseCase

Struktur: `test/domain/{feature}/usecases/{action}_{feature}_usecase_test.dart`

```dart
// test/domain/product/usecases/get_products_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zidanfath_codebase/domain/core/errors/failures.dart';
import 'package:zidanfath_codebase/domain/core/usecases/usecase.dart';
import 'package:zidanfath_codebase/domain/product/entities/product_entity.dart';
import 'package:zidanfath_codebase/domain/product/repositories/product_repository.dart';
import 'package:zidanfath_codebase/domain/product/usecases/get_products_usecase.dart';

import 'get_products_usecase_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  group('GetProductsUseCase', () {
    final tProducts = [
      ProductEntity(id: '1', name: 'Product A', price: 100, description: '', imageUrl: '', isActive: true),
      ProductEntity(id: '2', name: 'Product B', price: 200, description: '', imageUrl: '', isActive: true),
    ];

    test('should return list of products on success', () async {
      // arrange
      when(mockRepository.getProducts()).thenAnswer((_) async => Right(tProducts));

      // act
      final result = await useCase.execute(NoParams());

      // assert
      expect(result, Right(tProducts));
      verify(mockRepository.getProducts());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure on network error', () async {
      // arrange
      when(mockRepository.getProducts())
          .thenAnswer((_) async => Left(ServerFailure('Network Error')));

      // act
      final result = await useCase.execute(NoParams());

      // assert
      expect(result, Left(ServerFailure('Network Error')));
      verify(mockRepository.getProducts());
    });

    test('should return empty list when data is empty', () async {
      // arrange
      when(mockRepository.getProducts()).thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase.execute(NoParams());

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (products) => expect(products, isEmpty),
      );
    });
  });
}
```

---

## Unit Test UseCase dengan Parameter

```dart
@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tParams = LoginParams(email: 'test@email.com', password: '123456');
  final tUser = UserEntity(
    roleId: '1',
    roleName: 'Admin',
    appsId: 'app1',
    permissionToken: 'perm_token',
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  test('should return UserEntity on success login', () async {
    when(mockRepository.login(any, any)).thenAnswer((_) async => Right(tUser));

    final result = await useCase.execute(tParams);

    expect(result, Right(tUser));
    verify(mockRepository.login(tParams.email, tParams.password));
  });

  test('should return ServerFailure on wrong credentials', () async {
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => Left(ServerFailure('Email atau password salah')));

    final result = await useCase.execute(tParams);

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Email atau password salah'),
      (_) => fail('Expected Left'),
    );
  });
}
```

---

## Unit Test Controller

```dart
// test/presentation/controllers/product_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:zidanfath_codebase/domain/product/usecases/get_products_usecase.dart';
import 'package:zidanfath_codebase/presentation/product/controllers/product.controller.dart';

import 'product_controller_test.mocks.dart';

@GenerateMocks([GetProductsUseCase])
void main() {
  late ProductController controller;
  late MockGetProductsUseCase mockUseCase;

  setUp(() {
    Get.testMode = true;
    mockUseCase = MockGetProductsUseCase();
    controller = ProductController(getProductsUseCase: mockUseCase);
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test('initial state: products is empty, isLoading is false', () {
    expect(controller.products, isEmpty);
    expect(controller.isLoading.value, false);
  });

  test('fetchProducts: should populate products on success', () async {
    final tProducts = [
      ProductEntity(id: '1', name: 'A', price: 100, description: '', imageUrl: '', isActive: true),
    ];

    when(mockUseCase.execute(any)).thenAnswer((_) async => Right(tProducts));

    await controller.fetchProducts();

    expect(controller.products, tProducts);
    expect(controller.isLoading.value, false);
  });

  test('fetchProducts: should set errorMessage on failure', () async {
    when(mockUseCase.execute(any))
        .thenAnswer((_) async => Left(ServerFailure('Network Error')));

    await controller.fetchProducts();

    expect(controller.errorMessage.value, 'Network Error');
    expect(controller.products, isEmpty);
  });
}
```

---

## Contoh Nyata di Codebase

```dart
// test/domain/auth/usecases/login_usecase_test.dart
@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  test('returns UserEntity when login succeeds', () async {
    when(mockAuthRepository.login(any, any))
        .thenAnswer((_) async => Right(tUserEntity));
    final result = await useCase.execute(tParams);
    expect(result, Right(tUserEntity));
  });

  test('returns ServerFailure when login fails', () async {
    when(mockAuthRepository.login(any, any))
        .thenAnswer((_) async => Left(ServerFailure('Invalid credentials')));
    final result = await useCase.execute(tParams);
    expect(result.isLeft(), true);
  });
}
```

---

## Menjalankan Test

```bash
# Semua test
flutter test

# Test spesifik file
flutter test test/domain/product/usecases/get_products_usecase_test.dart

# Test spesifik dengan filter
flutter test --name "should return list"

# Generate mocks setelah tambah @GenerateMocks
dart run build_runner build --delete-conflicting-outputs
```

---

## Checklist

```
[ ] Tambah @GenerateMocks([Repository]) di file test
[ ] Generate mock: dart run build_runner build --delete-conflicting-outputs
[ ] setUp(): buat mock + inject ke usecase/controller
[ ] tearDown(): Get.reset() untuk controller test
[ ] Test naming: 'should [hasil] when [kondisi]'
[ ] Test minimal: success case, failure case, empty case
[ ] verify() untuk cek repository dipanggil dengan benar
[ ] verifyNoMoreInteractions() jika ingin strict check
```

---
name: Binding (Dependency Injection)
description: Wiring dependencies (Storage → ApiService → Repository → UseCase → Controller) for GetX
---
# Skill: Binding (Dependency Injection)

Binding wires all dependencies (storage → api service → repository → usecase → controller) before a screen is displayed.

---

## Binding Rules

1. Extend `Bindings` from GetX
2. Implement `dependencies()` method
3. Inject order: **Storage → ApiService → Repository → UseCase → Controller**
4. Use `Get.lazyPut` for all except the final Controller (use `Get.put`)
5. Register abstract repository with abstract type: `Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(...))`
6. Location: `lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart`

---

## Complete Template

```dart
// lib/infrastructure/navigation/bindings/controllers/product.controller.binding.dart
import 'package:get/get.dart';

import '../../../../domain/product/repositories/product_repository.dart';
import '../../../../domain/product/usecases/get_products_usecase.dart';
import '../../../../domain/product/usecases/get_product_by_id_usecase.dart';
import '../../../../domain/product/usecases/create_product_usecase.dart';
import '../../../../infrastructure/dal/product/repositories/product_repository_impl.dart';
import '../../../../infrastructure/dal/services/product_api_service.dart';
import '../../../../infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart';
import '../../../../presentation/product/controllers/product.controller.dart';

class ProductControllerBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Storage (bottom — no dependencies)
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());

    // 2. ApiService (needs SecureStorage)
    Get.lazyPut<ProductApiService>(
      () => ProductApiService(secureStorage: Get.find()),
    );

    // 3. Repository (needs ApiService)
    //    IMPORTANT: type <ProductRepository> (abstract), not impl
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(apiService: Get.find()),
    );

    // 4. UseCases (needs Repository)
    Get.lazyPut<GetProductsUseCase>(
      () => GetProductsUseCase(Get.find()),
    );
    Get.lazyPut<GetProductByIdUseCase>(
      () => GetProductByIdUseCase(Get.find()),
    );
    Get.lazyPut<CreateProductUseCase>(
      () => CreateProductUseCase(Get.find()),
    );

    // 5. Controller (top — needs UseCase)
    //    Use Get.put instead of lazyPut so the controller is active immediately
    Get.put<ProductController>(
      ProductController(
        getProductsUseCase: Get.find(),
        getProductByIdUseCase: Get.find(),
        createProductUseCase: Get.find(),
      ),
    );
  }
}
```

---

## Real Example in Codebase

```dart
// lib/infrastructure/navigation/bindings/controllers/home.controller.binding.dart
class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());
    Get.lazyPut<HomeApiService>(
      () => HomeApiService(secureStorage: Get.find()),
    );
    Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(apiService: Get.find()),
    );
    Get.lazyPut<GetBannersUseCase>(() => GetBannersUseCase(Get.find()));
    Get.put<HomeController>(HomeController(getBannersUseCase: Get.find()));
  }
}
```

---

## Binding with Non-Secure Storage

If the controller also needs `GetStorageImpl` (e.g., for theme preference):

```dart
class LoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());
    Get.lazyPut<GetStorageImpl>(() => GetStorageImpl()); // ← add this
    Get.lazyPut<AuthApiService>(
      () => AuthApiService(secureStorage: Get.find()),
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        apiService: Get.find(),
        secureStorage: Get.find<FlutterSecureStorageImpl>(),
        storage: Get.find(), // ← GetStorageImpl
      ),
    );
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find()));
    Get.put<LoginController>(LoginController(loginUseCase: Get.find()));
  }
}
```

---

## Register Binding in Navigation

```dart
// lib/infrastructure/navigation/navigation.dart
GetPage(
  name: Routes.product,
  page: () => const ProductScreen(),
  binding: ProductControllerBinding(), // ← register here
),
```

---

## lazyPut vs put

| | `Get.lazyPut` | `Get.put` |
|---|---|---|
| When created | First time `find()` is called | Immediately when binding runs |
| Use for | Lower dependencies (storage, api, repo, usecase) | Final Controller |
| Auto-dispose | Yes (when route is popped) | Yes |

---

## Tip: Get.find() Type Safety

If there are two storage implementations in the same binding, use named tags:

```dart
Get.lazyPut<FlutterSecureStorageImpl>(
  () => FlutterSecureStorageImpl(),
  tag: 'product_secure',
);
// Then retrieve with:
Get.find<FlutterSecureStorageImpl>(tag: 'product_secure');
```

Usually not needed since each binding is scoped separately per route.

---

## Checklist

```
[ ] File in lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart
[ ] Class extends Bindings
[ ] Order: Storage → ApiService → Repository → UseCase → Controller
[ ] Repository is registered with abstract type (domain layer)
[ ] Controller uses Get.put (not lazyPut)
[ ] Binding registered in GetPage in navigation.dart
```

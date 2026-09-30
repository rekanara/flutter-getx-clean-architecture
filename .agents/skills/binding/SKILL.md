# Skill: Binding (Dependency Injection)

Binding meng-wire semua dependency (storage → api service → repository → usecase → controller) sebelum sebuah screen ditampilkan.

---

## Aturan Binding

1. Extend `Bindings` dari GetX
2. Implement `dependencies()` method
3. Urutan inject: **Storage → ApiService → Repository → UseCase → Controller**
4. Gunakan `Get.lazyPut` untuk semua kecuali Controller akhir (gunakan `Get.put`)
5. Daftarkan abstract repository dengan tipe abstract: `Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(...))`
6. Lokasi: `lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart`

---

## Template Lengkap

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
    // 1. Storage (paling bawah — tidak ada dependency)
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());

    // 2. ApiService (butuh SecureStorage)
    Get.lazyPut<ProductApiService>(
      () => ProductApiService(secureStorage: Get.find()),
    );

    // 3. Repository (butuh ApiService)
    //    PENTING: tipe <ProductRepository> (abstract), bukan impl
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(apiService: Get.find()),
    );

    // 4. UseCases (butuh Repository)
    Get.lazyPut<GetProductsUseCase>(
      () => GetProductsUseCase(Get.find()),
    );
    Get.lazyPut<GetProductByIdUseCase>(
      () => GetProductByIdUseCase(Get.find()),
    );
    Get.lazyPut<CreateProductUseCase>(
      () => CreateProductUseCase(Get.find()),
    );

    // 5. Controller (paling atas — butuh UseCase)
    //    Gunakan Get.put bukan lazyPut agar controller langsung aktif
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

## Contoh Nyata di Codebase

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

## Binding dengan Storage Non-Secure

Jika controller juga perlu `GetStorageImpl` (misal untuk theme preference):

```dart
class LoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());
    Get.lazyPut<GetStorageImpl>(() => GetStorageImpl()); // ← tambahkan
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

## Register Binding di Navigation

```dart
// lib/infrastructure/navigation/navigation.dart
GetPage(
  name: Routes.product,
  page: () => const ProductScreen(),
  binding: ProductControllerBinding(), // ← daftarkan di sini
),
```

---

## lazyPut vs put

| | `Get.lazyPut` | `Get.put` |
|---|---|---|
| Kapan dibuat | Saat pertama kali di-`find()` | Langsung saat binding dijalankan |
| Gunakan untuk | Dependencies bawah (storage, api, repo, usecase) | Controller terakhir |
| Auto-dispose | Ya (saat route di-pop) | Ya |

---

## Tips: Get.find() Type Safety

Jika ada dua implementasi storage di binding yang sama, gunakan named tag:

```dart
Get.lazyPut<FlutterSecureStorageImpl>(
  () => FlutterSecureStorageImpl(),
  tag: 'product_secure',
);
// Lalu ambil dengan:
Get.find<FlutterSecureStorageImpl>(tag: 'product_secure');
```

Biasanya tidak diperlukan karena setiap binding scope-nya terpisah per route.

---

## Checklist

```
[ ] File di lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart
[ ] Class extends Bindings
[ ] Urutan: Storage → ApiService → Repository → UseCase → Controller
[ ] Repository didaftarkan dengan tipe abstract (domain layer)
[ ] Controller menggunakan Get.put (bukan lazyPut)
[ ] Binding didaftarkan di GetPage di navigation.dart
```

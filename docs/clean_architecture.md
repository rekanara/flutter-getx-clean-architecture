# Clean Architecture Guide

Panduan step-by-step membuat fitur baru dari awal hingga UI menggunakan Clean Architecture di codebase ini.

---

## Diagram Alur

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
                            │ injected via
┌───────────────────────────▼───────────────────────────────────┐
│  PRESENTATION                                                 │
│                                                               │
│  Binding → Controller (callUseCase) → Screen (Obx/GetBuilder)│
└───────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step: Membuat Fitur "Product"

### Step 1: Entity (Domain Layer)

`lib/domain/product/entities/product_entity.dart`

```dart
class ProductEntity {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}
```

> **Aturan:** Entity TIDAK import package apapun. Hanya field + constructor.

---

### Step 2: Repository Interface (Domain Layer)

`lib/domain/product/repositories/product_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductById(String id);
  Future<Either<Failure, void>> createProduct(ProductEntity product);
}
```

> **Aturan:** Repository di domain adalah `abstract class`. Implementasi ada di infrastructure.

---

### Step 3: UseCase (Domain Layer)

`lib/domain/product/usecases/get_products_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> execute(NoParams params) {
    return repository.getProducts();
  }
}
```

> **Aturan:** Satu UseCase = Satu aksi bisnis. Extend `UseCase<ReturnType, ParamsType>`. Pakai `NoParams` jika tidak ada parameter.

---

### Step 4: Model (Infrastructure Layer)

`lib/infrastructure/dal/product/models/product_model.dart`

```dart
import '../../../../domain/product/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
```

> **Aturan:** Model `extends` Entity dan menambahkan `fromJson` / `toJson`.

---

### Step 5: API Service (Infrastructure Layer)

`lib/infrastructure/dal/services/product_api_service.dart`

```dart
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class ProductApiService {
  final SecureStorage secureStorage;

  ProductApiService({required this.secureStorage});

  Dio get _authClient => DioClient.authClient(secureStorage);

  Future<Response> getProducts() async {
    return await _authClient.get(Endpoint.product.list);
  }

  Future<Response> getProductById(String id) async {
    return await _authClient.get('${Endpoint.product.detail}/$id');
  }

  Future<Response> createProduct(Map<String, dynamic> data) async {
    return await _authClient.post(Endpoint.product.create, data: data);
  }
}
```

> **Ingat:** Tambahkan `Endpoint.product` di `url.dart` (lihat `docs/environment.md`).

---

### Step 6: Repository Implementation (Infrastructure Layer)

`lib/infrastructure/dal/product/repositories/product_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../domain/core/errors/failures.dart';
import '../../../../domain/product/entities/product_entity.dart';
import '../../../../domain/product/repositories/product_repository.dart';
import '../../../../utils/json_parser.dart';
import '../../services/product_api_service.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService apiService;

  ProductRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final response = await apiService.getProducts();
      final data = response.data['data'] as List?;
      if (data != null) {
        final products = await JsonParser.parseList(
          jsonList: data,
          fromJson: ProductModel.fromJson,
        );
        return Right(products);
      }
      return const Right([]);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error'));
    }
  }

  // ... getProductById, createProduct serupa ...
}
```

---

### Step 7: Binding (Dependency Injection)

`lib/infrastructure/navigation/bindings/controllers/product.controller.binding.dart`

```dart
import 'package:get/get.dart';

import '../../../../domain/product/repositories/product_repository.dart';
import '../../../../domain/product/usecases/get_products_usecase.dart';
import '../../../../infrastructure/dal/product/repositories/product_repository_impl.dart';
import '../../../../infrastructure/dal/services/product_api_service.dart';
import '../../../../infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart';
import '../../../../presentation/product/controllers/product.controller.dart';

class ProductControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Urutan: dari paling bawah (storage) ke paling atas (controller)
    Get.lazyPut<FlutterSecureStorageImpl>(() => FlutterSecureStorageImpl());
    Get.lazyPut<ProductApiService>(
      () => ProductApiService(secureStorage: Get.find()),
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(apiService: Get.find()),
    );
    Get.lazyPut<GetProductsUseCase>(() => GetProductsUseCase(Get.find()));

    Get.put<ProductController>(
      ProductController(getProductsUseCase: Get.find()),
    );
  }
}
```

> **Urutan inject:** Storage → ApiService → Repository → UseCase → Controller

---

### Step 8: Controller (Presentation Layer)

`lib/presentation/product/controllers/product.controller.dart`

```dart
import 'package:get/get.dart';
import '../../../domain/core/usecases/usecase.dart';
import '../../../domain/product/entities/product_entity.dart';
import '../../../domain/product/usecases/get_products_usecase.dart';
import '../../core/base_controller.dart';

class ProductController extends BaseController {
  final GetProductsUseCase getProductsUseCase;

  ProductController({required this.getProductsUseCase});

  final products = <ProductEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    await callUseCase(
      getProductsUseCase.execute(NoParams()),
      onSuccess: (data) {
        products.assignAll(data);
      },
    );
  }
}
```

> `callUseCase` dari `BaseController` otomatis handle `isLoading` dan error snackbar.

---

### Step 9: Screen (Presentation Layer)

`lib/presentation/product/product.screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/product.controller.dart';

class ProductScreen extends GetView<ProductController> {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return const Center(child: Text('Belum ada produk'));
        }

        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('Rp ${product.price}'),
            );
          },
        );
      }),
    );
  }
}
```

---

### Step 10: Register Route

`lib/infrastructure/navigation/navigation.dart`

```dart
GetPage(
  name: Routes.product,
  page: () => const ProductScreen(),
  binding: ProductControllerBinding(),
),
```

---

## Checklist Fitur Baru

```
[ ] Domain: Entity
[ ] Domain: Repository (abstract)
[ ] Domain: UseCase
[ ] Infra:  Model (extends Entity + fromJson/toJson)
[ ] Infra:  API Service (Dio calls)
[ ] Infra:  Repository Implementation
[ ] Infra:  Endpoint di url.dart
[ ] Infra:  Binding (DI)
[ ] UI:     Controller (extends BaseController)
[ ] UI:     Screen (GetView + Obx)
[ ] Route:  Register di navigation.dart + routes.dart
```

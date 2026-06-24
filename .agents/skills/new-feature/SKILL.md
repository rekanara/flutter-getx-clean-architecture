# Skill: New Feature — Step-by-Step

Panduan lengkap membuat fitur baru dari awal hingga UI. Ikuti urutan ini agar konsisten dengan arsitektur yang ada.

---

## Urutan Implementasi

```
Step 1: Entity (Domain)
Step 2: Repository Interface (Domain)
Step 3: UseCase (Domain)
Step 4: Model (Infrastructure)
Step 5: API Service (Infrastructure)
Step 6: Repository Implementation (Infrastructure)
Step 7: Endpoint di url.dart + .env
Step 8: Binding (DI)
Step 9: Controller (Presentation)
Step 10: Screen (Presentation)
Step 11: Register Route
Step 12: Unit Test
```

---

## Step 1: Entity

`lib/domain/{feature}/entities/{feature}_entity.dart`

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

**Aturan:** TIDAK boleh import package apapun. Hanya field + constructor.

---

## Step 2: Repository Interface

`lib/domain/{feature}/repositories/{feature}_repository.dart`

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

**Aturan:** Hanya `abstract class`. Implementasi ada di infrastructure.

---

## Step 3: UseCase

`lib/domain/{feature}/usecases/{action}_{feature}_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

// Jika tidak ada params — pakai NoParams
class GetProductsUseCase extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> execute(NoParams params) {
    return repository.getProducts();
  }
}

// Jika ada params — buat class Params
class GetProductByIdParams {
  final String id;
  GetProductByIdParams({required this.id});
}

class GetProductByIdUseCase extends UseCase<ProductEntity, GetProductByIdParams> {
  final ProductRepository repository;
  GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> execute(GetProductByIdParams params) {
    return repository.getProductById(params.id);
  }
}
```

**Aturan:** Satu UseCase = satu aksi bisnis.

---

## Step 4: Model

`lib/infrastructure/dal/{feature}/models/{feature}_model.dart`

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

**Aturan:** Model `extends` Entity. Tambahkan `fromJson` dan `toJson`.

---

## Step 5: API Service

`lib/infrastructure/dal/services/{feature}_api_service.dart`

```dart
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class ProductApiService {
  final SecureStorage secureStorage;
  ProductApiService({required this.secureStorage});

  // Auth client (Bearer token otomatis)
  Dio get _authClient => DioClient.authClient(secureStorage);

  // No auth client (untuk endpoint publik)
  // Dio get _noAuthClient => DioClient.noAuthClient;

  Future<Response> getProducts({Map<String, dynamic>? query}) async {
    return await _authClient.get(Endpoint.product.list, queryParameters: query);
  }

  Future<Response> getProductById(String id) async {
    return await _authClient.get('${Endpoint.product.detail}/$id');
  }

  Future<Response> createProduct(Map<String, dynamic> data) async {
    return await _authClient.post(Endpoint.product.create, data: data);
  }

  Future<Response> updateProduct(String id, Map<String, dynamic> data) async {
    return await _authClient.put('${Endpoint.product.update}/$id', data: data);
  }

  Future<Response> deleteProduct(String id) async {
    return await _authClient.delete('${Endpoint.product.delete}/$id');
  }
}
```

---

## Step 6: Repository Implementation

`lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart`

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
      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          final products = await JsonParser.parseList(
            jsonList: data,
            fromJson: ProductModel.fromJson,
          );
          return Right(products);
        }
        return const Right([]);
      }
      return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return Left(ServerFailure(e.response?.data['message'] ?? 'Server Error'));
      }
      return Left(ServerFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error'));
    }
  }
}
```

---

## Step 7: Endpoint + .env

### .env
```env
NEX_PRODUCT_DEV=https://product-dev.example.com
NEX_PRODUCT_STAGING=https://product-staging.example.com
NEX_PRODUCT_PROD=https://product.example.com
```

### environments.dart — tambah field
```dart
class EnvironmentConfig {
  final String product; // TAMBAH
  // ...
}
// Isi di setiap env config:
product: dotenv.env['NEX_PRODUCT_DEV']!, // DEV
product: dotenv.env['NEX_PRODUCT_STAGING']!, // STAGING
product: dotenv.env['NEX_PRODUCT_PROD']!, // PROD
```

### url.dart — tambah Domain + Endpoint
```dart
class Domain {
  static String get product => '${_cfg.product}${PathSegment.api}${PathSegment.v1}';
}

class Endpoint {
  static final product = _ProductEndpoints();
}

class _ProductEndpoints {
  String get list   => '${Domain.product}/products';
  String get detail => '${Domain.product}/products';
  String get create => '${Domain.product}/products';
  String get update => '${Domain.product}/products';
  String get delete => '${Domain.product}/products';
}
```

---

## Step 8: Binding

`lib/infrastructure/navigation/bindings/controllers/{feature}.controller.binding.dart`

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
    // Urutan: dari bawah (storage) ke atas (controller)
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

**Urutan inject:** Storage → ApiService → Repository → UseCase → Controller

---

## Step 9: Controller

`lib/presentation/{feature}/controllers/{feature}.controller.dart`

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
      onSuccess: (data) => products.assignAll(data),
    );
  }
}
```

---

## Step 10: Screen

`lib/presentation/{feature}/{feature}.screen.dart`

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
            return ListTile(title: Text(product.name));
          },
        );
      }),
    );
  }
}
```

---

## Step 11: Register Route

### routes.dart
```dart
class Routes {
  static const product = '/product';
}
```

### navigation.dart
```dart
GetPage(
  name: Routes.product,
  page: () => const ProductScreen(),
  binding: ProductControllerBinding(),
),
```

### Export di screens.dart (opsional)
```dart
export 'package:zidanfath_codebase/presentation/product/product.screen.dart';
```

---

## Step 12: Unit Test

```dart
@GenerateMocks([ProductRepository])
import 'get_products_usecase_test.mocks.dart';

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  test('should return list on success', () async {
    when(mockRepository.getProducts()).thenAnswer((_) async => Right([]));
    final result = await useCase.execute(NoParams());
    expect(result, isA<Right>());
  });
}
```

Generate mocks:
```bash
dart run build_runner build --delete-conflicting-outputs
```

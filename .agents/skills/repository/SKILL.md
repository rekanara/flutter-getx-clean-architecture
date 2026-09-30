# Skill: Repository (Domain & Infrastructure)

Repository terdiri dari dua bagian: abstract interface di Domain, dan implementasi di Infrastructure.

---

## Bagian 1: Abstract Repository (Domain Layer)

`lib/domain/{feature}/repositories/{feature}_repository.dart`

### Aturan
- Hanya `abstract class`
- Tidak ada implementasi
- Return type selalu `Future<Either<Failure, T>>`
- Import hanya `dartz`, `failures.dart`, dan entity

### Template

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? page,
    int? limit,
    String? search,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required double price,
    required String description,
  });

  Future<Either<Failure, ProductEntity>> updateProduct({
    required String id,
    required String name,
    required double price,
  });

  Future<Either<Failure, void>> deleteProduct(String id);
}
```

---

## Bagian 2: Repository Implementation (Infrastructure Layer)

`lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart`

### Aturan
- `implements` abstract repository dari Domain
- Inject `ApiService` melalui constructor
- Semua method menggunakan try/catch → return `Right` (sukses) atau `Left` (gagal)
- Tangkap `DioException` secara terpisah dari generic `Exception`

### Template

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
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      final response = await apiService.getProducts(query: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data == null) return const Right([]);

        // Gunakan JsonParser untuk data besar (>=50 items pakai isolate)
        final products = await JsonParser.parseList(
          jsonList: data,
          fromJson: ProductModel.fromJson,
        );
        return Right(products);
      }
      return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
    } on DioException catch (e) {
      // Cek pesan error dari response body terlebih dahulu
      final message = e.response?.data?['message'] as String?;
      return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final response = await apiService.getProductById(id);
      if (response.statusCode == 200) {
        return Right(ProductModel.fromJson(response.data['data']));
      }
      return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required double price,
    required String description,
  }) async {
    try {
      final response = await apiService.createProduct({
        'name': name,
        'price': price,
        'description': description,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(ProductModel.fromJson(response.data['data']));
      }
      return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final response = await apiService.deleteProduct(id);
      if (response.statusCode == 200) {
        return const Right(null);
      }
      return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String?;
      return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error: $e'));
    }
  }
}
```

---

## Pattern ApiResponse (untuk endpoint dengan wrapper standar)

Jika API selalu return format `{success, message, data, meta}`, gunakan `ApiResponse`:

```dart
@override
Future<Either<Failure, List<ProductEntity>>> getProducts() async {
  try {
    final response = await apiService.getProducts();
    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJsonList(
        response.data,
        ProductModel.fromJson,
      );
      return Right(apiResponse.data ?? []);
    }
    return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
  } on DioException catch (e) {
    return Left(ServerFailure(e.message ?? 'Network Error'));
  }
}
```

---

## Checklist

```
[ ] Abstract repo di lib/domain/{feature}/repositories/{feature}_repository.dart
[ ] Impl di lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart
[ ] Impl menggunakan `implements` bukan `extends`
[ ] Constructor inject ApiService
[ ] Setiap method: try/catch → Right/Left
[ ] DioException ditangkap terpisah dari catch (e)
[ ] Cek response.data['message'] untuk pesan error dari server
```

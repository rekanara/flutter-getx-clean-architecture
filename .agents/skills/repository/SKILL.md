---
name: Repository (Domain & Infrastructure)
description: Creating abstract repositories and their implementations
---
# Skill: Repository (Domain & Infrastructure)

A Repository consists of two parts: an abstract interface in the Domain layer, and its implementation in the Infrastructure layer.

---

## Part 1: Abstract Repository (Domain Layer)

`lib/domain/{feature}/repositories/{feature}_repository.dart`

### Rules
- Only an `abstract class`
- No implementation
- Return type is always `Future<Either<Failure, T>>`
- Import only `dartz`, `failures.dart`, and entities

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

## Part 2: Repository Implementation (Infrastructure Layer)

`lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart`

### Rules
- `implements` the abstract repository from Domain
- Inject `ApiService` via constructor
- All methods use try/catch → return `Right` (success) or `Left` (failure)
- Catch `DioException` separately from generic `Exception`

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

        // Use JsonParser for large datasets (>=50 items uses isolate)
        final products = await JsonParser.parseList(
          jsonList: data,
          fromJson: ProductModel.fromJson,
        );
        return Right(products);
      }
      return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
    } on DioException catch (e) {
      // Check error message from response body first
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

## ApiResponse Pattern (for endpoints with standard wrappers)

If the API always returns a `{success, message, data, meta}` format, use `ApiResponse`:

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
[ ] Abstract repo in lib/domain/{feature}/repositories/{feature}_repository.dart
[ ] Impl in lib/infrastructure/dal/{feature}/repositories/{feature}_repository_impl.dart
[ ] Impl uses `implements`, not `extends`
[ ] Constructor injects ApiService
[ ] Every method: try/catch → Right/Left
[ ] Catch DioException separately from catch (e)
[ ] Check response.data['message'] for server error messages
```

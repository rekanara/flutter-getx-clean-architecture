---
name: JsonParser
description: Usage of JsonParser for isolate-based parsing
---
# Skill: JsonParser (Isolate Parsing)

`JsonParser` parses JSON lists using Dart isolates (`compute()`) for large lists to prevent blocking the UI thread.

---

## When to Use

| Item Count | Use |
|---|---|
| < 50 | `parseListSync()` or `parseList()` (same, no isolate) |
| >= 50 | `parseList()` — automatically uses `compute()` in an isolate |
| Single object | `parseObject()` |
| Inside isolate | `parseListSync()` (compute() cannot be nested) |

Threshold: `minItemsForIsolate = 50`

---

## parseList — Main Usage (Async)

```dart
// lib/utils/json_parser.dart
// Automatically selects isolate or main thread based on item count

// In RepositoryImpl:
final response = await apiService.getProducts();
if (response.statusCode == 200) {
  final rawList = response.data['data'] as List?;
  if (rawList == null) return const Right([]);

  final products = await JsonParser.parseList(
    jsonList: rawList,
    fromJson: ProductModel.fromJson,  // static function
  );
  return Right(products);
}
```

---

## parseObject — Single Object

```dart
// For a single object — always on the main thread
final rawData = response.data['data'] as Map<String, dynamic>;
final user = JsonParser.parseObject(
  json: rawData,
  fromJson: UserModel.fromJson,
);
return Right(user);
```

---

## parseListSync — Synchronous (Inside Isolate)

```dart
// Use ONLY inside an isolate (compute callback)
// because compute() cannot be nested
static List<T> _parseInIsolate<T>(
  Map<String, dynamic> args,
) {
  final jsonList = args['data'] as List;
  // Must be sync here because we are already in an isolate
  return JsonParser.parseListSync(
    jsonList: jsonList,
    fromJson: ProductModel.fromJson,
  );
}
```

---

## Real Example in Codebase

```dart
// lib/infrastructure/dal/home/repositories/home_repository_impl.dart
@override
Future<Either<Failure, List<BannerEntity>>> getBanners() async {
  try {
    final response = await apiService.getBanners();
    if (response.statusCode == 200) {
      final data = response.data['data'] as List?;
      if (data == null) return const Right([]);

      final banners = await JsonParser.parseList(
        jsonList: data,
        fromJson: BannerModel.fromJson,
      );
      return Right(banners);
    }
    return Left(ServerFailure(response.statusMessage ?? 'Error'));
  } on DioException catch (e) {
    return Left(ServerFailure(e.message ?? 'Network Error'));
  }
}
```

---

## ApiResponse with parseList

```dart
// If using the ApiResponse wrapper
final apiResponse = ApiResponse.fromJsonList(
  response.data,
  ProductModel.fromJson,
);
// ApiResponse.fromJsonList internally uses JsonParser.parseList
final products = apiResponse.data ?? [];
```

---

## Checklist

```
[ ] List from API → parseList() (auto selects isolate if >=50 items)
[ ] Single object → parseObject()
[ ] Inside isolate → parseListSync()
[ ] fromJson must be a static method or top-level function (for compute())
[ ] No need to manually check item counts — JsonParser handles the threshold
```

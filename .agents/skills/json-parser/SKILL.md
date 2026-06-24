# Skill: JsonParser (Isolate Parsing)

`JsonParser` memparse JSON list menggunakan Dart isolate (`compute()`) untuk list besar agar tidak memblokir UI thread.

---

## Kapan Menggunakan

| Jumlah Item | Gunakan |
|---|---|
| < 50 | `parseListSync()` atau `parseList()` (sama saja, tidak pakai isolate) |
| >= 50 | `parseList()` — otomatis pakai `compute()` di isolate |
| Single object | `parseObject()` |
| Di dalam isolate | `parseListSync()` (compute() tidak bisa nested) |

Threshold: `minItemsForIsolate = 50`

---

## parseList — Main Usage (Async)

```dart
// lib/utils/json_parser.dart
// Otomatis pilih isolate atau main thread berdasarkan jumlah item

// Di RepositoryImpl:
final response = await apiService.getProducts();
if (response.statusCode == 200) {
  final rawList = response.data['data'] as List?;
  if (rawList == null) return const Right([]);

  final products = await JsonParser.parseList(
    jsonList: rawList,
    fromJson: ProductModel.fromJson,  // fungsi static
  );
  return Right(products);
}
```

---

## parseObject — Single Object

```dart
// Untuk single object — selalu di main thread
final rawData = response.data['data'] as Map<String, dynamic>;
final user = JsonParser.parseObject(
  json: rawData,
  fromJson: UserModel.fromJson,
);
return Right(user);
```

---

## parseListSync — Synchronous (di dalam isolate)

```dart
// Gunakan HANYA di dalam isolate (compute callback)
// karena compute() tidak bisa nested
static List<T> _parseInIsolate<T>(
  Map<String, dynamic> args,
) {
  final jsonList = args['data'] as List;
  // Di sini harus sync karena kita sudah di dalam isolate
  return JsonParser.parseListSync(
    jsonList: jsonList,
    fromJson: ProductModel.fromJson,
  );
}
```

---

## Contoh Nyata di Codebase

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

## ApiResponse dengan parseList

```dart
// Jika menggunakan ApiResponse wrapper
final apiResponse = ApiResponse.fromJsonList(
  response.data,
  ProductModel.fromJson,
);
// ApiResponse.fromJsonList sudah menggunakan JsonParser.parseList di dalamnya
final products = apiResponse.data ?? [];
```

---

## Checklist

```
[ ] List dari API → parseList() (otomatis pilih isolate jika >=50 items)
[ ] Single object → parseObject()
[ ] Di dalam isolate → parseListSync()
[ ] fromJson harus static method atau top-level function (untuk compute())
[ ] Tidak perlu cek jumlah item manual — JsonParser sudah auto-threshold
```

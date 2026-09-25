# Skill: Networking (DioClient)

Panduan penggunaan DioClient untuk HTTP request, termasuk auth interceptor, refresh token, dan download file.

---

## DioClient Overview

```dart
// lib/infrastructure/network/dio_client.dart

// 3 utilitas utama:
DioClient.noAuthClient                    // Dio tanpa token
DioClient.authClient(secureStorage)       // Dio + Bearer token + auto-refresh
DioClient.download(...)                   // Helper untuk download file
```

---

## noAuthClient — Endpoint Publik

Gunakan untuk endpoint yang **tidak memerlukan** autentikasi:

```dart
class AuthApiService {
  Dio get _client => DioClient.noAuthClient;

  Future<Response> login(Map<String, dynamic> data) async {
    return await _client.post(Endpoint.be.login, data: data);
  }

  Future<Response> getBanners() async {
    return await _client.get(Endpoint.be.banners);
  }
}
```

Saat ini semua endpoint ada di satu namespace: `Endpoint.be.*` (`login`, `refresh`, `banners`, `customerDetail`).

**Fitur noAuthClient:**
- Timeout 30 detik (connect + send + receive)
- TalkerDioLogger (debug mode only)
- ChuckerDioInterceptor (debug mode only)
- TIDAK ada Bearer token

---

## authClient — Endpoint Private

Gunakan untuk endpoint yang **memerlukan** autentikasi:

```dart
class ProductApiService {
  final SecureStorage secureStorage;
  ProductApiService({required this.secureStorage});

  Dio get _client => DioClient.authClient(secureStorage);

  Future<Response> getProducts() async {
    return await _client.get(Endpoint.product.list);
  }
}
```

**Fitur authClient (tambahan dari noAuthClient):**
- Auto-inject `Authorization: Bearer <token>` dari SecureStorage
- Interceptor 401: auto-refresh token via `Endpoint.be.refresh`
  - Jika refresh berhasil: simpan token baru → retry request asli
  - Jika refresh gagal: `secureStorage.deleteAll()` → redirect ke login

---

## Refresh Token Flow

```
Request gagal 401
    │
    ▼
Baca refreshToken dari SecureStorage
    │
    ▼
POST /auth/refresh (menggunakan bare Dio() — sengaja tanpa interceptor agar tidak trigger auth loop)
    ├─ Success (200)
    │   ├─ Simpan accessToken baru ke SecureStorage
    │   └─ Retry request asli dengan token baru
    └─ Failed (401/500)
        ├─ deleteAll() — hapus semua token
        └─ Get.offAllNamed(Routes.login) — force logout
```

---

## HTTP Methods

```dart
final client = DioClient.authClient(secureStorage);

// GET
final response = await client.get(
  Endpoint.product.list,
  queryParameters: {'page': 1, 'limit': 10},
);

// POST
final response = await client.post(
  Endpoint.product.create,
  data: {'name': 'Product A', 'price': 100.0},
);

// PUT
final response = await client.put(
  '${Endpoint.product.update}/$id',
  data: {'name': 'Updated Name'},
);

// PATCH
final response = await client.patch(
  '${Endpoint.product.update}/$id',
  data: {'is_active': false},
);

// DELETE
final response = await client.delete('${Endpoint.product.delete}/$id');

// Multipart/FormData
final formData = FormData.fromMap({
  'name': 'Product A',
  'image': await MultipartFile.fromFile(filePath, filename: 'product.jpg'),
});
final response = await client.post(Endpoint.product.create, data: formData);
```

---

## Download File

```dart
// Di ApiService atau Repository
await DioClient.download(
  url: 'https://example.com/file.pdf',
  savePath: '/storage/downloads/file.pdf',
  secureStorage: secureStorage,  // pass null jika tidak butuh auth
  onReceiveProgress: (received, total) {
    final progress = (received / total * 100).toStringAsFixed(0);
    print('Download: $progress%');
  },
);
```

---

## Error Handling di RepositoryImpl

Pola standar untuk handle DioException:

```dart
try {
  final response = await apiService.getProducts();
  if (response.statusCode == 200) {
    return Right(...);
  }
  return Left(ServerFailure(response.statusMessage ?? 'Error'));
} on DioException catch (e) {
  // Cek response body untuk pesan error dari server
  final message = e.response?.data?['message'] as String?;
  return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
} catch (e) {
  return Left(ServerFailure('Unexpected Error: $e'));
}
```

---

## Response Format Standar

API selalu mengembalikan format:
```json
{
  "success": true,
  "message": "OK",
  "data": { ... },       // atau array
  "meta": {              // untuk pagination
    "current_page": 1,
    "last_page": 5,
    "per_page": 10,
    "total": 48
  }
}
```

Parse dengan `ApiResponse`:
```dart
// Single object
final apiResponse = ApiResponse.fromJson(
  response.data,
  (data) => ProductModel.fromJson(data),
);
final product = apiResponse.data; // ProductModel?

// List
final apiResponse = ApiResponse.fromJsonList(
  response.data,
  ProductModel.fromJson,
);
final products = apiResponse.data; // List<ProductModel>?
final lastPage = apiResponse.meta?.lastPage; // int?
```

---

## Logging & Inspector

- **TalkerDioLogger**: log request/response ke console (debug only)
- **ChuckerDioInterceptor**: HTTP inspector UI yang bisa diakses dengan shake gesture (debug only)

Keduanya otomatis aktif di debug, tidak aktif di release.

---

## Checklist

```
[ ] Endpoint publik → noAuthClient
[ ] Endpoint private → authClient(secureStorage)
[ ] Tidak hardcode URL — gunakan Endpoint.x.y
[ ] Error handling: DioException catch terpisah
[ ] Ambil pesan error dari e.response?.data?['message']
[ ] Download file menggunakan DioClient.download()
[ ] Tidak ada manual Bearer token injection (sudah di authClient)
```

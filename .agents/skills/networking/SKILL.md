---
name: Networking (DioClient)
description: HTTP requests, interceptors, refresh tokens, file downloads
---
# Skill: Networking (DioClient)

Guide to using DioClient for HTTP requests, including auth interceptors, refresh tokens, and file downloads.

---

## DioClient Overview

```dart
// lib/infrastructure/network/dio_client.dart

// 3 main utilities:
DioClient.noAuthClient                    // Dio without tokens
DioClient.authClient(secureStorage)       // Dio + Bearer token + auto-refresh
DioClient.download(...)                   // Helper for file downloads
```

---

## noAuthClient — Public Endpoints

Use for endpoints that **do not require** authentication:

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

Currently, all endpoints are in one namespace: `Endpoint.be.*` (`login`, `refresh`, `banners`, `customerDetail`).

**noAuthClient Features:**
- 30-second timeout (connect + send + receive)
- TalkerDioLogger (debug mode only)
- ChuckerDioInterceptor (debug mode only)
- NO Bearer token

---

## authClient — Private Endpoints

Use for endpoints that **require** authentication:

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

**authClient Features (in addition to noAuthClient):**
- Auto-inject `Authorization: Bearer <token>` from SecureStorage
- 401 Interceptor: auto-refresh token via `Endpoint.be.refresh`
  - If refresh succeeds: saves new tokens → retries original request
  - If refresh fails: `secureStorage.deleteAll()` → redirects to login

---

## Refresh Token Flow

```
Request fails 401
    │
    ▼
Read refreshToken from SecureStorage
    │
    ▼
POST /auth/refresh (using a bare Dio() — intentionally without interceptors to avoid auth loops)
    ├─ Success (200)
    │   ├─ Save new accessToken to SecureStorage
    │   └─ Retry original request with the new token
    └─ Failed (401/500)
        ├─ deleteAll() — delete all tokens
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

## File Downloads

```dart
// In ApiService or Repository
await DioClient.download(
  url: 'https://example.com/file.pdf',
  savePath: '/storage/downloads/file.pdf',
  secureStorage: secureStorage,  // pass null if no auth needed
  onReceiveProgress: (received, total) {
    final progress = (received / total * 100).toStringAsFixed(0);
    print('Download: $progress%');
  },
);
```

---

## Error Handling in RepositoryImpl

Standard pattern for handling DioExceptions:

```dart
try {
  final response = await apiService.getProducts();
  if (response.statusCode == 200) {
    return Right(...);
  }
  return Left(ServerFailure(response.statusMessage ?? 'Error'));
} on DioException catch (e) {
  // Check response body for server error messages
  final message = e.response?.data?['message'] as String?;
  return Left(ServerFailure(message ?? e.message ?? 'Network Error'));
} catch (e) {
  return Left(ServerFailure('Unexpected Error: $e'));
}
```

---

## Standard Response Format

The API always returns this format:
```json
{
  "success": true,
  "message": "OK",
  "data": { ... },       // or an array
  "meta": {              // for pagination
    "current_page": 1,
    "last_page": 5,
    "per_page": 10,
    "total": 48
  }
}
```

Parse with `ApiResponse`:
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

- **TalkerDioLogger**: logs requests/responses to the console (debug only)
- **ChuckerDioInterceptor**: HTTP inspector UI accessible via shake gesture (debug only)

Both are automatically active in debug mode and disabled in release.

---

## Checklist

```
[ ] Public endpoints → noAuthClient
[ ] Private endpoints → authClient(secureStorage)
[ ] Do not hardcode URLs — use Endpoint.x.y
[ ] Error handling: Catch DioExceptions separately
[ ] Extract error messages from e.response?.data?['message']
[ ] Download files using DioClient.download()
[ ] No manual Bearer token injection (already handled by authClient)
```

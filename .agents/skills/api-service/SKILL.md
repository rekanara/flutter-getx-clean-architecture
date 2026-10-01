---
name: API Service (Infrastructure)
description: Rules and templates for creating an API Service using DioClient in the infrastructure layer
---
# Skill: API Service (Infrastructure Layer)

API Service is responsible for making HTTP calls using Dio. Located in the Infrastructure layer.

---

## API Service Rules

1. Inject `SecureStorage` via constructor (required for `authClient`)
2. Use `DioClient.noAuthClient` for public endpoints (login, register)
3. Use `DioClient.authClient(secureStorage)` for endpoints that require a Bearer token
4. Endpoints are taken from `Endpoint.{feature}.{action}` (DO NOT hardcode URLs)
5. Location: `lib/infrastructure/dal/services/{feature}_api_service.dart`

---

## Auth Client Template (with token)

```dart
// lib/infrastructure/dal/services/product_api_service.dart
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class ProductApiService {
  final SecureStorage secureStorage;

  ProductApiService({required this.secureStorage});

  // authClient auto-injects Bearer token from SecureStorage
  // authClient also auto-refreshes token on 401
  Dio get _client => DioClient.authClient(secureStorage);

  Future<Response> getProducts({Map<String, dynamic>? query}) async {
    return await _client.get(
      Endpoint.product.list,
      queryParameters: query,
    );
  }

  Future<Response> getProductById(String id) async {
    return await _client.get('${Endpoint.product.detail}/$id');
  }

  Future<Response> createProduct(Map<String, dynamic> data) async {
    return await _client.post(Endpoint.product.create, data: data);
  }

  Future<Response> updateProduct(String id, Map<String, dynamic> data) async {
    return await _client.put('${Endpoint.product.update}/$id', data: data);
  }

  Future<Response> deleteProduct(String id) async {
    return await _client.delete('${Endpoint.product.delete}/$id');
  }
}
```

---

## No Auth Client Template (public endpoint)

```dart
// Real example (simplified) — lib/infrastructure/dal/services/auth_api_service.dart
class AuthApiService {
  final SecureStorage secureStorage;

  AuthApiService({required this.secureStorage});

  // noAuthClient does not inject a token
  final Dio _noAuthClient = DioClient.noAuthClient;

  // authClient for endpoints that need a token (e.g., getUserProfile)
  Dio get _authClient => DioClient.authClient(secureStorage);

  Future<Response> login(Map<String, dynamic> data) async {
    return await _noAuthClient.post(Endpoint.be.login, data: data);
  }

  Future<Response> getUserProfile() async {
    return await _authClient.get(Endpoint.be.customerDetail);
  }
}
```

Currently, there is only one endpoint namespace: `Endpoint.be` (see `environment/SKILL.md`). `Endpoint.product`/etc. in other skills are pattern examples for adding a new service, not existing ones.

---

## Template with FormData (multipart)

```dart
Future<Response> uploadProductImage(String id, String filePath) async {
  final formData = FormData.fromMap({
    'image': await MultipartFile.fromFile(filePath, filename: 'product.jpg'),
  });
  return await _client.post(
    '${Endpoint.product.uploadImage}/$id',
    data: formData,
  );
}
```

---

## Template with Pagination Query

```dart
Future<Response> getProducts({
  required int page,
  required int limit,
  String? search,
  String? category,
}) async {
  return await _client.get(
    Endpoint.product.list,
    queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
    },
  );
}
```

---

## Download File

```dart
// Using DioClient.download() static helper
Future<void> downloadReport(String url, String savePath) async {
  await DioClient.download(
    url: url,
    savePath: savePath,
    secureStorage: secureStorage, // null if auth is not needed
  );
}
```

---

## Differences between noAuthClient and authClient

| | `noAuthClient` | `authClient(secureStorage)` |
|---|---|---|
| Bearer token | No | Automatically injects from SecureStorage |
| Refresh token | No | Automatically refreshes on 401 |
| Force logout | No | Yes, if refresh fails |
| Use for | Login, register, public | All private endpoints |
| Timeout | 30 seconds | 30 seconds |
| Logger | Yes (debug only) | Yes (debug only) |
| Chucker | Yes (debug only) | Yes (debug only) |

---

## Checklist

```
[ ] File in lib/infrastructure/dal/services/{feature}_api_service.dart
[ ] Inject SecureStorage via constructor
[ ] Use noAuthClient for public endpoints
[ ] Use authClient for private endpoints
[ ] Endpoint from Endpoint.{feature}.{action} (do not hardcode URL)
[ ] Method returns Future<Response>
[ ] No try/catch in ApiService (catch in RepositoryImpl)
```

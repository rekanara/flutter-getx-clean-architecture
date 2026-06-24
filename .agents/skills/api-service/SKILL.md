# Skill: API Service (Infrastructure Layer)

API Service bertugas melakukan HTTP call menggunakan Dio. Berada di Infrastructure layer.

---

## Aturan API Service

1. Inject `SecureStorage` melalui constructor (diperlukan untuk `authClient`)
2. Gunakan `DioClient.noAuthClient` untuk endpoint publik (login, register)
3. Gunakan `DioClient.authClient(secureStorage)` untuk endpoint yang butuh Bearer token
4. Endpoint diambil dari `Endpoint.{feature}.{action}` (TIDAK hardcode URL)
5. Lokasi: `lib/infrastructure/dal/services/{feature}_api_service.dart`

---

## Template Auth Client (dengan token)

```dart
// lib/infrastructure/dal/services/product_api_service.dart
import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../network/url.dart';
import '../../platform/secure_storage/secure_storage.dart';

class ProductApiService {
  final SecureStorage secureStorage;

  ProductApiService({required this.secureStorage});

  // authClient auto-inject Bearer token dari SecureStorage
  // authClient juga auto-refresh token saat 401
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

## Template No Auth Client (endpoint publik)

```dart
// Gunakan noAuthClient untuk endpoint yang TIDAK butuh token
class AuthApiService {
  final SecureStorage secureStorage;

  AuthApiService({required this.secureStorage});

  // noAuthClient tidak inject token
  Dio get _noAuthClient => DioClient.noAuthClient;

  // authClient untuk endpoint yang perlu token (misal: getUserProfile)
  Dio get _authClient => DioClient.authClient(secureStorage);

  Future<Response> login(Map<String, dynamic> data) async {
    return await _noAuthClient.post(Endpoint.sso.login, data: data);
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _noAuthClient.post(Endpoint.sso.register, data: data);
  }

  Future<Response> getUserProfile() async {
    return await _authClient.get(Endpoint.sso.profile);
  }
}
```

---

## Template dengan FormData (multipart)

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

## Template dengan Pagination Query

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
// Menggunakan DioClient.download() static helper
Future<void> downloadReport(String url, String savePath) async {
  await DioClient.download(
    url: url,
    savePath: savePath,
    secureStorage: secureStorage, // null jika tidak butuh auth
  );
}
```

---

## Perbedaan noAuthClient vs authClient

| | `noAuthClient` | `authClient(secureStorage)` |
|---|---|---|
| Bearer token | Tidak | Otomatis inject dari SecureStorage |
| Refresh token | Tidak | Otomatis refresh saat 401 |
| Force logout | Tidak | Ya, jika refresh gagal |
| Gunakan untuk | Login, register, publik | Semua endpoint private |
| Timeout | 30 detik | 30 detik |
| Logger | Ya (debug only) | Ya (debug only) |
| Chucker | Ya (debug only) | Ya (debug only) |

---

## Checklist

```
[ ] File di lib/infrastructure/dal/services/{feature}_api_service.dart
[ ] Inject SecureStorage via constructor
[ ] Gunakan noAuthClient untuk endpoint publik
[ ] Gunakan authClient untuk endpoint private
[ ] Endpoint dari Endpoint.{feature}.{action} (tidak hardcode URL)
[ ] Method return Future<Response>
[ ] Tidak ada try/catch di ApiService (tangkap di RepositoryImpl)
```

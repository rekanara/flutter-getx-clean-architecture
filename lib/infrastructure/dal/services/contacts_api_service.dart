import 'package:dio/dio.dart';

import '../../network/dio_client.dart';
import '../models/pagination_filter.dart';

/// API service contoh — sengaja memanggil API publik ([dummyjson.com](https://dummyjson.com))
/// alih-alih `Endpoint.be` (backend utama project), murni untuk membuktikan
/// pola pagination end-to-end (`PaginationFilter` -> `BasePaginationController`
/// -> `PaginationListView`) tanpa bergantung ke backend privat.
///
/// Saat mengintegrasikan API sungguhan, ganti `_baseUrl` dengan
/// `Domain.be` (atau domain lain di `url.dart`) seperti pada `HomeApiService`.
class ContactsApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  Dio get _noAuthClient => DioClient.noAuthClient;

  Future<Response> getContacts(PaginationFilter filter) async {
    final skip = (filter.page - 1) * filter.limit;

    if (filter.search != null && filter.search!.isNotEmpty) {
      return _noAuthClient.get(
        '$_baseUrl/users/search',
        queryParameters: {
          'q': filter.search,
          'limit': filter.limit,
          'skip': skip,
        },
      );
    }

    return _noAuthClient.get(
      '$_baseUrl/users',
      queryParameters: {'limit': filter.limit, 'skip': skip},
    );
  }
}

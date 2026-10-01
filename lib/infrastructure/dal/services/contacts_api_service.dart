import 'package:dio/dio.dart';

import '../../network/dio_client.dart';
import '../models/pagination_filter.dart';

/// Example API service — intentionally calling public API ([dummyjson.com](https://dummyjson.com))
/// instead of `Endpoint.be` (main project backend), purely to demonstrate
/// the end-to-end pagination pattern (`PaginationFilter` -> `BasePaginationController`
/// -> `PaginationListView`) without depending on a private backend.
///
/// When integrating a real API, replace `_baseUrl` with
/// `Domain.be` (or another domain in `url.dart`) like in `HomeApiService`.
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

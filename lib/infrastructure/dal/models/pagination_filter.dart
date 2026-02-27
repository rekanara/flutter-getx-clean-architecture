/// Model standard untuk mengirim filter ke API saat melakukan pagination.
///
/// Biasa di-passing ke UseCase sebagai parameter.
class PaginationFilter {
  final int page;
  final int limit;
  final String? search;

  const PaginationFilter({this.page = 1, this.limit = 15, this.search});

  /// Convert to Json/QueryParameters untuk Dio
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search!.isNotEmpty) {
      map['search'] = search;
    }

    return map;
  }

  /// Copy with helper
  PaginationFilter copyWith({int? page, int? limit, String? search}) {
    return PaginationFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
    );
  }
}

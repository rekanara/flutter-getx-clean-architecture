/// Generic API response wrapper.
///
/// Standarisasi parsing response dari backend yang mengikuti format:
/// ```json
/// {
///   "success": true,
///   "message": "...",
///   "data": { ... }
/// }
/// ```
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final PaginationMeta? meta;

  ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.statusCode,
    this.meta,
  });

  /// Parse dari JSON map.
  ///
  /// [fromJson] digunakan untuk parse field `data` menjadi tipe [T].
  /// Jika `data` adalah List, gunakan [ApiResponse.fromJsonList].
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message']?.toString(),
      data: json['data'] != null ? fromJson(json['data']) : null,
    );
  }

  /// Parse dari JSON map dimana field `data` adalah List.
  static ApiResponse<List<T>> fromJsonList<T>(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJson,
  ) {
    final dataList = json['data'] as List?;
    final metaJson = json['meta'] as Map<String, dynamic>?;

    return ApiResponse<List<T>>(
      success: json['success'] ?? true,
      message: json['message']?.toString(),
      data: dataList?.map((e) => fromJson(e)).toList(),
      meta: metaJson != null ? PaginationMeta.fromJson(metaJson) : null,
    );
  }

  /// Apakah response menunjukkan error.
  bool get isError => !success;
}

/// Standarisasi Pagination Meta dari backend.
/// Sesuaikan field keys jika nama dari backend berbeda.
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      lastPage: json['last_page'] ?? json['total_pages'] ?? 1,
      perPage: json['per_page'] ?? json['limit'] ?? 15,
      total: json['total'] ?? json['total_data'] ?? 0,
    );
  }
}

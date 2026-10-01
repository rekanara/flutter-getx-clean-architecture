/// Generic API response wrapper.
///
/// Standardizes parsing responses from backend that follow this format:
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

  /// Parse from JSON map.
  ///
  /// [fromJson] is used to parse the `data` field into type [T].
  /// If `data` is a List, use [ApiResponse.fromJsonList].
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

  /// Parse from JSON map where the `data` field is a List.
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

  /// Whether the response indicates an error.
  bool get isError => !success;
}

/// Standardization of Pagination Meta from backend.
/// Adjust field keys if names from backend are different.
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

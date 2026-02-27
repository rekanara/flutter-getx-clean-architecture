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

  ApiResponse({this.data, this.message, this.success = true, this.statusCode});

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
    return ApiResponse<List<T>>(
      success: json['success'] ?? true,
      message: json['message']?.toString(),
      data: dataList?.map((e) => fromJson(e)).toList(),
    );
  }

  /// Apakah response menunjukkan error.
  bool get isError => !success;
}

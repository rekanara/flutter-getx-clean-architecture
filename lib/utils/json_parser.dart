import 'package:flutter/foundation.dart';

/// Utility untuk parsing JSON berat menggunakan **Isolate** (`compute()`).
///
/// Menghindari jank pada Main Thread saat me-parse response API berukuran besar.
///
/// **Cara pakai:**
/// ```dart
/// // Parse list
/// final banners = await JsonParser.parseList(
///   jsonList: response.data['data'],
///   fromJson: BannerModel.fromJson,
/// );
///
/// // Parse single object
/// final user = await JsonParser.parseObject(
///   json: response.data['data'],
///   fromJson: UserModel.fromJson,
/// );
/// ```
///
/// **Threshold:**
/// - Jika jumlah item < [minItemsForIsolate], parsing dilakukan di Main Thread
///   (overhead isolate lebih besar dari benefit-nya untuk list kecil).
class JsonParser {
  JsonParser._();

  /// Minimum item count sebelum menggunakan Isolate.
  /// List < threshold → parse di Main Thread (lebih cepat).
  static const int minItemsForIsolate = 50;

  // ═══════════════════════════════════════════════════════════
  //  PARSE LIST
  // ═══════════════════════════════════════════════════════════

  /// Parse JSON List menjadi `List<T>` menggunakan Isolate jika data besar.
  ///
  /// [jsonList] — raw List<dynamic> dari response API.
  /// [fromJson] — factory constructor, e.g. `BannerModel.fromJson`.
  static Future<List<T>> parseList<T>({
    required List<dynamic> jsonList,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    // Data kecil → parse di Main Thread
    if (jsonList.length < minItemsForIsolate) {
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    // Data besar → parse di Isolate
    return compute(
      _parseListInIsolate<T>,
      _ParseListPayload<T>(jsonList: jsonList, fromJson: fromJson),
    );
  }

  /// Fungsi top-level yang dijalankan di Isolate untuk parse list.
  static List<T> _parseListInIsolate<T>(_ParseListPayload<T> payload) {
    return payload.jsonList
        .map((e) => payload.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  //  PARSE SINGLE OBJECT
  // ═══════════════════════════════════════════════════════════

  /// Parse single JSON Map menjadi object `T`.
  ///
  /// Selalu di Main Thread (overhead isolate tidak worth it untuk single object).
  static T parseObject<T>({
    required Map<String, dynamic> json,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return fromJson(json);
  }

  // ═══════════════════════════════════════════════════════════
  //  PARSE LIST SYNC (Main Thread only)
  // ═══════════════════════════════════════════════════════════

  /// Versi synchronous — selalu di Main Thread.
  /// Gunakan jika yakin data kecil atau di dalam Isolate lain.
  static List<T> parseListSync<T>({
    required List<dynamic> jsonList,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// Payload container untuk dikirim ke Isolate.
/// Harus top-level atau static agar bisa digunakan oleh `compute()`.
class _ParseListPayload<T> {
  final List<dynamic> jsonList;
  final T Function(Map<String, dynamic> json) fromJson;

  _ParseListPayload({required this.jsonList, required this.fromJson});
}

import 'package:flutter/foundation.dart';

/// Utility for parsing heavy JSON using **Isolate** (`compute()`).
///
/// Avoids jank on Main Thread when parsing large API responses.
///
/// **Usage:**
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
/// - If item count < [minItemsForIsolate], parsing is done on Main Thread
///   (isolate overhead is greater than its benefit for small lists).
class JsonParser {
  JsonParser._();

  /// Minimum item count before using Isolate.
  /// List < threshold → parse on Main Thread (faster).
  static const int minItemsForIsolate = 50;

  // ═══════════════════════════════════════════════════════════
  //  PARSE LIST
  // ═══════════════════════════════════════════════════════════

  /// Parse JSON List to `List<T>` using Isolate if data is large.
  ///
  /// [jsonList] — raw `List<dynamic>` from API response.
  /// [fromJson] — factory constructor, e.g. `BannerModel.fromJson`.
  static Future<List<T>> parseList<T>({
    required List<dynamic> jsonList,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    // Small data → parse on Main Thread
    if (jsonList.length < minItemsForIsolate) {
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    // Large data → parse on Isolate
    return compute(
      _parseListInIsolate<T>,
      _ParseListPayload<T>(jsonList: jsonList, fromJson: fromJson),
    );
  }

  /// Top-level function running in Isolate to parse list.
  static List<T> _parseListInIsolate<T>(_ParseListPayload<T> payload) {
    return payload.jsonList
        .map((e) => payload.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  //  PARSE SINGLE OBJECT
  // ═══════════════════════════════════════════════════════════

  /// Parse single JSON Map to object `T`.
  ///
  /// Always on Main Thread (isolate overhead is not worth it for single object).
  static T parseObject<T>({
    required Map<String, dynamic> json,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return fromJson(json);
  }

  // ═══════════════════════════════════════════════════════════
  //  PARSE LIST SYNC (Main Thread only)
  // ═══════════════════════════════════════════════════════════

  /// Synchronous version — always on Main Thread.
  /// Use if certain data is small or inside another Isolate.
  static List<T> parseListSync<T>({
    required List<dynamic> jsonList,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// Payload container to be sent to Isolate.
/// Must be top-level or static to be used by `compute()`.
class _ParseListPayload<T> {
  final List<dynamic> jsonList;
  final T Function(Map<String, dynamic> json) fromJson;

  _ParseListPayload({required this.jsonList, required this.fromJson});
}

class DateTimeHelper {
  /// Convert Unix timestamp (dalam detik) ke DateTime UTC
  static DateTime fromUnixToUtc(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
  }

  /// Convert Unix timestamp (dalam detik) ke DateTime lokal
  static DateTime fromUnixToLocal(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    ).toLocal();
  }

  /// Convert DateTime ke Unix timestamp (detik)
  static int toUnix(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// Format cepat ke string (misalnya `yyyy-MM-dd HH:mm:ss`)
  static String format(DateTime dateTime) {
    return "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

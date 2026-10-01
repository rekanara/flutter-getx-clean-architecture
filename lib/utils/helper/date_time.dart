class DateTimeHelper {
  /// Convert Unix timestamp (in seconds) to DateTime UTC
  static DateTime fromUnixToUtc(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
  }

  /// Convert Unix timestamp (in seconds) to local DateTime
  static DateTime fromUnixToLocal(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
      timestamp * 1000,
      isUtc: true,
    ).toLocal();
  }

  /// Convert DateTime to Unix timestamp (seconds)
  static int toUnix(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// Quick format to string (e.g. `yyyy-MM-dd HH:mm:ss`)
  static String format(DateTime dateTime) {
    return "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

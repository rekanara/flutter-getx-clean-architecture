import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class DioWrapper {
  static TalkerDioLogger dioLog = TalkerDioLogger(
    settings: TalkerDioLoggerSettings(
      printRequestHeaders: true,
      printResponseHeaders: true,
      printResponseMessage: true,
      printResponseData: kDebugMode,
      printRequestData: kDebugMode,
      enabled: kDebugMode,
    ),
  );
}

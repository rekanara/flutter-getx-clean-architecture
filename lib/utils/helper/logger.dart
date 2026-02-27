import 'package:logger/logger.dart';

class LoggerHelper {
  static final Logger _logger = Logger(
    output: ConsoleOutput(),
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      errorMethodCount: 8,
      colors: true,
      printEmojis: true,
      levelColors: {
        // Level.verbose: const AnsiColor.fg(8),
        Level.debug: const AnsiColor.fg(4),
        Level.info: const AnsiColor.fg(2),
        Level.warning: const AnsiColor.fg(3),
        Level.error: const AnsiColor.fg(1),
        // Level.wtf: const AnsiColor.fg(5),
        // Level.nothing: const AnsiColor.fg(0),
        Level.all: const AnsiColor.fg(7),
        Level.trace: const AnsiColor.fg(6),
        Level.fatal: const AnsiColor.fg(1),
        Level.off: const AnsiColor.fg(0),
      },
      lineLength: 110,
      levelEmojis: {
        Level.trace: '📝',
        Level.debug: '🐛',
        Level.info: 'ℹ️',
        Level.warning: '⚠️',
        Level.error: '🚨',
        Level.fatal: '🤷‍♂️',
        // Level.nothing: '🙈',
        Level.all: '🙌🏻',
        // Level.verbose: '📣',
        // Level.wtf: '🤯',
        Level.off: '🔇',
      },
    ),
  );

  /// Instance getter (backward compatible)
  Logger get logger => _logger;

  // ─── Static Methods ───────────────────────────────────────

  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);

  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void t(dynamic message) => _logger.t(message);
  static void f(dynamic message) => _logger.f(message);
}

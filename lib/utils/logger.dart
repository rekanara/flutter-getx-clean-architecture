import 'package:logger/logger.dart';

class LoggerHelper {
  var logger = Logger(
    output: ConsoleOutput(),
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      // methodCount: 0,
      errorMethodCount: 8,
      colors: true,
      printEmojis: true,
      levelColors: {
        Level.verbose: const AnsiColor.fg(8),
        Level.debug: const AnsiColor.fg(4),
        Level.info: const AnsiColor.fg(2),
        Level.warning: const AnsiColor.fg(3),
        Level.error: const AnsiColor.fg(1),
        Level.wtf: const AnsiColor.fg(5),
        Level.nothing: const AnsiColor.fg(0),
        Level.all: const AnsiColor.fg(7),
        Level.trace: const AnsiColor.fg(6),
        Level.fatal: const AnsiColor.fg(1),
        Level.off: const AnsiColor.fg(0),
      },
      lineLength: 110,

      dateTimeFormat: (time) {
        return DateTime.now().toIso8601String();
      },
      levelEmojis: {
        Level.trace: '📝',
        Level.debug: '🐛',
        Level.info: 'ℹ️',
        Level.warning: '⚠️',
        Level.error: '🚨',
        Level.fatal: '🤷‍♂️',
        Level.nothing: '🙈',
        Level.all: '🙌🏻',
        Level.verbose: '📣',
        Level.wtf: '🤯',
        Level.off: '🔇',
      },
    ),
  );
}

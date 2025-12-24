import 'dart:developer' as developer;

enum LogLevel { debug, info, warn, error }

class AppLogger {
  final String defaultTag;
  final LogLevel minimumLevel;

  const AppLogger(
      {this.defaultTag = 'SPOTS', this.minimumLevel = LogLevel.debug});

  void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);
  void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);
  void warn(String message, {String? tag}) =>
      _log(LogLevel.warn, message, tag: tag);
  // Backwards-compatible alias used by some call sites
  void warning(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final composed = error != null ? '$message | error: $error' : message;
    _log(LogLevel.warn, composed, tag: tag, stackTrace: stackTrace);
  }

  void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final composed = error != null ? '$message | error: $error' : message;
    _log(LogLevel.error, composed, tag: tag, stackTrace: stackTrace);
  }

  void _log(LogLevel level, String message,
      {String? tag, StackTrace? stackTrace}) {
    if (level.index < minimumLevel.index) return;
    final name = tag ?? defaultTag;
    final prefix = switch (level) {
      LogLevel.debug => '🐛',
      LogLevel.info => 'ℹ️',
      LogLevel.warn => '⚠️',
      LogLevel.error => '❌',
    };
    final logMessage = '$prefix $message';
    // Use developer.log for DevTools, but also print for flutter run stdout visibility
    developer.log(logMessage, name: name, stackTrace: stackTrace);
    // Also print to stdout for flutter run visibility
    print('[$name] $logMessage');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}

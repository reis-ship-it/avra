import 'dart:developer' as developer;

enum LogLevel { debug, info, warn, error }

class AppLogger {
  final String defaultTag;
  final LogLevel minimumLevel;

  const AppLogger({this.defaultTag = 'SPOTS', this.minimumLevel = LogLevel.debug});

  void debug(String message, {String? tag}) => _log(LogLevel.debug, message, tag: tag);
  void info(String message, {String? tag}) => _log(LogLevel.info, message, tag: tag);
  void warn(String message, {String? tag}) => _log(LogLevel.warn, message, tag: tag);
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final composed = error != null ? '$message | error: $error' : message;
    _log(LogLevel.error, composed, tag: tag, stackTrace: stackTrace);
  }

  void _log(LogLevel level, String message, {String? tag, StackTrace? stackTrace}) {
    if (level.index < minimumLevel.index) return;
    final name = tag ?? defaultTag;
    final prefix = switch (level) {
      LogLevel.debug => '🐛',
      LogLevel.info => 'ℹ️',
      LogLevel.warn => '⚠️',
      LogLevel.error => '❌',
    };
    developer.log('$prefix $message', name: name, stackTrace: stackTrace);
  }
}



import 'dart:developer' as developer;

/// Severity of a log entry.
enum LogSeverity { debug, info, warning, error }

/// Local-only logging.
///
/// Log entries go to the debugging console and nowhere else: there is no
/// crash reporting or remote logging, because user data never leaves the device.
/// Never log user-entered text such as product names.
abstract interface class LocalLogger {
  void log(LogSeverity severity, String message, {Object? error, StackTrace? stackTrace});
}

/// Writes to `dart:developer`, which only reaches an attached debugger.
final class DeveloperConsoleLogger implements LocalLogger {
  const DeveloperConsoleLogger({this.loggerName = 'freezer'});

  final String loggerName;

  @override
  void log(LogSeverity severity, String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: loggerName,
      level: _levelFor(severity),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _levelFor(LogSeverity severity) => switch (severity) {
    LogSeverity.debug => 500,
    LogSeverity.info => 800,
    LogSeverity.warning => 900,
    LogSeverity.error => 1000,
  };
}

/// Keeps entries in memory; for tests that assert something was logged.
final class RecordingLogger implements LocalLogger {
  final List<RecordedLogEntry> recordedEntries = [];

  @override
  void log(LogSeverity severity, String message, {Object? error, StackTrace? stackTrace}) {
    recordedEntries.add(RecordedLogEntry(severity: severity, message: message, error: error));
  }
}

final class RecordedLogEntry {
  const RecordedLogEntry({required this.severity, required this.message, this.error});

  final LogSeverity severity;
  final String message;
  final Object? error;
}

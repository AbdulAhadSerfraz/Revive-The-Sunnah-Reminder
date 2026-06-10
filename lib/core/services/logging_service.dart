import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Comprehensive logging service for production-level apps
class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance => _instance ??= LoggingService._();

  LoggingService._();

  File? _logFile;

  /// Initialize the logging service
  void initialize() {
    if (!kDebugMode) {
      _setupFileLogging();
    }
  }

  /// Setup file logging for production
  Future<void> _setupFileLogging() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/app_logs.txt');
    } catch (e) {
      developer.log('Failed to setup file logging: $e', name: 'LOGGING');
    }
  }

  /// Log debug information
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
    if (kDebugMode) {
      developer.log(message, name: 'DEBUG');
    }
  }

  /// Log general information
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
    if (kDebugMode) {
      developer.log(message, name: 'INFO');
    }
  }

  /// Log warnings
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
    if (kDebugMode) {
      developer.log(message, name: 'WARNING');
    }
  }

  /// Log errors
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);

    // In production, send to crash reporting service
    if (!kDebugMode) {
      _sendToCrashlytics(message, error, stackTrace);
    }

    if (kDebugMode) {
      developer.log(message,
          name: 'ERROR', error: error, stackTrace: stackTrace);
    }
  }

  /// Log fatal errors
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('FATAL', message, error, stackTrace);

    // In production, send to crash reporting service with high priority
    if (!kDebugMode) {
      _sendToCrashlytics(message, error, stackTrace, isFatal: true);
    }

    developer.log(message, name: 'FATAL', error: error, stackTrace: stackTrace);
  }

  /// Log API calls
  void apiCall(String method, String endpoint, {Map<String, dynamic>? data}) {
    final message = 'API $method: $endpoint';
    _log('API', message, data);
  }

  /// Log API responses
  void apiResponse(String endpoint, int statusCode, {dynamic response}) {
    final message = 'API Response: $endpoint - Status: $statusCode';
    if (statusCode >= 200 && statusCode < 300) {
      _log('API', message);
    } else {
      _log('WARNING', message, response);
    }
  }

  /// Log user interactions
  void userAction(String action, {Map<String, dynamic>? data}) {
    final message = 'User Action: $action';
    _log('USER', message, data);
  }

  /// Log performance metrics
  void performance(String operation, Duration duration,
      {Map<String, dynamic>? data}) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    _log('PERF', message, data);
  }

  /// Internal logging method
  void _log(String level, String message,
      [dynamic error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [$level] $message';

    if (error != null) {
      final errorEntry = '[$timestamp] [$level] Error: $error';
      _writeToFile(errorEntry);
    }

    if (stackTrace != null) {
      final stackEntry = '[$timestamp] [$level] Stack: $stackTrace';
      _writeToFile(stackEntry);
    }

    _writeToFile(logEntry);
  }

  /// Write log entry to file
  void _writeToFile(String entry) {
    if (_logFile != null && !kDebugMode) {
      try {
        _logFile!.writeAsStringSync('$entry\n', mode: FileMode.append);
      } catch (e) {
        // Fail silently to avoid recursive logging
      }
    }
  }

  /// Send errors to crash reporting service (placeholder for production)
  void _sendToCrashlytics(String message, dynamic error, StackTrace? stackTrace,
      {bool isFatal = false}) {
    // Example implementation with Firebase Crashlytics
    // In production, uncomment and configure the following:
    //
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   fatal: isFatal,
    //   reason: message,
    // );
    //
    // Additional crash reporting services could be:
    // - Sentry: Sentry.captureException(error, stackTrace: stackTrace);
    // - Bugsnag: Bugsnag.notify(error, stackTrace);
    //
    // Make sure to initialize the service in LoggingService.initialize()
  }

  /// Clear log file
  Future<void> clearLogs() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
      }
    } catch (e) {
      developer.log('Failed to clear logs: $e', name: 'LOGGING');
    }
  }

  /// Get log file path
  String? get logFilePath => _logFile?.path;
}

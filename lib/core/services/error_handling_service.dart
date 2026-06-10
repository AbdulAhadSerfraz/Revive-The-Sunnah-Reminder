import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/navigation_service.dart'; // Added import for NavigationService
import 'package:flutter/material.dart';

/// Comprehensive error handling service for production apps
class ErrorHandlingService {
  static ErrorHandlingService? _instance;
  static ErrorHandlingService get instance =>
      _instance ??= ErrorHandlingService._();

  ErrorHandlingService._();

  final LoggingService _logger = LoggingService.instance;

  /// Initialize error handling
  void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.error(
        'Flutter Error: ${details.exception}',
        details.exception,
        details.stack,
      );

      if (!kDebugMode) {
        // In production, show user-friendly error dialog
        _handleProductionError(details.exception, details.stack);
      }
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.fatal('Platform Error: $error', error, stack);

      if (!kDebugMode) {
        _handleProductionError(error, stack);
      }

      return true;
    };
  }

  /// Handle and log various types of errors
  T handleError<T>(
    String operation,
    T Function() function, {
    T? fallback,
    bool showUserError = false,
  }) {
    try {
      return function();
    } catch (error, stackTrace) {
      _logger.error('Error in $operation: $error', error, stackTrace);

      if (showUserError && !kDebugMode) {
        _showUserFriendlyError(_getErrorMessage(error));
      }

      if (fallback != null) {
        return fallback;
      }

      rethrow;
    }
  }

  /// Handle async operations with error management
  Future<T> handleAsyncError<T>(
    String operation,
    Future<T> Function() function, {
    T? fallback,
    bool showUserError = false,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      _logger.error('Async error in $operation: $error', error, stackTrace);

      if (showUserError && !kDebugMode) {
        _showUserFriendlyError(_getErrorMessage(error));
      }

      if (fallback != null) {
        return fallback;
      }

      rethrow;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid data format received.';
    } else if (error is StateError) {
      return 'An unexpected error occurred. Please restart the app.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Show user-friendly error message
  void _showUserFriendlyError(String message) {
    // Basic implementation using Flutter's ScaffoldMessenger to show a snackbar
    // In production, this should be replaced with a more robust solution
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
    _logger.info('Showing user error: $message');
  }

  /// Handle production errors
  void _handleProductionError(dynamic error, StackTrace? stackTrace) {
    // In production, you might want to:
    // 1. Show a user-friendly error dialog
    // 2. Send error reports to analytics
    // 3. Attempt to recover from the error
    _logger.fatal('Production error occurred', error, stackTrace);
  }
}

/// Custom exception classes for better error handling
abstract class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final dynamic cause;

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

class DataException extends AppException {
  const DataException(super.message, [super.cause]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.cause]);
}

class StorageException extends AppException {
  const StorageException(super.message, [super.cause]);
}

class NotificationException extends AppException {
  const NotificationException(super.message, [super.cause]);
}

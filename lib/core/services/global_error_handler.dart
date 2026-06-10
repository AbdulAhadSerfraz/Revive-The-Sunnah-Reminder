import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';

class GlobalErrorHandler {
  static final LoggingService _logger = LoggingService.instance;

  /// Initialize global error handling
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // In debug mode, use the default red screen
        FlutterError.presentError(details);
      } else {
        // In release mode, log the error and show custom error widget
        _logError('Flutter Error', details.exception, details.stack);
      }
    };

    // Handle platform/asynchronous errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };
  }

  /// Log error with context
  static void _logError(String context, dynamic error, StackTrace? stack) {
    _logger.error('[$context] ${error.toString()}', error, stack);
  }

  /// Handle specific API errors
  static String getApiErrorMessage(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Invalid API key. Please check your OpenRouter API key in settings.';
    } else if (error.toString().contains('429')) {
      return 'Rate limit exceeded. Please wait a moment and try again.';
    } else if (error.toString().contains('403')) {
      return 'Access forbidden. Please check your API key permissions.';
    } else if (error.toString().contains('404')) {
      return 'Service not found. Please check your internet connection.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle chat specific errors
  static String getChatErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('api key')) {
      return 'API key issue. Please check your OpenRouter API key configuration.';
    } else if (errorStr.contains('credit') || errorStr.contains('quota')) {
      return 'Insufficient credits. Please add credits to your OpenRouter account.';
    } else if (errorStr.contains('model')) {
      return 'Model unavailable. The AI model may be temporarily unavailable.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timeout. Please try again with a shorter message.';
    } else {
      return getApiErrorMessage(error);
    }
  }

  /// Show error dialog
  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show retry dialog for critical errors
  static void showRetryDialog(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.refresh_rounded, color: AppColors.secondary),
            const SizedBox(width: 8),
            const Text('Connection Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying user-friendly error messages
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showIcon;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget for displaying loading states with error fallback
class SafeLoadingWidget extends StatelessWidget {
  final Future<dynamic> future;
  final Widget Function(dynamic data) builder;
  final Widget? loadingWidget;
  final Widget Function(String error)? errorBuilder;

  const SafeLoadingWidget({
    super.key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final errorMessage =
              GlobalErrorHandler.getApiErrorMessage(snapshot.error);
          return errorBuilder?.call(errorMessage) ??
              ErrorDisplayWidget(message: errorMessage);
        }

        return builder(snapshot.data);
      },
    );
  }
}

/// Mixin for handling errors in StatefulWidgets
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void clearError() {
    setError(null);
  }

  Future<R?> handleAsyncOperation<R>(
    Future<R> operation, {
    String? errorContext,
    bool showSnackbar = true,
  }) async {
    setLoading(true);
    clearError();

    try {
      final result = await operation;
      return result;
    } catch (e) {
      final errorMsg = errorContext != null
          ? '$errorContext: ${GlobalErrorHandler.getApiErrorMessage(e)}'
          : GlobalErrorHandler.getApiErrorMessage(e);

      setError(errorMsg);

      if (showSnackbar && mounted) {
        GlobalErrorHandler.showErrorSnackbar(context, errorMsg);
      }

      return null;
    } finally {
      setLoading(false);
    }
  }
}

/// Extension for safe navigation
extension SafeNavigation on BuildContext {
  void safePush(Widget page) {
    if (mounted) {
      Navigator.push(
        this,
        MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  void safePop([dynamic result]) {
    if (mounted && Navigator.canPop(this)) {
      Navigator.pop(this, result);
    }
  }

  void safeShowSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.secondary,
        ),
      );
    }
  }
}

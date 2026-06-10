import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/credits_info.dart';
import 'package:revive_sunnah_reminder/core/services/storage_service.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

class CreditsProvider extends ChangeNotifier {
  static const int _defaultDailyCredits = 5;
  static const String _creditsKey = 'user_credits_v2';
  static const String _dailyUsageKey = 'daily_usage_tracking';

  final StorageService _storageService;
  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  CreditsInfo? _creditsInfo;
  bool _isLoading = false;
  String? _error;
  final bool _hasUnlimitedCredits =
      false; // Always false since we removed custom API

  // Usage tracking
  List<DateTime> _dailyUsageLog = [];

  CreditsProvider(this._storageService);

  // Getters
  CreditsInfo? get creditsInfo => _creditsInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCredits => _creditsInfo?.hasCredits ?? false;
  int get remainingCredits => _creditsInfo?.remainingCredits ?? 0;
  int get totalCredits => _creditsInfo?.totalCredits ?? _defaultDailyCredits;
  int get usedCredits => _creditsInfo?.usedCredits ?? 0;
  double get usagePercentage => _creditsInfo?.usagePercentage ?? 0.0;
  bool get hasUnlimitedCredits => false; // Always false now
  bool get isDefaultApiMode => true; // Always true now

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadCredits();
      await _loadUsageLog();

      // Always check for reset since we only have limited credits now
      await _checkAndResetDailyCredits();

      _logger.info(
          'Credits Provider initialized - Limited mode, Remaining: $remainingCredits/$totalCredits');
    } catch (e) {
      _setError('Failed to initialize credits: $e');
      _logger.error('Failed to initialize credits', e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadCredits() async {
    final creditsData = _storageService.getObject(_creditsKey);

    if (creditsData != null) {
      try {
        _creditsInfo = CreditsInfo.fromJson(creditsData);
      } catch (e) {
        _logger.error('Error parsing credits data, resetting', e);
        await _initializeCredits();
      }
    } else {
      await _initializeCredits();
    }
  }

  Future<void> _loadUsageLog() async {
    final usageData = _storageService.getObject(_dailyUsageKey);
    if (usageData != null && usageData['usage_log'] is List) {
      _dailyUsageLog = (usageData['usage_log'] as List)
          .map((timestamp) => DateTime.parse(timestamp))
          .toList();

      // Clean old entries (keep only last 30 days)
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      _dailyUsageLog.removeWhere((date) => date.isBefore(cutoff));
      await _saveUsageLog();
    }
  }

  Future<void> _saveUsageLog() async {
    final usageData = {
      'usage_log':
          _dailyUsageLog.map((date) => date.toIso8601String()).toList(),
    };
    await _storageService.setObject(_dailyUsageKey, usageData);
  }

  Future<void> _initializeCredits() async {
    _creditsInfo =
        CreditsInfo.createInitial(totalCredits: _defaultDailyCredits);
    await _saveCredits();
    _logger
        .info('Credits initialized with $_defaultDailyCredits daily credits');
  }

  Future<void> _checkAndResetDailyCredits() async {
    if (_creditsInfo == null) return;

    if (_creditsInfo!.needsReset) {
      await _resetDailyCredits();
    }
  }

  Future<void> _resetDailyCredits() async {
    if (_creditsInfo == null) return;

    _creditsInfo = _creditsInfo!.resetCredits();
    await _saveCredits();

    _logger.info('Daily credits reset to $_defaultDailyCredits');
    notifyListeners();
  }

  Future<bool> consumeCredit() async {
    return await _errorHandler.handleAsyncError('Consume credit', () async {
      // Check if credits are initialized
      if (_creditsInfo == null) {
        throw Exception('Credits not initialized');
      }

      if (!hasCredits) {
        _setError(
            'No credits remaining. Daily limit of $totalCredits questions reached.');
        return false;
      }

      // Consume the credit
      _creditsInfo = _creditsInfo!.consumeCredit();

      // Log the usage
      _dailyUsageLog.add(DateTime.now());

      // Save both credits and usage log
      await Future.wait([
        _saveCredits(),
        _saveUsageLog(),
      ]);

      _logger
          .info('Credit consumed. Remaining: $remainingCredits/$totalCredits');
      notifyListeners();

      return true;
    });
  }

  Future<void> _saveCredits() async {
    if (_creditsInfo != null) {
      await _storageService.setObject(_creditsKey, _creditsInfo!.toJson());
    }
  }

  String getCreditsDisplayText() {
    if (_creditsInfo == null) return 'Loading...';
    if (_hasUnlimitedCredits) return '∞';
    return '$remainingCredits/$totalCredits';
  }

  String getTimeUntilReset() {
    if (_hasUnlimitedCredits) return 'Unlimited';
    if (_creditsInfo == null) return '';
    return _creditsInfo!.getTimeUntilReset();
  }

  Color getCreditsColor() {
    if (_hasUnlimitedCredits) {
      return const Color(0xFFFFD700); // Gold for unlimited
    }
    if (_creditsInfo == null) return const Color(0xFF2E7D32);
    return _creditsInfo!.getCreditsColor();
  }

  String getStatusText() {
    if (_hasUnlimitedCredits) return 'Unlimited Questions';
    if (_creditsInfo == null) return 'Loading...';
    return _creditsInfo!.getStatusText();
  }

  /// Get usage statistics
  Map<String, dynamic> getUsageStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    final todayUsage = _dailyUsageLog.where((date) {
      final logDate = DateTime(date.year, date.month, date.day);
      return logDate.isAtSameMomentAs(today);
    }).length;

    final weekUsage =
        _dailyUsageLog.where((date) => date.isAfter(thisWeek)).length;
    final monthUsage =
        _dailyUsageLog.where((date) => date.isAfter(thisMonth)).length;

    return {
      'today': todayUsage,
      'thisWeek': weekUsage,
      'thisMonth': monthUsage,
      'totalLogged': _dailyUsageLog.length,
      'averageDaily':
          monthUsage > 0 ? (monthUsage / now.day).toStringAsFixed(1) : '0.0',
    };
  }

  /// Get detailed usage pattern for analytics
  List<Map<String, dynamic>> getUsagePattern({int days = 7}) {
    final now = DateTime.now();
    final pattern = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      final usage = _dailyUsageLog.where((logDate) {
        final logDateKey = DateTime(logDate.year, logDate.month, logDate.day);
        return logDateKey.isAtSameMomentAs(dateKey);
      }).length;

      pattern.add({
        'date': dateKey,
        'usage': usage,
        'isToday': i == 0,
        'dayName': _getDayName(dateKey.weekday),
      });
    }

    return pattern;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Force refresh credits (useful for admin/testing)
  Future<void> refreshCredits() async {
    await initialize();
  }

  /// Get progress for circular indicators
  double get progressValue => usagePercentage;
  double get remainingProgressValue => 1.0 - usagePercentage;

  /// Check if user is approaching limit
  bool get isApproachingLimit => usagePercentage >= 0.8;

  /// Check if user is running low
  bool get isRunningLow => usagePercentage >= 0.6;

  /// Get appropriate icon for current status
  IconData getStatusIcon() {
    if (!hasCredits) return Icons.block_rounded;
    if (isApproachingLimit) return Icons.warning_rounded;
    if (isRunningLow) return Icons.info_rounded;
    return Icons.check_circle_rounded;
  }

  /// Get motivational message based on usage
  String getMotivationalMessage() {
    if (!hasCredits) {
      return 'Your daily questions reset tomorrow. Plan your next Islamic learning!';
    } else if (isApproachingLimit) {
      return 'Almost at your daily limit. Make your remaining questions count!';
    } else if (isRunningLow) {
      return 'You\'re doing great with your Islamic learning today!';
    } else {
      return 'Ready to explore Islamic knowledge? Ask your questions!';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    // Clear any sensitive data
    _creditsInfo = null;
    _dailyUsageLog.clear();
    super.dispose();
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

/// Comprehensive storage service for app data and preferences
class StorageService {
  final SharedPreferences _prefs;
  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;
  
  // Simple encryption setup
  late final List<int> _encryptionKey;
  
  // Storage keys
  static const String _keyPrefix = 'revive_app_';
  static const String _todaySunnahKey = '${_keyPrefix}today_sunnah';
  static const String _lastSunnahDateKey = '${_keyPrefix}last_sunnah_date';
  static const String _usedSunnahIdsKey = '${_keyPrefix}used_sunnah_ids';
  static const String _streakCountKey = '${_keyPrefix}streak_count';
  static const String _lastStreakDateKey = '${_keyPrefix}last_streak_date';
  static const String _totalCompletedKey = '${_keyPrefix}total_completed';
  static const String _notificationEnabledKey = '${_keyPrefix}notification_enabled';
  static const String _notificationTimeKey = '${_keyPrefix}notification_time';
  static const String _themePreferenceKey = '${_keyPrefix}theme_preference';
  static const String _languagePreferenceKey = '${_keyPrefix}language_preference';
  static const String _firstLaunchKey = '${_keyPrefix}first_launch';
  static const String _onboardingCompletedKey = '${_keyPrefix}onboarding_completed';
  static const String _privacyPolicyAcceptedKey = '${_keyPrefix}privacy_policy_accepted';
  
  StorageService(this._prefs) {
    _initializeEncryption();
  }
  
  /// Initialize simple encryption for sensitive data
  void _initializeEncryption() {
    // Generate a simple encryption key
    final random = Random.secure();
    _encryptionKey = List.generate(32, (index) => random.nextInt(256));
  }
  
  /// Store encrypted data (simplified XOR encryption)
  Future<bool> _storeEncrypted(String key, String value) async {
    return await _errorHandler.handleAsyncError('Store encrypted data', () async {
      final valueBytes = utf8.encode(value);
      final encryptedBytes = List<int>.generate(
        valueBytes.length,
        (i) => valueBytes[i] ^ _encryptionKey[i % _encryptionKey.length],
      );
      final encryptedString = base64.encode(encryptedBytes);
      return await _prefs.setString(key, encryptedString);
    }, fallback: false);
  }
  
  /// Retrieve encrypted data (simplified XOR decryption)
  String? _getEncrypted(String key) {
    return _errorHandler.handleError('Get encrypted data', () {
      final encryptedString = _prefs.getString(key);
      if (encryptedString != null) {
        final encryptedBytes = base64.decode(encryptedString);
        final decryptedBytes = List<int>.generate(
          encryptedBytes.length,
          (i) => encryptedBytes[i] ^ _encryptionKey[i % _encryptionKey.length],
        );
        return utf8.decode(decryptedBytes);
      }
      return null;
    });
  }
  
  /// Store today's Sunnah ID
  Future<bool> setTodaySunnahId(int sunnahId) async {
    return await _errorHandler.handleAsyncError('Set today Sunnah ID', () async {
      return await _prefs.setInt(_todaySunnahKey, sunnahId);
    }, fallback: false);
  }
  
  /// Get today's Sunnah ID
  int? getTodaySunnahId() {
    return _errorHandler.handleError('Get today Sunnah ID', () {
      return _prefs.getInt(_todaySunnahKey);
    });
  }
  
  /// Store last Sunnah date
  Future<bool> setLastSunnahDate(String date) async {
    return await _errorHandler.handleAsyncError('Set last Sunnah date', () async {
      return await _prefs.setString(_lastSunnahDateKey, date);
    }, fallback: false);
  }
  
  /// Get last Sunnah date
  String? getLastSunnahDate() {
    return _errorHandler.handleError('Get last Sunnah date', () {
      return _prefs.getString(_lastSunnahDateKey);
    });
  }
  
  /// Store used Sunnah IDs
  Future<bool> setUsedSunnahIds(List<String> ids) async {
    return await _errorHandler.handleAsyncError('Set used Sunnah IDs', () async {
      return await _prefs.setStringList(_usedSunnahIdsKey, ids);
    }, fallback: false);
  }
  
  /// Get used Sunnah IDs
  List<String> getUsedSunnahIds() {
    return _errorHandler.handleError('Get used Sunnah IDs', () {
      return _prefs.getStringList(_usedSunnahIdsKey) ?? <String>[];
    }, fallback: <String>[]);
  }
  
  /// Store streak count
  Future<bool> setStreakCount(int count) async {
    return await _errorHandler.handleAsyncError('Set streak count', () async {
      return await _prefs.setInt(_streakCountKey, count);
    }, fallback: false);
  }
  
  /// Get streak count
  int getStreakCount() {
    return _errorHandler.handleError('Get streak count', () {
      return _prefs.getInt(_streakCountKey) ?? 0;
    }, fallback: 0);
  }
  
  /// Store last streak date
  Future<bool> setLastStreakDate(String date) async {
    return await _errorHandler.handleAsyncError('Set last streak date', () async {
      return await _prefs.setString(_lastStreakDateKey, date);
    }, fallback: false);
  }
  
  /// Get last streak date
  String? getLastStreakDate() {
    return _errorHandler.handleError('Get last streak date', () {
      return _prefs.getString(_lastStreakDateKey);
    });
  }
  
  /// Store total completed count
  Future<bool> setTotalCompleted(int count) async {
    return await _errorHandler.handleAsyncError('Set total completed', () async {
      return await _prefs.setInt(_totalCompletedKey, count);
    }, fallback: false);
  }
  
  /// Get total completed count
  int getTotalCompleted() {
    return _errorHandler.handleError('Get total completed', () {
      return _prefs.getInt(_totalCompletedKey) ?? 0;
    }, fallback: 0);
  }
  
  /// Store notification enabled state
  Future<bool> setNotificationEnabled(bool enabled) async {
    return await _errorHandler.handleAsyncError('Set notification enabled', () async {
      return await _prefs.setBool(_notificationEnabledKey, enabled);
    }, fallback: false);
  }
  
  /// Get notification enabled state
  bool isNotificationEnabled() {
    return _errorHandler.handleError('Get notification enabled', () {
      return _prefs.getBool(_notificationEnabledKey) ?? true;
    }, fallback: true);
  }
  
  /// Store notification time
  Future<bool> setNotificationTime(String time) async {
    return await _errorHandler.handleAsyncError('Set notification time', () async {
      return await _prefs.setString(_notificationTimeKey, time);
    }, fallback: false);
  }
  
  /// Get notification time
  String getNotificationTime() {
    return _errorHandler.handleError('Get notification time', () {
      return _prefs.getString(_notificationTimeKey) ?? '09:00';
    }, fallback: '09:00');
  }
  
  /// Store theme preference
  Future<bool> setThemePreference(String theme) async {
    return await _errorHandler.handleAsyncError('Set theme preference', () async {
      return await _prefs.setString(_themePreferenceKey, theme);
    }, fallback: false);
  }
  
  /// Get theme preference
  String getThemePreference() {
    return _errorHandler.handleError('Get theme preference', () {
      return _prefs.getString(_themePreferenceKey) ?? 'system';
    }, fallback: 'system');
  }
  
  /// Store language preference
  Future<bool> setLanguagePreference(String language) async {
    return await _errorHandler.handleAsyncError('Set language preference', () async {
      return await _prefs.setString(_languagePreferenceKey, language);
    }, fallback: false);
  }
  
  /// Get language preference
  String getLanguagePreference() {
    return _errorHandler.handleError('Get language preference', () {
      return _prefs.getString(_languagePreferenceKey) ?? 'en';
    }, fallback: 'en');
  }
  
  /// Check if this is first launch
  bool isFirstLaunch() {
    return _errorHandler.handleError('Check first launch', () {
      return _prefs.getBool(_firstLaunchKey) ?? true;
    }, fallback: true);
  }
  
  /// Mark first launch as completed
  Future<bool> setFirstLaunchCompleted() async {
    return await _errorHandler.handleAsyncError('Set first launch completed', () async {
      return await _prefs.setBool(_firstLaunchKey, false);
    }, fallback: false);
  }
  
  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _errorHandler.handleError('Check onboarding completed', () {
      return _prefs.getBool(_onboardingCompletedKey) ?? false;
    }, fallback: false);
  }
  
  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted() async {
    return await _errorHandler.handleAsyncError('Set onboarding completed', () async {
      return await _prefs.setBool(_onboardingCompletedKey, true);
    }, fallback: false);
  }
  
  /// Check if privacy policy is accepted
  bool isPrivacyPolicyAccepted() {
    return _errorHandler.handleError('Check privacy policy accepted', () {
      return _prefs.getBool(_privacyPolicyAcceptedKey) ?? false;
    }, fallback: false);
  }
  
  /// Mark privacy policy as accepted
  Future<bool> setPrivacyPolicyAccepted() async {
    return await _errorHandler.handleAsyncError('Set privacy policy accepted', () async {
      return await _prefs.setBool(_privacyPolicyAcceptedKey, true);
    }, fallback: false);
  }
  
  /// Store complex object as JSON
  Future<bool> setObject(String key, Map<String, dynamic> object) async {
    return await _errorHandler.handleAsyncError('Set object', () async {
      final jsonString = json.encode(object);
      return await _prefs.setString('$_keyPrefix$key', jsonString);
    }, fallback: false);
  }
  
  /// Get complex object from JSON
  Map<String, dynamic>? getObject(String key) {
    return _errorHandler.handleError('Get object', () {
      final jsonString = _prefs.getString('$_keyPrefix$key');
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    });
  }
  
  /// Store sensitive data with encryption
  Future<bool> setSecureData(String key, String value) async {
    return await _storeEncrypted('${_keyPrefix}secure_$key', value);
  }
  
  /// Get sensitive data with decryption
  String? getSecureData(String key) {
    return _getEncrypted('${_keyPrefix}secure_$key');
  }
  
  /// Remove specific key
  Future<bool> remove(String key) async {
    return await _errorHandler.handleAsyncError('Remove key', () async {
      return await _prefs.remove('$_keyPrefix$key');
    }, fallback: false);
  }
  
  /// Clear all app data
  Future<bool> clearAll() async {
    return await _errorHandler.handleAsyncError('Clear all data', () async {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
      _logger.info('All app data cleared');
      return true;
    }, fallback: false);
  }
  
  /// Get storage size (approximate)
  int getStorageSize() {
    return _errorHandler.handleError('Get storage size', () {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      int totalSize = 0;
      
      for (final key in keys) {
        final value = _prefs.get(key);
        if (value != null) {
          totalSize += key.length + value.toString().length;
        }
      }
      
      return totalSize;
    }, fallback: 0);
  }
  
  /// Export user data
  Map<String, dynamic> exportUserData() {
    return _errorHandler.handleError('Export user data', () {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      final data = <String, dynamic>{};
      
      for (final key in keys) {
        // Skip sensitive data
        if (!key.contains('secure_')) {
          data[key] = _prefs.get(key);
        }
      }
      
      return data;
    }, fallback: <String, dynamic>{});
  }
}
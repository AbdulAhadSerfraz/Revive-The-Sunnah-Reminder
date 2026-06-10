import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revive_sunnah_reminder/core/services/storage_service.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

/// Localization service for managing translations and language settings
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance =>
      _instance ??= LocalizationService._();

  LocalizationService._();

  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  StorageService? _storageService;
  final Map<String, Map<String, String>> _localizedStrings = {};
  String _currentLanguage = 'en';

  // Supported languages
  static const List<Language> supportedLanguages = [
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    Language(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    Language(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    Language(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
    Language(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    Language(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    Language(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
  ];

  /// Initialize localization service
  Future<void> initialize(StorageService storageService) async {
    await _errorHandler.handleAsyncError('Initialize localization', () async {
      _storageService = storageService;

      // Load saved language preference
      _currentLanguage = _storageService!.getLanguagePreference();

      // Load all language files
      await _loadAllLanguages();

      _logger.info(
          'Localization service initialized with language: $_currentLanguage');
    });
  }

  /// Load all supported language files
  Future<void> _loadAllLanguages() async {
    for (final language in supportedLanguages) {
      await _loadLanguage(language.code);
    }
  }

  /// Load specific language file
  Future<void> _loadLanguage(String languageCode) async {
    await _errorHandler.handleAsyncError('Load language: $languageCode',
        () async {
      final String filePath = 'assets/translations/$languageCode.json';

      try {
        final String jsonString = await rootBundle.loadString(filePath);
        final Map<String, dynamic> jsonMap = json.decode(jsonString);

        _localizedStrings[languageCode] = jsonMap.map(
          (key, value) => MapEntry(key, value.toString()),
        );

        _logger.debug(
            'Loaded ${_localizedStrings[languageCode]?.length} translations for $languageCode');
      } catch (e) {
        _logger.warning('Failed to load language file: $filePath', e);

        // Use default English translations if file not found
        if (languageCode != 'en') {
          _localizedStrings[languageCode] = _localizedStrings['en'] ?? {};
        } else {
          // Provide basic English fallbacks
          _localizedStrings[languageCode] = _getDefaultEnglishStrings();
        }
      }
    });
  }

  /// Get default English strings as fallback
  Map<String, String> _getDefaultEnglishStrings() {
    return {
      'app_name': 'Revive - The Sunnah Reminder',
      'home': 'Home',
      'all_sunnahs': 'All Sunnahs',
      'progress': 'Progress',
      'settings': 'Settings',
      'today_sunnah': 'Today\'s Sunnah',
      'mark_completed': 'Mark as Completed',
      'completed': 'Completed ✓',
      'pending': 'Pending',
      'search': 'Search',
      'search_sunnahs': 'Search Sunnahs...',
      'category': 'Category',
      'source': 'Source',
      'hadith': 'Hadith',
      'benefit': 'Benefit',
      'streak': 'Streak',
      'days': 'Days',
      'total_completed': 'Total Completed',
      'notifications': 'Notifications',
      'notification_time': 'Notification Time',
      'language': 'Language',
      'theme': 'Theme',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'contact_support': 'Contact Support',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
    };
  }

  /// Get current language code
  String get currentLanguage => _currentLanguage;

  /// Get current language info
  Language get currentLanguageInfo {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _currentLanguage,
      orElse: () => supportedLanguages.first,
    );
  }

  /// Check if current language is RTL
  bool get isRTL {
    return ['ar', 'ur', 'fa'].contains(_currentLanguage);
  }

  /// Get text direction for current language
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get localized string by key
  String getString(String key, {Map<String, String>? params}) {
    String? text = _localizedStrings[_currentLanguage]?[key];

    // Fallback to English if translation not found
    text ??= _localizedStrings['en']?[key];

    // Fallback to key if no translation found
    text ??= key;

    // Replace parameters if provided
    if (params != null) {
      params.forEach((param, value) {
        text = text!.replaceAll('{$param}', value);
      });
    }

    return text!;
  }

  /// Get localized string with pluralization
  String getPlural(String key, int count, {Map<String, String>? params}) {
    String pluralKey;

    if (count == 0) {
      pluralKey = '${key}_zero';
    } else if (count == 1) {
      pluralKey = '${key}_one';
    } else {
      pluralKey = '${key}_other';
    }

    // Try to get specific plural form
    String? text = _localizedStrings[_currentLanguage]?[pluralKey];

    // Fallback to base key if plural form not found
    if (text == null) {
      text = getString(key, params: params);
    } else {
      // Replace parameters if provided
      if (params != null) {
        params.forEach((param, value) {
          text = text!.replaceAll('{$param}', value);
        });
      }
    }

    // Replace count parameter
    text = text!.replaceAll('{count}', count.toString());

    return text ?? '';
  }

  /// Change current language
  Future<void> changeLanguage(String languageCode) async {
    await _errorHandler.handleAsyncError('Change language to: $languageCode',
        () async {
      if (!supportedLanguages.any((lang) => lang.code == languageCode)) {
        throw ArgumentError('Unsupported language code: $languageCode');
      }

      _currentLanguage = languageCode;

      // Save to storage
      if (_storageService != null) {
        await _storageService!.setLanguagePreference(languageCode);
      }

      _logger.info('Language changed to: $languageCode');
    });
  }

  /// Get formatted date string
  String formatDate(DateTime date, {DateFormat format = DateFormat.medium}) {
    // This would typically use intl package for proper date formatting
    // For now, providing basic formatting
    switch (format) {
      case DateFormat.short:
        return '${date.day}/${date.month}/${date.year}';
      case DateFormat.medium:
        return '${date.day} ${_getMonthName(date.month)} ${date.year}';
      case DateFormat.long:
        return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  /// Get formatted time string
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period =
        time.period == DayPeriod.am ? getString('am') : getString('pm');

    return '$hour:$minute $period';
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];

    if (month >= 1 && month <= 12) {
      return getString(months[month - 1]);
    }
    return month.toString();
  }

  /// Get day name
  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    if (weekday >= 1 && weekday <= 7) {
      return getString(days[weekday - 1]);
    }
    return weekday.toString();
  }

  /// Get localized number string
  String formatNumber(num number) {
    // For Arabic and other RTL languages, you might want to use different number formats
    return number.toString();
  }

  /// Get all available languages
  List<Language> getAvailableLanguages() {
    return supportedLanguages;
  }

  /// Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.any((lang) => lang.code == languageCode);
  }

  /// Get device's default language if supported
  String getDeviceLanguage() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceLanguage = deviceLocale.languageCode;

    if (isLanguageSupported(deviceLanguage)) {
      return deviceLanguage;
    }

    return 'en'; // Default to English
  }

  /// Auto-detect and set best language
  Future<void> autoDetectLanguage() async {
    await _errorHandler.handleAsyncError('Auto-detect language', () async {
      final deviceLanguage = getDeviceLanguage();

      if (deviceLanguage != _currentLanguage) {
        await changeLanguage(deviceLanguage);
        _logger.info('Auto-detected and set language to: $deviceLanguage');
      }
    });
  }
}

/// Language model
class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$nativeName ($name)';
}

/// Date format enum
enum DateFormat {
  short,
  medium,
  long,
}

/// Localization delegate for Flutter
class AppLocalizationDelegate
    extends LocalizationsDelegate<LocalizationService> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationService.supportedLanguages
        .any((lang) => lang.code == locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    final service = LocalizationService.instance;
    if (service.isLanguageSupported(locale.languageCode)) {
      await service.changeLanguage(locale.languageCode);
    }
    return service;
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

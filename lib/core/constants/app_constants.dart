/// Application constants for configuration and settings
class AppConstants {
  // App Information
  static const String appName = 'Revive - The Sunnah Reminder';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A Flutter app to help Muslims revive forgotten Sunnahs with daily reminders and gamified motivation.';
  
  // Database
  static const String databaseName = 'revive_app.db';
  static const int databaseVersion = 1;
  
  // Notification
  static const String notificationChannelId = 'revive_daily_sunnah';
  static const String notificationChannelName = 'Daily Sunnah Reminders';
  static const String notificationChannelDescription = 'Daily notifications for Sunnah reminders';
  static const int dailyNotificationId = 1;
  
  // Default Settings
  static const String defaultNotificationTime = '09:00';
  static const bool defaultNotificationEnabled = true;
  static const String defaultTheme = 'system';
  static const String defaultLanguage = 'en';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Paths
  static const String assetsPath = 'assets/';
  static const String imagesPath = '${assetsPath}images/';
  static const String animationsPath = '${assetsPath}animations/';
  static const String dataPath = '${assetsPath}data/';
  static const String sunnahsJsonPath = '${dataPath}sunnahs.json';
  
  // Streak Configuration
  static const int maxStreakToShow = 365;
  static const int streakResetHour = 0; // Reset at midnight
  
  // Categories
  static const List<String> sunnahCategories = [
    'Eating',
    'Sleeping',
    'Social',
    'Daily',
    'Hygiene',
    'Prayer',
    'Travel',
    'Worship',
  ];
  
  // Colors (Hex values)
  static const int primaryColorValue = 0xFF2E7D32;
  static const int secondaryColorValue = 0xFF4CAF50;
  static const int accentColorValue = 0xFF8BC34A;
  static const int errorColorValue = 0xFFD32F2F;
  static const int warningColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF4CAF50;
  
  // Text Sizes
  static const double titleTextSize = 24.0;
  static const double headingTextSize = 20.0;
  static const double bodyTextSize = 16.0;
  static const double captionTextSize = 14.0;
  static const double smallTextSize = 12.0;
  
  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxNoteLength = 500;
  
  // Privacy & Terms URLs (would be actual URLs in production)
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmailUrl = 'mailto:support@reviveapp.com';
  
  // Feature Flags
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableDarkMode = true;
  static const bool enableLanguageSelection = true;
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB
  
  // Performance
  static const int listViewCacheExtent = 1000;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  
  // Accessibility
  static const double minTouchTargetSize = 48.0;
  static const double accessibilityFontScale = 1.2;
  
  // Development
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceOverlay = false;
  static const bool enableInspector = false;
  
  // Storage Keys (used as suffixes with app prefix)
  static const String keyTodaySunnah = 'today_sunnah';
  static const String keyLastSunnahDate = 'last_sunnah_date';
  static const String keyUsedSunnahIds = 'used_sunnah_ids';
  static const String keyStreakCount = 'streak_count';
  static const String keyLastStreakDate = 'last_streak_date';
  static const String keyTotalCompleted = 'total_completed';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyNotificationTime = 'notification_time';
  static const String keyThemePreference = 'theme_preference';
  static const String keyLanguagePreference = 'language_preference';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyPrivacyPolicyAccepted = 'privacy_policy_accepted';
}
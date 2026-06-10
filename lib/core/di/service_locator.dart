import 'package:shared_preferences/shared_preferences.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';
import 'package:revive_sunnah_reminder/core/services/validation_service.dart';
import 'package:revive_sunnah_reminder/core/services/data_sanitization_service.dart';
import 'package:revive_sunnah_reminder/core/services/encryption_service.dart';
import 'package:revive_sunnah_reminder/core/services/permissions_service.dart';
import 'package:revive_sunnah_reminder/core/services/accessibility_service.dart';
import 'package:revive_sunnah_reminder/core/services/localization_service.dart';
import 'package:revive_sunnah_reminder/core/services/offline_service.dart';
import 'package:revive_sunnah_reminder/core/services/lazy_loading_service.dart';
import 'package:revive_sunnah_reminder/core/services/image_optimization_service.dart';
import 'package:revive_sunnah_reminder/services/notification_service.dart';
import 'package:revive_sunnah_reminder/services/ai_chat_service.dart';
import 'package:revive_sunnah_reminder/providers/sunnah_provider.dart';
import 'package:revive_sunnah_reminder/providers/streak_provider.dart';
import 'package:revive_sunnah_reminder/providers/credits_provider.dart';
import 'package:revive_sunnah_reminder/providers/chat_provider.dart';
import 'package:revive_sunnah_reminder/core/services/database_service.dart';
import 'package:revive_sunnah_reminder/core/services/network_service.dart';
import 'package:revive_sunnah_reminder/core/services/storage_service.dart';

/// Simple service locator implementation
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  final Map<Type, Function> _factories = {};

  /// Register a singleton service
  void registerSingleton<T>(T service) {
    _services[T] = service;
  }

  /// Register a lazy singleton service
  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Register a factory service
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Get a service instance
  T get<T>() {
    // Check if singleton exists
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }

    // Check if factory exists
    if (_factories.containsKey(T)) {
      final factory = _factories[T] as T Function();
      final instance = factory();

      // For lazy singletons, store the instance
      if (!_services.containsKey(T)) {
        _services[T] = instance;
      }

      return instance;
    }

    throw Exception('Service of type $T is not registered');
  }

  /// Reset all services
  Future<void> reset() async {
    _services.clear();
    _factories.clear();
  }
}

/// Service locator instance
final ServiceLocator serviceLocator = ServiceLocator();

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core services (singletons)
  serviceLocator.registerLazySingleton<LoggingService>(
    () => LoggingService.instance,
  );

  serviceLocator.registerLazySingleton<ErrorHandlingService>(
    () => ErrorHandlingService.instance,
  );

  serviceLocator.registerLazySingleton<ValidationService>(
    () => ValidationService.instance,
  );

  serviceLocator.registerLazySingleton<DataSanitizationService>(
    () => DataSanitizationService.instance,
  );

  serviceLocator.registerLazySingleton<EncryptionService>(
    () => EncryptionService.instance,
  );

  serviceLocator.registerLazySingleton<PermissionsService>(
    () => PermissionsService.instance,
  );

  serviceLocator.registerLazySingleton<AccessibilityService>(
    () => AccessibilityService.instance,
  );

  serviceLocator.registerLazySingleton<LocalizationService>(
    () => LocalizationService.instance,
  );

  serviceLocator.registerLazySingleton<ImageOptimizationService>(
    () => ImageOptimizationService.instance,
  );

  serviceLocator.registerLazySingleton<OfflineService>(
    () => OfflineService.instance,
  );

  // Database
  serviceLocator.registerLazySingleton<DatabaseService>(
    () => DatabaseService(),
  );

  // Network
  serviceLocator.registerLazySingleton<NetworkService>(
    () => NetworkService(),
  );

  // Storage
  serviceLocator.registerLazySingleton<StorageService>(
    () => StorageService(serviceLocator.get<SharedPreferences>()),
  );

  // Lazy loading service
  serviceLocator.registerLazySingleton<LazyLoadingService>(
    () => LazyLoadingService(
      databaseService: serviceLocator.get<DatabaseService>(),
      loggingService: serviceLocator.get<LoggingService>(),
    ),
  );

  // Notification service
  serviceLocator.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  // AI Chat service
  serviceLocator.registerLazySingleton<AIChatService>(
    () => AIChatService(),
  );

  // Providers (lazy singletons for better state management)
  serviceLocator.registerLazySingleton<SunnahProvider>(
    () => SunnahProvider(
      databaseService: serviceLocator.get<DatabaseService>(),
      storageService: serviceLocator.get<StorageService>(),
      loggingService: serviceLocator.get<LoggingService>(),
    ),
  );

  serviceLocator.registerLazySingleton<StreakProvider>(
    () => StreakProvider(),
  );

  serviceLocator.registerLazySingleton<CreditsProvider>(
    () => CreditsProvider(serviceLocator.get<StorageService>()),
  );

  serviceLocator.registerLazySingleton<ChatProvider>(
    () => ChatProvider(
      aiService: serviceLocator.get<AIChatService>(),
      storageService: serviceLocator.get<StorageService>(),
    ),
  );

  // Initialize services that need setup
  await _initializeServices();

  // Initialize database with initial data
  final databaseService = serviceLocator.get<DatabaseService>();
  await databaseService.initialize();

  // Initialize encryption service
  final encryptionService = serviceLocator.get<EncryptionService>();
  await encryptionService.initialize();

  // Initialize credits
  final creditsProvider = serviceLocator.get<CreditsProvider>();
  await creditsProvider.initialize();

  final chatProvider = serviceLocator.get<ChatProvider>();
  await chatProvider.initialize();
}

/// Initialize services that require async setup
Future<void> _initializeServices() async {
  final loggingService = serviceLocator.get<LoggingService>();
  final errorHandlingService = serviceLocator.get<ErrorHandlingService>();

  try {
    // Initialize core services first
    loggingService.initialize();
    errorHandlingService.initialize();

    // Initialize other services that don't have complex dependencies
    final accessibilityService = serviceLocator.get<AccessibilityService>();
    accessibilityService.initialize();

    // Initialize notification service
    final notificationService = serviceLocator.get<NotificationService>();
    await notificationService.initialize();

    loggingService.info('Core services initialized successfully');
  } catch (error, stackTrace) {
    loggingService.fatal('Failed to initialize services', error, stackTrace);
    rethrow;
  }
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await serviceLocator.reset();
}

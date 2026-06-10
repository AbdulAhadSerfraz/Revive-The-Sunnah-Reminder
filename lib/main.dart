import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/core/di/service_locator.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/global_error_handler.dart';
import 'package:revive_sunnah_reminder/core/constants/app_constants.dart';
import 'package:revive_sunnah_reminder/providers/sunnah_provider.dart';
import 'package:revive_sunnah_reminder/providers/streak_provider.dart';
import 'package:revive_sunnah_reminder/providers/credits_provider.dart';
import 'package:revive_sunnah_reminder/providers/chat_provider.dart';
import 'package:revive_sunnah_reminder/screens/splash_screen.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging first
  LoggingService.instance.initialize();
  final logger = LoggingService.instance;

  try {
    logger.info('Starting app initialization');

    // Initialize global error handling
    GlobalErrorHandler.initialize();

    // Set production system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize all dependencies
    await initializeDependencies();

    logger.info('App initialization completed successfully');

    runApp(const ReviveApp());
  } catch (error, stackTrace) {
    logger.fatal('Failed to initialize app', error, stackTrace);

    // Run a minimal error app
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to start the app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please restart the application',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Close App'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class ReviveApp extends StatelessWidget {
  const ReviveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SunnahProvider>(
          create: (_) => serviceLocator.get<SunnahProvider>(),
        ),
        ChangeNotifierProvider<StreakProvider>(
          create: (_) => serviceLocator.get<StreakProvider>(),
        ),
        ChangeNotifierProvider<CreditsProvider>(
          create: (_) => serviceLocator.get<CreditsProvider>(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => serviceLocator.get<ChatProvider>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        themeMode: ThemeMode.light, // Light theme only as per user preference
        home: const SplashScreen(),
        builder: (context, child) {
          // Global error boundary
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return _buildErrorWidget(errorDetails);
          };

          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }

  /// Build production-ready theme with WCAG AA compliance
  /// Following design tokens and accessibility guidelines
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.green,
      primaryColor: AppColors.secondary,

      // Production color scheme with accessibility compliance
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        brightness: Brightness.light,

        // 60% - Dominant neutral colors (largest areas)
        surface: AppColors.dominantSurface,
        onSurface: AppColors.textSecondary,
        surfaceContainerHighest: AppColors.dominant,
        surfaceContainer: AppColors.getDominantColor(dark: true),

        // 30% - Secondary colors (supporting elements)
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnColor,
        secondaryContainer: AppColors.getSecondaryColor(alpha: 0.1),
        onSecondaryContainer: AppColors.textPrimary,

        // 10% - Accent colors (high-impact elements)
        primary: AppColors.accent,
        onPrimary: AppColors.textOnColor,
        primaryContainer: AppColors.getAccentColor(alpha: 0.1),
        onPrimaryContainer: AppColors.textPrimary,

        // System colors using accessible palette
        outline: AppColors.getSecondaryColor(alpha: 0.2),
        outlineVariant: AppColors.getSecondaryColor(alpha: 0.1),
        shadow: AppColors.secondary.withValues(alpha: 0.08),

        // Semantic colors with proper contrast
        error: AppColors.error,
        onError: AppColors.textOnColor,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorDark,
      ),

      // Production typography system
      textTheme: AppTypography.generateTextTheme(),

      // Enhanced app bar theme with proper spacing
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dominantSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: DesignTokens.elevationNone,
        centerTitle: false,
        shadowColor: AppColors.secondary.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Production card theme with design tokens
      cardTheme: CardThemeData(
        elevation: DesignTokens.elevationSm,
        color: AppColors.dominantSurface,
        shadowColor: AppColors.getSecondaryColor(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          side: BorderSide(
            color: AppColors.getSecondaryColor(alpha: 0.1),
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceSm,
        ),
      ),

      // Enhanced button themes with proper accessibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnColor,
          elevation: DesignTokens.elevationSm,
          shadowColor: AppColors.accent.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceLg,
          ),
          textStyle: AppTypography.labelLarge,
          minimumSize: Size(0, 48), // Minimum touch target for accessibility
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnColor,
          elevation: DesignTokens.elevationNone,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceLg,
          ),
          minimumSize: Size(0, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: BorderSide(
            color: AppColors.secondary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceLg,
          ),
          minimumSize: Size(0, 48),
        ),
      ),

      // Production scaffold background
      scaffoldBackgroundColor: AppColors.dominant,

      // Enhanced input decoration with design tokens
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          borderSide: BorderSide(
            color: AppColors.getSecondaryColor(alpha: 0.3),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          borderSide: BorderSide(
            color: AppColors.getSecondaryColor(alpha: 0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          borderSide: BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: AppColors.dominantSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceLg,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),

      // Enhanced bottom navigation with proper spacing
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.dominantSurface,
        elevation: DesignTokens.elevationLg,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: AppTypography.weightSemiBold,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // Progress indicators with brand colors
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.getAccentColor(alpha: 0.2),
        circularTrackColor: AppColors.getAccentColor(alpha: 0.2),
      ),

      // Dividers with subtle styling
      dividerTheme: DividerThemeData(
        color: AppColors.getSecondaryColor(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),

      // Enhanced chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.getSecondaryColor(alpha: 0.1),
        selectedColor: AppColors.getAccentColor(alpha: 0.2),
        disabledColor: AppColors.getDominantColor(dark: true),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        elevation: DesignTokens.elevationNone,
        pressElevation: DesignTokens.elevationXs,
      ),
    );
  }

  /// Build production-ready error widget with accessibility
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return Material(
      child: Container(
        color: AppColors.errorLight,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignTokens.space2xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: DesignTokens.space6xl,
                  color: AppColors.error,
                ),
                SizedBox(height: DesignTokens.space2xl),
                Text(
                  'Something went wrong',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.errorDark,
                  ),
                ),
                SizedBox(height: DesignTokens.spaceLg),
                Text(
                  'Please restart the app',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: DesignTokens.space3xl),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textOnColor,
                  ),
                  child: Text('Close App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Responsive Typography Utility for Mobile-First Design
/// Implements adaptive text scaling based on screen size and device characteristics
class ResponsiveText {
  // Private constructor to prevent instantiation
  ResponsiveText._();

  // ============================================================================
  // SCREEN SIZE BREAKPOINTS
  // ============================================================================
  
  /// Extra small screens (e.g., iPhone SE, older Android devices)
  static const double _extraSmallWidth = 320.0;
  
  /// Small screens (e.g., iPhone 12/13 mini)
  static const double _smallWidth = 360.0;
  
  /// Medium screens (e.g., iPhone 12/13, Pixel 6)
  static const double _mediumWidth = 390.0;
  
  /// Large screens (e.g., iPhone 12/13 Pro Max, large Android phones)
  static const double _largeWidth = 430.0;
  
  // ============================================================================
  // TYPOGRAPHY SCALE FACTORS
  // ============================================================================
  
  /// Scale factors for different screen sizes
  /// Based on Material Design and iOS Human Interface Guidelines
  static const Map<String, double> _scaleFactors = {
    'extraSmall': 0.85,  // 15% smaller text for very small screens
    'small': 0.92,       // 8% smaller text for small screens  
    'medium': 1.0,       // Base size for medium screens
    'large': 1.08,       // 8% larger text for large screens
    'extraLarge': 1.15,  // 15% larger text for extra large screens
  };
  
  // ============================================================================
  // RESPONSIVE TEXT SIZE METHODS
  // ============================================================================
  
  /// Get responsive font size based on screen width and base size
  static double getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = _getScaleFactor(screenWidth);
    return baseSize * scaleFactor;
  }
  
  /// Get scale factor based on screen width
  static double _getScaleFactor(double screenWidth) {
    if (screenWidth <= _extraSmallWidth) {
      return _scaleFactors['extraSmall']!;
    } else if (screenWidth <= _smallWidth) {
      return _scaleFactors['small']!;
    } else if (screenWidth <= _mediumWidth) {
      return _scaleFactors['medium']!;
    } else if (screenWidth <= _largeWidth) {
      return _scaleFactors['large']!;
    } else {
      return _scaleFactors['extraLarge']!;
    }
  }
  
  // ============================================================================
  // PREDEFINED RESPONSIVE TEXT STYLES
  // ============================================================================
  
  /// Display Large - Main app headings
  static TextStyle displayLarge(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 32.0),
      fontWeight: fontWeight ?? FontWeight.w800,
      color: color,
      letterSpacing: letterSpacing ?? -0.5,
      height: 1.2,
    );
  }
  
  /// Display Medium - Section headings
  static TextStyle displayMedium(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 28.0),
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing ?? -0.25,
      height: 1.25,
    );
  }
  
  /// Headline Large - Card titles and important headings
  static TextStyle headlineLarge(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 24.0),
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing ?? -0.25,
      height: 1.3,
    );
  }
  
  /// Headline Medium - Sub-headings
  static TextStyle headlineMedium(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 22.0),
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing ?? 0.0,
      height: 1.3,
    );
  }
  
  /// Headline Small - Card sub-titles
  static TextStyle headlineSmall(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 20.0),
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing ?? 0.0,
      height: 1.35,
    );
  }
  
  /// Title Large - Button labels and important actions
  static TextStyle titleLarge(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 18.0),
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing ?? 0.15,
      height: 1.4,
    );
  }
  
  /// Title Medium - Navigation and secondary actions
  static TextStyle titleMedium(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 16.0),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing ?? 0.15,
      height: 1.4,
    );
  }
  
  /// Title Small - Small labels and tags
  static TextStyle titleSmall(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 14.0),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing ?? 0.1,
      height: 1.4,
    );
  }
  
  /// Body Large - Main content text
  static TextStyle bodyLarge(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 16.0),
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing ?? 0.15,
      height: height ?? 1.5,
    );
  }
  
  /// Body Medium - Supporting text content
  static TextStyle bodyMedium(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 14.0),
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing ?? 0.25,
      height: height ?? 1.5,
    );
  }
  
  /// Body Small - Caption and metadata
  static TextStyle bodySmall(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 12.0),
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.4,
    );
  }
  
  /// Label Large - Button text and form labels
  static TextStyle labelLarge(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 14.0),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing ?? 0.1,
      height: 1.4,
    );
  }
  
  /// Label Medium - Form fields and chips
  static TextStyle labelMedium(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 12.0),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
      height: 1.3,
    );
  }
  
  /// Label Small - Tiny labels and badges
  static TextStyle labelSmall(BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: getResponsiveSize(context, 11.0),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
      height: 1.3,
    );
  }
  
  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Check if the current screen is considered small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= _smallWidth;
  }
  
  /// Check if the current screen is considered medium
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > _smallWidth && width <= _mediumWidth;
  }
  
  /// Check if the current screen is considered large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > _largeWidth;
  }
  
  /// Get current screen size category
  static String getScreenSizeCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= _extraSmallWidth) return 'extraSmall';
    if (width <= _smallWidth) return 'small';
    if (width <= _mediumWidth) return 'medium';
    if (width <= _largeWidth) return 'large';
    return 'extraLarge';
  }
  
  /// Get readable text size for accessibility
  /// Ensures minimum 12px font size for readability
  static double getAccessibleSize(BuildContext context, double baseSize) {
    final responsiveSize = getResponsiveSize(context, baseSize);
    return responsiveSize < 12.0 ? 12.0 : responsiveSize;
  }
}

/// Extension to easily access responsive text styles
extension ResponsiveTextExtension on BuildContext {
  /// Access responsive text utility
  ResponsiveText get text => ResponsiveText._();
  
  /// Quick access to common responsive sizes
  double responsiveSize(double baseSize) => ResponsiveText.getResponsiveSize(this, baseSize);
  
  /// Quick screen size checks
  bool get isSmallScreen => ResponsiveText.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveText.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveText.isLargeScreen(this);
  
  /// Quick access to screen size category
  String get screenSize => ResponsiveText.getScreenSizeCategory(this);
}

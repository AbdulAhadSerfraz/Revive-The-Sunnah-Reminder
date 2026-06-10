import 'package:flutter/material.dart';

/// Production-ready design tokens system
/// Following 8px grid system and accessibility guidelines
class DesignTokens {
  // Private constructor to prevent instantiation
  DesignTokens._();

  // ============================================================================
  // SPACING SYSTEM (8px Grid)
  // ============================================================================

  /// Extra small spacing - 4px (0.5 * base)
  static const double spaceXs = 4.0;

  /// Small spacing - 8px (base unit)
  static const double spaceSm = 8.0;

  /// Medium spacing - 12px (1.5 * base)
  static const double spaceMd = 12.0;

  /// Large spacing - 16px (2 * base)
  static const double spaceLg = 16.0;

  /// Extra large spacing - 20px (2.5 * base)
  static const double spaceXl = 20.0;

  /// Double extra large spacing - 24px (3 * base)
  static const double space2xl = 24.0;

  /// Triple extra large spacing - 32px (4 * base)
  static const double space3xl = 32.0;

  /// Quadruple extra large spacing - 40px (5 * base)
  static const double space4xl = 40.0;

  /// Quintuple extra large spacing - 48px (6 * base)
  static const double space5xl = 48.0;

  /// Sextuple extra large spacing - 64px (8 * base)
  static const double space6xl = 64.0;

  // ============================================================================
  // TYPOGRAPHY SCALE (1.25 Ratio - Perfect Fourth)
  // ============================================================================

  /// Caption text - 12px
  static const double textXs = 12.0;

  /// Small body text - 14px
  static const double textSm = 14.0;

  /// Base body text - 16px (base unit)
  static const double textBase = 16.0;

  /// Large body text - 18px
  static const double textLg = 18.0;

  /// Extra large text - 20px
  static const double textXl = 20.0;

  /// Heading 6 - 24px
  static const double text2xl = 24.0;

  /// Heading 5 - 28px
  static const double text3xl = 28.0;

  /// Heading 4 - 32px
  static const double text4xl = 32.0;

  /// Heading 3 - 40px
  static const double text5xl = 40.0;

  /// Heading 2 - 48px
  static const double text6xl = 48.0;

  /// Heading 1 - 56px
  static const double text7xl = 56.0;

  // ============================================================================
  // BORDER RADIUS SCALE
  // ============================================================================

  /// None - 0px
  static const double radiusNone = 0.0;

  /// Small radius - 4px
  static const double radiusSm = 4.0;

  /// Medium radius - 8px
  static const double radiusMd = 8.0;

  /// Large radius - 12px
  static const double radiusLg = 12.0;

  /// Extra large radius - 16px
  static const double radiusXl = 16.0;

  /// Double extra large radius - 20px
  static const double radius2xl = 20.0;

  /// Triple extra large radius - 24px
  static const double radius3xl = 24.0;

  /// Full radius - 9999px (pill shape)
  static const double radiusFull = 9999.0;

  // ============================================================================
  // ELEVATION/SHADOW SCALE
  // ============================================================================

  /// No shadow
  static const double elevationNone = 0.0;

  /// Subtle shadow - 1dp
  static const double elevationXs = 1.0;

  /// Small shadow - 2dp
  static const double elevationSm = 2.0;

  /// Medium shadow - 4dp
  static const double elevationMd = 4.0;

  /// Large shadow - 8dp
  static const double elevationLg = 8.0;

  /// Extra large shadow - 12dp
  static const double elevationXl = 12.0;

  /// Double extra large shadow - 16dp
  static const double elevation2xl = 16.0;

  /// Triple extra large shadow - 24dp
  static const double elevation3xl = 24.0;

  // ============================================================================
  // OPACITY SCALE
  // ============================================================================

  /// Fully transparent
  static const double opacity0 = 0.0;

  /// Very subtle
  static const double opacity5 = 0.05;

  /// Subtle
  static const double opacity10 = 0.1;

  /// Light
  static const double opacity20 = 0.2;

  /// Medium light
  static const double opacity30 = 0.3;

  /// Medium
  static const double opacity40 = 0.4;

  /// Medium strong
  static const double opacity50 = 0.5;

  /// Strong
  static const double opacity60 = 0.6;

  /// Very strong
  static const double opacity70 = 0.7;

  /// Almost opaque
  static const double opacity80 = 0.8;

  /// Nearly opaque
  static const double opacity90 = 0.9;

  /// Fully opaque
  static const double opacity100 = 1.0;

  // ============================================================================
  // LINE HEIGHT SCALE
  // ============================================================================

  /// Tight line height - 1.25
  static const double lineHeightTight = 1.25;

  /// Snug line height - 1.375
  static const double lineHeightSnug = 1.375;

  /// Normal line height - 1.5
  static const double lineHeightNormal = 1.5;

  /// Relaxed line height - 1.625
  static const double lineHeightRelaxed = 1.625;

  /// Loose line height - 2.0
  static const double lineHeightLoose = 2.0;

  // ============================================================================
  // BREAKPOINTS (for responsive design)
  // ============================================================================

  /// Small screens (phones) - up to 480px
  static const double breakpointSm = 480.0;

  /// Medium screens (tablets) - up to 768px
  static const double breakpointMd = 768.0;

  /// Large screens (laptops) - up to 1024px
  static const double breakpointLg = 1024.0;

  /// Extra large screens (desktops) - up to 1280px
  static const double breakpointXl = 1280.0;

  /// Double extra large screens - 1536px and up
  static const double breakpoint2xl = 1536.0;

  // ============================================================================
  // ANIMATION TIMING
  // ============================================================================

  /// Very fast animation - 150ms
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Normal animation - 200ms
  static const Duration durationNormal = Duration(milliseconds: 200);

  /// Medium animation - 300ms
  static const Duration durationMedium = Duration(milliseconds: 300);

  /// Slow animation - 500ms
  static const Duration durationSlow = Duration(milliseconds: 500);

  /// Very slow animation - 700ms
  static const Duration durationSlower = Duration(milliseconds: 700);

  // ============================================================================
  // CURVES (animation easing)
  // ============================================================================

  /// Standard easing curve
  static const Curve curveStandard = Curves.easeInOutCubic;

  /// Emphasized easing curve
  static const Curve curveEmphasized = Curves.easeOutBack;

  /// Decelerated easing curve
  static const Curve curveDecelerated = Curves.easeOut;

  /// Accelerated easing curve
  static const Curve curveAccelerated = Curves.easeIn;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < breakpointSm) {
      return baseSpacing * 0.75; // 25% smaller on small screens
    } else if (screenWidth > breakpointLg) {
      return baseSpacing * 1.25; // 25% larger on large screens
    }

    return baseSpacing; // Default size on medium screens
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < breakpointSm) {
      return baseFontSize * 0.9; // 10% smaller on small screens
    } else if (screenWidth > breakpointLg) {
      return baseFontSize * 1.1; // 10% larger on large screens
    }

    return baseFontSize; // Default size on medium screens
  }

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointSm;
  }

  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > breakpointLg;
  }
}

/// Extension to easily access design tokens from BuildContext
extension DesignTokensExtension on BuildContext {
  /// Get responsive spacing
  double spacing(double baseSpacing) =>
      DesignTokens.getResponsiveSpacing(this, baseSpacing);

  /// Get responsive font size
  double fontSize(double baseFontSize) =>
      DesignTokens.getResponsiveFontSize(this, baseFontSize);

  /// Check if small screen
  bool get isSmallScreen => DesignTokens.isSmallScreen(this);

  /// Check if large screen
  bool get isLargeScreen => DesignTokens.isLargeScreen(this);
}

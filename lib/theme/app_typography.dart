import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';

/// Production-ready typography system
/// Following Material Design 3 and accessibility guidelines
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // ============================================================================
  // BASE FONT CONFIGURATION
  // ============================================================================

  /// Primary font family for the app
  static String get primaryFontFamily => 'Roboto';

  /// Secondary font family for emphasis
  static String get secondaryFontFamily => 'Roboto';

  /// Font family for Arabic text
  static String get arabicFontFamily => 'Amiri';

  // ============================================================================
  // FONT WEIGHT SCALE
  // ============================================================================

  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightExtraLight = FontWeight.w200;
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;
  static const FontWeight weightBlack = FontWeight.w900;

  // ============================================================================
  // DISPLAY TEXT STYLES (Headlines)
  // ============================================================================

  /// Display Large - 57px
  /// Used for: Large marketing headlines, hero text
  static TextStyle get displayLarge => GoogleFonts.roboto(
        fontSize: DesignTokens.text7xl,
        fontWeight: weightBold,
        height: DesignTokens.lineHeightTight,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      );

  /// Display Medium - 45px
  /// Used for: Section headers, important headlines
  static TextStyle get displayMedium => GoogleFonts.roboto(
        fontSize: DesignTokens.text6xl,
        fontWeight: weightBold,
        height: DesignTokens.lineHeightTight,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  /// Display Small - 36px
  /// Used for: Page titles, modal headers
  static TextStyle get displaySmall => GoogleFonts.roboto(
        fontSize: DesignTokens.text5xl,
        fontWeight: weightBold,
        height: DesignTokens.lineHeightTight,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // ============================================================================
  // HEADLINE TEXT STYLES
  // ============================================================================

  /// Headline Large - 32px
  /// Used for: Screen titles, section headers
  static TextStyle get headlineLarge => GoogleFonts.roboto(
        fontSize: DesignTokens.text4xl,
        fontWeight: weightBold,
        height: DesignTokens.lineHeightTight,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  /// Headline Medium - 28px
  /// Used for: Card titles, prominent headers
  static TextStyle get headlineMedium => GoogleFonts.roboto(
        fontSize: DesignTokens.text3xl,
        fontWeight: weightSemiBold,
        height: DesignTokens.lineHeightTight,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  /// Headline Small - 24px
  /// Used for: Dialog titles, component headers
  static TextStyle get headlineSmall => GoogleFonts.roboto(
        fontSize: DesignTokens.text2xl,
        fontWeight: weightSemiBold,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // ============================================================================
  // TITLE TEXT STYLES
  // ============================================================================

  /// Title Large - 22px
  /// Used for: List item headers, card titles
  static TextStyle get titleLarge => GoogleFonts.roboto(
        fontSize: DesignTokens.textXl + 2,
        fontWeight: weightSemiBold,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  /// Title Medium - 16px
  /// Used for: Subheaders, emphasized text
  static TextStyle get titleMedium => GoogleFonts.roboto(
        fontSize: DesignTokens.textBase,
        fontWeight: weightMedium,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      );

  /// Title Small - 14px
  /// Used for: Dense UI titles, table headers
  static TextStyle get titleSmall => GoogleFonts.roboto(
        fontSize: DesignTokens.textSm,
        fontWeight: weightMedium,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.1,
        color: AppColors.textSecondary,
      );

  // ============================================================================
  // BODY TEXT STYLES
  // ============================================================================

  /// Body Large - 16px
  /// Used for: Main content, paragraph text
  static TextStyle get bodyLarge => GoogleFonts.roboto(
        fontSize: DesignTokens.textBase,
        fontWeight: weightRegular,
        height: DesignTokens.lineHeightRelaxed,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  /// Body Medium - 14px
  /// Used for: Secondary content, descriptions
  static TextStyle get bodyMedium => GoogleFonts.roboto(
        fontSize: DesignTokens.textSm,
        fontWeight: weightRegular,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.25,
        color: AppColors.textSecondary,
      );

  /// Body Small - 12px
  /// Used for: Supporting text, captions
  static TextStyle get bodySmall => GoogleFonts.roboto(
        fontSize: DesignTokens.textXs,
        fontWeight: weightRegular,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.4,
        color: AppColors.textTertiary,
      );

  // ============================================================================
  // LABEL TEXT STYLES (Buttons, Chips, etc.)
  // ============================================================================

  /// Label Large - 14px
  /// Used for: Button text, prominent labels
  static TextStyle get labelLarge => GoogleFonts.roboto(
        fontSize: DesignTokens.textSm,
        fontWeight: weightMedium,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  /// Label Medium - 12px
  /// Used for: Chip labels, small buttons
  static TextStyle get labelMedium => GoogleFonts.roboto(
        fontSize: DesignTokens.textXs,
        fontWeight: weightMedium,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  /// Label Small - 11px
  /// Used for: Dense UI labels, badges
  static TextStyle get labelSmall => GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: weightMedium,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      );

  // ============================================================================
  // SPECIALIZED TEXT STYLES
  // ============================================================================

  /// Arabic Text Style
  /// Used for: Quran verses, Arabic hadith text
  static TextStyle get arabicText => GoogleFonts.amiri(
        fontSize: DesignTokens.textLg,
        fontWeight: weightRegular,
        height: DesignTokens.lineHeightLoose,
        color: AppColors.textPrimary,
      );

  /// Arabic Large Text Style
  /// Used for: Prominent Arabic text
  static TextStyle get arabicLarge => GoogleFonts.amiri(
        fontSize: DesignTokens.textXl,
        fontWeight: weightMedium,
        height: DesignTokens.lineHeightLoose,
        color: AppColors.textPrimary,
      );

  /// Monospace Text Style
  /// Used for: Code, references, technical text
  static TextStyle get monospace => GoogleFonts.robotoMono(
        fontSize: DesignTokens.textSm,
        fontWeight: weightRegular,
        height: DesignTokens.lineHeightNormal,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  /// Quote Text Style
  /// Used for: Quotations, hadith text
  static TextStyle get quote => GoogleFonts.roboto(
        fontSize: DesignTokens.textBase,
        fontWeight: weightRegular,
        height: DesignTokens.lineHeightRelaxed,
        fontStyle: FontStyle.italic,
        color: AppColors.textSecondary,
      );

  // ============================================================================
  // RESPONSIVE TEXT STYLES
  // ============================================================================

  /// Get responsive text style based on screen size
  static TextStyle getResponsiveStyle(
    BuildContext context,
    TextStyle baseStyle, {
    double scaleFactor = 1.0,
  }) {
    final responsive = DesignTokens.getResponsiveFontSize(
      context,
      baseStyle.fontSize ?? DesignTokens.textBase,
    );

    return baseStyle.copyWith(
      fontSize: responsive * scaleFactor,
    );
  }

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  // ============================================================================
  // THEME INTEGRATION
  // ============================================================================

  /// Generate complete TextTheme for app
  static TextTheme generateTextTheme({Color? primaryColor}) {
    final textColor = primaryColor ?? AppColors.textPrimary;

    return TextTheme(
      // Display styles
      displayLarge: displayLarge.copyWith(color: textColor),
      displayMedium: displayMedium.copyWith(color: textColor),
      displaySmall: displaySmall.copyWith(color: textColor),

      // Headline styles
      headlineLarge: headlineLarge.copyWith(color: textColor),
      headlineMedium: headlineMedium.copyWith(color: textColor),
      headlineSmall: headlineSmall.copyWith(color: textColor),

      // Title styles
      titleLarge: titleLarge.copyWith(color: textColor),
      titleMedium: titleMedium.copyWith(color: textColor),
      titleSmall: titleSmall.copyWith(color: AppColors.textSecondary),

      // Body styles
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,

      // Label styles
      labelLarge: labelLarge.copyWith(color: textColor),
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  // ============================================================================
  // ACCESSIBILITY HELPERS
  // ============================================================================

  /// Check if text style meets accessibility requirements
  static bool isAccessible(TextStyle style, Color background) {
    final textColor = style.color ?? AppColors.textPrimary;
    return AppColors.isWCAGAACompliant(textColor, background);
  }

  /// Get accessible text color for background
  static Color getAccessibleColor(Color background) {
    return AppColors.getTextColor(background);
  }

  /// Create high contrast version of text style
  static TextStyle makeHighContrast(TextStyle style, Color background) {
    return style.copyWith(
      color: getAccessibleColor(background),
      fontWeight: FontWeight.w600, // Increase weight for better readability
    );
  }
}

/// Extension to easily apply typography styles
extension TextStyleExtension on Text {
  /// Apply display large style
  Text displayLarge() => Text(
        data!,
        style: AppTypography.displayLarge,
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );

  /// Apply headline medium style
  Text headlineMedium() => Text(
        data!,
        style: AppTypography.headlineMedium,
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );

  /// Apply body large style
  Text bodyLarge() => Text(
        data!,
        style: AppTypography.bodyLarge,
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );

  /// Apply body medium style
  Text bodyMedium() => Text(
        data!,
        style: AppTypography.bodyMedium,
        key: key,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );

  /// Apply Arabic text style
  Text arabicText() => Text(
        data!,
        style: AppTypography.arabicText,
        key: key,
        textAlign: textAlign ?? TextAlign.right,
        textDirection: TextDirection.rtl,
        maxLines: maxLines,
        overflow: overflow,
      );
}

/// BuildContext extension for easy typography access
extension TypographyContext on BuildContext {
  /// Get theme's text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get responsive typography
  TextStyle responsiveText(TextStyle baseStyle, {double scaleFactor = 1.0}) {
    return AppTypography.getResponsiveStyle(this, baseStyle,
        scaleFactor: scaleFactor);
  }

  /// Check if current typography is accessible
  bool isTypographyAccessible() {
    final theme = Theme.of(this);
    return AppTypography.isAccessible(
      theme.textTheme.bodyLarge ?? AppTypography.bodyLarge,
      theme.scaffoldBackgroundColor,
    );
  }
}

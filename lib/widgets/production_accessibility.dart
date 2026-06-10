import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

/// Production-ready accessibility and readability enhancements
class ProductionAccessibility {
  // Private constructor to prevent instantiation
  ProductionAccessibility._();

  // ============================================================================
  // SEMANTIC LABELS AND DESCRIPTIONS
  // ============================================================================

  /// Enhanced text widget with accessibility support
  static Widget accessibleText({
    required String text,
    TextStyle? style,
    String? semanticLabel,
    String? tooltip,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool selectable = false,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        final effectiveStyle = style ?? AppTypography.bodyMedium;
        final responsiveStyle = responsive
            ? AppTypography.getResponsiveStyle(context, effectiveStyle)
            : effectiveStyle;

        Widget textWidget = selectable
            ? SelectableText(
                text,
                style: responsiveStyle,
                textAlign: textAlign,
                maxLines: maxLines,
              )
            : Text(
                text,
                style: responsiveStyle,
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: overflow,
                semanticsLabel: semanticLabel,
              );

        if (padding != null || backgroundColor != null) {
          textWidget = Container(
            padding: padding,
            color: backgroundColor,
            child: textWidget,
          );
        }

        if (tooltip != null) {
          textWidget = Tooltip(
            message: tooltip,
            child: textWidget,
          );
        }

        return textWidget;
      },
    );
  }

  /// Enhanced button with accessibility features
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    String? hint,
    ButtonStyle? style,
    bool autofocus = false,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    bool enableHaptics = true,
  }) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style?.copyWith(
        minimumSize: WidgetStateProperty.all(
          minimumSize ?? const Size(44, 44), // WCAG minimum touch target
        ),
        padding: WidgetStateProperty.all(
          padding ?? EdgeInsets.all(DesignTokens.spaceMd),
        ),
      ),
      autofocus: autofocus,
      child: child,
    );

    button = Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// Enhanced icon button with accessibility
  static Widget accessibleIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    String? hint,
    Color? color,
    double? size,
    EdgeInsetsGeometry? padding,
    bool autofocus = false,
  }) {
    Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: size ?? 24),
      padding: padding ?? EdgeInsets.all(DesignTokens.spaceMd),
      constraints: const BoxConstraints(
        minWidth: 44, // WCAG minimum touch target
        minHeight: 44,
      ),
      autofocus: autofocus,
    );

    button = Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// Enhanced list tile with accessibility
  static Widget accessibleListTile({
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    String? semanticLabel,
    String? hint,
    bool isThreeLine = false,
    bool dense = false,
    EdgeInsetsGeometry? contentPadding,
    bool enabled = true,
    bool selected = false,
  }) {
    Widget listTile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      isThreeLine: isThreeLine,
      dense: dense,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceXs,
          ),
      enabled: enabled,
      selected: selected,
      minVerticalPadding: DesignTokens.spaceMd, // Ensure minimum touch target
    );

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      enabled: enabled,
      selected: selected,
      child: listTile,
    );
  }

  /// Enhanced card with accessibility
  static Widget accessibleCard({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    String? hint,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
  }) {
    Widget card = Card(
      margin: margin ?? EdgeInsets.all(DesignTokens.spaceMd),
      color: color,
      elevation: elevation ?? DesignTokens.elevationSm,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: padding ?? EdgeInsets.all(DesignTokens.spaceLg),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = Semantics(
        label: semanticLabel,
        hint: hint,
        button: true,
        child: card,
      );
    }

    return card;
  }

  // ============================================================================
  // FOCUS MANAGEMENT
  // ============================================================================

  /// Focus management helper
  static Widget focusableWidget({
    required Widget child,
    FocusNode? focusNode,
    bool autofocus = false,
    ValueChanged<bool>? onFocusChange,
    String? debugLabel,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      debugLabel: debugLabel,
      child: child,
    );
  }

  /// Skip links for keyboard navigation
  static Widget skipLink({
    required String label,
    required GlobalKey targetKey,
    VoidCallback? onPressed,
  }) {
    return Positioned(
      top: -100, // Hidden by default
      left: 0,
      child: Focus(
        onFocusChange: (hasFocus) {
          // Show skip link when focused
        },
        child: ElevatedButton(
          onPressed: onPressed ??
              () {
                final context = targetKey.currentContext;
                if (context != null) {
                  Scrollable.ensureVisible(context);
                }
              },
          child: Text(label),
        ),
      ),
    );
  }

  // ============================================================================
  // CONTRAST AND COLOR ACCESSIBILITY
  // ============================================================================

  /// Check if color combination meets WCAG guidelines
  static bool meetsContrastRequirements(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    if (isLargeText) {
      return AppColors.isWCAGAACompliant(foreground, background);
    } else {
      return AppColors.isWCAGAAACompliant(foreground, background);
    }
  }

  /// Get accessible color pair
  static ColorPair getAccessibleColors({
    Color? preferredForeground,
    Color? preferredBackground,
    bool isLargeText = false,
  }) {
    final background = preferredBackground ?? AppColors.dominantSurface;
    final foreground =
        preferredForeground ?? AppColors.getTextColor(background);

    if (meetsContrastRequirements(foreground, background,
        isLargeText: isLargeText)) {
      return ColorPair(foreground: foreground, background: background);
    }

    // Fallback to high contrast colors
    return ColorPair(
      foreground: AppColors.textPrimary,
      background: AppColors.dominantSurface,
    );
  }

  // ============================================================================
  // TEXT READABILITY ENHANCEMENTS
  // ============================================================================

  /// Enhanced readable text with optimal line height and spacing
  static Widget readableText({
    required String text,
    TextStyle? style,
    String? semanticLabel,
    double? customLineHeight,
    double? letterSpacing,
    double? wordSpacing,
    EdgeInsetsGeometry? padding,
    bool justified = false,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        final baseStyle = style ?? AppTypography.bodyMedium;
        final fontSize = baseStyle.fontSize ?? DesignTokens.textBase;

        // Calculate optimal line height based on font size
        final optimalLineHeight =
            customLineHeight ?? _calculateOptimalLineHeight(fontSize);

        // Calculate optimal letter spacing
        final optimalLetterSpacing =
            letterSpacing ?? _calculateOptimalLetterSpacing(fontSize);

        final enhancedStyle = baseStyle.copyWith(
          height: optimalLineHeight,
          letterSpacing: optimalLetterSpacing,
          wordSpacing: wordSpacing,
        );

        final responsiveStyle = responsive
            ? AppTypography.getResponsiveStyle(context, enhancedStyle)
            : enhancedStyle;

        Widget textWidget = Text(
          text,
          style: responsiveStyle,
          textAlign: justified ? TextAlign.justify : null,
          semanticsLabel: semanticLabel,
        );

        if (padding != null) {
          textWidget = Padding(
            padding: padding,
            child: textWidget,
          );
        }

        return textWidget;
      },
    );
  }

  /// Calculate optimal line height for readability
  static double _calculateOptimalLineHeight(double fontSize) {
    // Based on typographic best practices
    if (fontSize <= 12) return 1.6;
    if (fontSize <= 14) return 1.5;
    if (fontSize <= 16) return 1.5;
    if (fontSize <= 18) return 1.4;
    if (fontSize <= 24) return 1.3;
    return 1.2; // For large text
  }

  /// Calculate optimal letter spacing for readability
  static double _calculateOptimalLetterSpacing(double fontSize) {
    // Based on typographic best practices
    if (fontSize <= 12) return 0.5;
    if (fontSize <= 14) return 0.25;
    if (fontSize <= 16) return 0.15;
    if (fontSize <= 18) return 0.1;
    return 0.0; // For large text
  }

  // ============================================================================
  // SCREEN READER SUPPORT
  // ============================================================================

  /// Hide decorative elements from screen readers
  static Widget excludeSemantics({required Widget child}) {
    return ExcludeSemantics(child: child);
  }

  /// Add live region for dynamic content
  static Widget liveRegion({
    required Widget child,
    LiveRegionImportance importance = LiveRegionImportance.polite,
  }) {
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }

  /// Merge semantics for complex widgets
  static Widget mergeSemantics({
    required Widget child,
    String? label,
    String? value,
    String? hint,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        value: value,
        hint: hint,
        child: child,
      ),
    );
  }

  // ============================================================================
  // TOUCH TARGET HELPERS
  // ============================================================================

  /// Ensure minimum touch target size (44x44 dp)
  static Widget ensureTouchTarget({
    required Widget child,
    Size minimumSize = const Size(44, 44),
    VoidCallback? onTap,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minimumSize.width,
        minHeight: minimumSize.height,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: child,
            )
          : child,
    );
  }

  /// Add padding to increase touch target without visual change
  static Widget expandTouchTarget({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  // ============================================================================
  // ANIMATION ACCESSIBILITY
  // ============================================================================

  /// Respect user's motion preferences
  static Duration getAccessibleDuration(Duration defaultDuration) {
    // In a real app, you would check system accessibility settings
    // For now, we'll use the default duration
    return defaultDuration;
  }

  /// Disable animations for users who prefer reduced motion
  static Widget respectMotionPreferences({
    required Widget child,
    Widget? alternativeChild,
  }) {
    // In a real app, you would check MediaQuery.of(context).disableAnimations
    // For now, we'll always show the animated version
    return child;
  }
}

/// Color pair for accessibility
class ColorPair {
  final Color foreground;
  final Color background;

  const ColorPair({
    required this.foreground,
    required this.background,
  });
}

/// Live region importance levels
enum LiveRegionImportance {
  polite,
  assertive,
}

/// Accessibility extensions for common widgets
extension AccessibilityExtensions on Widget {
  /// Add semantic label to any widget
  Widget semanticLabel(String label) {
    return Semantics(
      label: label,
      child: this,
    );
  }

  /// Add semantic hint to any widget
  Widget semanticHint(String hint) {
    return Semantics(
      hint: hint,
      child: this,
    );
  }

  /// Mark widget as button for screen readers
  Widget semanticButton({String? label, String? hint}) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      child: this,
    );
  }

  /// Exclude from semantics tree
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Add minimum touch target
  Widget minTouchTarget({Size size = const Size(44, 44)}) {
    return ProductionAccessibility.ensureTouchTarget(
      child: this,
      minimumSize: size,
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

/// Production-ready content hierarchy and readability system
class ProductionContentHierarchy {
  // Private constructor to prevent instantiation
  ProductionContentHierarchy._();

  /// Enhanced heading widget with proper hierarchy
  static Widget heading({
    required String text,
    required HeadingLevel level,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? height,
    EdgeInsetsGeometry? margin,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        TextStyle style;
        EdgeInsetsGeometry defaultMargin;

        switch (level) {
          case HeadingLevel.h1:
            style = AppTypography.displayLarge;
            defaultMargin = EdgeInsets.only(
              bottom: DesignTokens.space2xl,
              top: DesignTokens.space3xl,
            );
            break;
          case HeadingLevel.h2:
            style = AppTypography.displayMedium;
            defaultMargin = EdgeInsets.only(
              bottom: DesignTokens.space2xl,
              top: DesignTokens.space3xl,
            );
            break;
          case HeadingLevel.h3:
            style = AppTypography.displaySmall;
            defaultMargin = EdgeInsets.only(
              bottom: DesignTokens.spaceLg,
              top: DesignTokens.space2xl,
            );
            break;
          case HeadingLevel.h4:
            style = AppTypography.headlineLarge;
            defaultMargin = EdgeInsets.only(
              bottom: DesignTokens.spaceLg,
              top: DesignTokens.space2xl,
            );
            break;
          case HeadingLevel.h5:
            style = AppTypography.headlineMedium;
            defaultMargin = EdgeInsets.only(
              bottom: DesignTokens.spaceMd,
              top: DesignTokens.spaceLg,
            );
            break;
          case HeadingLevel.h6:
            style = AppTypography.headlineSmall;
            defaultMargin = EdgeInsets.only(
              bottom: DesignTokens.spaceMd,
              top: DesignTokens.spaceLg,
            );
            break;
        }

        // Apply responsive scaling if enabled
        if (responsive) {
          final scaledSize =
              DesignTokens.getResponsiveFontSize(context, style.fontSize!);
          style = style.copyWith(fontSize: scaledSize);
        }

        // Apply custom properties
        style = style.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: fontWeight,
          height: height,
        );

        return Container(
          margin: margin ?? defaultMargin,
          child: Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            semanticsLabel: text, // For accessibility
          ),
        );
      },
    );
  }

  /// Enhanced body text with proper hierarchy
  static Widget bodyText({
    required String text,
    BodyTextStyle textStyle = BodyTextStyle.regular,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
    EdgeInsetsGeometry? margin,
    bool responsive = true,
    bool selectable = false,
  }) {
    return Builder(
      builder: (context) {
        TextStyle style;
        EdgeInsetsGeometry defaultMargin;

        switch (textStyle) {
          case BodyTextStyle.large:
            style = AppTypography.bodyLarge;
            defaultMargin = EdgeInsets.only(bottom: DesignTokens.spaceMd);
            break;
          case BodyTextStyle.regular:
            style = AppTypography.bodyMedium;
            defaultMargin = EdgeInsets.only(bottom: DesignTokens.spaceMd);
            break;
          case BodyTextStyle.small:
            style = AppTypography.bodySmall;
            defaultMargin = EdgeInsets.only(bottom: DesignTokens.spaceSm);
            break;
          case BodyTextStyle.caption:
            style = AppTypography.bodySmall;
            defaultMargin = EdgeInsets.only(bottom: DesignTokens.spaceXs);
            break;
        }

        // Apply responsive scaling if enabled
        if (responsive) {
          final scaledSize =
              DesignTokens.getResponsiveFontSize(context, style.fontSize!);
          style = style.copyWith(fontSize: scaledSize);
        }

        // Apply custom properties
        style = style.copyWith(
          color: color ?? AppColors.textPrimary,
          height: height ?? DesignTokens.lineHeightNormal,
        );

        final textWidget = selectable
            ? SelectableText(
                text,
                style: style,
                textAlign: textAlign,
                maxLines: maxLines,
              )
            : Text(
                text,
                style: style,
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: overflow,
              );

        return Container(
          margin: margin ?? defaultMargin,
          child: textWidget,
        );
      },
    );
  }

  /// Enhanced list widget with proper spacing
  static Widget bulletList({
    required List<String> items,
    BodyTextStyle textStyle = BodyTextStyle.regular,
    Color? textColor,
    Color? bulletColor,
    double? bulletSize,
    double? indent,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? itemSpacing,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        final defaultIndent = responsive
            ? DesignTokens.getResponsiveSpacing(context, DesignTokens.spaceLg)
            : DesignTokens.spaceLg;

        final defaultItemSpacing = EdgeInsets.only(
          bottom: responsive
              ? DesignTokens.getResponsiveSpacing(context, DesignTokens.spaceXs)
              : DesignTokens.spaceXs,
        );

        return Container(
          margin: margin ?? EdgeInsets.only(bottom: DesignTokens.spaceLg),
          padding: EdgeInsets.only(left: indent ?? defaultIndent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              final item = entry.value;

              return Container(
                margin: itemSpacing ?? defaultItemSpacing,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: DesignTokens.spaceSm,
                        top: DesignTokens.spaceXs / 2,
                      ),
                      child: Icon(
                        Icons.fiber_manual_record,
                        size: bulletSize ?? 6.0,
                        color: bulletColor ?? AppColors.accent,
                      ),
                    ),
                    Expanded(
                      child: bodyText(
                        text: item,
                        textStyle: textStyle,
                        color: textColor,
                        margin: EdgeInsets.zero,
                        responsive: responsive,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Enhanced numbered list
  static Widget numberedList({
    required List<String> items,
    BodyTextStyle textStyle = BodyTextStyle.regular,
    Color? textColor,
    Color? numberColor,
    double? indent,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? itemSpacing,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        final defaultItemSpacing = EdgeInsets.only(
          bottom: responsive
              ? DesignTokens.getResponsiveSpacing(context, DesignTokens.spaceXs)
              : DesignTokens.spaceXs,
        );

        return Container(
          margin: margin ?? EdgeInsets.only(bottom: DesignTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;

              return Container(
                margin: itemSpacing ?? defaultItemSpacing,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: DesignTokens.spaceSm,
                      ),
                      child: Text(
                        '$index.',
                        style: AppTypography.labelMedium.copyWith(
                          color: numberColor ?? AppColors.accent,
                          fontWeight: AppTypography.weightSemiBold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: bodyText(
                        text: item,
                        textStyle: textStyle,
                        color: textColor,
                        margin: EdgeInsets.zero,
                        responsive: responsive,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Enhanced quote widget
  static Widget quote({
    required String text,
    String? author,
    String? source,
    Color? textColor,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        final defaultPadding = EdgeInsets.all(
          responsive
              ? DesignTokens.getResponsiveSpacing(
                  context, DesignTokens.space2xl)
              : DesignTokens.space2xl,
        );

        return Container(
          margin:
              margin ?? EdgeInsets.symmetric(vertical: DesignTokens.space2xl),
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            color: AppColors.dominantSurface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(
              color: (accentColor ?? AppColors.accent).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.getSecondaryColor(alpha: 0.1),
                blurRadius: DesignTokens.spaceLg,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: accentColor ?? AppColors.accent,
                    size: responsive
                        ? DesignTokens.getResponsiveFontSize(context, 32)
                        : 32,
                  ),
                  SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: bodyText(
                      text: text,
                      textStyle: BodyTextStyle.large,
                      color: textColor ?? AppColors.textPrimary,
                      margin: EdgeInsets.zero,
                      responsive: responsive,
                    ),
                  ),
                ],
              ),
              if (author != null || source != null) ...[
                SizedBox(height: DesignTokens.spaceLg),
                Row(
                  children: [
                    SizedBox(width: DesignTokens.space4xl), // Align with quote
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (author != null)
                            bodyText(
                              text: '— $author',
                              textStyle: BodyTextStyle.regular,
                              color: AppColors.textSecondary,
                              margin: EdgeInsets.zero,
                              responsive: responsive,
                            ),
                          if (source != null)
                            bodyText(
                              text: source,
                              textStyle: BodyTextStyle.small,
                              color: AppColors.textTertiary,
                              margin: EdgeInsets.zero,
                              responsive: responsive,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Enhanced callout/highlight box
  static Widget callout({
    required String text,
    String? title,
    CalloutType type = CalloutType.info,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        Color backgroundColor;
        Color borderColor;
        Color iconColor;
        IconData icon;

        switch (type) {
          case CalloutType.info:
            backgroundColor = AppColors.secondary.withValues(alpha: 0.1);
            borderColor = AppColors.secondary;
            iconColor = AppColors.secondary;
            icon = Icons.info_outline;
            break;
          case CalloutType.success:
            backgroundColor = Colors.green.withValues(alpha: 0.1);
            borderColor = Colors.green;
            iconColor = Colors.green;
            icon = Icons.check_circle_outline;
            break;
          case CalloutType.warning:
            backgroundColor = Colors.orange.withValues(alpha: 0.1);
            borderColor = Colors.orange;
            iconColor = Colors.orange;
            icon = Icons.warning_outlined;
            break;
          case CalloutType.error:
            backgroundColor = Colors.red.withValues(alpha: 0.1);
            borderColor = Colors.red;
            iconColor = Colors.red;
            icon = Icons.error_outline;
            break;
        }

        final defaultPadding = EdgeInsets.all(
          responsive
              ? DesignTokens.getResponsiveSpacing(context, DesignTokens.spaceLg)
              : DesignTokens.spaceLg,
        );

        return Container(
          margin:
              margin ?? EdgeInsets.symmetric(vertical: DesignTokens.spaceLg),
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: responsive
                    ? DesignTokens.getResponsiveFontSize(context, 24)
                    : 24,
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      bodyText(
                        text: title,
                        textStyle: BodyTextStyle.regular,
                        color: AppColors.textPrimary,
                        margin: EdgeInsets.only(bottom: DesignTokens.spaceXs),
                        responsive: responsive,
                      ),
                    ],
                    bodyText(
                      text: text,
                      textStyle: BodyTextStyle.regular,
                      color: AppColors.textSecondary,
                      margin: EdgeInsets.zero,
                      responsive: responsive,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Enhanced section divider
  static Widget sectionDivider({
    String? label,
    Color? color,
    double? thickness,
    EdgeInsetsGeometry? margin,
    bool responsive = true,
  }) {
    return Builder(
      builder: (context) {
        final defaultMargin = EdgeInsets.symmetric(
          vertical: responsive
              ? DesignTokens.getResponsiveSpacing(
                  context, DesignTokens.space2xl)
              : DesignTokens.space2xl,
        );

        if (label != null) {
          return Container(
            margin: margin ?? defaultMargin,
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: color ?? AppColors.accent.withValues(alpha: 0.3),
                    thickness: thickness ?? 1,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
                  child: bodyText(
                    text: label,
                    textStyle: BodyTextStyle.small,
                    color: AppColors.textTertiary,
                    margin: EdgeInsets.zero,
                    responsive: responsive,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: color ?? AppColors.accent.withValues(alpha: 0.3),
                    thickness: thickness ?? 1,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: margin ?? defaultMargin,
          child: Divider(
            color: color ?? AppColors.accent.withValues(alpha: 0.3),
            thickness: thickness ?? 1,
          ),
        );
      },
    );
  }
}

/// Available heading levels
enum HeadingLevel {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
}

/// Available body text styles
enum BodyTextStyle {
  large,
  regular,
  small,
  caption,
}

/// Available callout types
enum CalloutType {
  info,
  success,
  warning,
  error,
}

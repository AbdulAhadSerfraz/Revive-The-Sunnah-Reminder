import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';

/// Production-ready responsive layout system
/// Handles different screen sizes and orientations
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.constraints,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isTablet = screenWidth > DesignTokens.breakpointMd;
        final isLandscape = screenWidth > screenHeight;

        // Calculate responsive padding
        final responsivePadding =
            _calculatePadding(screenWidth, isTablet, isLandscape);

        // Calculate max width for content
        final contentMaxWidth =
            maxWidth ?? _calculateMaxWidth(screenWidth, isTablet);

        return Container(
          margin: margin,
          padding: padding ?? responsivePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: this.constraints ??
                  BoxConstraints(
                    maxWidth: contentMaxWidth,
                  ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  EdgeInsetsGeometry _calculatePadding(
      double screenWidth, bool isTablet, bool isLandscape) {
    if (isTablet) {
      return EdgeInsets.symmetric(
        horizontal: isLandscape ? DesignTokens.space6xl : DesignTokens.space4xl,
        vertical: DesignTokens.space2xl,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: screenWidth < DesignTokens.breakpointSm
            ? DesignTokens.spaceLg
            : DesignTokens.space2xl,
        vertical: DesignTokens.spaceLg,
      );
    }
  }

  double _calculateMaxWidth(double screenWidth, bool isTablet) {
    if (isTablet) {
      return screenWidth * 0.7; // 70% of screen width on tablets
    } else {
      return screenWidth; // Full width on phones
    }
  }
}

/// Responsive grid system for laying out items
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
    this.childAspectRatio = 1.0,
  });

  final List<Widget> children;
  final double spacing;
  final double? runSpacing;
  final int? crossAxisCount;
  final double? maxCrossAxisExtent;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final effectiveRunSpacing = runSpacing ?? spacing;

        // Calculate appropriate grid configuration
        final gridConfig = _calculateGridConfig(screenWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount ?? gridConfig.crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: effectiveRunSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  _GridConfig _calculateGridConfig(double screenWidth) {
    if (screenWidth < DesignTokens.breakpointSm) {
      // Small screens (phones in portrait)
      return _GridConfig(crossAxisCount: 1);
    } else if (screenWidth < DesignTokens.breakpointMd) {
      // Medium screens (phones in landscape, small tablets)
      return _GridConfig(crossAxisCount: 2);
    } else if (screenWidth < DesignTokens.breakpointLg) {
      // Large screens (tablets)
      return _GridConfig(crossAxisCount: 3);
    } else {
      // Extra large screens (large tablets, desktop)
      return _GridConfig(crossAxisCount: 4);
    }
  }
}

class _GridConfig {
  final int crossAxisCount;

  _GridConfig({required this.crossAxisCount});
}

/// Responsive wrapper that adapts content based on screen size
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        if (screenWidth >= DesignTokens.breakpointLg && desktop != null) {
          return desktop!;
        } else if (screenWidth >= DesignTokens.breakpointMd && tablet != null) {
          return tablet!;
        } else {
          return phone;
        }
      },
    );
  }
}

/// Responsive text that scales based on screen size
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    required this.style,
    this.scaleFactor = 1.0,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final double scaleFactor;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveFontSize = DesignTokens.getResponsiveFontSize(
          context,
          style.fontSize ?? DesignTokens.textBase,
        );

        return Text(
          text,
          style: style.copyWith(
            fontSize: responsiveFontSize * scaleFactor,
          ),
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
      },
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  const ResponsiveSpacing({
    super.key,
    this.height,
    this.width,
    this.factor = 1.0,
  });

  final double? height;
  final double? width;
  final double factor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final adjustedHeight = height != null
            ? DesignTokens.getResponsiveSpacing(context, height!) * factor
            : null;

        final adjustedWidth = width != null
            ? DesignTokens.getResponsiveSpacing(context, width!) * factor
            : null;

        return SizedBox(
          height: adjustedHeight,
          width: adjustedWidth,
        );
      },
    );
  }
}

/// Responsive container with adaptive sizing
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < DesignTokens.breakpointSm;

        // Calculate responsive padding
        final responsivePadding = padding ??
            EdgeInsets.all(
              isSmallScreen ? DesignTokens.spaceLg : DesignTokens.space2xl,
            );

        // Calculate responsive margin
        final responsiveMargin = margin ??
            EdgeInsets.symmetric(
              horizontal:
                  isSmallScreen ? DesignTokens.spaceLg : DesignTokens.space2xl,
              vertical: DesignTokens.spaceLg,
            );

        return Container(
          width: width,
          height: height,
          margin: responsiveMargin,
          padding: responsivePadding,
          decoration: decoration,
          constraints: this.constraints,
          child: child,
        );
      },
    );
  }
}

/// Responsive column with adaptive spacing
class ResponsiveColumn extends StatelessWidget {
  const ResponsiveColumn({
    super.key,
    required this.children,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double? spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final adaptiveSpacing = spacing ??
            (screenWidth < DesignTokens.breakpointSm
                ? DesignTokens.spaceLg
                : DesignTokens.space2xl);

        return Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: _buildChildrenWithSpacing(adaptiveSpacing),
        );
      },
    );
  }

  List<Widget> _buildChildrenWithSpacing(double spacing) {
    if (children.isEmpty) return [];

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}

/// Responsive row with adaptive spacing
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double? spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final adaptiveSpacing = spacing ??
            (screenWidth < DesignTokens.breakpointSm
                ? DesignTokens.spaceSm
                : DesignTokens.spaceLg);

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: _buildChildrenWithSpacing(adaptiveSpacing),
        );
      },
    );
  }

  List<Widget> _buildChildrenWithSpacing(double spacing) {
    if (children.isEmpty) return [];

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}

/// Utility functions for responsive design
class ResponsiveUtils {
  /// Get the current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < DesignTokens.breakpointSm) {
      return ScreenSize.small;
    } else if (screenWidth < DesignTokens.breakpointMd) {
      return ScreenSize.medium;
    } else if (screenWidth < DesignTokens.breakpointLg) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// Check if the current device is in landscape mode
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Get adaptive value based on screen size
  static T adaptive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
      case ScreenSize.medium:
        return mobile;
      case ScreenSize.large:
        return tablet ?? mobile;
      case ScreenSize.extraLarge:
        return desktop ?? tablet ?? mobile;
    }
  }
}

enum ScreenSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Extension methods for responsive design
extension ResponsiveExtension on BuildContext {
  /// Get screen size category
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(this);

  /// Check if landscape
  bool get isLandscape => ResponsiveUtils.isLandscape(this);

  /// Get adaptive value
  T adaptive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) =>
      ResponsiveUtils.adaptive(
        context: this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}

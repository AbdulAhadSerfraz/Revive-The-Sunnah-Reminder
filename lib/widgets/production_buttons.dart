import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';

/// Production-ready button component with consistent styling
class ProductionButton extends StatefulWidget {
  const ProductionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.icon,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final IconData? icon;
  final String? tooltip;

  @override
  State<ProductionButton> createState() => _ProductionButtonState();
}

class _ProductionButtonState extends State<ProductionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isInteractive =>
      widget.isEnabled && !widget.isLoading && widget.onPressed != null;

  void _handleTapDown(TapDownDetails details) {
    if (!_isInteractive) return;

    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isInteractive) return;

    setState(() => _isPressed = false);
    _animationController.reverse();

    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    Widget button = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _isInteractive ? _opacityAnimation.value : 0.6,
            child: Container(
              width: widget.width,
              height: buttonStyle.height,
              decoration: BoxDecoration(
                color: buttonStyle.backgroundColor,
                borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
                border: buttonStyle.border,
                boxShadow: _isPressed || !_isInteractive
                    ? null
                    : buttonStyle.boxShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
                  child: Container(
                    padding: buttonStyle.padding,
                    child: _buildButtonContent(buttonStyle),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: _isInteractive,
      child: button,
    );
  }

  Widget _buildButtonContent(_ButtonStyle style) {
    if (widget.isLoading) {
      return _buildLoadingContent(style);
    }

    if (widget.icon != null) {
      return _buildIconButtonContent(style);
    }

    return _buildTextButtonContent(style);
  }

  Widget _buildLoadingContent(_ButtonStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: style.iconSize,
          height: style.iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(style.foregroundColor),
          ),
        ),
        SizedBox(width: DesignTokens.spaceSm),
        DefaultTextStyle(
          style: style.textStyle,
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildIconButtonContent(_ButtonStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          widget.icon,
          size: style.iconSize,
          color: style.foregroundColor,
        ),
        SizedBox(width: DesignTokens.spaceSm),
        DefaultTextStyle(
          style: style.textStyle,
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildTextButtonContent(_ButtonStyle style) {
    return Center(
      child: DefaultTextStyle(
        style: style.textStyle,
        child: widget.child,
      ),
    );
  }

  _ButtonStyle _getButtonStyle() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _getPrimaryStyle();
      case ButtonVariant.secondary:
        return _getSecondaryStyle();
      case ButtonVariant.outline:
        return _getOutlineStyle();
      case ButtonVariant.ghost:
        return _getGhostStyle();
      case ButtonVariant.destructive:
        return _getDestructiveStyle();
    }
  }

  _ButtonStyle _getPrimaryStyle() {
    final sizeConfig = _getSizeConfig();
    return _ButtonStyle(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnColor,
      textStyle: sizeConfig.textStyle.copyWith(
        color: AppColors.textOnColor,
        fontWeight: AppTypography.weightSemiBold,
      ),
      height: sizeConfig.height,
      padding: sizeConfig.padding,
      borderRadius: sizeConfig.borderRadius,
      iconSize: sizeConfig.iconSize,
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.3),
          blurRadius: DesignTokens.spaceSm,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  _ButtonStyle _getSecondaryStyle() {
    final sizeConfig = _getSizeConfig();
    return _ButtonStyle(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textOnColor,
      textStyle: sizeConfig.textStyle.copyWith(
        color: AppColors.textOnColor,
        fontWeight: AppTypography.weightSemiBold,
      ),
      height: sizeConfig.height,
      padding: sizeConfig.padding,
      borderRadius: sizeConfig.borderRadius,
      iconSize: sizeConfig.iconSize,
      boxShadow: [
        BoxShadow(
          color: AppColors.secondary.withValues(alpha: 0.2),
          blurRadius: DesignTokens.spaceSm,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  _ButtonStyle _getOutlineStyle() {
    final sizeConfig = _getSizeConfig();
    return _ButtonStyle(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.secondary,
      textStyle: sizeConfig.textStyle.copyWith(
        color: AppColors.secondary,
        fontWeight: AppTypography.weightSemiBold,
      ),
      height: sizeConfig.height,
      padding: sizeConfig.padding,
      borderRadius: sizeConfig.borderRadius,
      iconSize: sizeConfig.iconSize,
      border: Border.all(
        color: AppColors.secondary,
        width: 1.5,
      ),
    );
  }

  _ButtonStyle _getGhostStyle() {
    final sizeConfig = _getSizeConfig();
    return _ButtonStyle(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textSecondary,
      textStyle: sizeConfig.textStyle.copyWith(
        color: AppColors.textSecondary,
        fontWeight: AppTypography.weightMedium,
      ),
      height: sizeConfig.height,
      padding: sizeConfig.padding,
      borderRadius: sizeConfig.borderRadius,
      iconSize: sizeConfig.iconSize,
    );
  }

  _ButtonStyle _getDestructiveStyle() {
    final sizeConfig = _getSizeConfig();
    return _ButtonStyle(
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.textOnColor,
      textStyle: sizeConfig.textStyle.copyWith(
        color: AppColors.textOnColor,
        fontWeight: AppTypography.weightSemiBold,
      ),
      height: sizeConfig.height,
      padding: sizeConfig.padding,
      borderRadius: sizeConfig.borderRadius,
      iconSize: sizeConfig.iconSize,
      boxShadow: [
        BoxShadow(
          color: AppColors.error.withValues(alpha: 0.3),
          blurRadius: DesignTokens.spaceSm,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  _SizeConfig _getSizeConfig() {
    switch (widget.size) {
      case ButtonSize.small:
        return _SizeConfig(
          height: 32,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceXs,
          ),
          borderRadius: DesignTokens.radiusSm,
          textStyle: AppTypography.labelSmall,
          iconSize: DesignTokens.spaceLg,
        );
      case ButtonSize.medium:
        return _SizeConfig(
          height: 44,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space2xl,
            vertical: DesignTokens.spaceLg,
          ),
          borderRadius: DesignTokens.radiusLg,
          textStyle: AppTypography.labelLarge,
          iconSize: DesignTokens.spaceLg,
        );
      case ButtonSize.large:
        return _SizeConfig(
          height: 56,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space3xl,
            vertical: DesignTokens.space2xl,
          ),
          borderRadius: DesignTokens.radiusXl,
          textStyle: AppTypography.titleMedium,
          iconSize: DesignTokens.space2xl,
        );
    }
  }
}

class _ButtonStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle textStyle;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.textStyle,
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.iconSize,
    this.border,
    this.boxShadow,
  });
}

class _SizeConfig {
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle textStyle;
  final double iconSize;

  _SizeConfig({
    required this.height,
    required this.padding,
    required this.borderRadius,
    required this.textStyle,
    required this.iconSize,
  });
}

enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

enum ButtonSize {
  small,
  medium,
  large,
}

/// Production-ready icon button
class ProductionIconButton extends StatefulWidget {
  const ProductionIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = IconButtonVariant.filled,
    this.size = IconButtonSize.medium,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final IconButtonVariant variant;
  final IconButtonSize size;
  final String? tooltip;
  final String? badge;

  @override
  State<ProductionIconButton> createState() => _ProductionIconButtonState();
}

class _ProductionIconButtonState extends State<ProductionIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: config.size,
            height: config.size,
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(config.borderRadius),
              border: config.border,
              boxShadow: config.boxShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(config.borderRadius),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: config.iconSize,
                      color: config.foregroundColor,
                    ),
                    if (widget.badge != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.all(DesignTokens.spaceXs / 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusFull),
                          ),
                          constraints: BoxConstraints(
                            minWidth: DesignTokens.spaceSm,
                            minHeight: DesignTokens.spaceSm,
                          ),
                          child: Text(
                            widget.badge!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textOnColor,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: button,
    );
  }

  _IconButtonConfig _getConfig() {
    final sizeValue = _getSizeValue();

    switch (widget.variant) {
      case IconButtonVariant.filled:
        return _IconButtonConfig(
          size: sizeValue,
          iconSize: sizeValue * 0.5,
          borderRadius: sizeValue / 4,
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.2),
              blurRadius: DesignTokens.spaceXs,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case IconButtonVariant.outline:
        return _IconButtonConfig(
          size: sizeValue,
          iconSize: sizeValue * 0.5,
          borderRadius: sizeValue / 4,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.secondary,
          border: Border.all(
            color: AppColors.secondary,
            width: 1.5,
          ),
        );
      case IconButtonVariant.ghost:
        return _IconButtonConfig(
          size: sizeValue,
          iconSize: sizeValue * 0.5,
          borderRadius: sizeValue / 4,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textSecondary,
        );
    }
  }

  double _getSizeValue() {
    switch (widget.size) {
      case IconButtonSize.small:
        return 32;
      case IconButtonSize.medium:
        return 44;
      case IconButtonSize.large:
        return 56;
    }
  }
}

class _IconButtonConfig {
  final double size;
  final double iconSize;
  final double borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  _IconButtonConfig({
    required this.size,
    required this.iconSize,
    required this.borderRadius,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    this.boxShadow,
  });
}

enum IconButtonVariant {
  filled,
  outline,
  ghost,
}

enum IconButtonSize {
  small,
  medium,
  large,
}

/// Production-ready floating action button
class ProductionFAB extends StatefulWidget {
  const ProductionFAB({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.size = FABSize.regular,
    this.tooltip,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final FABSize size;
  final String? tooltip;
  final Object? heroTag;

  @override
  State<ProductionFAB> createState() => _ProductionFABState();
}

class _ProductionFABState extends State<ProductionFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));

    _elevationAnimation = Tween<double>(
      begin: DesignTokens.elevationLg,
      end: DesignTokens.elevationMd,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeValue = _getSizeValue();

    return Hero(
      tag: widget.heroTag ?? 'production_fab',
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              color: widget.backgroundColor ?? AppColors.accent,
              borderRadius: BorderRadius.circular(sizeValue / 2),
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(sizeValue / 2),
                child: Container(
                  width: sizeValue,
                  height: sizeValue,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sizeValue / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppColors.accent)
                            .withValues(alpha: 0.3),
                        blurRadius: DesignTokens.spaceLg,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: widget.foregroundColor ?? AppColors.textOnColor,
                        size: sizeValue * 0.4,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _getSizeValue() {
    switch (widget.size) {
      case FABSize.small:
        return 40;
      case FABSize.regular:
        return 56;
      case FABSize.large:
        return 72;
      case FABSize.extended:
        return 56; // Same height as regular, but can be wider
    }
  }
}

enum FABSize {
  small,
  regular,
  large,
  extended,
}

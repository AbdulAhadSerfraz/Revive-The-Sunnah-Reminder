import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

/// Production-ready microinteractions system
/// Provides haptic feedback, hover effects, and interactive animations
class ProductionMicrointeractions {
  // Private constructor to prevent instantiation
  ProductionMicrointeractions._();

  /// Light haptic feedback for subtle interactions
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for button presses
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important actions
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for picker items
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for errors
  static void vibrateError() {
    HapticFeedback.heavyImpact();
  }

  /// Vibrate pattern for success
  static void vibrateSuccess() {
    HapticFeedback.lightImpact();
  }
}

/// Enhanced button with microinteractions
class ProductionInteractiveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableHaptics;
  final bool enableScaleAnimation;
  final double scaleDownFactor;
  final Duration animationDuration;
  final bool enableRipple;

  const ProductionInteractiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.enableHaptics = true,
    this.enableScaleAnimation = true,
    this.scaleDownFactor = 0.95,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enableRipple = true,
  });

  @override
  State<ProductionInteractiveButton> createState() =>
      _ProductionInteractiveButtonState();
}

class _ProductionInteractiveButtonState
    extends State<ProductionInteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownFactor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && widget.enableScaleAnimation) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableScaleAnimation) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableScaleAnimation) {
      _animationController.reverse();
    }
  }

  void _onTap() {
    if (widget.enableHaptics) {
      ProductionMicrointeractions.mediumImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableScaleAnimation ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.enableRipple ? _onTap : null,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(DesignTokens.radiusMd),
                  child: Padding(
                    padding:
                        widget.padding ?? EdgeInsets.all(DesignTokens.spaceMd),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Interactive card with hover and press effects
class ProductionInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableHover;
  final bool enablePress;
  final bool enableHaptics;

  const ProductionInteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.enableHover = true,
    this.enablePress = true,
    this.enableHaptics = true,
  });

  @override
  State<ProductionInteractiveCard> createState() =>
      _ProductionInteractiveCardState();
}

class _ProductionInteractiveCardState extends State<ProductionInteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? DesignTokens.elevationXs,
      end: (widget.elevation ?? DesignTokens.elevationXs) + 4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (!widget.enableHover) return;

    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else if (!_isPressed) {
      _animationController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enablePress) return;

    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enablePress) return;

    setState(() => _isPressed = false);
    if (!_isHovered) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.enablePress) return;

    setState(() => _isPressed = false);
    if (!_isHovered) {
      _animationController.reverse();
    }
  }

  void _onTap() {
    if (widget.enableHaptics) {
      ProductionMicrointeractions.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: Transform.scale(
              scale: widget.enablePress ? _scaleAnimation.value : 1.0,
              child: Container(
                margin: widget.margin,
                child: Material(
                  elevation: widget.enableHover
                      ? _elevationAnimation.value
                      : widget.elevation ?? DesignTokens.elevationXs,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(DesignTokens.radiusMd),
                  color: widget.backgroundColor ?? Theme.of(context).cardColor,
                  child: InkWell(
                    onTap: _onTap,
                    borderRadius: widget.borderRadius ??
                        BorderRadius.circular(DesignTokens.radiusMd),
                    child: Padding(
                      padding: widget.padding ??
                          EdgeInsets.all(DesignTokens.spaceMd),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Interactive list item with feedback
class ProductionInteractiveListItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enableHaptics;
  final EdgeInsetsGeometry? padding;

  const ProductionInteractiveListItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enableHaptics = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ProductionInteractiveCard(
      enableHaptics: enableHaptics,
      onTap: onTap,
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceXs,
      ),
      padding: padding ?? EdgeInsets.all(DesignTokens.spaceMd),
      child: Row(
        children: [
          leading,
          SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  SizedBox(height: DesignTokens.spaceXs),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: DesignTokens.spaceMd),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Floating action button with enhanced interactions
class ProductionFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool mini;
  final bool enableHaptics;

  const ProductionFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.mini = false,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProductionInteractiveButton(
      onPressed: () {
        if (enableHaptics) {
          ProductionMicrointeractions.mediumImpact();
        }
        onPressed?.call();
      },
      enableHaptics: false, // We handle haptics manually
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(mini ? 28 : 32),
      padding:
          EdgeInsets.all(mini ? DesignTokens.spaceMd : DesignTokens.spaceLg),
      child: child,
    );
  }
}

/// Progress indicator with smooth animations
class ProductionProgressIndicator extends StatefulWidget {
  final double value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const ProductionProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 8.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ProductionProgressIndicator> createState() =>
      _ProductionProgressIndicatorState();
}

class _ProductionProgressIndicatorState
    extends State<ProductionProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProductionProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey[300],
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
          ),
          child: ClipRRect(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
            child: LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.valueColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Switch with enhanced interactions
class ProductionSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableHaptics;

  const ProductionSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged != null
          ? (value) {
              if (enableHaptics) {
                ProductionMicrointeractions.lightImpact();
              }
              onChanged!(value);
            }
          : null,
      activeThumbColor: activeColor,
      inactiveTrackColor: inactiveColor,
    );
  }
}

/// Slider with enhanced interactions
class ProductionSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableHaptics;

  const ProductionSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: onChanged != null
          ? (value) {
              if (enableHaptics) {
                ProductionMicrointeractions.lightImpact();
              }
              onChanged!(value);
            }
          : null,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}

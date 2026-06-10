import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';

/// Production-ready loading indicators
class ProductionLoading extends StatefulWidget {
  const ProductionLoading({
    super.key,
    this.message,
    this.size = LoadingSize.medium,
    this.color,
  });

  final String? message;
  final LoadingSize size;
  final Color? color;

  @override
  State<ProductionLoading> createState() => _ProductionLoadingState();
}

class _ProductionLoadingState extends State<ProductionLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeValue = _getSizeValue();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: sizeValue,
              height: sizeValue,
              child: CircularProgressIndicator(
                strokeWidth: sizeValue / 12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? AppColors.accent,
                ),
              ),
            ),
            if (widget.message != null) ...[
              SizedBox(height: DesignTokens.spaceLg),
              Text(
                widget.message!,
                style: _getTextStyle(),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _getSizeValue() {
    switch (widget.size) {
      case LoadingSize.small:
        return 24;
      case LoadingSize.medium:
        return 40;
      case LoadingSize.large:
        return 56;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case LoadingSize.small:
        return AppTypography.bodySmall;
      case LoadingSize.medium:
        return AppTypography.bodyMedium;
      case LoadingSize.large:
        return AppTypography.bodyLarge;
    }
  }
}

enum LoadingSize {
  small,
  medium,
  large,
}

/// Production-ready empty state component
class ProductionEmptyState extends StatefulWidget {
  const ProductionEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.illustration,
    this.action,
    this.actionText,
    this.onActionPressed,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? illustration;
  final Widget? action;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  State<ProductionEmptyState> createState() => _ProductionEmptyStateState();
}

class _ProductionEmptyStateState extends State<ProductionEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEmphasized,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.all(DesignTokens.space3xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIllustration(),
                SizedBox(height: DesignTokens.space2xl),
                _buildTitle(),
                if (widget.subtitle != null) ...[
                  SizedBox(height: DesignTokens.spaceLg),
                  _buildSubtitle(),
                ],
                if (widget.action != null ||
                    (widget.actionText != null &&
                        widget.onActionPressed != null)) ...[
                  SizedBox(height: DesignTokens.space3xl),
                  _buildAction(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    if (widget.illustration != null) {
      return widget.illustration!;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.getDominantColor(dark: true),
        borderRadius: BorderRadius.circular(DesignTokens.radius3xl),
        border: Border.all(
          color: AppColors.getSecondaryColor(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Icon(
        widget.icon ?? Icons.inbox_outlined,
        size: 56,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.subtitle!,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAction() {
    if (widget.action != null) {
      return widget.action!;
    }

    if (widget.actionText != null && widget.onActionPressed != null) {
      return ElevatedButton(
        onPressed: widget.onActionPressed,
        child: Text(widget.actionText!),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Production-ready error state component
class ProductionErrorState extends StatefulWidget {
  const ProductionErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.error,
    this.onRetry,
    this.retryText = 'Try Again',
    this.showDetails = false,
  });

  final String title;
  final String? subtitle;
  final String? error;
  final VoidCallback? onRetry;
  final String retryText;
  final bool showDetails;

  @override
  State<ProductionErrorState> createState() => _ProductionErrorStateState();
}

class _ProductionErrorStateState extends State<ProductionErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEmphasized,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.all(DesignTokens.space3xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildErrorIcon(),
                SizedBox(height: DesignTokens.space2xl),
                _buildTitle(),
                if (widget.subtitle != null) ...[
                  SizedBox(height: DesignTokens.spaceLg),
                  _buildSubtitle(),
                ],
                if (widget.error != null && widget.showDetails) ...[
                  SizedBox(height: DesignTokens.spaceLg),
                  _buildDetailsToggle(),
                  if (_showDetails) ...[
                    SizedBox(height: DesignTokens.spaceLg),
                    _buildErrorDetails(),
                  ],
                ],
                if (widget.onRetry != null) ...[
                  SizedBox(height: DesignTokens.space3xl),
                  _buildRetryButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(DesignTokens.radius3xl),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.error_outline_rounded,
        size: 56,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: AppTypography.headlineSmall.copyWith(
        color: AppColors.errorDark,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.subtitle!,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDetailsToggle() {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      icon: Icon(
        _showDetails ? Icons.expand_less : Icons.expand_more,
        color: AppColors.textTertiary,
      ),
      label: Text(
        _showDetails ? 'Hide Details' : 'Show Details',
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildErrorDetails() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.getDominantColor(dark: true),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        widget.error!,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: widget.onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: Text(widget.retryText),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnColor,
      ),
    );
  }
}

/// Production-ready snackbar component
class ProductionSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final config = _getSnackBarConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: config.iconColor,
              size: DesignTokens.spaceLg,
            ),
            SizedBox(width: DesignTokens.spaceLg),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: config.textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        margin: EdgeInsets.all(DesignTokens.spaceLg),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: config.actionColor,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  static _SnackBarConfig _getSnackBarConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          backgroundColor: AppColors.success,
          textColor: AppColors.textOnColor,
          iconColor: AppColors.textOnColor,
          actionColor: AppColors.textOnColor,
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          backgroundColor: AppColors.error,
          textColor: AppColors.textOnColor,
          iconColor: AppColors.textOnColor,
          actionColor: AppColors.textOnColor,
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          backgroundColor: AppColors.warning,
          textColor: AppColors.textOnColor,
          iconColor: AppColors.textOnColor,
          actionColor: AppColors.textOnColor,
          icon: Icons.warning_rounded,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          backgroundColor: AppColors.info,
          textColor: AppColors.textOnColor,
          iconColor: AppColors.textOnColor,
          actionColor: AppColors.textOnColor,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;
  final IconData icon;

  _SnackBarConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
    required this.icon,
  });
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// Production-ready progress indicator
class ProductionProgressIndicator extends StatefulWidget {
  const ProductionProgressIndicator({
    super.key,
    required this.value,
    this.label,
    this.showPercentage = true,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
  });

  final double value; // 0.0 to 1.0
  final String? label;
  final bool showPercentage;
  final Color? color;
  final Color? backgroundColor;
  final double height;

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
      duration: DesignTokens.durationSlow,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEmphasized,
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
        curve: DesignTokens.curveEmphasized,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: AppTypography.labelMedium,
                ),
              if (widget.showPercentage)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).round()}%',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: DesignTokens.spaceXs),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                AppColors.getDominantColor(dark: true),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? AppColors.accent,
                ),
                borderRadius: BorderRadius.circular(widget.height / 2),
              );
            },
          ),
        ),
      ],
    );
  }
}

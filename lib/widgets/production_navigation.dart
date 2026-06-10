import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';

/// Production-ready navigation component with enhanced design
class ProductionBottomNavigation extends StatefulWidget {
  const ProductionBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [],
    this.showLabels = true,
  });

  final int currentIndex;
  final Function(int) onTap;
  final List<ProductionNavItem> items;
  final bool showLabels;

  @override
  State<ProductionBottomNavigation> createState() =>
      _ProductionBottomNavigationState();
}

class _ProductionBottomNavigationState extends State<ProductionBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: DesignTokens.durationNormal,
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: DesignTokens.curveEmphasized,
            )))
        .toList();

    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 0.6,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: DesignTokens.curveStandard,
            )))
        .toList();

    // Animate current item
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ProductionBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset old animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dominantSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radius2xl),
          topRight: Radius.circular(DesignTokens.radius2xl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getSecondaryColor(alpha: 0.08),
            blurRadius: DesignTokens.space3xl,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: AppColors.getSecondaryColor(alpha: 0.04),
            blurRadius: DesignTokens.spaceLg,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = DesignTokens.isSmallScreen(context);
            final navHeight = isSmallScreen ? 70.0 : 80.0;
            final horizontalPadding =
                isSmallScreen ? DesignTokens.spaceLg : DesignTokens.space2xl;

            return Container(
              height: navHeight,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: DesignTokens.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildNavItem(item, index, isSmallScreen);
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(ProductionNavItem item, int index, bool isSmallScreen) {
    final isSelected = index == widget.currentIndex;

    return Expanded(
      child: Semantics(
        label: 'Navigation: ${item.label}',
        hint: isSelected ? 'Currently selected' : 'Tap to navigate',
        button: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 48, // Minimum touch target for accessibility
            maxWidth: isSmallScreen ? 72 : 88,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(index),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              splashColor: AppColors.getSecondaryColor(alpha: 0.1),
              highlightColor: AppColors.getSecondaryColor(alpha: 0.05),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimations[index],
                  _fadeAnimations[index],
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: DesignTokens.spaceXs,
                        horizontal: DesignTokens.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.getSecondaryColor(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusLg),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.getSecondaryColor(alpha: 0.25),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIcon(item, isSelected, isSmallScreen),
                          if (widget.showLabels) ...[
                            SizedBox(height: DesignTokens.spaceXs),
                            _buildLabel(item, isSelected, isSmallScreen),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(
      ProductionNavItem item, bool isSelected, bool isSmallScreen) {
    return AnimatedSwitcher(
      duration: DesignTokens.durationFast,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: Container(
        key: ValueKey(isSelected),
        padding:
            isSelected ? EdgeInsets.all(DesignTokens.spaceXs) : EdgeInsets.zero,
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              )
            : null,
        child: Icon(
          isSelected ? item.activeIcon : item.icon,
          color: isSelected ? AppColors.secondary : AppColors.textTertiary,
          size: isSelected
              ? (isSmallScreen ? 24 : 26)
              : (isSmallScreen ? 22 : 24),
        ),
      ),
    );
  }

  Widget _buildLabel(
      ProductionNavItem item, bool isSelected, bool isSmallScreen) {
    return AnimatedDefaultTextStyle(
      duration: DesignTokens.durationFast,
      style: AppTypography.labelSmall.copyWith(
        fontWeight: isSelected
            ? AppTypography.weightSemiBold
            : AppTypography.weightRegular,
        color: isSelected ? AppColors.secondary : AppColors.textTertiary,
        fontSize: isSmallScreen ? 10 : 11,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          item.label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      // Haptic feedback
      // HapticFeedback.lightImpact(); // Uncomment if haptic feedback is desired

      // Call the onTap callback
      widget.onTap(index);
    }
  }
}

/// Navigation item data class
class ProductionNavItem {
  const ProductionNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;
}

/// Predefined navigation items for common use cases
class NavigationItems {
  static const home = ProductionNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  );

  static const chat = ProductionNavItem(
    icon: Icons.chat_bubble_outline_rounded,
    activeIcon: Icons.chat_bubble_rounded,
    label: 'Chat',
  );

  static const progress = ProductionNavItem(
    icon: Icons.trending_up_outlined,
    activeIcon: Icons.trending_up_rounded,
    label: 'Progress',
  );

  static const library = ProductionNavItem(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    label: 'Library',
  );

  static const settings = ProductionNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  );

  /// Default navigation items for the app
  static const List<ProductionNavItem> defaultItems = [
    home,
    chat,
    progress,
    library,
    settings,
  ];
}

/// Floating Action Button style navigation item
class FloatingNavItem extends StatefulWidget {
  const FloatingNavItem({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56.0,
    this.badge,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final String? badge;
  final String? tooltip;

  @override
  State<FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEmphasized,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? 'Action Button',
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Material(
                elevation: DesignTokens.elevationLg,
                color: widget.backgroundColor ?? AppColors.accent,
                borderRadius: BorderRadius.circular(widget.size / 2),
                child: InkWell(
                  onTap: _handleTap,
                  onTapDown: (_) => _animationController.forward(),
                  onTapUp: (_) => _animationController.reverse(),
                  onTapCancel: () => _animationController.reverse(),
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.backgroundColor ?? AppColors.accent)
                              .withValues(alpha: 0.3),
                          blurRadius: DesignTokens.spaceLg,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color:
                              widget.foregroundColor ?? AppColors.textOnColor,
                          size: widget.size * 0.4,
                        ),
                        if (widget.badge != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.all(DesignTokens.spaceXs),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusFull),
                                border: Border.all(
                                  color: AppColors.dominantSurface,
                                  width: 2,
                                ),
                              ),
                              constraints: BoxConstraints(
                                minWidth: DesignTokens.spaceLg,
                                minHeight: DesignTokens.spaceLg,
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
            ),
          );
        },
      ),
    );
  }

  void _handleTap() {
    // HapticFeedback.mediumImpact(); // Uncomment if haptic feedback is desired
    widget.onPressed();
  }
}

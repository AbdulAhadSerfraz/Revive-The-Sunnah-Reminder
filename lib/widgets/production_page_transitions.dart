import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/design_tokens.dart';

/// Production-ready page transitions and navigation animations
class ProductionPageTransitions {
  // Private constructor to prevent instantiation
  ProductionPageTransitions._();

  /// Custom slide transition from right to left
  static Widget slideTransitionRightToLeft(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Custom slide transition from left to right
  static Widget slideTransitionLeftToRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(-1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Custom slide transition from bottom to top
  static Widget slideTransitionBottomToTop(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Custom fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Combined fade and slide transition
  static Widget fadeSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.3);
    const end = Offset.zero;

    var slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: DesignTokens.curveEmphasized),
    );

    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeIn),
    );

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  }

  /// Scale transition with fade
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    var scaleTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: DesignTokens.curveEmphasized),
    );

    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeIn),
    );

    return ScaleTransition(
      scale: animation.drive(scaleTween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  }

  /// Rotation transition with fade
  static Widget rotationTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    var rotationTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: DesignTokens.curveStandard),
    );

    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeIn),
    );

    return RotationTransition(
      turns: animation.drive(rotationTween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  }

  /// Shared axis transition (Material Design) - simplified version
  static Widget sharedAxisTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: DesignTokens.curveStandard,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Custom route with enhanced transitions
  static Route<T> customRoute<T extends Object?>(
    Widget child, {
    RouteSettings? settings,
    Duration? duration,
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )? transitionBuilder,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration ?? DesignTokens.durationMedium,
      reverseTransitionDuration: duration ?? DesignTokens.durationMedium,
      transitionsBuilder: transitionBuilder ?? fadeSlideTransition,
    );
  }

  /// Hero-style transition for cards and images
  static Widget heroTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: DesignTokens.curveEmphasized,
        )),
        child: child,
      ),
    );
  }
}

/// Enhanced page route with custom transitions
class ProductionPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final ProductionTransitionType transitionType;
  final Duration? customDuration;

  ProductionPageRoute({
    required this.child,
    this.transitionType = ProductionTransitionType.fadeSlide,
    this.customDuration,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: customDuration ?? DesignTokens.durationMedium,
          reverseTransitionDuration:
              customDuration ?? DesignTokens.durationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case ProductionTransitionType.slide:
                return ProductionPageTransitions.slideTransitionRightToLeft(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.slideLeft:
                return ProductionPageTransitions.slideTransitionLeftToRight(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.slideUp:
                return ProductionPageTransitions.slideTransitionBottomToTop(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.fade:
                return ProductionPageTransitions.fadeTransition(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.fadeSlide:
                return ProductionPageTransitions.fadeSlideTransition(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.scale:
                return ProductionPageTransitions.scaleTransition(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.rotation:
                return ProductionPageTransitions.rotationTransition(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.hero:
                return ProductionPageTransitions.heroTransition(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
              case ProductionTransitionType.sharedAxis:
                return ProductionPageTransitions.sharedAxisTransition(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
            }
          },
        );
}

/// Available transition types
enum ProductionTransitionType {
  slide,
  slideLeft,
  slideUp,
  fade,
  fadeSlide,
  scale,
  rotation,
  hero,
  sharedAxis,
}

/// Navigation helpers with enhanced transitions
class ProductionNavigator {
  // Private constructor to prevent instantiation
  ProductionNavigator._();

  /// Navigate to a new screen with custom transition
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget destination, {
    ProductionTransitionType transition = ProductionTransitionType.fadeSlide,
    Duration? duration,
    RouteSettings? settings,
  }) {
    return Navigator.of(context).push(
      ProductionPageRoute<T>(
        child: destination,
        transitionType: transition,
        customDuration: duration,
        settings: settings,
      ),
    );
  }

  /// Replace current screen with new screen
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget destination, {
    ProductionTransitionType transition = ProductionTransitionType.fadeSlide,
    Duration? duration,
    RouteSettings? settings,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement(
      ProductionPageRoute<T>(
        child: destination,
        transitionType: transition,
        customDuration: duration,
        settings: settings,
      ),
      result: result,
    );
  }

  /// Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget destination,
    RoutePredicate predicate, {
    ProductionTransitionType transition = ProductionTransitionType.fadeSlide,
    Duration? duration,
    RouteSettings? settings,
  }) {
    return Navigator.of(context).pushAndRemoveUntil(
      ProductionPageRoute<T>(
        child: destination,
        transitionType: transition,
        customDuration: duration,
        settings: settings,
      ),
      predicate,
    );
  }

  /// Pop with custom animation
  static void pop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) {
    Navigator.of(context).pop(result);
  }

  /// Pop until specific route
  static void popUntil(
    BuildContext context,
    RoutePredicate predicate,
  ) {
    Navigator.of(context).popUntil(predicate);
  }

  /// Pop to root (first route)
  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Show modal bottom sheet with enhanced animation
  static Future<T?> showBottomSheet<T>(
    BuildContext context,
    Widget child, {
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool isDismissible = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    AnimationController? transitionAnimationController,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor:
          backgroundColor ?? Theme.of(context).bottomSheetTheme.backgroundColor,
      elevation: elevation ?? 8.0,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignTokens.radiusXl),
            ),
          ),
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      barrierColor: barrierColor ?? Colors.black54,
      transitionAnimationController: transitionAnimationController,
      builder: (context) => child,
    );
  }

  /// Show dialog with enhanced animation
  static Future<T?> showEnhancedDialog<T>(
    BuildContext context,
    Widget child, {
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      builder: (context) => child,
    );
  }
}

/// Custom app bar with enhanced animations
class ProductionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final double? titleSpacing;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;
  final ShapeBorder? shape;
  final bool enableAnimation;

  const ProductionAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.titleSpacing,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
    this.shape,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: enableAnimation
          ? AnimatedDefaultTextStyle(
              duration: DesignTokens.durationFast,
              style: Theme.of(context).appBarTheme.titleTextStyle ??
                  Theme.of(context).textTheme.titleLarge!,
              child: Text(title),
            )
          : Text(title),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      shape: shape,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

/// Smooth page view with enhanced physics
class ProductionPageView extends StatelessWidget {
  final List<Widget> children;
  final PageController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final ValueChanged<int>? onPageChanged;
  final bool pageSnapping;
  final bool allowImplicitScrolling;
  final String? restorationId;
  final Clip clipBehavior;
  final DragStartBehavior dragStartBehavior;
  final bool padEnds;

  const ProductionPageView({
    super.key,
    required this.children,
    this.controller,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.onPageChanged,
    this.pageSnapping = true,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.dragStartBehavior = DragStartBehavior.start,
    this.padEnds = true,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      onPageChanged: onPageChanged,
      pageSnapping: pageSnapping,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      allowImplicitScrolling: allowImplicitScrolling,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      dragStartBehavior: dragStartBehavior,
      padEnds: padEnds,
      children: children,
    );
  }
}

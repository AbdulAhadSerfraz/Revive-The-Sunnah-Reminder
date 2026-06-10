import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';

/// Production-ready animation system with consistent timing and easing
class ProductionAnimations {
  ProductionAnimations._();

  // ============================================================================
  // FADE ANIMATIONS
  // ============================================================================

  /// Smooth fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    return _FadeInAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      delay: delay ?? Duration.zero,
      curve: curve ?? DesignTokens.curveStandard,
      child: child,
    );
  }

  /// Smooth fade out animation
  static Widget fadeOut({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return _FadeOutAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      curve: curve ?? DesignTokens.curveStandard,
      child: child,
    );
  }

  /// Cross fade between two widgets
  static Widget crossFade({
    required Widget firstChild,
    required Widget secondChild,
    required bool showFirst,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration ?? DesignTokens.durationMedium,
      firstCurve: curve ?? DesignTokens.curveStandard,
      secondCurve: curve ?? DesignTokens.curveStandard,
      sizeCurve: curve ?? DesignTokens.curveStandard,
    );
  }

  // ============================================================================
  // SLIDE ANIMATIONS
  // ============================================================================

  /// Slide in from direction
  static Widget slideIn({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double distance = 1.0,
  }) {
    return _SlideInAnimation(
      direction: direction,
      duration: duration ?? DesignTokens.durationMedium,
      delay: delay ?? Duration.zero,
      curve: curve ?? DesignTokens.curveEmphasized,
      distance: distance,
      child: child,
    );
  }

  /// Slide out to direction
  static Widget slideOut({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration? duration,
    Curve? curve,
    double distance = 1.0,
  }) {
    return _SlideOutAnimation(
      direction: direction,
      duration: duration ?? DesignTokens.durationMedium,
      curve: curve ?? DesignTokens.curveStandard,
      distance: distance,
      child: child,
    );
  }

  // ============================================================================
  // SCALE ANIMATIONS
  // ============================================================================

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double startScale = 0.0,
  }) {
    return _ScaleInAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      delay: delay ?? Duration.zero,
      curve: curve ?? DesignTokens.curveEmphasized,
      startScale: startScale,
      child: child,
    );
  }

  /// Scale out animation
  static Widget scaleOut({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double endScale = 0.0,
  }) {
    return _ScaleOutAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      curve: curve ?? DesignTokens.curveStandard,
      endScale: endScale,
      child: child,
    );
  }

  /// Bounce scale animation
  static Widget bounceScale({
    required Widget child,
    Duration? duration,
    Duration? delay,
  }) {
    return _BounceScaleAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      delay: delay ?? Duration.zero,
      child: child,
    );
  }

  // ============================================================================
  // COMBINED ANIMATIONS
  // ============================================================================

  /// Fade and slide in combination
  static Widget fadeSlideIn({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double distance = 0.3,
  }) {
    return _FadeSlideInAnimation(
      direction: direction,
      duration: duration ?? DesignTokens.durationMedium,
      delay: delay ?? Duration.zero,
      curve: curve ?? DesignTokens.curveEmphasized,
      distance: distance,
      child: child,
    );
  }

  /// Fade and scale in combination
  static Widget fadeScaleIn({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double startScale = 0.8,
  }) {
    return _FadeScaleInAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      delay: delay ?? Duration.zero,
      curve: curve ?? DesignTokens.curveEmphasized,
      startScale: startScale,
      child: child,
    );
  }

  // ============================================================================
  // LIST ANIMATIONS
  // ============================================================================

  /// Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration? duration,
    Duration? staggerDelay,
    SlideDirection direction = SlideDirection.bottom,
    Curve? curve,
  }) {
    return _StaggeredListAnimation(
      duration: duration ?? DesignTokens.durationMedium,
      staggerDelay: staggerDelay ?? const Duration(milliseconds: 100),
      direction: direction,
      curve: curve ?? DesignTokens.curveEmphasized,
      children: children,
    );
  }

  // ============================================================================
  // SHIMMER LOADING
  // ============================================================================

  /// Shimmer loading animation
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
  }) {
    return _ShimmerAnimation(
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration ?? const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

enum SlideDirection {
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// ============================================================================
// ANIMATION IMPLEMENTATIONS
// ============================================================================

class _FadeInAnimation extends StatefulWidget {
  const _FadeInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<_FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<_FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class _FadeOutAnimation extends StatefulWidget {
  const _FadeOutAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<_FadeOutAnimation> createState() => _FadeOutAnimationState();
}

class _FadeOutAnimationState extends State<_FadeOutAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class _SlideInAnimation extends StatefulWidget {
  const _SlideInAnimation({
    required this.child,
    required this.direction,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.distance,
  });

  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double distance;

  @override
  State<_SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<_SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-widget.distance, 0.0);
      case SlideDirection.right:
        return Offset(widget.distance, 0.0);
      case SlideDirection.top:
        return Offset(0.0, -widget.distance);
      case SlideDirection.bottom:
        return Offset(0.0, widget.distance);
      case SlideDirection.topLeft:
        return Offset(-widget.distance, -widget.distance);
      case SlideDirection.topRight:
        return Offset(widget.distance, -widget.distance);
      case SlideDirection.bottomLeft:
        return Offset(-widget.distance, widget.distance);
      case SlideDirection.bottomRight:
        return Offset(widget.distance, widget.distance);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class _SlideOutAnimation extends StatefulWidget {
  const _SlideOutAnimation({
    required this.child,
    required this.direction,
    required this.duration,
    required this.curve,
    required this.distance,
  });

  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;
  final double distance;

  @override
  State<_SlideOutAnimation> createState() => _SlideOutAnimationState();
}

class _SlideOutAnimationState extends State<_SlideOutAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: _getEndOffset(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  Offset _getEndOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-widget.distance, 0.0);
      case SlideDirection.right:
        return Offset(widget.distance, 0.0);
      case SlideDirection.top:
        return Offset(0.0, -widget.distance);
      case SlideDirection.bottom:
        return Offset(0.0, widget.distance);
      case SlideDirection.topLeft:
        return Offset(-widget.distance, -widget.distance);
      case SlideDirection.topRight:
        return Offset(widget.distance, -widget.distance);
      case SlideDirection.bottomLeft:
        return Offset(-widget.distance, widget.distance);
      case SlideDirection.bottomRight:
        return Offset(widget.distance, widget.distance);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class _ScaleInAnimation extends StatefulWidget {
  const _ScaleInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.startScale,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double startScale;

  @override
  State<_ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<_ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.startScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class _ScaleOutAnimation extends StatefulWidget {
  const _ScaleOutAnimation({
    required this.child,
    required this.duration,
    required this.curve,
    required this.endScale,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double endScale;

  @override
  State<_ScaleOutAnimation> createState() => _ScaleOutAnimationState();
}

class _ScaleOutAnimationState extends State<_ScaleOutAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class _BounceScaleAnimation extends StatefulWidget {
  const _BounceScaleAnimation({
    required this.child,
    required this.duration,
    required this.delay,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<_BounceScaleAnimation> createState() => _BounceScaleAnimationState();
}

class _BounceScaleAnimationState extends State<_BounceScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class _FadeSlideInAnimation extends StatefulWidget {
  const _FadeSlideInAnimation({
    required this.child,
    required this.direction,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.distance,
  });

  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double distance;

  @override
  State<_FadeSlideInAnimation> createState() => _FadeSlideInAnimationState();
}

class _FadeSlideInAnimationState extends State<_FadeSlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-widget.distance, 0.0);
      case SlideDirection.right:
        return Offset(widget.distance, 0.0);
      case SlideDirection.top:
        return Offset(0.0, -widget.distance);
      case SlideDirection.bottom:
        return Offset(0.0, widget.distance);
      case SlideDirection.topLeft:
        return Offset(-widget.distance, -widget.distance);
      case SlideDirection.topRight:
        return Offset(widget.distance, -widget.distance);
      case SlideDirection.bottomLeft:
        return Offset(-widget.distance, widget.distance);
      case SlideDirection.bottomRight:
        return Offset(widget.distance, widget.distance);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class _FadeScaleInAnimation extends StatefulWidget {
  const _FadeScaleInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.startScale,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double startScale;

  @override
  State<_FadeScaleInAnimation> createState() => _FadeScaleInAnimationState();
}

class _FadeScaleInAnimationState extends State<_FadeScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.startScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _StaggeredListAnimation extends StatefulWidget {
  const _StaggeredListAnimation({
    required this.children,
    required this.duration,
    required this.staggerDelay,
    required this.direction,
    required this.curve,
  });

  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final SlideDirection direction;
  final Curve curve;

  @override
  State<_StaggeredListAnimation> createState() =>
      _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<_StaggeredListAnimation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = widget.staggerDelay * index;

        return ProductionAnimations.fadeSlideIn(
          direction: widget.direction,
          duration: widget.duration,
          delay: delay,
          curve: widget.curve,
          child: child,
        );
      }).toList(),
    );
  }
}

class _ShimmerAnimation extends StatefulWidget {
  const _ShimmerAnimation({
    required this.child,
    this.baseColor,
    this.highlightColor,
    required this.duration,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

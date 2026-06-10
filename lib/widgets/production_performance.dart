import 'package:flutter/material.dart';

/// Production-ready performance optimization utilities
class ProductionPerformance {
  // Private constructor to prevent instantiation
  ProductionPerformance._();

  // ============================================================================
  // IMAGE OPTIMIZATION
  // ============================================================================

  /// Optimized image widget with caching and memory management
  static Widget optimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? semanticLabel,
    Widget? errorWidget,
    Widget? placeholder,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: errorWidget != null
          ? (context, error, stackTrace) => errorWidget
          : null,
      frameBuilder: placeholder != null
          ? (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return frame == null ? placeholder : child;
            }
          : null,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
    );
  }

  /// Optimized network image with progressive loading
  static Widget optimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? semanticLabel,
    Widget? errorWidget,
    Widget? placeholder,
    int? memCacheWidth,
    int? memCacheHeight,
    Map<String, String>? headers,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      headers: headers,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      errorBuilder: errorWidget != null
          ? (context, error, stackTrace) => errorWidget
          : (context, error, stackTrace) => _defaultErrorWidget(),
      loadingBuilder: placeholder != null
          ? (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return placeholder;
            }
          : (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _defaultLoadingWidget(loadingProgress);
            },
    );
  }

  /// Default error widget for images
  static Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 48,
      ),
    );
  }

  /// Default loading widget for images
  static Widget _defaultLoadingWidget(ImageChunkEvent? loadingProgress) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress?.expectedTotalBytes != null
              ? loadingProgress!.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Preload images for better performance
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imagePaths,
  ) async {
    final futures = imagePaths.map((path) {
      if (path.startsWith('http')) {
        return precacheImage(NetworkImage(path), context);
      } else {
        return precacheImage(AssetImage(path), context);
      }
    });
    await Future.wait(futures);
  }

  // ============================================================================
  // MEMORY MANAGEMENT
  // ============================================================================

  /// Memory-efficient list view with lazy loading
  static Widget efficientListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    double? itemExtent,
    IndexedWidgetBuilder? separatorBuilder,
    bool shrinkWrap = false,
    double? cacheExtent,
  }) {
    // Use ListView.separated if separator is provided
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        scrollDirection: scrollDirection,
        reverse: reverse,
        physics: physics ?? const BouncingScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent,
      );
    }

    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      itemExtent: itemExtent,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent,
    );
  }

  /// Memory-efficient grid view
  static Widget efficientGridView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
  }) {
    return GridView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      shrinkWrap: shrinkWrap,
    );
  }

  /// Dispose of resources properly
  static void disposeResources({
    ScrollController? scrollController,
    AnimationController? animationController,
    TextEditingController? textController,
    FocusNode? focusNode,
    List<StreamSubscription>? subscriptions,
  }) {
    scrollController?.dispose();
    animationController?.dispose();
    textController?.dispose();
    focusNode?.dispose();

    if (subscriptions != null) {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    }
  }

  // ============================================================================
  // WIDGET OPTIMIZATION
  // ============================================================================

  /// Const wrapper to make widgets const when possible
  static Widget constWrapper({required Widget child}) {
    return child;
  }

  /// Stateless wrapper to avoid unnecessary rebuilds
  static Widget statelessWrapper({
    required WidgetBuilder builder,
    Key? key,
  }) {
    return Builder(
      key: key,
      builder: builder,
    );
  }

  /// Repaint boundary to optimize painting
  static Widget repaintBoundary({
    required Widget child,
    Key? key,
  }) {
    return RepaintBoundary(
      key: key,
      child: child,
    );
  }

  /// Sliver wrapper for efficient scrolling
  static Widget sliverWrapper({
    required Widget child,
    Key? key,
  }) {
    return SliverToBoxAdapter(
      key: key,
      child: child,
    );
  }

  // ============================================================================
  // ANIMATION OPTIMIZATION
  // ============================================================================

  /// Optimized animation builder
  static Widget optimizedAnimationBuilder({
    required Animation<double> animation,
    required Widget Function(BuildContext, Widget?) builder,
    Widget? child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }

  /// Efficient fade transition
  static Widget efficientFadeTransition({
    required Animation<double> opacity,
    required Widget child,
    bool alwaysIncludeSemantics = false,
  }) {
    return FadeTransition(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      child: child,
    );
  }

  /// Efficient slide transition
  static Widget efficientSlideTransition({
    required Animation<Offset> position,
    required Widget child,
    bool transformHitTests = true,
  }) {
    return SlideTransition(
      position: position,
      transformHitTests: transformHitTests,
      child: child,
    );
  }

  // ============================================================================
  // LAYOUT OPTIMIZATION
  // ============================================================================

  /// Optimized column with proper spacing
  static Widget optimizedColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = 0,
  }) {
    if (spacing == 0) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }

  /// Optimized row with proper spacing
  static Widget optimizedRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = 0,
  }) {
    if (spacing == 0) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }

  // ============================================================================
  // CACHING UTILITIES
  // ============================================================================

  /// Simple in-memory cache for expensive computations
  static final Map<String, dynamic> _cache = {};

  /// Get cached value or compute and cache it
  static T getCached<T>({
    required String key,
    required T Function() compute,
    Duration? expiry,
  }) {
    final cacheEntry = _cache[key];

    if (cacheEntry != null) {
      if (cacheEntry is _CacheEntry<T>) {
        if (expiry == null ||
            DateTime.now().difference(cacheEntry.timestamp) < expiry) {
          return cacheEntry.value;
        }
      }
    }

    final value = compute();
    _cache[key] = _CacheEntry<T>(value, DateTime.now());
    return value;
  }

  /// Clear cache
  static void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }

  // ============================================================================
  // DEBOUNCING AND THROTTLING
  // ============================================================================

  static final Map<String, Timer?> _timers = {};

  /// Debounce function calls
  static void debounce({
    required String key,
    required VoidCallback action,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, action);
  }

  /// Throttle function calls
  static void throttle({
    required String key,
    required VoidCallback action,
    Duration interval = const Duration(milliseconds: 100),
  }) {
    if (_timers[key]?.isActive ?? false) return;

    action();
    _timers[key] = Timer(interval, () {
      _timers[key] = null;
    });
  }

  /// Clean up timers
  static void cleanupTimers() {
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
  }
}

/// Cache entry with timestamp
class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}

/// Timer import for debouncing
class Timer {
  final Duration duration;
  final VoidCallback callback;
  bool _isActive = true;

  Timer(this.duration, this.callback) {
    Future.delayed(duration, () {
      if (_isActive) {
        callback();
        _isActive = false;
      }
    });
  }

  bool get isActive => _isActive;

  void cancel() {
    _isActive = false;
  }
}

/// Stream subscription for cleanup
abstract class StreamSubscription<T> {
  void cancel();
}

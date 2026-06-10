import 'package:flutter/material.dart';

/// Service for navigation operations across the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

// Usage example:
// Navigator.of(NavigationService.navigatorKey.currentContext!).push(...);

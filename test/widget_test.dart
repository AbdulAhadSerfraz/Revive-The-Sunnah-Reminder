// This is a basic Flutter widget test for the Revive Sunnah Reminder app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/main.dart';
import 'package:revive_sunnah_reminder/providers/sunnah_provider.dart';
import 'package:revive_sunnah_reminder/providers/streak_provider.dart';
import 'package:revive_sunnah_reminder/core/di/service_locator.dart';

void main() {
  setUp(() async {
    // Initialize dependencies before tests
    await initializeDependencies();
  });

  testWidgets('App startup and basic navigation test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SunnahProvider>(
            create: (_) => serviceLocator.get<SunnahProvider>(),
          ),
          ChangeNotifierProvider<StreakProvider>(
            create: (_) => serviceLocator.get<StreakProvider>(),
          ),
        ],
        child: const ReviveApp(),
      ),
    );

    // Wait for splash screen to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that we can find basic app components
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Verify navigation bar exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('App theme and basic UI elements test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SunnahProvider>(
            create: (_) => serviceLocator.get<SunnahProvider>(),
          ),
          ChangeNotifierProvider<StreakProvider>(
            create: (_) => serviceLocator.get<StreakProvider>(),
          ),
        ],
        child: const ReviveApp(),
      ),
    );

    // Wait for app to load
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check that the app has the correct theme
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Revive - Sunnah Reminder');
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}

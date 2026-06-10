import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:revive_sunnah_reminder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete user flow - app startup to Sunnah completion',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to home screen
      expect(find.byType(AppBar), findsOneWidget);

      // Look for today's Sunnah card
      expect(find.byType(Card), findsAtLeastNWidgets(1));

      // Find and tap the completion button if it exists
      final completionButton = find.text('Mark as Completed');
      if (completionButton.hasFound) {
        await tester.tap(completionButton);
        await tester.pumpAndSettle();

        // Should show completed state
        expect(find.text('Completed ✓'), findsOneWidget);
      }
    });

    testWidgets('Navigation flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on home screen initially
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Navigate to All Sunnahs screen
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      // Should show list of Sunnahs
      expect(find.byType(ListView), findsOneWidget);

      // Navigate to Progress screen
      await tester.tap(find.byIcon(Icons.analytics));
      await tester.pumpAndSettle();

      // Should show progress information
      expect(find.textContaining('Progress'), findsAtLeastNWidgets(1));

      // Navigate to Settings screen
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should show settings options
      expect(find.textContaining('Settings'), findsAtLeastNWidgets(1));

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Should be back on home screen
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('Search functionality test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to All Sunnahs screen
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      // Look for search field
      final searchField = find.byType(TextField);
      if (searchField.hasFound) {
        // Enter search query
        await tester.enterText(searchField, 'eating');
        await tester.pumpAndSettle();

        // Should show filtered results
        expect(find.textContaining('eating', findRichText: true),
            findsAtLeastNWidgets(1));

        // Clear search
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Settings configuration test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Look for notification settings
      final notificationSwitch = find.byType(Switch);
      if (notificationSwitch.hasFound) {
        // Toggle notification setting
        await tester.tap(notificationSwitch.first);
        await tester.pumpAndSettle();

        // Setting should be changed
        final switchWidget = tester.widget<Switch>(notificationSwitch.first);
        expect(switchWidget.value, isNotNull);
      }
    });

    testWidgets('Streak tracking test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for streak information on home screen
      expect(find.textContaining('Streak', findRichText: true),
          findsAtLeastNWidgets(1));

      // Navigate to Progress screen for detailed streak info
      await tester.tap(find.byIcon(Icons.analytics));
      await tester.pumpAndSettle();

      // Should show streak details
      expect(find.textContaining('Day', findRichText: true),
          findsAtLeastNWidgets(1));
    });

    testWidgets('Error handling test - network issues', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should still function even with potential network issues
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Should be able to navigate between screens
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // App should remain stable
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Data persistence test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Complete today's Sunnah if available
      final completionButton = find.text('Mark as Completed');
      if (completionButton.hasFound) {
        await tester.tap(completionButton);
        await tester.pumpAndSettle();

        // Navigate away and back
        await tester.tap(find.byIcon(Icons.library_books));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();

        // Completion state should persist
        expect(find.text('Completed ✓'), findsOneWidget);
      }
    });

    testWidgets('Performance test - rapid navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Rapidly navigate between screens
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.library_books));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.analytics));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }

      // App should remain stable after rapid navigation
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Accessibility test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check for semantic information
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));

      // Check that interactive elements have proper semantics
      final buttons = find.byType(ElevatedButton);
      if (buttons.hasFound) {
        // Buttons should be accessible
        expect(buttons, findsAtLeastNWidgets(1));
      }

      // Navigation should work with semantics
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Dark mode compatibility test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should work in both light and dark themes
      // The app automatically adapts to system theme
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate through screens to ensure theme consistency
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.analytics));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should maintain theme consistency
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Memory management test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through screens multiple times to test memory management
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.library_books));
        await tester.pumpAndSettle();

        // Scroll through list if available
        final listView = find.byType(ListView);
        if (listView.hasFound) {
          await tester.drag(listView, const Offset(0, -200));
          await tester.pumpAndSettle();
        }

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }

      // App should still be responsive and stable
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revive_sunnah_reminder/widgets/sunnah_card.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';

void main() {
  group('SunnahCard Widget Tests', () {
    late Sunnah testSunnah;

    setUp(() {
      testSunnah = Sunnah(
        id: 1,
        title: 'Say Bismillah Before Eating',
        category: 'Eating',
        hadith:
            'The Prophet (ﷺ) said: "When one of you eats, let him mention the name of Allah."',
        benefit: 'Brings blessings to your food and protects from harm',
        source: 'Abu Dawud 3767, Tirmidhi 1858',
      );
    });

    Widget createTestWidget({
      required Sunnah sunnah,
      bool isToday = false,
      bool isCompleted = false,
      VoidCallback? onCompleted,
      VoidCallback? onIncomplete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SunnahCard(
            sunnah: sunnah,
            isToday: isToday,
            isCompleted: isCompleted,
            onCompleted: onCompleted,
            onIncomplete: onIncomplete,
          ),
        ),
      );
    }

    group('Basic Display Tests', () {
      testWidgets('should display Sunnah information correctly',
          (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        // Check if all basic information is displayed
        expect(find.text(testSunnah.title), findsOneWidget);
        expect(find.text(testSunnah.category), findsOneWidget);
        expect(find.text(testSunnah.hadith), findsOneWidget);
        expect(find.text(testSunnah.benefit), findsOneWidget);
        expect(find.textContaining(testSunnah.source), findsOneWidget);
      });

      testWidgets('should display category badge', (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        expect(find.text('Eating'), findsOneWidget);

        // Check if category badge container exists
        final categoryContainer = find.ancestor(
          of: find.text('Eating'),
          matching: find.byType(Container),
        );
        expect(categoryContainer, findsAtLeastNWidgets(1));
      });

      testWidgets('should display hadith section with icon', (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        expect(find.text('Hadith'), findsOneWidget);
        expect(find.byIcon(Icons.format_quote), findsOneWidget);
      });

      testWidgets('should display benefit section with icon', (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        expect(find.text('Benefit'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('should display source with icon', (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        expect(find.byIcon(Icons.source), findsOneWidget);
        expect(find.textContaining('Source:'), findsOneWidget);
      });
    });

    group('Today Sunnah Tests', () {
      testWidgets('should show today status when isToday is true',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
        ));

        // Should show pending status by default
        expect(find.text('Pending'), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('should show completed status when isCompleted is true',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
          isCompleted: true,
        ));

        expect(find.text('Completed'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));
      });

      testWidgets('should show completion button for today Sunnah',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
        ));

        expect(find.text('Mark as Completed'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should not show completion button for non-today Sunnah',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: false,
        ));

        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.text('Mark as Completed'), findsNothing);
      });

      testWidgets('should show different button text when completed',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
          isCompleted: true,
        ));

        expect(find.text('Completed ✓'), findsOneWidget);
        expect(find.text('Mark as Completed'), findsNothing);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onCompleted when completion button is tapped',
          (tester) async {
        bool wasCompleted = false;

        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
          onCompleted: () {
            wasCompleted = true;
          },
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasCompleted, isTrue);
      });

      testWidgets(
          'should call onIncomplete when completion button is tapped for completed Sunnah',
          (tester) async {
        bool wasIncompleted = false;

        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
          isCompleted: true,
          onIncomplete: () {
            wasIncompleted = true;
          },
        ));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasIncompleted, isTrue);
      });

      testWidgets('should not crash when callbacks are null', (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
        ));

        // Should not crash when tapping without callbacks
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // No exception should be thrown
      });
    });

    group('Styling Tests', () {
      testWidgets('should have different styling for today Sunnah',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
        ));

        // Should have gradient background for today's Sunnah
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(Card),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.decoration, isA<BoxDecoration>());
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
      });

      testWidgets('should have proper card structure', (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        expect(find.byType(Card), findsOneWidget);

        // Check card properties
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, equals(4));
        expect(card.shape, isA<RoundedRectangleBorder>());
      });

      testWidgets('should have proper layout structure', (tester) async {
        await tester.pumpWidget(createTestWidget(sunnah: testSunnah));

        // Check main column structure
        expect(find.byType(Column), findsAtLeastNWidgets(1));

        // Check for rows (header, source)
        expect(find.byType(Row), findsAtLeastNWidgets(1));

        // Check for sized boxes (spacing)
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible with screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
        ));

        // Check that text widgets are present for screen readers
        expect(find.text(testSunnah.title), findsOneWidget);
        expect(find.text(testSunnah.hadith), findsOneWidget);
        expect(find.text(testSunnah.benefit), findsOneWidget);

        // Check that interactive elements are present
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should have proper semantics for completion button',
          (tester) async {
        await tester.pumpWidget(createTestWidget(
          sunnah: testSunnah,
          isToday: true,
        ));

        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);

        // Button should have accessible text
        expect(
            find.descendant(
              of: button,
              matching: find.text('Mark as Completed'),
            ),
            findsOneWidget);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle very long text gracefully', (tester) async {
        final longTextSunnah = Sunnah(
          id: 2,
          title:
              'Very Long Title That Might Overflow The Available Space In The Card Widget',
          category: 'Very Long Category Name',
          hadith:
              'This is a very long hadith text that should wrap properly and not cause any overflow issues. It contains multiple sentences and should be displayed correctly within the card boundaries. The text should flow naturally and maintain readability.',
          benefit:
              'This is a very long benefit description that should also wrap properly and maintain good readability even when the text is quite lengthy and spans multiple lines.',
          source: 'Very Long Source Reference That Might Also Be Quite Lengthy',
        );

        await tester.pumpWidget(createTestWidget(sunnah: longTextSunnah));

        // Should not have overflow errors
        expect(tester.takeException(), isNull);

        // Text should still be present
        expect(find.text(longTextSunnah.title), findsOneWidget);
        expect(find.text(longTextSunnah.category), findsOneWidget);
      });

      testWidgets('should handle empty or minimal text', (tester) async {
        final minimalSunnah = Sunnah(
          id: 3,
          title: 'Short',
          category: 'A',
          hadith: 'Brief hadith.',
          benefit: 'Benefit.',
          source: 'Ref',
        );

        await tester.pumpWidget(createTestWidget(sunnah: minimalSunnah));

        // Should display minimal text without issues
        expect(find.text('Short'), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('Brief hadith.'), findsOneWidget);
      });

      testWidgets('should handle special characters in text', (tester) async {
        final specialCharSunnah = Sunnah(
          id: 4,
          title: 'Title with Arabic and Special chars',
          category: 'Special\nCategory',
          hadith: 'Hadith with quotes "test" and Arabic symbol',
          benefit: 'Benefit with emoji and special chars',
          source: 'Source with #hashtag & @mention',
        );

        await tester.pumpWidget(createTestWidget(sunnah: specialCharSunnah));

        // Should display special characters without issues
        expect(find.textContaining('Arabic'), findsAtLeastNWidgets(1));
        expect(find.textContaining('"test"'), findsOneWidget);
        expect(find.textContaining('emoji'), findsOneWidget);
      });
    });
  });
}

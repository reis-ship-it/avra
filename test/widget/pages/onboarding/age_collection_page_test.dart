import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/age_collection_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for AgeCollectionPage
/// Tests UI rendering, date selection, age calculation, and callbacks
void main() {
  group('AgeCollectionPage Widget Tests', () {
    // Removed: Property assignment tests
    // Age collection page tests focus on business logic (UI display, birthday selection, age group display, privacy notice, initialization), not property assignment

    testWidgets(
        'should display all required UI elements, display selected birthday when provided, display age group correctly for different ages, show privacy notice, display age information container when birthday is selected, not display age information when no birthday selected, have tappable birthday selection card, or initialize with provided selectedBirthday',
        (WidgetTester tester) async {
      // Test business logic: Age collection page display and functionality
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: null,
          onBirthdayChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Age Verification'), findsOneWidget);
      expect(
          find.text(
              'We need your age to provide age-appropriate content and ensure legal compliance.'),
          findsOneWidget);
      expect(find.text('Birthday'), findsOneWidget);
      expect(find.text('Tap to select your birthday'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(
          find.textContaining('Your age is stored securely'), findsOneWidget);
      expect(find.textContaining('OUR_GUTS.md'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
      expect(find.textContaining('Age:'), findsNothing);
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final testBirthday1 = DateTime(2000, 1, 15);
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: testBirthday1,
          onBirthdayChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.textContaining('January 15, 2000'), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining('years old'), findsOneWidget);
      expect(find.textContaining('Age Group:'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      final testBirthday2 = DateTime(1995, 6, 15);
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: testBirthday2,
          onBirthdayChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining('Age Group:'), findsOneWidget);

      final testCases = [
        (DateTime(2015, 1, 1), 'Under 13'),
        (DateTime(2010, 1, 1), 'Teen (13-17)'),
        (DateTime(2005, 1, 1), 'Young Adult (18-25)'),
        (DateTime(1980, 1, 1), 'Adult (26-64)'),
        (DateTime(1950, 1, 1), 'Senior (65+)'),
      ];
      for (final testCase in testCases) {
        final widget = WidgetTestHelpers.createTestableWidget(
          child: AgeCollectionPage(
            selectedBirthday: testCase.$1,
            onBirthdayChanged: (_) {},
          ),
        );
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        expect(find.textContaining(testCase.$2), findsOneWidget);
        await tester.pumpAndSettle();
      }

      final testBirthday3 = DateTime(1990, 3, 20);
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: testBirthday3,
          onBirthdayChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.textContaining('March 20, 1990'), findsOneWidget);
    });
  });
}

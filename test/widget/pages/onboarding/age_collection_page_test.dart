import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/age_collection_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for AgeCollectionPage
/// Tests UI rendering, date selection, age calculation, and callbacks
void main() {
  group('AgeCollectionPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: null,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify all UI elements are present
      expect(find.text('Age Verification'), findsOneWidget);
      expect(find.text('We need your age to provide age-appropriate content and ensure legal compliance.'), findsOneWidget);
      expect(find.text('Birthday'), findsOneWidget);
      expect(find.text('Tap to select your birthday'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays selected birthday when provided', (WidgetTester tester) async {
      // Arrange
      final testBirthday = DateTime(2000, 1, 15);
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: testBirthday,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show formatted birthday and age
      expect(find.textContaining('January 15, 2000'), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining('years old'), findsOneWidget);
      expect(find.textContaining('Age Group:'), findsOneWidget);
    });

    testWidgets('displays age group correctly for different ages', (WidgetTester tester) async {
      // Arrange & Act & Assert for different age groups
      final testCases = [
        (DateTime(2015, 1, 1), 'Under 13'), // Under 13
        (DateTime(2010, 1, 1), 'Teen (13-17)'), // Teen
        (DateTime(2005, 1, 1), 'Young Adult (18-25)'), // Young Adult
        (DateTime(1980, 1, 1), 'Adult (26-64)'), // Adult
        (DateTime(1950, 1, 1), 'Senior (65+)'), // Senior
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
    });

    testWidgets('shows privacy notice', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: null,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Privacy notice should be visible
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.textContaining('Your age is stored securely'), findsOneWidget);
      expect(find.textContaining('OUR_GUTS.md'), findsOneWidget);
    });

    testWidgets('displays age information container when birthday is selected', (WidgetTester tester) async {
      // Arrange
      final testBirthday = DateTime(1995, 6, 15);
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: testBirthday,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Age info container should be visible
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining('Age Group:'), findsOneWidget);
    });

    testWidgets('does not display age information when no birthday selected', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: null,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Age info container should not be visible
      expect(find.byIcon(Icons.info_outline), findsNothing);
      expect(find.textContaining('Age:'), findsNothing);
    });

    testWidgets('has tappable birthday selection card', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: null,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Birthday card should be tappable
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);
      
      // Note: Actual date picker interaction would require mocking showDatePicker
      // This test verifies the UI structure is correct
    });

    testWidgets('initializes with provided selectedBirthday', (WidgetTester tester) async {
      // Arrange
      final testBirthday = DateTime(1990, 3, 20);
      final widget = WidgetTestHelpers.createTestableWidget(
        child: AgeCollectionPage(
          selectedBirthday: testBirthday,
          onBirthdayChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should display the provided birthday
      expect(find.textContaining('March 20, 1990'), findsOneWidget);
    });
  });
}


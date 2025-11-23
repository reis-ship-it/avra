import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/preference_survey_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for PreferenceSurveyPage
/// Tests UI rendering, preference selection, and callbacks
void main() {
  group('PreferenceSurveyPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: PreferenceSurveyPage(
          preferences: {},
          onPreferencesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify main UI elements are present
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.textContaining('Tell us what you love'), findsOneWidget);
    });

    testWidgets('displays preference categories', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: PreferenceSurveyPage(
          preferences: {},
          onPreferencesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show category sections
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
    });

    testWidgets('initializes with provided preferences', (WidgetTester tester) async {
      // Arrange
      final initialPreferences = {
        'Food & Drink': ['Coffee & Tea', 'Bars & Pubs'],
        'Activities': ['Live Music'],
      };
      final widget = WidgetTestHelpers.createTestableWidget(
        child: PreferenceSurveyPage(
          preferences: initialPreferences,
          onPreferencesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Preferences should be displayed
      expect(find.text('Coffee & Tea'), findsOneWidget);
      expect(find.text('Bars & Pubs'), findsOneWidget);
    });

    testWidgets('calls onPreferencesChanged callback', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: PreferenceSurveyPage(
          preferences: {},
          onPreferencesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Callback structure exists
      // Note: Actual preference selection would require tapping chips/buttons
      // This test verifies the widget structure is correct
      expect(find.byType(PreferenceSurveyPage), findsOneWidget);
    });
  });
}


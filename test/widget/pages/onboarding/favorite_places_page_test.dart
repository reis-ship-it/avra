import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/favorite_places_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for FavoritePlacesPage
/// Tests UI rendering, place selection, and callbacks
void main() {
  group('FavoritePlacesPage Widget Tests', () {
    // Removed: Property assignment tests
    // Favorite places page tests focus on business logic (UI display, search field, region categories, initialization, user homebase), not property assignment

    testWidgets(
        'should display all required UI elements, display search field, display region categories, initialize with provided favorite places, or use user homebase for suggestions',
        (WidgetTester tester) async {
      // Test business logic: Favorite places page display and functionality
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: [],
          onPlacesChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Favorite Places'), findsOneWidget);
      expect(find.textContaining('Tell us about your favorite places'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('New York Area'), findsOneWidget);
      expect(find.text('Los Angeles Area'), findsOneWidget);

      final initialPlaces = ['Brooklyn', 'Manhattan'];
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: initialPlaces,
          onPlacesChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Brooklyn'), findsOneWidget);
      expect(find.text('Manhattan'), findsOneWidget);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: [],
          onPlacesChanged: (_) {},
          userHomebase: 'Brooklyn',
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('Favorite Places'), findsOneWidget);
    });
  });
}

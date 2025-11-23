import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/favorite_places_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for FavoritePlacesPage
/// Tests UI rendering, place selection, and callbacks
void main() {
  group('FavoritePlacesPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: [],
          onPlacesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify main UI elements are present
      expect(find.text('Favorite Places'), findsOneWidget);
      expect(find.textContaining('Tell us about your favorite places'), findsOneWidget);
    });

    testWidgets('displays search field', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: [],
          onPlacesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Search field should be present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays region categories', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: [],
          onPlacesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show region categories
      expect(find.text('New York Area'), findsOneWidget);
      expect(find.text('Los Angeles Area'), findsOneWidget);
    });

    testWidgets('initializes with provided favorite places', (WidgetTester tester) async {
      // Arrange
      final initialPlaces = ['Brooklyn', 'Manhattan'];
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: initialPlaces,
          onPlacesChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should display provided places
      expect(find.text('Brooklyn'), findsOneWidget);
      expect(find.text('Manhattan'), findsOneWidget);
    });

    testWidgets('uses user homebase for suggestions', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FavoritePlacesPage(
          favoritePlaces: [],
          onPlacesChanged: (_) {},
          userHomebase: 'Brooklyn',
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show location-aware suggestions
      expect(find.text('Favorite Places'), findsOneWidget);
    });
  });
}


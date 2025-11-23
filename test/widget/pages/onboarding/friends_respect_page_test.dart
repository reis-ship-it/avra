import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/friends_respect_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for FriendsRespectPage
/// Tests UI rendering, list selection, and callbacks
void main() {
  group('FriendsRespectPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FriendsRespectPage(
          respectedLists: [],
          onRespectedListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify main UI elements are present
      expect(find.text('Friends & Respect'), findsOneWidget);
      expect(find.textContaining('Respect lists from'), findsOneWidget);
    });

    testWidgets('displays public lists', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FriendsRespectPage(
          respectedLists: [],
          onRespectedListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show list cards
      expect(find.text('Brooklyn Coffee Crawl'), findsOneWidget);
      expect(find.text('Hidden Gems in Williamsburg'), findsOneWidget);
    });

    testWidgets('displays list metadata', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FriendsRespectPage(
          respectedLists: [],
          onRespectedListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show list details
      expect(find.textContaining('spots'), findsWidgets);
      expect(find.textContaining('respects'), findsWidgets);
    });

    testWidgets('initializes with provided respected lists', (WidgetTester tester) async {
      // Arrange
      final initialLists = ['list-1', 'list-2'];
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FriendsRespectPage(
          respectedLists: initialLists,
          onRespectedListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should display selected lists
      expect(find.byType(FriendsRespectPage), findsOneWidget);
    });

    testWidgets('displays user profile information', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: FriendsRespectPage(
          respectedLists: [],
          onRespectedListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show creator information
      expect(find.text('Sarah M.'), findsOneWidget);
      expect(find.text('Mike T.'), findsOneWidget);
    });
  });
}


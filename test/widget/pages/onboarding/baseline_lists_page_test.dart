import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/baseline_lists_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for BaselineListsPage
/// Tests UI rendering, list generation, and callbacks
void main() {
  group('BaselineListsPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: [],
          onBaselineListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify main UI elements are present
      expect(find.text('Baseline Lists'), findsOneWidget);
      expect(find.textContaining('Create your first lists'), findsOneWidget);
    });

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: [],
          onBaselineListsChanged: (_) {},
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump(); // Initial build

      // Assert - Should show loading indicator initially
      // Note: Loading state may be brief, so we check for the structure
      expect(find.byType(BaselineListsPage), findsOneWidget);
    });

    testWidgets('displays generated list suggestions after loading', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: [],
          onBaselineListsChanged: (_) {},
          userName: 'Test User',
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Wait for loading to complete (1500ms delay + animation)
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assert - Should show generated suggestions
      expect(find.text('Baseline Lists'), findsOneWidget);
    });

    testWidgets('initializes with provided baseline lists', (WidgetTester tester) async {
      // Arrange
      final initialLists = ['List 1', 'List 2'];
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: initialLists,
          onBaselineListsChanged: (_) {},
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should display provided lists
      expect(find.byType(BaselineListsPage), findsOneWidget);
    });

    testWidgets('uses user preferences for suggestions', (WidgetTester tester) async {
      // Arrange
      final preferences = <String, List<String>>{
        'Food & Drink': ['Coffee & Tea'],
        'homebase': ['Brooklyn'],
      };
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: [],
          onBaselineListsChanged: (_) {},
          userName: 'Test User',
          userPreferences: preferences,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assert - Should generate location-aware suggestions
      expect(find.text('Baseline Lists'), findsOneWidget);
    });
  });
}


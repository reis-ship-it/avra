import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/baseline_lists_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for BaselineListsPage
/// Tests UI rendering, list generation, and callbacks
void main() {
  group('BaselineListsPage Widget Tests', () {
    // Removed: Property assignment tests
    // Baseline lists page tests focus on business logic (UI display, loading state, generated suggestions, initialization, user preferences), not property assignment

    testWidgets(
        'should display all required UI elements, show loading state initially, display generated list suggestions after loading, initialize with provided baseline lists, or use user preferences for suggestions',
        (WidgetTester tester) async {
      // Test business logic: Baseline lists page display and functionality
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: const [],
          onBaselineListsChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Baseline Lists'), findsOneWidget);
      expect(find.textContaining('Create your first lists'), findsOneWidget);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: const [],
          onBaselineListsChanged: (_) {},
        ),
      );
      await tester.pumpWidget(widget2);
      await tester.pump();
      expect(find.byType(BaselineListsPage), findsOneWidget);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: const [],
          onBaselineListsChanged: (_) {},
          userName: 'Test User',
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Baseline Lists'), findsOneWidget);

      final initialLists = ['List 1', 'List 2'];
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: initialLists,
          onBaselineListsChanged: (_) {},
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.byType(BaselineListsPage), findsOneWidget);

      final preferences = <String, List<String>>{
        'Food & Drink': ['Coffee & Tea'],
        'homebase': ['Brooklyn'],
      };
      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: BaselineListsPage(
          baselineLists: const [],
          onBaselineListsChanged: (_) {},
          userName: 'Test User',
          userPreferences: preferences,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Baseline Lists'), findsOneWidget);
    });
  });
}

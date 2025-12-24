import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/common/search_bar.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for CustomSearchBar
/// Tests search bar UI, interactions, and callbacks
void main() {
  setUpAll(() async {
    await WidgetTestHelpers.setupWidgetTestEnvironment();
  });

  tearDownAll(() async {
    await WidgetTestHelpers.cleanupWidgetTestEnvironment();
  });

  group('CustomSearchBar Widget Tests', () {
    // Removed: Property assignment tests
    // Search bar tests focus on business logic (search bar display, user interactions, state management), not property assignment

    testWidgets(
        'should display search bar with default hint, display custom hint text, display initial value, call onChanged callback when text changes, show clear button when text is entered, or respect enabled state',
        (WidgetTester tester) async {
      // Test business logic: search bar display and interactions
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const CustomSearchBar(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const CustomSearchBar(hintText: 'Search spots...'),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Search spots...'), findsOneWidget);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const CustomSearchBar(initialValue: 'test query'),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('test query'), findsOneWidget);

      String? changedValue;
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: CustomSearchBar(
          onChanged: (value) => changedValue = value,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      await tester.enterText(find.byType(TextField), 'new query');
      await tester.pump();
      expect(changedValue, equals('new query'));

      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: const CustomSearchBar(showClearButton: true),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      final widget6 = WidgetTestHelpers.createTestableWidget(
        child: const CustomSearchBar(enabled: false),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget6);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}

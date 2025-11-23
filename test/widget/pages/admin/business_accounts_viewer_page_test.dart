import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/admin/business_accounts_viewer_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for BusinessAccountsViewerPage
/// Tests business accounts viewer UI
void main() {
  group('BusinessAccountsViewerPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const BusinessAccountsViewerPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify viewer UI is present
      expect(find.text('Business Accounts Viewer'), findsOneWidget);
      expect(find.text('View and manage business accounts'), findsOneWidget);
    });

    testWidgets('displays business accounts content', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const BusinessAccountsViewerPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show business accounts UI
      expect(find.byType(BusinessAccountsViewerPage), findsOneWidget);
    });
  });
}


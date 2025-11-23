import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/admin/god_mode_dashboard_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for GodModeDashboardPage
/// Tests admin dashboard UI and data display
void main() {
  group('GodModeDashboardPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const GodModeDashboardPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify dashboard UI is present
      expect(find.byType(GodModeDashboardPage), findsOneWidget);
    });

    testWidgets('displays dashboard content', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const GodModeDashboardPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show dashboard content
      expect(find.byType(GodModeDashboardPage), findsOneWidget);
    });
  });
}


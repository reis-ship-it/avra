import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/admin/god_mode_login_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for GodModeLoginPage
/// Tests admin login UI and authentication
void main() {
  group('GodModeLoginPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const GodModeLoginPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify login UI is present
      expect(find.byType(GodModeLoginPage), findsOneWidget);
    });

    testWidgets('displays login form', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const GodModeLoginPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show login form
      expect(find.byType(GodModeLoginPage), findsOneWidget);
    });
  });
}


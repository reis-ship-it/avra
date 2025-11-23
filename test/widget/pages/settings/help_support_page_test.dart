import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/settings/help_support_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for HelpSupportPage
/// Tests help and support content
void main() {
  group('HelpSupportPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const HelpSupportPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify all UI elements are present
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('We\'re Here to Help'), findsOneWidget);
    });

    testWidgets('displays help content', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const HelpSupportPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show help content
      expect(find.byType(HelpSupportPage), findsOneWidget);
    });
  });
}


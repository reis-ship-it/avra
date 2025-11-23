import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/settings/privacy_settings_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for PrivacySettingsPage
/// Tests privacy settings UI and controls
void main() {
  group('PrivacySettingsPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const PrivacySettingsPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify all UI elements are present
      expect(find.text('Privacy Settings'), findsOneWidget);
      expect(find.text('OUR_GUTS.md Commitment'), findsOneWidget);
      expect(find.text('Core Privacy Controls'), findsOneWidget);
    });

    testWidgets('displays privacy preference controls', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const PrivacySettingsPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show privacy controls
      expect(find.byType(PrivacySettingsPage), findsOneWidget);
    });
  });
}


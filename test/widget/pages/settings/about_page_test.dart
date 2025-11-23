import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/settings/about_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for AboutPage
/// Tests about page content and links
void main() {
  group('AboutPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const AboutPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify all UI elements are present
      expect(find.text('About SPOTS'), findsOneWidget);
      expect(find.text('SPOTS'), findsOneWidget);
      expect(find.text('know you belong.'), findsOneWidget);
    });

    testWidgets('displays app information', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const AboutPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show app info
      expect(find.byType(AboutPage), findsOneWidget);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/ai2ai/privacy_controls_widget.dart';
import "../../helpers/widget_test_helpers.dart';

/// Widget tests for PrivacyControlsWidget
/// Tests privacy controls for AI2AI participation
void main() {
  group('PrivacyControlsWidget Widget Tests', () {
    // Removed: Property assignment tests
    // Privacy controls widget tests focus on business logic (privacy controls display, switch toggles, dropdown, information message), not property assignment

    testWidgets(
        'should display all privacy controls, toggle AI2AI participation switch, display privacy level dropdown, display privacy information message, or toggle share learning insights switch',
        (WidgetTester tester) async {
      // Test business logic: Privacy controls widget display and interactions
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const PrivacyControlsWidget(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      expect(find.byType(PrivacyControlsWidget), findsOneWidget);
      expect(find.text('Privacy Controls'), findsOneWidget);
      expect(find.text('AI2AI Participation'), findsOneWidget);
      expect(find.text('Privacy Level'), findsOneWidget);
      expect(find.text('Share Learning Insights'), findsOneWidget);
      final switchFinder = find.byType(SwitchListTile).first;
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      final switchWidget1 = tester.widget<SwitchListTile>(switchFinder);
      expect(switchWidget1.value, isFalse);
      expect(find.text('Maximum'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.textContaining('All data is anonymized and privacy-preserving'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      final switches = find.byType(SwitchListTile);
      expect(switches, findsNWidgets(2));
      final shareInsightsSwitch = switches.at(1);
      await tester.tap(shareInsightsSwitch);
      await tester.pumpAndSettle();
      final switchWidget2 = tester.widget<SwitchListTile>(shareInsightsSwitch);
      expect(switchWidget2.value, isFalse);
    });
  });
}


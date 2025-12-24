/// SPOTS DiscoverySettingsPage Widget Tests
/// Date: November 20, 2025
/// Purpose: Test DiscoverySettingsPage functionality and UI behavior
///
/// Test Coverage:
/// - Rendering: Page displays correctly with settings
/// - User Interactions: Update scan interval, device timeout
/// - Settings Persistence: Saves settings correctly
/// - Validation: Validates input ranges
///
/// Dependencies:
/// - DeviceDiscoveryService: For applying settings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/network/discovery_settings_page.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../mocks/mock_storage_service.dart';

/// Widget tests for DiscoverySettingsPage
/// Tests page rendering, settings display, and user interactions
void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockGetStorage.reset();
  });

  group('DiscoverySettingsPage Widget Tests', () {
    // Removed: Property assignment tests
    // Discovery settings page tests focus on business logic (page display, settings display, user interactions, validation, settings persistence), not property assignment

    testWidgets(
        'should display page with app bar, display scan interval setting, display device timeout setting, display save button, allow changing scan interval, allow changing device timeout, show validation error for invalid scan interval, save settings when save button is tapped, display default scan interval value, or display default device timeout value',
        (WidgetTester tester) async {
      // Test business logic: Discovery settings page display and interactions
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(DiscoverySettingsPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Discovery Settings'),
          ),
          findsOneWidget);
      expect(find.text('Scan Interval'), findsOneWidget);
      expect(find.text('How often to scan for nearby devices (in seconds)'),
          findsOneWidget);
      expect(find.text('Device Timeout'), findsOneWidget);
      expect(
          find.text(
              'How long to keep discovered devices before removing them (in minutes)'),
          findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      final scanIntervalField1 = find.byType(TextFormField).first;
      await tester.enterText(scanIntervalField1, '10');
      await tester.pumpAndSettle();
      expect(find.text('10'), findsWidgets);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      final timeoutField = find.byType(TextFormField).last;
      await tester.enterText(timeoutField, '5');
      await tester.pumpAndSettle();
      expect(find.text('5'), findsWidgets);

      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      final scanIntervalField2 = find.byType(TextFormField).first;
      await tester.enterText(scanIntervalField2, '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Must be at least 1 second'), findsOneWidget);

      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      final scanIntervalField3 = find.byType(TextFormField).first;
      await tester.enterText(scanIntervalField3, '10');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Settings saved successfully'), findsOneWidget);

      final widget6 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget6);
      final textField1 = find.byType(TextFormField).first;
      expect(textField1, findsOneWidget);
      final textFieldWidget1 = tester.widget<TextFormField>(textField1);
      expect(textFieldWidget1.controller?.text, isNotEmpty);

      final widget7 = WidgetTestHelpers.createTestableWidget(
        child: const DiscoverySettingsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget7);
      final textField2 = find.byType(TextFormField).last;
      expect(textField2, findsOneWidget);
      final textFieldWidget2 = tester.widget<TextFormField>(textField2);
      expect(textFieldWidget2.controller?.text, isNotEmpty);
    });
  });
}

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
import 'package:get_storage/get_storage.dart';
import 'package:spots/presentation/pages/network/discovery_settings_page.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_storage_service.dart';

/// Widget tests for DiscoverySettingsPage
/// Tests page rendering, settings display, and user interactions
void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockGetStorage.reset();
  });

  group('DiscoverySettingsPage Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays page with app bar', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(DiscoverySettingsPage), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Discovery Settings'),
        ), findsOneWidget);
      });

      testWidgets('displays scan interval setting', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Scan Interval'), findsOneWidget);
        expect(find.text('How often to scan for nearby devices (in seconds)'), findsOneWidget);
      });

      testWidgets('displays device timeout setting', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Device Timeout'), findsOneWidget);
        expect(find.text('How long to keep discovered devices before removing them (in minutes)'), findsOneWidget);
      });

      testWidgets('displays save button', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Save'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('allows changing scan interval', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        
        // Find the scan interval text field
        final scanIntervalField = find.byType(TextFormField).first;
        await tester.enterText(scanIntervalField, '10');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('10'), findsWidgets);
      });

      testWidgets('allows changing device timeout', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        
        // Find the device timeout text field
        final timeoutField = find.byType(TextFormField).last;
        await tester.enterText(timeoutField, '5');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('5'), findsWidgets);
      });

      testWidgets('shows validation error for invalid scan interval', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        
        final scanIntervalField = find.byType(TextFormField).first;
        await tester.enterText(scanIntervalField, '0');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Must be at least 1 second'), findsOneWidget);
      });

      testWidgets('saves settings when save button is tapped', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        
        final scanIntervalField = find.byType(TextFormField).first;
        await tester.enterText(scanIntervalField, '10');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert
        // Should show success message
        expect(find.text('Settings saved successfully'), findsOneWidget);
      });
    });

    group('Settings Display', () {
      testWidgets('displays default scan interval value', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        // Text field should exist and have a value
        final textField = find.byType(TextFormField).first;
        expect(textField, findsOneWidget);
        final textFieldWidget = tester.widget<TextFormField>(textField);
        expect(textFieldWidget.controller?.text, isNotEmpty);
      });

      testWidgets('displays default device timeout value', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const DiscoverySettingsPage(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        // Text field should exist and have a value
        final textField = find.byType(TextFormField).last;
        expect(textField, findsOneWidget);
        final textFieldWidget = tester.widget<TextFormField>(textField);
        expect(textFieldWidget.controller?.text, isNotEmpty);
      });
    });
  });
}


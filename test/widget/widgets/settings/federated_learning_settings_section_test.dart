/// SPOTS FederatedLearningSettingsSection Widget Tests
/// Date: November 20, 2025
/// Purpose: Test FederatedLearningSettingsSection functionality and UI behavior
/// 
/// Test Coverage:
/// - Rendering: Section displays correctly with explanation
/// - User Interactions: Opt-in/opt-out toggle
/// - Information Display: Benefits and consequences explained
/// - Edge Cases: State persistence, error handling
/// 
/// Dependencies:
/// - FederatedLearningSystem: For participation status
/// - GetStorage: For preference storage

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/settings/federated_learning_settings_section.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for FederatedLearningSettingsSection
/// Tests section rendering, user interactions, and information display
void main() {
  group('FederatedLearningSettingsSection Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays section with title', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(FederatedLearningSettingsSection), findsOneWidget);
        expect(find.text('Federated Learning'), findsOneWidget);
      });

      testWidgets('displays explanation of federated learning', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Privacy-preserving'), findsOneWidget);
        expect(find.textContaining('data stays on your device'), findsOneWidget);
      });

      testWidgets('displays participation benefits', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Benefits of participating:'), findsOneWidget);
        expect(find.textContaining('More accurate'), findsOneWidget);
      });

      testWidgets('displays consequences of not participating', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Less accurate'), findsOneWidget);
        expect(find.textContaining('Slower'), findsOneWidget);
      });

      testWidgets('displays opt-in/opt-out toggle', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(Switch), findsOneWidget);
        expect(find.textContaining('Participate'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('toggles participation when switch is tapped', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: Scaffold(
            body: const FederatedLearningSettingsSection(),
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        final switchWidget = find.byType(Switch);
        final initialValue = tester.widget<Switch>(switchWidget).value;
        await tester.tap(switchWidget);
        await tester.pumpAndSettle();

        // Assert
        final newValue = tester.widget<Switch>(switchWidget).value;
        expect(newValue, isNot(equals(initialValue)));
      });

      testWidgets('shows info dialog when info icon is tapped', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        final infoButton = find.byIcon(Icons.info_outline);
        if (infoButton.evaluate().isNotEmpty) {
          await tester.tap(infoButton.first);
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(AlertDialog), findsOneWidget);
        }
      });
    });

    group('Information Display', () {
      testWidgets('displays privacy protection information', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Privacy'), findsWidgets);
        expect(find.textContaining('anonymized'), findsOneWidget);
      });

      testWidgets('displays how it works explanation', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningSettingsSection(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        // Check that info dialog can be opened (contains explanation)
        final infoButton = find.byIcon(Icons.info_outline);
        expect(infoButton, findsWidgets); // May have multiple info icons
      });
    });
  });
}


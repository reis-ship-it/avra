/// SPOTS ActionConfirmationDialog Widget Tests
/// Date: November 20, 2025
/// Purpose: Test ActionConfirmationDialog widget functionality and UI behavior
/// 
/// Test Coverage:
/// - Rendering: Dialog displays correctly with various action types
/// - User Interactions: Cancel/confirm button taps
/// - Action Preview: Shows correct preview for each action type
/// - Edge Cases: Different action intents, null handling
/// 
/// Dependencies:
/// - ActionIntent models from core/ai/action_models.dart
/// - AppTheme for consistent styling

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/ai/action_models.dart';
import 'package:spots/presentation/widgets/common/action_confirmation_dialog.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for ActionConfirmationDialog
/// Tests dialog rendering, user interactions, and action preview display
void main() {
  group('ActionConfirmationDialog Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays dialog correctly for CreateSpotIntent', (WidgetTester tester) async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Blue Bottle Coffee',
          description: 'A great coffee shop',
          latitude: 37.7749,
          longitude: -122.4194,
          category: 'Coffee',
          userId: 'user123',
          confidence: 0.95,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(ActionConfirmationDialog), findsOneWidget);
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Create Spot'), findsOneWidget);
        expect(find.text('Blue Bottle Coffee'), findsOneWidget);
      });

      testWidgets('displays dialog correctly for CreateListIntent', (WidgetTester tester) async {
        // Arrange
        final intent = CreateListIntent(
          title: 'My Coffee Shops',
          description: 'Favorite coffee spots',
          userId: 'user123',
          confidence: 0.90,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(ActionConfirmationDialog), findsOneWidget);
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Create List'), findsOneWidget);
        expect(find.text('My Coffee Shops'), findsOneWidget);
      });

      testWidgets('displays dialog correctly for AddSpotToListIntent', (WidgetTester tester) async {
        // Arrange
        final intent = AddSpotToListIntent(
          spotId: 'spot123',
          listId: 'list456',
          userId: 'user123',
          confidence: 0.85,
          metadata: {
            'spotName': 'Blue Bottle Coffee',
            'listName': 'My Coffee Shops',
          },
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(ActionConfirmationDialog), findsOneWidget);
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Add Spot to List'), findsOneWidget);
        expect(find.text('Blue Bottle Coffee'), findsOneWidget);
        expect(find.text('My Coffee Shops'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('calls onConfirm when confirm button is tapped', (WidgetTester tester) async {
        // Arrange
        bool confirmCalled = false;
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {
                      confirmCalled = true;
                      Navigator.of(context).pop();
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Assert
        expect(confirmCalled, isTrue);
        expect(find.byType(ActionConfirmationDialog), findsNothing);
      });

      testWidgets('calls onCancel when cancel button is tapped', (WidgetTester tester) async {
        // Arrange
        bool cancelCalled = false;
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {
                      Navigator.of(context).pop();
                    },
                    onCancel: () {
                      cancelCalled = true;
                      Navigator.of(context).pop();
                    },
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert
        expect(cancelCalled, isTrue);
        expect(find.byType(ActionConfirmationDialog), findsNothing);
      });

      testWidgets('dismisses dialog when tapping outside', (WidgetTester tester) async {
        // Arrange
        bool cancelCalled = false;
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {
                      Navigator.of(context).pop();
                    },
                    onCancel: () {
                      cancelCalled = true;
                    },
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ActionConfirmationDialog), findsNothing);
      });
    });

    group('Action Preview', () {
      testWidgets('shows correct preview for CreateSpotIntent with all fields', (WidgetTester tester) async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Blue Bottle Coffee',
          description: 'A great coffee shop',
          latitude: 37.7749,
          longitude: -122.4194,
          category: 'Coffee',
          address: '123 Main St',
          tags: ['coffee', 'cafe'],
          userId: 'user123',
          confidence: 0.95,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Blue Bottle Coffee'), findsOneWidget);
        expect(find.text('Coffee'), findsOneWidget);
        expect(find.text('123 Main St'), findsOneWidget);
      });

      testWidgets('shows correct preview for CreateListIntent with public setting', (WidgetTester tester) async {
        // Arrange
        final intent = CreateListIntent(
          title: 'My Coffee Shops',
          description: 'Favorite coffee spots',
          category: 'Food & Drink',
          isPublic: true,
          tags: ['coffee', 'favorites'],
          userId: 'user123',
          confidence: 0.90,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('My Coffee Shops'), findsOneWidget);
        expect(find.text('Public'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles CreateSpotIntent with minimal fields', (WidgetTester tester) async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: '',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Other',
          userId: 'user123',
          confidence: 0.5,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(ActionConfirmationDialog), findsOneWidget);
        expect(find.text('Test Spot'), findsOneWidget);
      });

      testWidgets('displays confidence level when provided', (WidgetTester tester) async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => ActionConfirmationDialog(
                    intent: intent,
                    onConfirm: () {},
                    onCancel: () {},
                    showConfidence: true,
                  ),
                );
              });
              return const Scaffold(body: SizedBox());
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('75%'), findsOneWidget);
      });
    });
  });
}


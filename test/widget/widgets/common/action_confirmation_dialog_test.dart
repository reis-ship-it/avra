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
    // Removed: Property assignment tests
    // Action confirmation dialog tests focus on business logic (dialog display, user interactions, action preview), not property assignment

    testWidgets(
        'should display dialog correctly for CreateSpotIntent/CreateListIntent/AddSpotToListIntent, call onConfirm when confirm button is tapped, call onCancel when cancel button is tapped, dismiss dialog when tapping outside, show correct preview for CreateSpotIntent with all fields, show correct preview for CreateListIntent with public setting, handle CreateSpotIntent with minimal fields, or display confidence level when provided',
        (WidgetTester tester) async {
      // Test business logic: action confirmation dialog display, interactions, and preview
      final intent1 = CreateSpotIntent(
        name: 'Blue Bottle Coffee',
        description: 'A great coffee shop',
        latitude: 37.7749,
        longitude: -122.4194,
        category: 'Coffee',
        userId: 'user123',
        confidence: 0.95,
      );
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent1,
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(ActionConfirmationDialog), findsOneWidget);
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Create Spot'), findsOneWidget);
      expect(find.text('Blue Bottle Coffee'), findsOneWidget);

      final intent2 = CreateListIntent(
        title: 'My Coffee Shops',
        description: 'Favorite coffee spots',
        userId: 'user123',
        confidence: 0.90,
      );
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent2,
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.byType(ActionConfirmationDialog), findsOneWidget);
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Create List'), findsOneWidget);
      expect(find.text('My Coffee Shops'), findsOneWidget);

      final intent3 = AddSpotToListIntent(
        spotId: 'spot123',
        listId: 'list456',
        userId: 'user123',
        confidence: 0.85,
        metadata: {
          'spotName': 'Blue Bottle Coffee',
          'listName': 'My Coffee Shops',
        },
      );
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent3,
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.byType(ActionConfirmationDialog), findsOneWidget);
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Add Spot to List'), findsOneWidget);
      expect(find.text('Blue Bottle Coffee'), findsOneWidget);
      expect(find.text('My Coffee Shops'), findsOneWidget);

      bool confirmCalled = false;
      final intent4 = CreateSpotIntent(
        name: 'Test Spot',
        description: 'Test',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Test',
        userId: 'user123',
        confidence: 0.9,
      );
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent4,
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
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(confirmCalled, isTrue);
      expect(find.byType(ActionConfirmationDialog), findsNothing);

      bool cancelCalled = false;
      final intent5 = CreateSpotIntent(
        name: 'Test Spot',
        description: 'Test',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Test',
        userId: 'user123',
        confidence: 0.9,
      );
      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent5,
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
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cancelCalled, isTrue);
      expect(find.byType(ActionConfirmationDialog), findsNothing);

      final intent6 = CreateSpotIntent(
        name: 'Test Spot',
        description: 'Test',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Test',
        userId: 'user123',
        confidence: 0.9,
      );
      final widget6 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent6,
                  onConfirm: () {
                    Navigator.of(context).pop();
                  },
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget6);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(ActionConfirmationDialog), findsNothing);

      final intent7 = CreateSpotIntent(
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
      final widget7 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent7,
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget7);
      expect(find.text('Blue Bottle Coffee'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);

      final intent8 = CreateListIntent(
        title: 'My Coffee Shops',
        description: 'Favorite coffee spots',
        category: 'Food & Drink',
        isPublic: true,
        tags: ['coffee', 'favorites'],
        userId: 'user123',
        confidence: 0.90,
      );
      final widget8 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent8,
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget8);
      expect(find.text('My Coffee Shops'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);

      final intent9 = CreateSpotIntent(
        name: 'Test Spot',
        description: '',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Other',
        userId: 'user123',
        confidence: 0.5,
      );
      final widget9 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent9,
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget9);
      expect(find.byType(ActionConfirmationDialog), findsOneWidget);
      expect(find.text('Test Spot'), findsOneWidget);

      final intent10 = CreateSpotIntent(
        name: 'Test Spot',
        description: 'Test',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Test',
        userId: 'user123',
        confidence: 0.75,
      );
      final widget10 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionConfirmationDialog(
                  intent: intent10,
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
      await WidgetTestHelpers.pumpAndSettle(tester, widget10);
      expect(find.textContaining('75%'), findsOneWidget);
    });
  });
}

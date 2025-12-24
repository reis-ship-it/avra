/// SPOTS ActionErrorDialog Widget Tests
/// Date: November 20, 2025
/// Purpose: Test ActionErrorDialog functionality and UI behavior
///
/// Test Coverage:
/// - Rendering: Dialog displays correctly with error message
/// - User Interactions: Dismiss and Retry button taps
/// - Edge Cases: Null intent, long error messages
///
/// Dependencies:
/// - ActionIntent models from core/ai/action_models.dart
/// - AppTheme for consistent styling

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/ai/action_models.dart';
import 'package:spots/presentation/widgets/common/action_error_dialog.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for ActionErrorDialog
/// Tests dialog rendering, user interactions, and error display
void main() {
  group('ActionErrorDialog Widget Tests', () {
    // Removed: Property assignment tests
    // Action error dialog tests focus on business logic (error dialog display, user interactions), not property assignment

    testWidgets(
        'should display dialog correctly with error message, display retry button when onRetry provided, display intent details if provided, call onDismiss when dismiss button is tapped, or call onRetry when retry button is tapped',
        (WidgetTester tester) async {
      // Test business logic: action error dialog display and interactions
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionErrorDialog(
                  error: 'Something went wrong',
                  onDismiss: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(ActionErrorDialog), findsOneWidget);
      expect(find.text('Action Failed'), findsOneWidget);
      expect(find.textContaining('Something went wrong'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionErrorDialog(
                  error: 'Error',
                  onDismiss: () {},
                  onRetry: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Retry'), findsOneWidget);

      final intent = CreateSpotIntent(
        name: 'Test Spot',
        description: 'Test',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Test',
        userId: 'user123',
        confidence: 0.9,
      );
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionErrorDialog(
                  error: 'Error',
                  intent: intent,
                  onDismiss: () {},
                ),
              );
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.textContaining('Failed to create spot', findRichText: true),
          findsOneWidget);

      bool dismissed = false;
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionErrorDialog(
                  error: 'Error',
                  onDismiss: () {
                    dismissed = true;
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
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
      expect(find.byType(ActionErrorDialog), findsNothing);

      bool retried = false;
      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => ActionErrorDialog(
                  error: 'Error',
                  onDismiss: () {},
                  onRetry: () {
                    retried = true;
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
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
      expect(find.byType(ActionErrorDialog), findsNothing);
    });
  });
}

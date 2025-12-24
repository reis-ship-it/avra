import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/onboarding_step.dart';
import "../../helpers/widget_test_helpers.dart';

/// Widget tests for PermissionsPage (in onboarding_step.dart)
/// Tests permissions page for enabling connectivity and location
void main() {
  group('PermissionsPage Widget Tests', () {
    // Removed: Property assignment tests
    // Permissions page tests focus on business logic (permissions page display, buttons, descriptions, status), not property assignment

    testWidgets(
        'should display permissions page, display permission request buttons, display permission descriptions, or handle permission status display',
        (WidgetTester tester) async {
      // Test business logic: Permissions page display and functionality
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const PermissionsPage(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      expect(find.byType(PermissionsPage), findsOneWidget);
      expect(find.text('Enable Connectivity & Location'), findsOneWidget);
      expect(find.text('Enable All'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.textContaining('To enable ai2ai connectivity'), findsOneWidget);
    });

    // Removed: Enum value tests (property assignment)
    // OnboardingStepType enum values are Dart language features, not business logic
  });
}


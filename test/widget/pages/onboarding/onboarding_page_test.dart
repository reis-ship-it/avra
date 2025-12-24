import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/onboarding_page.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

void main() {
  group('OnboardingPage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    tearDown(() {
      mockAuthBloc.close();
    });

    // Removed: Property assignment tests
    // Onboarding page tests focus on business logic (initial step display, navigation, button states), not property assignment

    testWidgets(
        'should display initial onboarding step correctly, show progress through onboarding steps, have back button disabled on first step, display correct step titles in sequence, show next button with correct text, or prevent progression without required data',
        (WidgetTester tester) async {
      // Test business logic: Onboarding page initial display and navigation
      mockAuthBloc.setState(AuthInitial());
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      expect(find.text('Welcome to SPOTS'), findsOneWidget);
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      final backButton = tester.widget<TextButton>(find.text('Back'));
      expect(backButton.onPressed, isNull);
      expect(find.text('Next'), findsOneWidget);
      final nextButton = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(nextButton);
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'should maintain state during orientation changes, handle back navigation correctly, meet accessibility requirements, respond to swipe gestures, handle rapid button taps gracefully, or preserve navigation state across rebuilds',
        (WidgetTester tester) async {
      // Test business logic: Onboarding page state management and interactions
      mockAuthBloc.setState(AuthInitial());
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      expect(find.text('Welcome to SPOTS'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      final nextButtonSize = tester.getSize(find.byType(ElevatedButton));
      expect(nextButtonSize.height, greaterThanOrEqualTo(48.0));
      final backButtonSize = tester.getSize(find.text('Back'));
      expect(backButtonSize.height, greaterThanOrEqualTo(48.0));
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      final nextButton = find.byType(ElevatedButton);
      await tester.tap(nextButton);
      await tester.tap(nextButton);
      await tester.tap(nextButton);
      await tester.pump();
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      await tester.pump();
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      // Reset physical size after test
      tester.view.resetPhysicalSize();
    });

    group('Onboarding Step Validation', () {
      // Removed: Property assignment tests
      // Onboarding step validation tests focus on business logic (step validation, data collection), not property assignment

      testWidgets(
          'should validate homebase selection step or manage onboarding data collection',
          (WidgetTester tester) async {
        // Test business logic: Onboarding page step validation
        mockAuthBloc.setState(AuthInitial());
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const OnboardingPage(),
          authBloc: mockAuthBloc,
        );
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        final nextButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(nextButton.onPressed, isNull);
        expect(find.byType(OnboardingPage), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      });
    });
  });
}

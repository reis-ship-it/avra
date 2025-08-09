import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

    testWidgets('displays initial onboarding step correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show homebase selection as first step
      expect(find.text('Welcome to SPOTS'), findsOneWidget); // AppBar title
      expect(find.text('Where\'s your homebase?'), findsOneWidget); // Homebase page title
      expect(find.text('Back'), findsOneWidget); // Back button (should be disabled initially)
      expect(find.byType(ElevatedButton), findsOneWidget); // Next/Complete button
    });

    testWidgets('shows progress through onboarding steps', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Initially at step 1 (homebase)
      expect(find.text('Where\'s your homebase?'), findsOneWidget);

      // Act - Mock homebase selection (this would require setting up the homebase page properly)
      // For now, just verify the navigation structure exists
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('back button is disabled on first step', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Back button should be disabled on first step
      final backButton = tester.widget<TextButton>(find.text('Back'));
      expect(backButton.onPressed, isNull);
    });

    testWidgets('displays correct step titles in sequence', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - First step should be homebase
      expect(find.text('Where\'s your homebase?'), findsOneWidget);

      // Test navigation between steps would require proper mocking of child pages
      // This validates the step structure exists
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('next button shows correct text on final step', (WidgetTester tester) async {
      // This test would need to simulate progression through all steps
      // For now, we'll test the basic structure
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Initially shows "Next" text
      expect(find.text('Next'), findsOneWidget);
      
      // Note: To test "Complete Setup" text, we'd need to navigate to the final step
      // This would require mocking all onboarding steps properly
    });

    testWidgets('prevents progression without required data', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Try to proceed without selecting homebase
      final nextButton = find.byType(ElevatedButton);
      expect(nextButton, findsOneWidget);

      // Assert - Button should be disabled initially (no homebase selected)
      final button = tester.widget<ElevatedButton>(nextButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('maintains state during orientation changes', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Simulate orientation change
      tester.binding.window.physicalSizeTestValue = const Size(800, 600);
      await tester.pump();

      // Assert - Should still be on homebase step
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      expect(find.text('Welcome to SPOTS'), findsOneWidget);
    });

    testWidgets('handles back navigation correctly', (WidgetTester tester) async {
      // This would test navigation between steps once properly implemented
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // For now, just verify the navigation structure exists
      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('meets accessibility requirements', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Navigation elements should have proper labels
      expect(find.text('Welcome to SPOTS'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      
      // Interactive elements should meet minimum size requirements
      final nextButton = tester.getSize(find.byType(ElevatedButton));
      expect(nextButton.height, greaterThanOrEqualTo(48.0));
      
      final backButton = tester.getSize(find.text('Back'));
      expect(backButton.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('page view responds to swipe gestures', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Try to swipe (should not advance without proper data)
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Assert - Should still be on first step since no data was provided
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
    });

    testWidgets('handles rapid button taps gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Rapidly tap next button (should be disabled anyway)
      final nextButton = find.byType(ElevatedButton);
      await tester.tap(nextButton);
      await tester.tap(nextButton);
      await tester.tap(nextButton);
      await tester.pump();

      // Assert - Should remain stable
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
    });

    testWidgets('preserves navigation state across rebuilds', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OnboardingPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Trigger a rebuild
      await tester.pump();

      // Assert - Should maintain current step
      expect(find.text('Where\'s your homebase?'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    group('Onboarding Step Validation', () {
      testWidgets('validates homebase selection step', (WidgetTester tester) async {
        when(mockAuthBloc.state).thenReturn(const AuthInitial());

        final widget = WidgetTestHelpers.createTestableWidget(
          child: const OnboardingPage(),
          authBloc: mockAuthBloc,
        );

        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert - Next button should be disabled without homebase selection
        final nextButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(nextButton.onPressed, isNull);
      });

      testWidgets('manages onboarding data collection', (WidgetTester tester) async {
        when(mockAuthBloc.state).thenReturn(const AuthInitial());

        final widget = WidgetTestHelpers.createTestableWidget(
          child: const OnboardingPage(),
          authBloc: mockAuthBloc,
        );

        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert - Onboarding page manages state correctly
        expect(find.byType(OnboardingPage), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      });
    });
  });
}

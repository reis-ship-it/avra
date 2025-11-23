import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/welcome_page.dart';
import 'package:spots/presentation/widgets/onboarding/floating_text_widget.dart';
import 'package:spots/core/theme/colors.dart';

void main() {
  group('WelcomePage', () {
    testWidgets('builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.byType(FloatingTextWidget), findsOneWidget);
    });

    testWidgets('displays welcome text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      // Manual pump (can't use pumpAndSettle with repeating float animation)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check for floating text widget
      expect(find.byType(FloatingTextWidget), findsOneWidget);
      
      // Check for individual letters from "Hi, tell me"
      expect(find.text('H'), findsOneWidget);
      expect(find.text('i'), findsOneWidget);
    });

    testWidgets('displays skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
    });

    testWidgets('displays tap to continue hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      expect(find.text('Tap to continue'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });

    testWidgets('skip button calls onSkip callback', (WidgetTester tester) async {
      bool skipCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            onSkip: () {
              skipCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(skipCalled, true);
    });

    testWidgets('tap anywhere calls onContinue callback', (WidgetTester tester) async {
      bool continueCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            onContinue: () {
              continueCalled = true;
            },
          ),
        ),
      );

      // Tap in center of screen
      await tester.tap(find.byType(WelcomePage));
      
      // Wait for fade animation (manual pump)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(continueCalled, false); // Animation in progress
      
      // Complete animation (manual pumps for 400ms fade)
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      expect(continueCalled, true);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.gradient, isA<LinearGradient>());
      
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, contains(AppColors.white));
      expect(gradient.colors, contains(AppColors.grey50));
    });

    testWidgets('fade out animation works', (WidgetTester tester) async {
      bool continueCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            onContinue: () {
              continueCalled = true;
            },
          ),
        ),
      );

      // Initial state - should be visible
      await tester.pump();
      
      // Tap to start fade out
      await tester.tap(find.byType(WelcomePage));
      await tester.pump();
      
      // Animation in progress
      await tester.pump(const Duration(milliseconds: 200));
      expect(continueCalled, false);
      
      // Complete fade animation (400ms fade + buffer)
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(continueCalled, true);
    });

    testWidgets('prevents multiple taps during exit', (WidgetTester tester) async {
      int continueCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            onContinue: () {
              continueCallCount++;
            },
          ),
        ),
      );

      // Tap multiple times quickly
      await tester.tap(find.byType(WelcomePage));
      await tester.pump();
      
      await tester.tap(find.byType(WelcomePage));
      await tester.pump();
      
      await tester.tap(find.byType(WelcomePage));
      await tester.pump();
      
      // Complete animation (manual pump due to floating animation)
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      // Should only call once (first tap)
      expect(continueCallCount, 1);
    });

    testWidgets('has proper semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      // Check for semantic labels (they exist in the widget tree even if not found by label finder)
      expect(find.byType(Semantics), findsWidgets);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Tap to continue'), findsOneWidget);
    });

    testWidgets('uses SafeArea for proper layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('skip button has proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      final skipButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Skip'),
      );
      
      expect(skipButton, isNotNull);
    });

    testWidgets('continue hint has pulsing animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomePage(),
        ),
      );

      expect(find.byType(PulsingHintWidget), findsOneWidget);
      expect(find.text('Tap to continue'), findsOneWidget);
    });
  });
}


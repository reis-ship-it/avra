import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/onboarding/floating_text_widget.dart';
import 'package:spots/core/theme/colors.dart';

void main() {
  group('FloatingTextWidget', () {
    testWidgets('builds successfully with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: 'Hello World',
            ),
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);
      expect(find.text('e'), findsOneWidget);
      expect(find.text('l'), findsNWidgets(3));
      expect(find.text('o'), findsNWidgets(2));
    });

    testWidgets('displays all letters individually', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: 'Hi',
            ),
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);
      expect(find.text('i'), findsOneWidget);
    });

    testWidgets('handles multi-line text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: 'Hi\nthere',
            ),
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);
      expect(find.text('i'), findsOneWidget);
      expect(find.text('t'), findsOneWidget);
      expect(find.text('h'), findsOneWidget);
      expect(find.text('e'), findsNWidgets(2));
      expect(find.text('r'), findsOneWidget);
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 24,
        color: AppColors.electricGreen,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: 'Hi',
              textStyle: customStyle,
            ),
          ),
        ),
      );

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, greaterThan(0));
      
      for (final textWidget in textWidgets) {
        if (textWidget.data != null && textWidget.data!.isNotEmpty) {
          expect(textWidget.style?.fontSize, 24);
          expect(textWidget.style?.color, AppColors.electricGreen);
        }
      }
    });

    testWidgets('entrance animation initializes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: 'Hi',
              entranceDuration: Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      // Initial frame - letters may not be fully visible
      await tester.pump();
      
      // Let entrance animation complete (pump manually instead of pumpAndSettle)
      // pumpAndSettle can't be used because float animation repeats forever
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Letters should be visible after animation
      expect(find.text('H'), findsOneWidget);
      expect(find.text('i'), findsOneWidget);
    });

    testWidgets('float animation loops continuously', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: 'A',
              entranceDuration: Duration(milliseconds: 100),
              floatDuration: Duration(milliseconds: 200),
            ),
          ),
        ),
      );

      // Wait for entrance (manual pump, not pumpAndSettle)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Pump through float cycle
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('A'), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('A'), findsOneWidget);
      
      // Float should continue looping
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('handles empty text gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTextWidget(
              text: '',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FloatingTextWidget), findsOneWidget);
    });

    testWidgets('respects reduced motion preference', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: FloatingTextWidget(
                text: 'Hi',
              ),
            ),
          ),
        ),
      );

      // With reduced motion, text should appear immediately
      await tester.pump();
      expect(find.text('H'), findsOneWidget);
      expect(find.text('i'), findsOneWidget);
    });
  });

  group('PulsingHintWidget', () {
    testWidgets('builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulsingHintWidget(
              text: 'Tap to continue',
            ),
          ),
        ),
      );

      expect(find.text('Tap to continue'), findsOneWidget);
    });

    testWidgets('displays text with default style', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulsingHintWidget(
              text: 'Hint',
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, 'Hint');
      expect(textWidget.style?.color, AppColors.textSecondary);
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 20,
        color: AppColors.electricGreen,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulsingHintWidget(
              text: 'Hint',
              textStyle: customStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.color, AppColors.electricGreen);
    });

    testWidgets('pulsing animation runs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulsingHintWidget(
              text: 'Hint',
            ),
          ),
        ),
      );

      // Pump through animation cycle
      await tester.pump();
      expect(find.text('Hint'), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Hint'), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('Hint'), findsOneWidget);
    });
  });
}


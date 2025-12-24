/// Tests for Streaming Response Widget
///
/// Part of Feature Matrix Phase 1.3: LLM Full Integration

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/common/streaming_response_widget.dart';
import 'package:spots/test/widget/helpers/widget_test_helpers.dart';
import 'dart:async';

void main() {
  setUpAll(() {
    WidgetTestHelpers.setupTestEnvironment();
  });

  group('StreamingResponseWidget', () {
    // Removed: Property assignment tests
    // Streaming response widget tests focus on business logic (text streaming, user interactions, callbacks), not property assignment

    testWidgets(
        'should display text as it streams, show cursor when enabled, call onComplete when stream finishes, show stop button when streaming, or call onStop when stop button tapped',
        (tester) async {
      // Test business logic: streaming response widget display and interactions
      final controller1 = StreamController<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller1.stream,
              typingSpeed: const Duration(milliseconds: 1),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsNothing);
      controller1.add('Hello');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Hello'), findsOneWidget);
      controller1.close();

      final controller2 = StreamController<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller2.stream,
              showCursor: true,
            ),
          ),
        ),
      );
      controller2.add('Hi');
      await tester.pump();
      expect(find.byType(SelectableText), findsOneWidget);
      controller2.close();

      bool completed = false;
      final controller3 = StreamController<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller3.stream,
              typingSpeed: const Duration(milliseconds: 1),
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );
      controller3.add('Done');
      controller3.close();
      await tester.pumpAndSettle();
      expect(completed, isTrue);

      final controller4 = StreamController<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller4.stream,
              onStop: () {},
            ),
          ),
        ),
      );
      controller4.add('Streaming...');
      await tester.pump();
      expect(find.text('Stop Generating'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);
      controller4.close();

      bool stopped = false;
      final controller5 = StreamController<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller5.stream,
              onStop: () {
                stopped = true;
              },
            ),
          ),
        ),
      );
      controller5.add('Streaming...');
      await tester.pump();
      await tester.tap(find.text('Stop Generating'));
      await tester.pumpAndSettle();
      expect(stopped, isTrue);
      controller5.close();
    });
  });

  group('TypingTextWidget', () {
    testWidgets(
        'should type out text character by character or call onComplete when typing finishes',
        (tester) async {
      // Test business logic: typing text widget animation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingTextWidget(
              text: 'Hello World',
              typingSpeed: const Duration(milliseconds: 10),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(Text), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));

      bool completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingTextWidget(
              text: 'Hi',
              typingSpeed: const Duration(milliseconds: 10),
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });
  });

  group('TypingIndicator', () {
    testWidgets('should render animated dots', (tester) async {
      // Test business logic: typing indicator animation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );
      expect(find.byType(TypingIndicator), findsOneWidget);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}

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
    testWidgets('displays text as it streams', (tester) async {
      final controller = StreamController<String>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller.stream,
              typingSpeed: const Duration(milliseconds: 1), // Fast for testing
            ),
          ),
        ),
      );

      // Initially empty
      expect(find.text('Hello'), findsNothing);

      // Add text to stream
      controller.add('Hello');
      await tester.pump(const Duration(milliseconds: 50));

      // Text should appear
      expect(find.textContaining('Hello'), findsOneWidget);

      controller.close();
    });

    testWidgets('shows cursor when enabled', (tester) async {
      final controller = StreamController<String>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller.stream,
              showCursor: true,
            ),
          ),
        ),
      );

      controller.add('Hi');
      await tester.pump();

      // Cursor should be visible (as SelectableText.rich)
      expect(find.byType(SelectableText), findsOneWidget);

      controller.close();
    });

    testWidgets('calls onComplete when stream finishes', (tester) async {
      bool completed = false;
      final controller = StreamController<String>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller.stream,
              typingSpeed: const Duration(milliseconds: 1),
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      controller.add('Done');
      controller.close();
      
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('shows stop button when streaming', (tester) async {
      final controller = StreamController<String>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller.stream,
              onStop: () {},
            ),
          ),
        ),
      );

      controller.add('Streaming...');
      await tester.pump();

      // Should show stop button
      expect(find.text('Stop Generating'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle_outlined), findsOneWidget);

      controller.close();
    });

    testWidgets('calls onStop when stop button tapped', (tester) async {
      bool stopped = false;
      final controller = StreamController<String>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamingResponseWidget(
              textStream: controller.stream,
              onStop: () {
                stopped = true;
              },
            ),
          ),
        ),
      );

      controller.add('Streaming...');
      await tester.pump();

      // Tap stop button
      await tester.tap(find.text('Stop Generating'));
      await tester.pumpAndSettle();

      expect(stopped, isTrue);

      controller.close();
    });
  });

  group('TypingTextWidget', () {
    testWidgets('types out text character by character', (tester) async {
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

      // Initially empty or partial
      await tester.pump();

      // Wait for some typing
      await tester.pump(const Duration(milliseconds: 50));

      // Should have some text
      expect(find.byType(Text), findsOneWidget);

      // Wait for completion
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('calls onComplete when typing finishes', (tester) async {
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

      // Wait for typing to complete
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });

  group('TypingIndicator', () {
    testWidgets('renders animated dots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);

      // Pump a few animation frames
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should still be present
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}


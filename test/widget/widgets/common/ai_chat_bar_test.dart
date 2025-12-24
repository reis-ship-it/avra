import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/common/ai_chat_bar.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for AIChatBar
/// Tests AI chat input bar functionality
void main() {
  group('AIChatBar Widget Tests', () {
    // Removed: Property assignment tests
    // AI chat bar tests focus on business logic (chat bar display, user interactions, state management), not property assignment

    testWidgets(
        'should display chat bar with default hint text, display custom hint text, display initial value, call onSendMessage when send button is tapped or enter is pressed, disable/enable send button based on text input, show loading indicator when isLoading is true, disable input when enabled is false, call onTap when text field is tapped, or clear text after sending message',
        (WidgetTester tester) async {
      // Test business logic: AI chat bar display and interactions
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(AIChatBar), findsOneWidget);
      expect(
          find.text('Ask AI about spots, recommendations...'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(hintText: 'Custom hint text'),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Custom hint text'), findsOneWidget);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(initialValue: 'Initial message'),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('Initial message'), findsOneWidget);

      String? sentMessage1;
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: AIChatBar(
          onSendMessage: (message) {
            sentMessage1 = message;
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(sentMessage1, equals('Test message'));

      String? sentMessage2;
      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: AIChatBar(
          onSendMessage: (message) {
            sentMessage2 = message;
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(sentMessage2, equals('Test message'));

      final widget6 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget6);
      final sendButton1 = tester.widget<IconButton>(find.byIcon(Icons.send));
      expect(sendButton1.onPressed, isNull);

      final widget7 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget7);
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();
      final sendButton2 = tester.widget<IconButton>(find.byIcon(Icons.send));
      expect(sendButton2.onPressed, isNotNull);

      final widget8 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(isLoading: true),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget8);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);

      final widget9 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(enabled: false),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget9);
      final textField1 = tester.widget<TextField>(find.byType(TextField));
      expect(textField1.enabled, isFalse);

      bool tapped = false;
      final widget10 = WidgetTestHelpers.createTestableWidget(
        child: AIChatBar(
          onTap: () {
            tapped = true;
          },
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget10);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      final widget11 = WidgetTestHelpers.createTestableWidget(
        child: const AIChatBar(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget11);
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      final textField2 = tester.widget<TextField>(find.byType(TextField));
      expect(textField2.controller?.text, isEmpty);
    });
  });
}

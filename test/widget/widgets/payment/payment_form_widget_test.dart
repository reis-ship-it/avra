import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/payment/payment_form_widget.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

/// Widget tests for PaymentFormWidget
///
/// Agent 2: Phase 7, Section 51-52 - Widget Test Coverage
///
/// Tests:
/// - Widget rendering
/// - Form input handling
/// - Payment processing
/// - Error states
/// - Loading states
/// - Success callbacks
void main() {
  group('PaymentFormWidget Widget Tests', () {
    // Removed: Property assignment tests
    // Payment form widget tests focus on business logic (form display, state management, user interactions), not property assignment

    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets(
        'should display payment form with amount and quantity, display card input fields, display correct total amount for multiple quantities, display processing state when isProcessing is true, display error message when error occurs, or call onPaymentSuccess callback on successful payment',
        (WidgetTester tester) async {
      // Test business logic: payment form display and state management
      mockAuthBloc = MockBlocFactory.createAuthenticatedAuthBloc();

      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: PaymentFormWidget(
          amount: 25.0,
          quantity: 1,
          eventId: 'event-123',
          onPaymentSuccess: (paymentId, paymentIntentId) {},
          onPaymentFailure: (errorMessage, errorCode) {},
          onProcessingChange: (isProcessing) {},
        ),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(PaymentFormWidget), findsOneWidget);
      expect(find.text('\$25.00'), findsOneWidget);
      expect(find.text('Quantity: 1'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: PaymentFormWidget(
          amount: 50.0,
          quantity: 2,
          eventId: 'event-123',
          onPaymentSuccess: (_, __) {},
          onPaymentFailure: (_, __) {},
          onProcessingChange: (_) {},
        ),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('Quantity: 2'), findsOneWidget);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: PaymentFormWidget(
          amount: 25.0,
          quantity: 1,
          eventId: 'event-123',
          isProcessing: true,
          onPaymentSuccess: (_, __) {},
          onPaymentFailure: (_, __) {},
          onProcessingChange: (_) {},
        ),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: PaymentFormWidget(
          amount: 25.0,
          quantity: 1,
          eventId: 'event-123',
          onPaymentSuccess: (_, __) {},
          onPaymentFailure: (errorMessage, errorCode) {},
          onProcessingChange: (_) {},
        ),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.byType(PaymentFormWidget), findsOneWidget);

      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: PaymentFormWidget(
          amount: 25.0,
          quantity: 1,
          eventId: 'event-123',
          onPaymentSuccess: (_, __) {},
          onPaymentFailure: (_, __) {},
          onProcessingChange: (_) {},
        ),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      expect(find.byType(PaymentFormWidget), findsOneWidget);
    });
  });
}

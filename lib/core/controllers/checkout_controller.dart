import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';

import 'package:spots/core/controllers/base/workflow_controller.dart';
import 'package:spots/core/controllers/base/controller_result.dart';
import 'package:spots/core/controllers/payment_processing_controller.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/payment.dart';
import 'package:spots/core/services/sales_tax_service.dart';
import 'package:spots/core/services/legal_document_service.dart';
import 'package:spots/core/services/expertise_event_service.dart';

/// Checkout Controller
/// 
/// Orchestrates the complete checkout workflow for event ticket purchases.
/// Coordinates validation, tax calculation, waiver checking, payment processing,
/// and receipt generation.
/// 
/// **Responsibilities:**
/// - Validate checkout data (quantity, event availability)
/// - Check waiver acceptance status
/// - Calculate totals (subtotal + tax)
/// - Delegate payment processing to PaymentProcessingController
/// - Generate receipt (when ReceiptService available)
/// - Send confirmation (when NotificationService available)
/// - Return unified checkout result
/// 
/// **Dependencies:**
/// - `PaymentProcessingController` - Handles payment processing
/// - `SalesTaxService` - Calculates sales tax
/// - `LegalDocumentService` - Checks waiver acceptance
/// - `ExpertiseEventService` - Validates event availability
/// 
/// **Usage:**
/// ```dart
/// final controller = CheckoutController();
/// final result = await controller.processCheckout(
///   event: event,
///   buyer: user,
///   quantity: 2,
///   requireWaiver: true,
/// );
/// 
/// if (result.isSuccess) {
///   // Checkout successful
///   final payment = result.payment!;
///   final totalAmount = result.totalAmount;
/// } else {
///   // Handle errors
/// }
/// ```
class CheckoutController
    implements WorkflowController<CheckoutInput, CheckoutResult> {
  static const String _logName = 'CheckoutController';

  final PaymentProcessingController _paymentController;
  final SalesTaxService _salesTaxService;
  final LegalDocumentService _legalService;
  final ExpertiseEventService _eventService;

  CheckoutController({
    PaymentProcessingController? paymentController,
    SalesTaxService? salesTaxService,
    LegalDocumentService? legalService,
    ExpertiseEventService? eventService,
  })  : _paymentController =
            paymentController ?? GetIt.instance<PaymentProcessingController>(),
        _salesTaxService =
            salesTaxService ?? GetIt.instance<SalesTaxService>(),
        _legalService =
            legalService ??
            LegalDocumentService(
              eventService: GetIt.instance<ExpertiseEventService>(),
            ),
        _eventService =
            eventService ?? GetIt.instance<ExpertiseEventService>();

  /// Process checkout
  /// 
  /// Orchestrates the complete checkout workflow:
  /// 1. Validate input
  /// 2. Validate event availability
  /// 3. Check waiver acceptance (if required)
  /// 4. Calculate totals (subtotal + tax)
  /// 5. Process payment via PaymentProcessingController
  /// 6. Generate receipt (when ReceiptService available)
  /// 7. Send confirmation (when NotificationService available)
  /// 8. Return unified result
  /// 
  /// **Parameters:**
  /// - `event`: Event to purchase tickets for
  /// - `buyer`: User purchasing tickets
  /// - `quantity`: Number of tickets to purchase
  /// - `requireWaiver`: Whether waiver acceptance is required (default: true)
  /// 
  /// **Returns:**
  /// `CheckoutResult` with success/failure and checkout details
  Future<CheckoutResult> processCheckout({
    required ExpertiseEvent event,
    required UnifiedUser buyer,
    required int quantity,
    bool requireWaiver = true,
  }) async {
    try {
      developer.log(
        'Processing checkout: eventId=${event.id}, buyerId=${buyer.id}, quantity=$quantity',
        name: _logName,
      );

      // Step 1: Validate input
      final input = CheckoutInput(
        event: event,
        buyer: buyer,
        quantity: quantity,
        requireWaiver: requireWaiver,
      );

      final validationResult = validate(input);
      if (!validationResult.isValid) {
        return CheckoutResult.failure(
          error: validationResult.allErrors.join(', '),
          errorCode: 'VALIDATION_ERROR',
        );
      }

      // Step 2: Validate event availability
      final updatedEvent = await _eventService.getEventById(event.id);
      if (updatedEvent == null) {
        return CheckoutResult.failure(
          error: 'Event not found',
          errorCode: 'EVENT_NOT_FOUND',
        );
      }

      // Check capacity
      final availableTickets = updatedEvent.maxAttendees - updatedEvent.attendeeCount;
      if (quantity > availableTickets) {
        return CheckoutResult.failure(
          error: 'Insufficient tickets available. Only $availableTickets tickets remaining.',
          errorCode: 'INSUFFICIENT_CAPACITY',
        );
      }

      // Check event status
      if (updatedEvent.hasStarted) {
        return CheckoutResult.failure(
          error: 'Event has already started',
          errorCode: 'EVENT_STARTED',
        );
      }

      // Step 3: Check waiver acceptance (if required)
      if (requireWaiver) {
        final hasAcceptedWaiver = await _legalService.hasAcceptedEventWaiver(
          buyer.id,
          event.id,
        );
        if (!hasAcceptedWaiver) {
          return CheckoutResult.failure(
            error: 'Event waiver must be accepted before checkout',
            errorCode: 'WAIVER_NOT_ACCEPTED',
          );
        }
      }

      // Step 4: Calculate totals (subtotal + tax)
      double subtotal = 0.0;
      double taxAmount = 0.0;
      double totalAmount = 0.0;

      if (updatedEvent.isPaid && updatedEvent.price != null) {
        subtotal = updatedEvent.price! * quantity;

        // Calculate sales tax
        try {
          final taxCalculation = await _salesTaxService.calculateSalesTax(
            eventId: event.id,
            ticketPrice: updatedEvent.price!,
          );
          taxAmount = taxCalculation.taxAmount * quantity;
          totalAmount = subtotal + taxAmount;
        } catch (e) {
          developer.log(
            'Error calculating sales tax: $e',
            name: _logName,
            error: e,
          );
          // Proceed without tax if calculation fails
          totalAmount = subtotal;
        }
      } else {
        // Free event
        totalAmount = 0.0;
      }

      // Step 5: Process payment via PaymentProcessingController
      final paymentResult = await _paymentController.processEventPayment(
        event: updatedEvent,
        buyer: buyer,
        quantity: quantity,
      );

      if (!paymentResult.isSuccess) {
        return CheckoutResult.failure(
          error: paymentResult.error ?? 'Payment processing failed',
          errorCode: paymentResult.errorCode ?? 'PAYMENT_FAILED',
        );
      }

      // Step 6: Generate receipt (when ReceiptService available)
      // TODO(Phase 8.12): Implement receipt generation when ReceiptService is available
      // For now, receipt generation is handled by UI (PaymentSuccessPage)

      // Step 7: Send confirmation (when NotificationService available)
      // TODO(Phase 8.12): Implement confirmation sending when NotificationService is available

      developer.log(
        'Checkout successful: payment=${paymentResult.payment?.id}, totalAmount=$totalAmount',
        name: _logName,
      );

      return CheckoutResult.success(
        payment: paymentResult.payment,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        quantity: quantity,
        event: paymentResult.event ?? updatedEvent,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error processing checkout: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return CheckoutResult.failure(
        error: 'Unexpected error: $e',
        errorCode: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// Calculate checkout totals
  /// 
  /// Calculates subtotal, tax, and total for a checkout without processing payment.
  /// Useful for displaying totals before checkout.
  /// 
  /// **Parameters:**
  /// - `event`: Event to calculate totals for
  /// - `quantity`: Number of tickets
  /// 
  /// **Returns:**
  /// `CheckoutTotals` with subtotal, tax, and total
  Future<CheckoutTotals> calculateTotals({
    required ExpertiseEvent event,
    required int quantity,
  }) async {
    try {
      double subtotal = 0.0;
      double taxAmount = 0.0;
      double totalAmount = 0.0;

      if (event.isPaid && event.price != null) {
        subtotal = event.price! * quantity;

        // Calculate sales tax
        try {
          final taxCalculation = await _salesTaxService.calculateSalesTax(
            eventId: event.id,
            ticketPrice: event.price!,
          );
          taxAmount = taxCalculation.taxAmount * quantity;
          totalAmount = subtotal + taxAmount;
        } catch (e) {
          developer.log(
            'Error calculating sales tax: $e',
            name: _logName,
            error: e,
          );
          // Proceed without tax if calculation fails
          totalAmount = subtotal;
        }
      }

      return CheckoutTotals(
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        quantity: quantity,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error calculating totals: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<CheckoutResult> execute(CheckoutInput input) async {
    return processCheckout(
      event: input.event,
      buyer: input.buyer,
      quantity: input.quantity,
      requireWaiver: input.requireWaiver,
    );
  }

  @override
  ValidationResult validate(CheckoutInput input) {
    final errors = <String, String>{};
    final generalErrors = <String>[];

    // Validate quantity
    if (input.quantity <= 0) {
      errors['quantity'] = 'Quantity must be greater than 0';
    }

    if (input.quantity > 100) {
      errors['quantity'] = 'Quantity cannot exceed 100 tickets per purchase';
    }

    // Validate event
    if (input.event.id.trim().isEmpty) {
      errors['event'] = 'Event ID is required';
    }

    // Validate buyer
    if (input.buyer.id.trim().isEmpty) {
      errors['buyer'] = 'Buyer ID is required';
    }

    if (errors.isNotEmpty || generalErrors.isNotEmpty) {
      return ValidationResult.invalid(
        fieldErrors: errors,
        generalErrors: generalErrors,
      );
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> rollback(CheckoutResult result) async {
    // Rollback checkout (cancel payment if applicable)
    if (result.success && result.payment != null) {
      try {
        // Payment rollback would be handled by PaymentProcessingController
        // For now, just log the rollback
        developer.log(
          'Rolled back checkout: paymentId=${result.payment!.id}',
          name: _logName,
        );
      } catch (e) {
        developer.log(
          'Error rolling back checkout: $e',
          name: _logName,
          error: e,
        );
        // Don't rethrow - rollback failures should be logged but not block
      }
    }
  }
}

/// Checkout Input
/// 
/// Input data for checkout
class CheckoutInput {
  final ExpertiseEvent event;
  final UnifiedUser buyer;
  final int quantity;
  final bool requireWaiver;

  CheckoutInput({
    required this.event,
    required this.buyer,
    required this.quantity,
    this.requireWaiver = true,
  });
}

/// Checkout Totals
/// 
/// Calculated totals for checkout (before payment processing)
class CheckoutTotals {
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final int quantity;

  CheckoutTotals({
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.quantity,
  });
}

/// Checkout Result
/// 
/// Unified result for checkout operations
class CheckoutResult extends ControllerResult {
  final Payment? payment;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final int quantity;
  final ExpertiseEvent? event;

  const CheckoutResult._({
    required super.success,
    required super.error,
    required super.errorCode,
    this.payment,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.quantity = 0,
    this.event,
  });

  factory CheckoutResult.success({
    required Payment? payment,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    required int quantity,
    required ExpertiseEvent event,
  }) {
    return CheckoutResult._(
      success: true,
      error: null,
      errorCode: null,
      payment: payment,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      quantity: quantity,
      event: event,
    );
  }

  factory CheckoutResult.failure({
    required String error,
    required String errorCode,
  }) {
    return CheckoutResult._(
      success: false,
      error: error,
      errorCode: errorCode,
    );
  }
}


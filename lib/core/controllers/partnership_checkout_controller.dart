import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';

import 'package:avrai/core/controllers/base/workflow_controller.dart';
import 'package:avrai/core/controllers/base/controller_result.dart';
import 'package:avrai/core/controllers/payment_processing_controller.dart';
import 'package:avrai/core/models/expertise_event.dart';
import 'package:avrai/core/models/event_partnership.dart';
import 'package:avrai/core/models/unified_user.dart';
import 'package:avrai/core/models/payment.dart';
import 'package:avrai/core/models/revenue_split.dart';
import 'package:avrai/core/services/revenue_split_service.dart';
import 'package:avrai/core/services/partnership_service.dart';
import 'package:avrai/core/services/expertise_event_service.dart';
import 'package:avrai/core/services/sales_tax_service.dart';

/// Partnership Checkout Controller
/// 
/// Orchestrates the complete checkout workflow for partnership event ticket purchases.
/// Coordinates validation, partnership verification, revenue split calculation, tax calculation,
/// payment processing, and receipt generation for partnership events.
/// 
/// **Responsibilities:**
/// - Validate partnership checkout data (quantity, availability, partnership status)
/// - Verify partnership exists and is active
/// - Calculate revenue split for partnership events (N-way split)
/// - Calculate totals (subtotal + tax)
/// - Process payment with multi-party revenue split
/// - Update event attendance
/// - Return unified checkout result
/// 
/// **Dependencies:**
/// - `PaymentProcessingController` - Handles payment processing
/// - `RevenueSplitService` - Calculates partnership revenue splits
/// - `PartnershipService` - Validates partnership status
/// - `ExpertiseEventService` - Validates event availability
/// - `SalesTaxService` - Calculates sales tax
/// 
/// **Usage:**
/// ```dart
/// final controller = PartnershipCheckoutController();
/// final result = await controller.processCheckout(
///   event: event,
///   buyer: user,
///   quantity: 2,
///   partnership: partnership,
/// );
/// 
/// if (result.isSuccess) {
///   // Checkout successful
///   final payment = result.payment!;
///   final revenueSplit = result.revenueSplit!;
/// } else {
///   // Handle errors
/// }
/// ```
class PartnershipCheckoutController
    implements WorkflowController<PartnershipCheckoutInput, PartnershipCheckoutResult> {
  static const String _logName = 'PartnershipCheckoutController';

  // Payment processing is only needed when checkout is submitted.
  // Keep optional so UI/tests can render without full payment DI wiring.
  final PaymentProcessingController? _paymentController;
  final RevenueSplitService _revenueSplitService;
  final PartnershipService _partnershipService;
  final ExpertiseEventService _eventService;
  final SalesTaxService _salesTaxService;

  PartnershipCheckoutController({
    PaymentProcessingController? paymentController,
    RevenueSplitService? revenueSplitService,
    PartnershipService? partnershipService,
    ExpertiseEventService? eventService,
    SalesTaxService? salesTaxService,
  })  : _paymentController = paymentController,
        _revenueSplitService =
            revenueSplitService ?? GetIt.instance<RevenueSplitService>(),
        _partnershipService =
            partnershipService ?? GetIt.instance<PartnershipService>(),
        _eventService =
            eventService ?? GetIt.instance<ExpertiseEventService>(),
        _salesTaxService =
            salesTaxService ?? GetIt.instance<SalesTaxService>();

  PaymentProcessingController _resolvePaymentController() {
    return _paymentController ?? GetIt.instance<PaymentProcessingController>();
  }

  /// Process partnership checkout
  /// 
  /// Orchestrates the complete partnership checkout workflow:
  /// 1. Validate input
  /// 2. Validate event availability
  /// 3. Validate partnership exists and is active
  /// 4. Calculate revenue split for partnership (N-way split)
  /// 5. Calculate totals (subtotal + tax)
  /// 6. Process payment via PaymentProcessingController (which handles partnership revenue splits)
  /// 7. Return unified result with revenue split details
  /// 
  /// **Parameters:**
  /// - `event`: Event to purchase tickets for
  /// - `buyer`: User purchasing tickets
  /// - `quantity`: Number of tickets to purchase
  /// - `partnership`: Partnership for the event (optional - will be looked up if not provided)
  /// 
  /// **Returns:**
  /// `PartnershipCheckoutResult` with success/failure and checkout details including revenue split
  Future<PartnershipCheckoutResult> processCheckout({
    required ExpertiseEvent event,
    required UnifiedUser buyer,
    required int quantity,
    EventPartnership? partnership,
  }) async {
    try {
      developer.log(
        'Processing partnership checkout: eventId=${event.id}, buyerId=${buyer.id}, quantity=$quantity, partnership=${partnership?.id}',
        name: _logName,
      );

      // Step 1: Validate input
      final input = PartnershipCheckoutInput(
        event: event,
        buyer: buyer,
        quantity: quantity,
        partnership: partnership,
      );

      final validationResult = validate(input);
      if (!validationResult.isValid) {
        return PartnershipCheckoutResult.failure(
          error: validationResult.allErrors.join(', '),
          errorCode: 'VALIDATION_ERROR',
        );
      }

      // Step 2: Validate event availability
      final updatedEvent = await _eventService.getEventById(event.id);
      if (updatedEvent == null) {
        return PartnershipCheckoutResult.failure(
          error: 'Event not found',
          errorCode: 'EVENT_NOT_FOUND',
        );
      }

      // Check capacity
      final availableTickets = updatedEvent.maxAttendees - updatedEvent.attendeeCount;
      if (quantity > availableTickets) {
        return PartnershipCheckoutResult.failure(
          error: 'Insufficient tickets available. Only $availableTickets tickets remaining.',
          errorCode: 'INSUFFICIENT_CAPACITY',
        );
      }

      // Check event status
      if (updatedEvent.hasStarted) {
        return PartnershipCheckoutResult.failure(
          error: 'Event has already started',
          errorCode: 'EVENT_STARTED',
        );
      }

      // Step 3: Validate partnership exists and is active
      EventPartnership? verifiedPartnership = partnership;
      if (verifiedPartnership == null) {
        // Look up partnership for event
        final partnerships = await _partnershipService.getPartnershipsForEvent(event.id);
        if (partnerships.isEmpty) {
          return PartnershipCheckoutResult.failure(
            error: 'No partnership found for this event',
            errorCode: 'PARTNERSHIP_NOT_FOUND',
          );
        }
        verifiedPartnership = partnerships.first;
      }

      // Verify partnership is active (approved or locked)
      if (!verifiedPartnership.isActive &&
          verifiedPartnership.status != PartnershipStatus.approved &&
          verifiedPartnership.status != PartnershipStatus.locked) {
        return PartnershipCheckoutResult.failure(
          error: 'Partnership is not active. Status: ${verifiedPartnership.status.displayName}',
          errorCode: 'PARTNERSHIP_NOT_ACTIVE',
        );
      }

      // Step 4: Calculate revenue split for partnership (if needed)
      RevenueSplit? revenueSplit = verifiedPartnership.revenueSplit;
      if (revenueSplit == null && updatedEvent.isPaid && updatedEvent.price != null) {
        try {
          final totalAmount = updatedEvent.price! * quantity;
          revenueSplit = await _revenueSplitService.calculateFromPartnership(
            partnershipId: verifiedPartnership.id,
            totalAmount: totalAmount,
            ticketsSold: quantity,
          );
          developer.log(
            'Calculated partnership revenue split: ${revenueSplit.id}',
            name: _logName,
          );
        } catch (e) {
          developer.log(
            'Error calculating partnership revenue split: $e',
            name: _logName,
            error: e,
          );
          // Proceed without revenue split - payment controller will handle it
        }
      }

      // Step 5: Calculate totals (subtotal + tax)
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

      // Step 6: Process payment via PaymentProcessingController
      // Note: PaymentProcessingController and PaymentService handle partnership revenue splits
      // automatically when processing payments for partnership events
      final paymentResult = await _resolvePaymentController().processEventPayment(
        event: updatedEvent,
        buyer: buyer,
        quantity: quantity,
      );

      if (!paymentResult.isSuccess) {
        return PartnershipCheckoutResult.failure(
          error: paymentResult.error ?? 'Payment processing failed',
          errorCode: paymentResult.errorCode ?? 'PAYMENT_FAILED',
        );
      }

      // Step 7: Get final revenue split from payment result (if available)
      final finalRevenueSplit = paymentResult.revenueSplit ?? revenueSplit;

      developer.log(
        'Partnership checkout successful: payment=${paymentResult.payment?.id}, revenueSplit=${finalRevenueSplit?.id}',
        name: _logName,
      );

      return PartnershipCheckoutResult.success(
        payment: paymentResult.payment,
        subtotal: subtotal,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        quantity: quantity,
        event: paymentResult.event ?? updatedEvent,
        partnership: verifiedPartnership,
        revenueSplit: finalRevenueSplit,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error processing partnership checkout: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return PartnershipCheckoutResult.failure(
        error: 'Unexpected error: $e',
        errorCode: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// Calculate revenue split for partnership checkout
  /// 
  /// Calculates the N-way revenue split for a partnership event without processing payment.
  /// Useful for displaying revenue split breakdown before checkout.
  /// 
  /// **Parameters:**
  /// - `event`: Event to calculate revenue split for
  /// - `quantity`: Number of tickets
  /// - `partnership`: Partnership for the event (optional - will be looked up if not provided)
  /// 
  /// **Returns:**
  /// `RevenueSplit` with N-way distribution, or null if partnership not found
  Future<RevenueSplit?> calculateRevenueSplit({
    required ExpertiseEvent event,
    required int quantity,
    EventPartnership? partnership,
  }) async {
    try {
      // Get partnership if not provided
      EventPartnership? verifiedPartnership = partnership;
      if (verifiedPartnership == null) {
        final partnerships = await _partnershipService.getPartnershipsForEvent(event.id);
        if (partnerships.isEmpty) {
          return null;
        }
        verifiedPartnership = partnerships.first;
      }

      // Use existing revenue split if available
      if (verifiedPartnership.revenueSplit != null) {
        return verifiedPartnership.revenueSplit;
      }

      // Calculate new revenue split
      if (event.isPaid && event.price != null) {
        final totalAmount = event.price! * quantity;
        return await _revenueSplitService.calculateFromPartnership(
          partnershipId: verifiedPartnership.id,
          totalAmount: totalAmount,
          ticketsSold: quantity,
        );
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Error calculating partnership revenue split: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<PartnershipCheckoutResult> execute(PartnershipCheckoutInput input) async {
    return processCheckout(
      event: input.event,
      buyer: input.buyer,
      quantity: input.quantity,
      partnership: input.partnership,
    );
  }

  @override
  ValidationResult validate(PartnershipCheckoutInput input) {
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

    // Validate partnership (if provided)
    if (input.partnership != null) {
      if (input.partnership!.id.trim().isEmpty) {
        errors['partnership'] = 'Partnership ID is required';
      }
      if (input.partnership!.eventId != input.event.id) {
        errors['partnership'] = 'Partnership event ID does not match event ID';
      }
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
  Future<void> rollback(PartnershipCheckoutResult result) async {
    // Rollback partnership checkout (cancel payment if applicable)
    if (result.success && result.payment != null) {
      try {
        // Payment rollback would be handled by PaymentProcessingController
        // For now, just log the rollback
        developer.log(
          'Rolled back partnership checkout: paymentId=${result.payment!.id}',
          name: _logName,
        );
      } catch (e) {
        developer.log(
          'Error rolling back partnership checkout: $e',
          name: _logName,
          error: e,
        );
        // Don't rethrow - rollback failures should be logged but not block
      }
    }
  }
}

/// Partnership Checkout Input
/// 
/// Input data for partnership checkout
class PartnershipCheckoutInput {
  final ExpertiseEvent event;
  final UnifiedUser buyer;
  final int quantity;
  final EventPartnership? partnership;

  PartnershipCheckoutInput({
    required this.event,
    required this.buyer,
    required this.quantity,
    this.partnership,
  });
}

/// Partnership Checkout Result
/// 
/// Unified result for partnership checkout operations
class PartnershipCheckoutResult extends ControllerResult {
  final Payment? payment;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final int quantity;
  final ExpertiseEvent? event;
  final EventPartnership? partnership;
  final RevenueSplit? revenueSplit;

  const PartnershipCheckoutResult._({
    required super.success,
    required super.error,
    required super.errorCode,
    this.payment,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.quantity = 0,
    this.event,
    this.partnership,
    this.revenueSplit,
  });

  factory PartnershipCheckoutResult.success({
    required Payment? payment,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    required int quantity,
    required ExpertiseEvent event,
    required EventPartnership partnership,
    RevenueSplit? revenueSplit,
  }) {
    return PartnershipCheckoutResult._(
      success: true,
      error: null,
      errorCode: null,
      payment: payment,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      quantity: quantity,
      event: event,
      partnership: partnership,
      revenueSplit: revenueSplit,
    );
  }

  factory PartnershipCheckoutResult.failure({
    required String error,
    required String errorCode,
  }) {
    return PartnershipCheckoutResult._(
      success: false,
      error: error,
      errorCode: errorCode,
    );
  }
}


import 'package:spots/core/services/stripe_service.dart';
import 'package:spots/core/config/stripe_config.dart';
import 'package:spots/core/services/logger.dart';

/// Payment Service
/// 
/// High-level payment processing service for event ticket purchases.
/// Handles Stripe initialization and payment flow coordination.
/// 
/// **Usage:**
/// ```dart
/// final paymentService = PaymentService(stripeService);
/// await paymentService.initialize();
/// ```
/// 
/// **Dependencies:**
/// - Requires `StripeService` for Stripe operations
class PaymentService {
  static const String _logName = 'PaymentService';
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  
  final StripeService _stripeService;
  bool _initialized = false;
  
  PaymentService(this._stripeService);
  
  /// Initialize payment service
  /// 
  /// Initializes Stripe and prepares payment service for use.
  /// 
  /// **Throws:**
  /// - `Exception` if Stripe initialization fails
  Future<void> initialize() async {
    try {
      _logger.info('Initializing PaymentService...', tag: _logName);
      
      // Initialize Stripe
      await _stripeService.initializeStripe();
      
      _initialized = true;
      _logger.info('PaymentService initialized successfully', tag: _logName);
    } catch (e) {
      _logger.error('Failed to initialize PaymentService', error: e, tag: _logName);
      _initialized = false;
      rethrow;
    }
  }
  
  /// Check if payment service is initialized
  bool get isInitialized => _initialized && _stripeService.isInitialized;
  
  /// Get Stripe service instance
  StripeService get stripeService => _stripeService;
}


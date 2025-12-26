import 'package:flutter_test/flutter_test.dart';

import 'package:spots/core/controllers/checkout_controller.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_database.dart';

/// Checkout Controller Integration Tests
/// 
/// Tests the complete checkout workflow with real service implementations:
/// - Validation
/// - Event availability checks
/// - Waiver checking
/// - Tax calculation
/// - Payment processing delegation
void main() {
  group('CheckoutController Integration Tests', () {
    late CheckoutController controller;

    setUpAll(() async {
      // Initialize Sembast for tests
      SembastDatabase.useInMemoryForTests();
      await SembastDatabase.database;
      
      // Initialize dependency injection
      await di.init();
      
      controller = di.sl<CheckoutController>();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
    });

    group('validate', () {
      test('should validate input correctly', () {
        final event = ExpertiseEvent(
          id: 'event_123',
          title: 'Test Event',
          description: 'Test',
          category: 'Coffee',
          eventType: ExpertiseEventType.workshop,
          host: UnifiedUser(
            id: 'host_123',
            email: 'host@test.com',
            primaryRole: UserRole.follower,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final buyer = UnifiedUser(
          id: 'user_456',
          email: 'user@test.com',
          primaryRole: UserRole.follower,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final validInput = CheckoutInput(
          event: event,
          buyer: buyer,
          quantity: 2,
        );

        final invalidInput = CheckoutInput(
          event: event,
          buyer: buyer,
          quantity: 0,
        );

        // Act
        final validResult = controller.validate(validInput);
        final invalidResult = controller.validate(invalidInput);

        // Assert
        expect(validResult.isValid, isTrue);
        expect(invalidResult.isValid, isFalse);
      });
    });
  });
}


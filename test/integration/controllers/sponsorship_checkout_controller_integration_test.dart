import 'package:flutter_test/flutter_test.dart';

import 'package:spots/core/controllers/sponsorship_checkout_controller.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/sponsorship.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_database.dart';
import '../../helpers/platform_channel_helper.dart';

/// Sponsorship Checkout Controller Integration Tests
/// 
/// Tests the complete sponsorship checkout workflow with real service implementations:
/// - Validation
/// - Sponsorship creation
/// - Product tracking
void main() {
  group('SponsorshipCheckoutController Integration Tests', () {
    late SponsorshipCheckoutController controller;

    setUpAll(() async {
      // Initialize Sembast for tests
      SembastDatabase.useInMemoryForTests();
      await SembastDatabase.database;
      
      // Initialize dependency injection
      await setupTestStorage();
      await di.init();
      
      controller = di.sl<SponsorshipCheckoutController>();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
    });

    group('validate', () {
      test('should validate input correctly', () {
        final event = ExpertiseEvent(
          id: 'event_123',
          title: 'Test Sponsored Event',
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

        final validFinancialInput = SponsorshipCheckoutInput(
          event: event,
          brandId: 'brand_456',
          type: SponsorshipType.financial,
          contributionAmount: 500.0,
        );

        final invalidInput = SponsorshipCheckoutInput(
          event: event,
          brandId: 'brand_456',
          type: SponsorshipType.financial,
          contributionAmount: null,
        );

        // Act
        final validResult = controller.validate(validFinancialInput);
        final invalidResult = controller.validate(invalidInput);

        // Assert
        expect(validResult.isValid, isTrue);
        expect(invalidResult.isValid, isFalse);
      });
    });
  });
}


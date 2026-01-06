import 'package:flutter_test/flutter_test.dart';

import 'package:spots/core/controllers/partnership_proposal_controller.dart';
import 'package:spots/core/models/event_partnership.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_database.dart';
import '../../helpers/platform_channel_helper.dart';

/// Partnership Proposal Controller Integration Tests
/// 
/// Tests the complete partnership proposal workflow with real service implementations:
/// - Proposal validation
/// - Partnership creation
/// - Proposal acceptance/rejection
/// - Error handling
void main() {
  group('PartnershipProposalController Integration Tests', () {
    late PartnershipProposalController controller;

    setUpAll(() async {
      // Initialize Sembast for tests
      SembastDatabase.useInMemoryForTests();
      await SembastDatabase.database;
      
      // Initialize dependency injection
      await setupTestStorage();
      await di.init();
      
      controller = di.sl<PartnershipProposalController>();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
    });

    group('validate', () {
      test('should validate input correctly', () {
        final validData = PartnershipProposalData(
          type: PartnershipType.eventBased,
          sharedResponsibilities: ['Venue'],
        );
        final validInput = PartnershipProposalInput(
          eventId: 'event_123',
          proposerId: 'user_456',
          businessId: 'business_789',
          data: validData,
        );

        final invalidData = PartnershipProposalData();
        final invalidInput = PartnershipProposalInput(
          eventId: '',
          proposerId: 'user_456',
          businessId: 'business_789',
          data: invalidData,
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


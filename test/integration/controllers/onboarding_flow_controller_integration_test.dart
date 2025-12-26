import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/controllers/onboarding_flow_controller.dart';
import 'package:spots/core/models/onboarding_data.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:spots/core/services/onboarding_data_service.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/legal_document_service.dart';

/// Integration tests for OnboardingFlowController
/// 
/// Tests verify that the controller works correctly when integrated
/// with real services and the onboarding page workflow.
void main() {
  group('OnboardingFlowController Integration', () {
    late OnboardingFlowController controller;
    const testUserId = 'test_user_123';

    setUpAll(() async {
      // Initialize dependency injection
      await di.init();
      
      // Use in-memory database for tests
      SembastDatabase.useInMemoryForTests();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
      controller = di.sl<OnboardingFlowController>();
    });

    tearDown(() async {
      // Clean up test data - database is reset in setUp, so no manual cleanup needed
      // The in-memory database is reset between tests automatically
    });

    group('completeOnboarding', () {
      test('should successfully complete onboarding with valid data', () async {
        final data = OnboardingData(
          agentId: '', // Will be set by controller
          age: 25,
          homebase: 'New York',
          favoritePlaces: ['Central Park', 'Brooklyn Bridge'],
          preferences: {
            'Food & Drink': ['Coffee', 'Craft Beer'],
            'Activities': ['Hiking', 'Photography'],
          },
          baselineLists: ['My Favorite Spots'],
          respectedFriends: ['friend1', 'friend2'],
          socialMediaConnected: {
            'google': true,
            'instagram': false,
          },
          completedAt: DateTime.now(),
        );

        final result = await controller.completeOnboarding(
          data: data,
          userId: testUserId,
        );

        expect(result.isSuccess, isTrue, reason: 'Onboarding should complete successfully');
        expect(result.agentId, isNotNull, reason: 'AgentId should be assigned');
        expect(result.onboardingData, isNotNull, reason: 'OnboardingData should be returned');
        expect(result.onboardingData!.agentId, equals(result.agentId),
            reason: 'OnboardingData should have correct agentId');
      });

      test('should save onboarding data to storage', () async {
        final data = OnboardingData(
          agentId: '',
          age: 30,
          homebase: 'San Francisco',
          completedAt: DateTime.now(),
        );

        final result = await controller.completeOnboarding(
          data: data,
          userId: testUserId,
        );

        expect(result.isSuccess, isTrue);

        // Verify data was saved by retrieving it
        final onboardingService = di.sl<OnboardingDataService>();
        final savedData = await onboardingService.getOnboardingData(testUserId);

        expect(savedData, isNotNull, reason: 'Onboarding data should be retrievable');
        expect(savedData!.age, equals(30), reason: 'Age should match');
        expect(savedData.homebase, equals('San Francisco'), reason: 'Homebase should match');
        expect(savedData.agentId, equals(result.agentId), reason: 'AgentId should match');
      });

      test('should handle validation errors gracefully', () async {
        final invalidData = OnboardingData(
          agentId: '', // Invalid - will be set by controller, but age is invalid
          age: 5, // Too young
          completedAt: DateTime.now(),
        );

        final result = await controller.completeOnboarding(
          data: invalidData,
          userId: testUserId,
        );

        expect(result.isSuccess, isFalse, reason: 'Should fail validation');
        expect(result.error, isNotNull, reason: 'Should have error message');
        expect(result.validationErrors, isNotNull, reason: 'Should have validation errors');
        expect(result.validationErrors!.fieldErrors['age'], isNotNull,
            reason: 'Should have age validation error');
      });

      test('should assign consistent agentId for same user', () async {
        final data1 = OnboardingData(
          agentId: '',
          age: 25,
          completedAt: DateTime.now(),
        );
        final data2 = OnboardingData(
          agentId: '',
          age: 25,
          completedAt: DateTime.now(),
        );

        final result1 = await controller.completeOnboarding(
          data: data1,
          userId: testUserId,
        );
        final result2 = await controller.completeOnboarding(
          data: data2,
          userId: testUserId,
        );

        expect(result1.isSuccess, isTrue);
        expect(result2.isSuccess, isTrue);
        expect(result1.agentId, equals(result2.agentId),
            reason: 'Same user should get same agentId');
      });

      test('should handle missing required fields', () async {
        final incompleteData = OnboardingData(
          agentId: '',
          completedAt: DateTime.now().add(const Duration(days: 2)), // Invalid - future date (>1 day)
        );

        final result = await controller.completeOnboarding(
          data: incompleteData,
          userId: testUserId,
        );

        expect(result.isSuccess, isFalse, reason: 'Should fail validation for future date >1 day');
        expect(result.validationErrors, isNotNull, reason: 'Should have validation errors');
        // Validation should catch future completion date
        expect(result.validationErrors!.generalErrors.isNotEmpty || 
               result.validationErrors!.fieldErrors.isNotEmpty, 
               isTrue, 
               reason: 'Should have validation errors for future date');
      });
    });

    group('validate', () {
      test('should validate correct onboarding data', () {
        final data = OnboardingData(
          agentId: 'agent_test123456789012345678901234567890',
          age: 25,
          homebase: 'New York',
          completedAt: DateTime.now(),
        );

        final validation = controller.validate(data);

        expect(validation.isValid, isTrue, reason: 'Valid data should pass validation');
        expect(validation.allErrors, isEmpty, reason: 'Should have no errors');
      });

      test('should reject invalid age', () {
        final data = OnboardingData(
          agentId: 'agent_test123456789012345678901234567890',
          age: 5, // Too young
          completedAt: DateTime.now(),
        );

        final validation = controller.validate(data);

        expect(validation.isValid, isFalse, reason: 'Invalid age should fail validation');
        expect(validation.fieldErrors['age'], isNotNull, reason: 'Should have age error');
      });

      test('should reject future birthday', () {
        final data = OnboardingData(
          agentId: 'agent_test123456789012345678901234567890',
          birthday: DateTime.now().add(const Duration(days: 1)),
          completedAt: DateTime.now(),
        );

        final validation = controller.validate(data);

        expect(validation.isValid, isFalse, reason: 'Future birthday should fail validation');
        expect(validation.fieldErrors['birthday'], isNotNull, reason: 'Should have birthday error');
      });
    });
  });
}


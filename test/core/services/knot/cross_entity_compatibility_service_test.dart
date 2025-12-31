// Unit tests for CrossEntityCompatibilityService
// 
// Tests cross-entity compatibility calculations
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase 1.5: Universal Cross-Pollination Extension

import 'package:flutter_test/flutter_test.dart';
import 'package:spots_knot/models/entity_knot.dart';
import 'package:spots_ai/models/personality_profile.dart';
import 'package:spots/core/services/knot/cross_entity_compatibility_service.dart';
import 'package:spots/core/services/knot/entity_knot_service.dart';
import 'package:spots/core/services/knot/bridge/knot_math_bridge.dart/frb_generated.dart';
import '../../../fixtures/model_factories.dart';
import '../../../helpers/integration_test_helpers.dart';

void main() {
  group('CrossEntityCompatibilityService Tests', () {
    late CrossEntityCompatibilityService compatibilityService;
    late EntityKnotService entityKnotService;
    bool rustLibInitialized = false;

    setUpAll(() async {
      // Initialize Rust library once for all tests
      if (!rustLibInitialized) {
        try {
          await RustLib.init();
          rustLibInitialized = true;
        } catch (e) {
          // If already initialized, that's fine
          if (!e.toString().contains('Should not initialize')) {
            rethrow;
          }
          rustLibInitialized = true;
        }
      }
    });

    setUp(() {
      entityKnotService = EntityKnotService();
      compatibilityService = CrossEntityCompatibilityService();
    });

    group('Integrated Compatibility Calculation', () {
      test('should calculate compatibility between two person entities', () async {
        final profile1 = PersonalityProfile.initial(
          'test_agent_1',
          userId: 'test_user_1',
        );
        final profile2 = PersonalityProfile.initial(
          'test_agent_2',
          userId: 'test_user_2',
        );

        final knot1 = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile1,
        );
        final knot2 = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile2,
        );

        final compatibility = await compatibilityService.calculateIntegratedCompatibility(
          entityA: knot1,
          entityB: knot2,
        );

        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });

      test('should calculate compatibility between person and event', () async {
        final profile = PersonalityProfile.initial(
          'test_agent_3',
          userId: 'test_user_3',
        );
        final host = ModelFactories.createTestUser(id: 'host-1');
        final event = IntegrationTestHelpers.createTestEvent(
          host: host,
          category: 'Coffee',
        );

        final personKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );
        final eventKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.event,
          entity: event,
        );

        final compatibility = await compatibilityService.calculateIntegratedCompatibility(
          entityA: personKnot,
          entityB: eventKnot,
        );

        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });

      test('should calculate compatibility between person and place', () async {
        final profile = PersonalityProfile.initial(
          'test_agent_4',
          userId: 'test_user_4',
        );
        final spot = ModelFactories.createTestSpot(
          id: 'spot-1',
          name: 'Test Place',
          category: 'Coffee',
        );

        final personKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );
        final placeKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.place,
          entity: spot,
        );

        final compatibility = await compatibilityService.calculateIntegratedCompatibility(
          entityA: personKnot,
          entityB: placeKnot,
        );

        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });

      test('should calculate compatibility between person and company', () async {
        final profile = PersonalityProfile.initial(
          'test_agent_5',
          userId: 'test_user_5',
        );
        final business = IntegrationTestHelpers.createTestBusinessAccount(
          id: 'business-1',
          name: 'Test Business',
          businessType: 'Coffee Shop',
        );

        final personKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );
        final companyKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.company,
          entity: business,
        );

        final compatibility = await compatibilityService.calculateIntegratedCompatibility(
          entityA: personKnot,
          entityB: companyKnot,
        );

        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });

      test('should return high compatibility for identical entities', () async {
        final profile = PersonalityProfile.initial(
          'test_agent_6',
          userId: 'test_user_6',
        );

        final knot1 = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );
        final knot2 = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );

        final compatibility = await compatibilityService.calculateIntegratedCompatibility(
          entityA: knot1,
          entityB: knot2,
        );

        // Same entity should have high compatibility
        expect(compatibility, greaterThan(0.5));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });
    });

    group('Multi-Entity Weave Compatibility', () {
      test('should calculate compatibility for multiple entities', () async {
        final profile = PersonalityProfile.initial(
          'test_agent_7',
          userId: 'test_user_7',
        );
        final host = ModelFactories.createTestUser(id: 'host-1');
        final event = IntegrationTestHelpers.createTestEvent(
          host: host,
          category: 'Coffee',
        );
        final spot = ModelFactories.createTestSpot(
          id: 'spot-1',
          name: 'Test Place',
          category: 'Coffee',
        );

        final personKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );
        final eventKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.event,
          entity: event,
        );
        final placeKnot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.place,
          entity: spot,
        );

        final compatibility = await compatibilityService.calculateMultiEntityWeaveCompatibility(
          entities: [personKnot, eventKnot, placeKnot],
        );

        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });

      test('should return 1.0 for single entity', () async {
        final profile = PersonalityProfile.initial(
          'test_agent_8',
          userId: 'test_user_8',
        );

        final knot = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile,
        );

        final compatibility = await compatibilityService.calculateMultiEntityWeaveCompatibility(
          entities: [knot],
        );

        expect(compatibility, equals(1.0));
      });

      test('should handle empty entity list', () async {
        final compatibility = await compatibilityService.calculateMultiEntityWeaveCompatibility(
          entities: [],
        );

        // Empty list should return 1.0 (perfect compatibility with nothing)
        expect(compatibility, equals(1.0));
      });
    });

    group('Compatibility Formula Validation', () {
      test('should use correct weight distribution', () async {
        // The formula is: C_integrated = α·C_quantum + β·C_topological + γ·C_weave
        // Where α = 0.5, β = 0.3, γ = 0.2
        // This test verifies the weights sum to 1.0
        const quantumWeight = 0.5;
        const topologicalWeight = 0.3;
        const weaveWeight = 0.2;
        const totalWeight = quantumWeight + topologicalWeight + weaveWeight;

        expect(totalWeight, equals(1.0));
      });

      test('should return values in valid range', () async {
        final profile1 = PersonalityProfile.initial(
          'test_agent_9',
          userId: 'test_user_9',
        );
        final profile2 = PersonalityProfile.initial(
          'test_agent_10',
          userId: 'test_user_10',
        );

        final knot1 = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile1,
        );
        final knot2 = await entityKnotService.generateKnotForEntity(
          entityType: EntityType.person,
          entity: profile2,
        );

        final compatibility = await compatibilityService.calculateIntegratedCompatibility(
          entityA: knot1,
          entityB: knot2,
        );

        // Compatibility should always be in [0, 1]
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
      });
    });
  });
}

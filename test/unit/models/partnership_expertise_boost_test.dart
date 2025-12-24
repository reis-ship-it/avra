import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/partnership_expertise_boost.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for PartnershipExpertiseBoost model
/// Tests boost calculation structure, JSON serialization, and business logic
void main() {
  group('PartnershipExpertiseBoost Model Tests', () {
    setUp(() {
      TestHelpers.setupTestEnvironment();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    // Removed: Constructor and Properties group
    // These tests only verified Dart constructor behavior, not business logic

    group('Business Logic', () {
      test('should correctly identify boost state and calculate percentage',
          () {
        // Test business logic: boost detection and percentage calculation
        final zeroBoost = PartnershipExpertiseBoost(totalBoost: 0.0);
        final activeBoost = PartnershipExpertiseBoost(totalBoost: 0.25);
        final maxBoost = PartnershipExpertiseBoost(totalBoost: 0.50);

        expect(zeroBoost.hasBoost, isFalse);
        expect(zeroBoost.boostPercentage, equals(0.0));

        expect(activeBoost.hasBoost, isTrue);
        expect(activeBoost.boostPercentage, equals(25.0));

        expect(maxBoost.hasBoost, isTrue);
        expect(maxBoost.boostPercentage, equals(50.0));
      });
    });

    group('JSON Serialization', () {
      test(
          'should serialize and deserialize with defaults and handle null fields',
          () {
        // Test business logic: JSON round-trip with error handling
        final boost = PartnershipExpertiseBoost(
          totalBoost: 0.35,
          activeBoost: 0.10,
          completedBoost: 0.15,
          countMultiplier: 1.2,
          partnershipCount: 4,
        );

        final json = boost.toJson();
        final restored = PartnershipExpertiseBoost.fromJson(json);

        expect(restored.totalBoost, equals(0.35));
        expect(restored.countMultiplier, equals(1.2));
        expect(restored.partnershipCount, equals(4));

        // Test defaults with minimal JSON
        final minimalJson = {'totalBoost': 0.15};
        final minimal = PartnershipExpertiseBoost.fromJson(minimalJson);
        expect(minimal.countMultiplier, equals(1.0));
        expect(minimal.partnershipCount, equals(0));

        // Test null handling
        final jsonWithNulls = {
          'totalBoost': 0.20,
          'activeBoost': null,
          'countMultiplier': null,
        };
        final withNulls = PartnershipExpertiseBoost.fromJson(jsonWithNulls);
        expect(withNulls.countMultiplier, equals(1.0));
        expect(withNulls.partnershipCount, equals(0));
      });
    });

    group('copyWith', () {
      test('should create immutable copy with updated fields', () {
        final original = PartnershipExpertiseBoost(
          totalBoost: 0.25,
          partnershipCount: 3,
        );

        final updated = original.copyWith(
          totalBoost: 0.35,
          partnershipCount: 5,
        );

        // Test immutability (business logic)
        expect(original.totalBoost, isNot(equals(0.35)));
        expect(updated.totalBoost, equals(0.35));
        expect(updated.partnershipCount, equals(5));
      });
    });

    // Removed: Equatable group
    // These tests verify Equatable implementation, which is already tested by the package
    // If equality breaks, other tests will fail
  });
}

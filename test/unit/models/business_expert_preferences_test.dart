import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/business_expert_preferences.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for BusinessExpertPreferences model
/// Tests expert matching preferences, JSON serialization, and helper methods
void main() {
  group('BusinessExpertPreferences Model Tests', () {
    setUp(() {
      TestHelpers.setupTestEnvironment();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create preferences with default values', () {
        final prefs = BusinessExpertPreferences();

        expect(prefs.requiredExpertiseCategories, isEmpty);
        expect(prefs.preferredExpertiseCategories, isEmpty);
        expect(prefs.minExpertLevel, isNull);
        expect(prefs.preferredExpertLevel, isNull);
        expect(prefs.preferredLocation, isNull);
        expect(prefs.preferredLocations, isNull);
        expect(prefs.maxDistanceKm, isNull);
        expect(prefs.allowRemote, isFalse);
        expect(prefs.preferredAgeRange, isNull);
        expect(prefs.preferredLanguages, isNull);
        expect(prefs.minYearsExperience, isNull);
        expect(prefs.aiMatchingCriteria, isEmpty);
        expect(prefs.allowRemote, isFalse);
        expect(prefs.requireFlexibleSchedule, isFalse);
        expect(prefs.preferLongTermRelationships, isFalse);
        expect(prefs.preferCommunityLeaders, isFalse);
      });

      test('should create preferences with all fields', () {
        final ageRange = AgeRange(minAge: 25, maxAge: 45);
        final prefs = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee', 'Food'],
          preferredExpertiseCategories: ['Hospitality'],
          minExpertLevel: 3,
          preferredExpertLevel: 4,
          preferredLocation: 'NYC',
          preferredLocations: ['NYC', 'Brooklyn'],
          maxDistanceKm: 50,
          allowRemote: true,
          preferredAgeRange: ageRange,
          preferredLanguages: ['English', 'Spanish'],
          minYearsExperience: 5,
          preferredBackgrounds: ['Restaurant', 'Hospitality'],
          preferredCertifications: ['Food Safety'],
          preferredSkills: ['Customer Service'],
          preferredPersonalityTraits: ['Outgoing'],
          preferredWorkStyles: ['Collaborative'],
          preferredCommunicationStyles: ['Direct'],
          preferredAvailability: ['Weekdays'],
          requireFlexibleSchedule: true,
          preferredEngagementTypes: ['Consulting'],
          preferredCommitmentLevel: 4,
          preferLongTermRelationships: true,
          preferredCommunities: ['community-1'],
          preferCommunityLeaders: true,
          minCommunityConnections: 10,
          aiMatchingCriteria: {'custom': 'value'},
          minMatchScore: 0.8,
          aiKeywords: ['expert', 'experienced'],
          aiMatchingPrompt: 'Find experienced coffee experts',
          excludedExpertise: ['Retail'],
          excludedLocations: ['Remote'],
        );

        expect(prefs.requiredExpertiseCategories, equals(['Coffee', 'Food']));
        expect(prefs.preferredExpertiseCategories, equals(['Hospitality']));
        expect(prefs.minExpertLevel, equals(3));
        expect(prefs.preferredExpertLevel, equals(4));
        expect(prefs.preferredLocation, equals('NYC'));
        expect(prefs.preferredLocations, equals(['NYC', 'Brooklyn']));
        expect(prefs.maxDistanceKm, equals(50));
        expect(prefs.allowRemote, isTrue);
        expect(prefs.preferredAgeRange, equals(ageRange));
        expect(prefs.preferredLanguages, equals(['English', 'Spanish']));
        expect(prefs.minYearsExperience, equals(5));
        expect(prefs.preferredBackgrounds, equals(['Restaurant', 'Hospitality']));
        expect(prefs.preferredCertifications, equals(['Food Safety']));
        expect(prefs.preferredSkills, equals(['Customer Service']));
        expect(prefs.preferredPersonalityTraits, equals(['Outgoing']));
        expect(prefs.preferredWorkStyles, equals(['Collaborative']));
        expect(prefs.preferredCommunicationStyles, equals(['Direct']));
        expect(prefs.preferredAvailability, equals(['Weekdays']));
        expect(prefs.requireFlexibleSchedule, isTrue);
        expect(prefs.preferredEngagementTypes, equals(['Consulting']));
        expect(prefs.preferredCommitmentLevel, equals(4));
        expect(prefs.preferLongTermRelationships, isTrue);
        expect(prefs.preferredCommunities, equals(['community-1']));
        expect(prefs.preferCommunityLeaders, isTrue);
        expect(prefs.minCommunityConnections, equals(10));
        expect(prefs.aiMatchingCriteria, equals({'custom': 'value'}));
        expect(prefs.minMatchScore, equals(0.8));
        expect(prefs.aiKeywords, equals(['expert', 'experienced']));
        expect(prefs.aiMatchingPrompt, equals('Find experienced coffee experts'));
        expect(prefs.excludedExpertise, equals(['Retail']));
        expect(prefs.excludedLocations, equals(['Remote']));
      });
    });

    group('AgeRange Model', () {
      test('should create age range with min and max', () {
        final ageRange = AgeRange(minAge: 25, maxAge: 45);

        expect(ageRange.minAge, equals(25));
        expect(ageRange.maxAge, equals(45));
      });

      test('should create age range with only min age', () {
        final ageRange = AgeRange(minAge: 25);

        expect(ageRange.minAge, equals(25));
        expect(ageRange.maxAge, isNull);
      });

      test('should create age range with only max age', () {
        final ageRange = AgeRange(maxAge: 45);

        expect(ageRange.minAge, isNull);
        expect(ageRange.maxAge, equals(45));
      });

      test('should have correct display text', () {
        expect(AgeRange(minAge: 25, maxAge: 45).displayText, equals('25-45'));
        expect(AgeRange(minAge: 25).displayText, equals('25+'));
        expect(AgeRange(maxAge: 45).displayText, equals('Under 45'));
        expect(AgeRange().displayText, equals('Any age'));
      });

      test('should match ages correctly', () {
        final ageRange = AgeRange(minAge: 25, maxAge: 45);

        expect(ageRange.matches(30), isTrue);
        expect(ageRange.matches(25), isTrue);
        expect(ageRange.matches(45), isTrue);
        expect(ageRange.matches(24), isFalse);
        expect(ageRange.matches(46), isFalse);
      });

      test('should serialize and deserialize age range', () {
        final ageRange = AgeRange(minAge: 25, maxAge: 45);
        final json = ageRange.toJson();
        final deserialized = AgeRange.fromJson(json);

        expect(deserialized.minAge, equals(25));
        expect(deserialized.maxAge, equals(45));
      });
    });

    group('isEmpty Checker', () {
      test('should return true for empty preferences', () {
        final prefs = BusinessExpertPreferences();
        expect(prefs.isEmpty, isTrue);
      });

      test('should return false when required categories are set', () {
        final prefs = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when preferred categories are set', () {
        final prefs = BusinessExpertPreferences(
          preferredExpertiseCategories: ['Food'],
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when min expert level is set', () {
        final prefs = BusinessExpertPreferences(
          minExpertLevel: 3,
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when preferred location is set', () {
        final prefs = BusinessExpertPreferences(
          preferredLocation: 'NYC',
        );
        expect(prefs.isEmpty, isFalse);
      });
    });

    group('getSummary', () {
      test('should return "No preferences set" for empty preferences', () {
        final prefs = BusinessExpertPreferences();
        expect(prefs.getSummary(), equals('No preferences set'));
      });

      test('should include required categories in summary', () {
        final prefs = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee', 'Food'],
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Required: Coffee, Food'));
      });

      test('should include preferred categories in summary', () {
        final prefs = BusinessExpertPreferences(
          preferredExpertiseCategories: ['Hospitality'],
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Preferred: Hospitality'));
      });

      test('should include location in summary', () {
        final prefs = BusinessExpertPreferences(
          preferredLocation: 'NYC',
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Location: NYC'));
      });

      test('should include min level in summary', () {
        final prefs = BusinessExpertPreferences(
          minExpertLevel: 3,
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Min Level: 3'));
      });

      test('should include all fields in summary', () {
        final prefs = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          preferredExpertiseCategories: ['Food'],
          preferredLocation: 'NYC',
          minExpertLevel: 3,
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Required: Coffee'));
        expect(summary, contains('Preferred: Food'));
        expect(summary, contains('Location: NYC'));
        expect(summary, contains('Min Level: 3'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final ageRange = AgeRange(minAge: 25, maxAge: 45);
        final prefs = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          preferredExpertiseCategories: ['Food'],
          minExpertLevel: 3,
          preferredLocation: 'NYC',
          allowRemote: true,
          preferredAgeRange: ageRange,
          preferredLanguages: ['English'],
          minYearsExperience: 5,
          aiMatchingCriteria: {'custom': 'value'},
          minMatchScore: 0.8,
        );

        final json = prefs.toJson();

        expect(json['requiredExpertiseCategories'], equals(['Coffee']));
        expect(json['preferredExpertiseCategories'], equals(['Food']));
        expect(json['minExpertLevel'], equals(3));
        expect(json['preferredLocation'], equals('NYC'));
        expect(json['allowRemote'], isTrue);
        expect(json['preferredAgeRange'], isNotNull);
        expect(json['preferredLanguages'], equals(['English']));
        expect(json['minYearsExperience'], equals(5));
        expect(json['aiMatchingCriteria'], equals({'custom': 'value'}));
        expect(json['minMatchScore'], equals(0.8));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'requiredExpertiseCategories': ['Coffee'],
          'preferredExpertiseCategories': ['Food'],
          'minExpertLevel': 3,
          'preferredExpertLevel': 4,
          'preferredLocation': 'NYC',
          'preferredLocations': ['NYC', 'Brooklyn'],
          'maxDistanceKm': 50,
          'allowRemote': true,
          'preferredAgeRange': {'minAge': 25, 'maxAge': 45},
          'preferredLanguages': ['English', 'Spanish'],
          'minYearsExperience': 5,
          'preferredBackgrounds': ['Restaurant'],
          'preferredCertifications': ['Food Safety'],
          'preferredSkills': ['Customer Service'],
          'preferredPersonalityTraits': ['Outgoing'],
          'preferredWorkStyles': ['Collaborative'],
          'preferredCommunicationStyles': ['Direct'],
          'preferredAvailability': ['Weekdays'],
          'requireFlexibleSchedule': true,
          'preferredEngagementTypes': ['Consulting'],
          'preferredCommitmentLevel': 4,
          'preferLongTermRelationships': true,
          'preferredCommunities': ['community-1'],
          'preferCommunityLeaders': true,
          'minCommunityConnections': 10,
          'aiMatchingCriteria': {'custom': 'value'},
          'minMatchScore': 0.8,
          'aiKeywords': ['expert'],
          'aiMatchingPrompt': 'Find experts',
          'excludedExpertise': ['Retail'],
          'excludedLocations': ['Remote'],
        };

        final prefs = BusinessExpertPreferences.fromJson(json);

        expect(prefs.requiredExpertiseCategories, equals(['Coffee']));
        expect(prefs.preferredExpertiseCategories, equals(['Food']));
        expect(prefs.minExpertLevel, equals(3));
        expect(prefs.preferredExpertLevel, equals(4));
        expect(prefs.preferredLocation, equals('NYC'));
        expect(prefs.preferredLocations, equals(['NYC', 'Brooklyn']));
        expect(prefs.maxDistanceKm, equals(50));
        expect(prefs.allowRemote, isTrue);
        expect(prefs.preferredAgeRange?.minAge, equals(25));
        expect(prefs.preferredAgeRange?.maxAge, equals(45));
        expect(prefs.preferredLanguages, equals(['English', 'Spanish']));
        expect(prefs.minYearsExperience, equals(5));
        expect(prefs.preferredBackgrounds, equals(['Restaurant']));
        expect(prefs.preferredCertifications, equals(['Food Safety']));
        expect(prefs.preferredSkills, equals(['Customer Service']));
        expect(prefs.preferredPersonalityTraits, equals(['Outgoing']));
        expect(prefs.preferredWorkStyles, equals(['Collaborative']));
        expect(prefs.preferredCommunicationStyles, equals(['Direct']));
        expect(prefs.preferredAvailability, equals(['Weekdays']));
        expect(prefs.requireFlexibleSchedule, isTrue);
        expect(prefs.preferredEngagementTypes, equals(['Consulting']));
        expect(prefs.preferredCommitmentLevel, equals(4));
        expect(prefs.preferLongTermRelationships, isTrue);
        expect(prefs.preferredCommunities, equals(['community-1']));
        expect(prefs.preferCommunityLeaders, isTrue);
        expect(prefs.minCommunityConnections, equals(10));
        expect(prefs.aiMatchingCriteria, equals({'custom': 'value'}));
        expect(prefs.minMatchScore, equals(0.8));
        expect(prefs.aiKeywords, equals(['expert']));
        expect(prefs.aiMatchingPrompt, equals('Find experts'));
        expect(prefs.excludedExpertise, equals(['Retail']));
        expect(prefs.excludedLocations, equals(['Remote']));
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'requiredExpertiseCategories': [],
        };

        final prefs = BusinessExpertPreferences.fromJson(json);

        expect(prefs.preferredExpertiseCategories, isEmpty);
        expect(prefs.minExpertLevel, isNull);
        expect(prefs.preferredLocation, isNull);
        expect(prefs.preferredAgeRange, isNull);
        expect(prefs.preferredLanguages, isNull);
        expect(prefs.aiMatchingCriteria, isEmpty);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          minExpertLevel: 3,
        );

        final updated = original.copyWith(
          requiredExpertiseCategories: ['Food'],
          minExpertLevel: 4,
        );

        expect(updated.requiredExpertiseCategories, equals(['Food'])); // Changed
        expect(updated.minExpertLevel, equals(4)); // Changed
        expect(updated.preferredExpertiseCategories, isEmpty); // Unchanged
      });

      test('should create copy with null fields', () {
        final original = BusinessExpertPreferences(
          preferredLocation: 'NYC',
        );

        final updated = original.copyWith(preferredLocation: null);

        expect(updated.preferredLocation, isNull);
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final prefs1 = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          minExpertLevel: 3,
        );

        final prefs2 = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          minExpertLevel: 3,
        );

        expect(prefs1, equals(prefs2));
      });

      test('should not be equal when properties differ', () {
        final prefs1 = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
        );

        final prefs2 = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Food'], // Different
        );

        expect(prefs1, isNot(equals(prefs2)));
      });
    });
  });
}


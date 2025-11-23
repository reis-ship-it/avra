import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/business_patron_preferences.dart';
import 'package:spots/core/models/business_expert_preferences.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for BusinessPatronPreferences model
/// Tests patron matching preferences, JSON serialization, and helper methods
void main() {
  group('BusinessPatronPreferences Model Tests', () {
    setUp(() {
      TestHelpers.setupTestEnvironment();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create preferences with default values', () {
        final prefs = BusinessPatronPreferences();

        expect(prefs.preferredAgeRange, isNull);
        expect(prefs.preferredLanguages, isNull);
        expect(prefs.preferredLocations, isNull);
        expect(prefs.preferredInterests, isNull);
        expect(prefs.preferredLifestyleTraits, isNull);
        expect(prefs.preferredActivities, isNull);
        expect(prefs.preferredPersonalityTraits, isNull);
        expect(prefs.preferredSocialStyles, isNull);
        expect(prefs.preferredVibePreferences, isNull);
        expect(prefs.preferredSpendingLevel, isNull);
        expect(prefs.preferLoyalCustomers, isFalse);
        expect(prefs.preferNewCustomers, isFalse);
        expect(prefs.preferEducatedPatrons, isFalse);
        expect(prefs.preferCommunityMembers, isFalse);
        expect(prefs.preferLocalPatrons, isFalse);
        expect(prefs.preferTourists, isFalse);
        expect(prefs.preferAgeVerified, isFalse);
        expect(prefs.preferPetOwners, isFalse);
        expect(prefs.preferAccessibilityNeeds, isFalse);
        expect(prefs.aiMatchingCriteria, isEmpty);
      });

      test('should create preferences with all fields', () {
        final ageRange = AgeRange(minAge: 21, maxAge: 65);
        final prefs = BusinessPatronPreferences(
          preferredAgeRange: ageRange,
          preferredLanguages: ['English', 'Spanish'],
          preferredLocations: ['NYC', 'Brooklyn'],
          preferredInterests: ['Food', 'Music'],
          preferredLifestyleTraits: ['Health-conscious', 'Eco-friendly'],
          preferredActivities: ['Dining', 'Socializing'],
          preferredPersonalityTraits: ['Outgoing', 'Friendly'],
          preferredSocialStyles: ['Group-oriented', 'Family-friendly'],
          preferredVibePreferences: ['Casual', 'Trendy'],
          preferredSpendingLevel: SpendingLevel.midRange,
          preferredVisitFrequency: ['Regular', 'Occasional'],
          preferLoyalCustomers: true,
          preferNewCustomers: true,
          preferredExpertiseLevels: ['Intermediate', 'Expert'],
          preferEducatedPatrons: true,
          preferredKnowledgeAreas: ['Coffee', 'Wine'],
          preferCommunityMembers: true,
          preferredCommunities: ['community-1'],
          preferLocalPatrons: true,
          preferTourists: true,
          preferredVisitTimes: ['Evening', 'Late Night'],
          preferredDaysOfWeek: ['Weekends'],
          preferAgeVerified: true,
          preferPetOwners: true,
          preferAccessibilityNeeds: true,
          preferredSpecialNeeds: ['Wheelchair accessible'],
          aiMatchingCriteria: {'custom': 'value'},
          aiKeywords: ['foodie', 'social'],
          aiMatchingPrompt: 'Find food enthusiasts',
          excludedInterests: ['Sports'],
          excludedPersonalityTraits: ['Aggressive'],
          excludedLocations: ['Suburbs'],
        );

        expect(prefs.preferredAgeRange, equals(ageRange));
        expect(prefs.preferredLanguages, equals(['English', 'Spanish']));
        expect(prefs.preferredLocations, equals(['NYC', 'Brooklyn']));
        expect(prefs.preferredInterests, equals(['Food', 'Music']));
        expect(prefs.preferredLifestyleTraits, equals(['Health-conscious', 'Eco-friendly']));
        expect(prefs.preferredActivities, equals(['Dining', 'Socializing']));
        expect(prefs.preferredPersonalityTraits, equals(['Outgoing', 'Friendly']));
        expect(prefs.preferredSocialStyles, equals(['Group-oriented', 'Family-friendly']));
        expect(prefs.preferredVibePreferences, equals(['Casual', 'Trendy']));
        expect(prefs.preferredSpendingLevel, equals(SpendingLevel.midRange));
        expect(prefs.preferredVisitFrequency, equals(['Regular', 'Occasional']));
        expect(prefs.preferLoyalCustomers, isTrue);
        expect(prefs.preferNewCustomers, isTrue);
        expect(prefs.preferredExpertiseLevels, equals(['Intermediate', 'Expert']));
        expect(prefs.preferEducatedPatrons, isTrue);
        expect(prefs.preferredKnowledgeAreas, equals(['Coffee', 'Wine']));
        expect(prefs.preferCommunityMembers, isTrue);
        expect(prefs.preferredCommunities, equals(['community-1']));
        expect(prefs.preferLocalPatrons, isTrue);
        expect(prefs.preferTourists, isTrue);
        expect(prefs.preferredVisitTimes, equals(['Evening', 'Late Night']));
        expect(prefs.preferredDaysOfWeek, equals(['Weekends']));
        expect(prefs.preferAgeVerified, isTrue);
        expect(prefs.preferPetOwners, isTrue);
        expect(prefs.preferAccessibilityNeeds, isTrue);
        expect(prefs.preferredSpecialNeeds, equals(['Wheelchair accessible']));
        expect(prefs.aiMatchingCriteria, equals({'custom': 'value'}));
        expect(prefs.aiKeywords, equals(['foodie', 'social']));
        expect(prefs.aiMatchingPrompt, equals('Find food enthusiasts'));
        expect(prefs.excludedInterests, equals(['Sports']));
        expect(prefs.excludedPersonalityTraits, equals(['Aggressive']));
        expect(prefs.excludedLocations, equals(['Suburbs']));
      });
    });

    group('SpendingLevel Enum', () {
      test('should have all spending level values', () {
        expect(SpendingLevel.values, hasLength(4));
        expect(SpendingLevel.values, contains(SpendingLevel.budget));
        expect(SpendingLevel.values, contains(SpendingLevel.midRange));
        expect(SpendingLevel.values, contains(SpendingLevel.premium));
        expect(SpendingLevel.values, contains(SpendingLevel.any));
      });

      test('should have correct display names', () {
        expect(SpendingLevel.budget.displayName, equals('Budget'));
        expect(SpendingLevel.midRange.displayName, equals('Mid-Range'));
        expect(SpendingLevel.premium.displayName, equals('Premium'));
        expect(SpendingLevel.any.displayName, equals('Any'));
      });

      test('should parse spending level from string correctly', () {
        expect(SpendingLevelExtension.fromString('budget'), equals(SpendingLevel.budget));
        expect(SpendingLevelExtension.fromString('midrange'), equals(SpendingLevel.midRange));
        expect(SpendingLevelExtension.fromString('mid-range'), equals(SpendingLevel.midRange));
        expect(SpendingLevelExtension.fromString('midRange'), equals(SpendingLevel.midRange));
        expect(SpendingLevelExtension.fromString('premium'), equals(SpendingLevel.premium));
        expect(SpendingLevelExtension.fromString('any'), equals(SpendingLevel.any));
        expect(SpendingLevelExtension.fromString('unknown'), isNull);
        expect(SpendingLevelExtension.fromString(null), isNull);
      });
    });

    group('isEmpty Checker', () {
      test('should return true for empty preferences', () {
        final prefs = BusinessPatronPreferences();
        expect(prefs.isEmpty, isTrue);
      });

      test('should return false when age range is set', () {
        final prefs = BusinessPatronPreferences(
          preferredAgeRange: AgeRange(minAge: 21),
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when languages are set', () {
        final prefs = BusinessPatronPreferences(
          preferredLanguages: ['English'],
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when locations are set', () {
        final prefs = BusinessPatronPreferences(
          preferredLocations: ['NYC'],
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when interests are set', () {
        final prefs = BusinessPatronPreferences(
          preferredInterests: ['Food'],
        );
        expect(prefs.isEmpty, isFalse);
      });

      test('should return false when spending level is set', () {
        final prefs = BusinessPatronPreferences(
          preferredSpendingLevel: SpendingLevel.midRange,
        );
        expect(prefs.isEmpty, isFalse);
      });
    });

    group('getSummary', () {
      test('should return "No patron preferences set" for empty preferences', () {
        final prefs = BusinessPatronPreferences();
        expect(prefs.getSummary(), equals('No patron preferences set'));
      });

      test('should include age range in summary', () {
        final prefs = BusinessPatronPreferences(
          preferredAgeRange: AgeRange(minAge: 21, maxAge: 65),
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Age: 21-65'));
      });

      test('should include interests in summary', () {
        final prefs = BusinessPatronPreferences(
          preferredInterests: ['Food', 'Music', 'Art'],
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Interests: Food, Music, Art'));
      });

      test('should include spending level in summary', () {
        final prefs = BusinessPatronPreferences(
          preferredSpendingLevel: SpendingLevel.premium,
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Spending: Premium'));
      });

      test('should include vibe preferences in summary', () {
        final prefs = BusinessPatronPreferences(
          preferredVibePreferences: ['Casual', 'Trendy', 'Cozy'],
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Vibe: Casual, Trendy'));
      });

      test('should include all fields in summary', () {
        final prefs = BusinessPatronPreferences(
          preferredAgeRange: AgeRange(minAge: 21),
          preferredInterests: ['Food'],
          preferredSpendingLevel: SpendingLevel.midRange,
          preferredVibePreferences: ['Casual'],
        );
        final summary = prefs.getSummary();
        expect(summary, contains('Age:'));
        expect(summary, contains('Interests:'));
        expect(summary, contains('Spending:'));
        expect(summary, contains('Vibe:'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final ageRange = AgeRange(minAge: 21, maxAge: 65);
        final prefs = BusinessPatronPreferences(
          preferredAgeRange: ageRange,
          preferredLanguages: ['English'],
          preferredInterests: ['Food'],
          preferredSpendingLevel: SpendingLevel.midRange,
          preferLoyalCustomers: true,
          aiMatchingCriteria: {'custom': 'value'},
        );

        final json = prefs.toJson();

        expect(json['preferredAgeRange'], isNotNull);
        expect(json['preferredLanguages'], equals(['English']));
        expect(json['preferredInterests'], equals(['Food']));
        expect(json['preferredSpendingLevel'], equals('midRange'));
        expect(json['preferLoyalCustomers'], isTrue);
        expect(json['aiMatchingCriteria'], equals({'custom': 'value'}));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'preferredAgeRange': {'minAge': 21, 'maxAge': 65},
          'preferredLanguages': ['English', 'Spanish'],
          'preferredLocations': ['NYC'],
          'preferredInterests': ['Food', 'Music'],
          'preferredLifestyleTraits': ['Health-conscious'],
          'preferredActivities': ['Dining'],
          'preferredPersonalityTraits': ['Outgoing'],
          'preferredSocialStyles': ['Group-oriented'],
          'preferredVibePreferences': ['Casual'],
          'preferredSpendingLevel': 'midRange',
          'preferredVisitFrequency': ['Regular'],
          'preferLoyalCustomers': true,
          'preferNewCustomers': true,
          'preferredExpertiseLevels': ['Intermediate'],
          'preferEducatedPatrons': true,
          'preferredKnowledgeAreas': ['Coffee'],
          'preferCommunityMembers': true,
          'preferredCommunities': ['community-1'],
          'preferLocalPatrons': true,
          'preferTourists': true,
          'preferredVisitTimes': ['Evening'],
          'preferredDaysOfWeek': ['Weekends'],
          'preferAgeVerified': true,
          'preferPetOwners': true,
          'preferAccessibilityNeeds': true,
          'preferredSpecialNeeds': ['Wheelchair accessible'],
          'aiMatchingCriteria': {'custom': 'value'},
          'aiKeywords': ['foodie'],
          'aiMatchingPrompt': 'Find food enthusiasts',
          'excludedInterests': ['Sports'],
          'excludedPersonalityTraits': ['Aggressive'],
          'excludedLocations': ['Suburbs'],
        };

        final prefs = BusinessPatronPreferences.fromJson(json);

        expect(prefs.preferredAgeRange?.minAge, equals(21));
        expect(prefs.preferredAgeRange?.maxAge, equals(65));
        expect(prefs.preferredLanguages, equals(['English', 'Spanish']));
        expect(prefs.preferredLocations, equals(['NYC']));
        expect(prefs.preferredInterests, equals(['Food', 'Music']));
        expect(prefs.preferredLifestyleTraits, equals(['Health-conscious']));
        expect(prefs.preferredActivities, equals(['Dining']));
        expect(prefs.preferredPersonalityTraits, equals(['Outgoing']));
        expect(prefs.preferredSocialStyles, equals(['Group-oriented']));
        expect(prefs.preferredVibePreferences, equals(['Casual']));
        expect(prefs.preferredSpendingLevel, equals(SpendingLevel.midRange));
        expect(prefs.preferredVisitFrequency, equals(['Regular']));
        expect(prefs.preferLoyalCustomers, isTrue);
        expect(prefs.preferNewCustomers, isTrue);
        expect(prefs.preferredExpertiseLevels, equals(['Intermediate']));
        expect(prefs.preferEducatedPatrons, isTrue);
        expect(prefs.preferredKnowledgeAreas, equals(['Coffee']));
        expect(prefs.preferCommunityMembers, isTrue);
        expect(prefs.preferredCommunities, equals(['community-1']));
        expect(prefs.preferLocalPatrons, isTrue);
        expect(prefs.preferTourists, isTrue);
        expect(prefs.preferredVisitTimes, equals(['Evening']));
        expect(prefs.preferredDaysOfWeek, equals(['Weekends']));
        expect(prefs.preferAgeVerified, isTrue);
        expect(prefs.preferPetOwners, isTrue);
        expect(prefs.preferAccessibilityNeeds, isTrue);
        expect(prefs.preferredSpecialNeeds, equals(['Wheelchair accessible']));
        expect(prefs.aiMatchingCriteria, equals({'custom': 'value'}));
        expect(prefs.aiKeywords, equals(['foodie']));
        expect(prefs.aiMatchingPrompt, equals('Find food enthusiasts'));
        expect(prefs.excludedInterests, equals(['Sports']));
        expect(prefs.excludedPersonalityTraits, equals(['Aggressive']));
        expect(prefs.excludedLocations, equals(['Suburbs']));
      });

      test('should handle null optional fields in JSON', () {
        final json = <String, dynamic>{};

        final prefs = BusinessPatronPreferences.fromJson(json);

        expect(prefs.preferredAgeRange, isNull);
        expect(prefs.preferredLanguages, isNull);
        expect(prefs.preferredInterests, isNull);
        expect(prefs.preferredSpendingLevel, isNull);
        expect(prefs.aiMatchingCriteria, isEmpty);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = BusinessPatronPreferences(
          preferredInterests: ['Food'],
          preferredSpendingLevel: SpendingLevel.budget,
        );

        final updated = original.copyWith(
          preferredInterests: ['Music'],
          preferredSpendingLevel: SpendingLevel.premium,
        );

        expect(updated.preferredInterests, equals(['Music'])); // Changed
        expect(updated.preferredSpendingLevel, equals(SpendingLevel.premium)); // Changed
        expect(updated.preferredLanguages, isNull); // Unchanged
      });

      test('should create copy with null fields', () {
        final original = BusinessPatronPreferences(
          preferredInterests: ['Food'],
        );

        // Note: copyWith doesn't support null values - passing null keeps original value
        // This is standard Dart copyWith behavior using ?? operator
        final updated = original.copyWith(preferredInterests: null);

        expect(updated.preferredInterests, equals(['Food'])); // Keeps original value
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final prefs1 = BusinessPatronPreferences(
          preferredInterests: ['Food'],
          preferredSpendingLevel: SpendingLevel.midRange,
        );

        final prefs2 = BusinessPatronPreferences(
          preferredInterests: ['Food'],
          preferredSpendingLevel: SpendingLevel.midRange,
        );

        expect(prefs1, equals(prefs2));
      });

      test('should not be equal when properties differ', () {
        final prefs1 = BusinessPatronPreferences(
          preferredInterests: ['Food'],
        );

        final prefs2 = BusinessPatronPreferences(
          preferredInterests: ['Music'], // Different
        );

        expect(prefs1, isNot(equals(prefs2)));
      });
    });
  });
}


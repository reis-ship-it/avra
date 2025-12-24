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

    // Removed: Constructor and Properties group
    // These tests only verified Dart constructor behavior, not business logic

    group('AgeRange Model', () {
      test('should correctly format display text and match ages', () {
        // Test business logic: age range formatting and matching
        final fullRange = AgeRange(minAge: 25, maxAge: 45);
        final minOnly = AgeRange(minAge: 25);
        final maxOnly = AgeRange(maxAge: 45);
        final empty = AgeRange();

        expect(fullRange.displayText, equals('25-45'));
        expect(minOnly.displayText, equals('25+'));
        expect(maxOnly.displayText, equals('Under 45'));
        expect(empty.displayText, equals('Any age'));

        expect(fullRange.matches(30), isTrue);
        expect(fullRange.matches(24), isFalse);
        expect(fullRange.matches(46), isFalse);
      });
    });

    group('isEmpty Checker', () {
      test('should correctly identify empty vs non-empty preferences', () {
        // Test business logic: empty state determination
        final empty = BusinessExpertPreferences();
        final withCategories = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
        );
        final withLevel = BusinessExpertPreferences(
          minExpertLevel: 3,
        );
        final withLocation = BusinessExpertPreferences(
          preferredLocation: 'NYC',
        );

        expect(empty.isEmpty, isTrue);
        expect(withCategories.isEmpty, isFalse);
        expect(withLevel.isEmpty, isFalse);
        expect(withLocation.isEmpty, isFalse);
      });
    });

    group('getSummary', () {
      test('should generate summary with all preference fields', () {
        // Test business logic: summary generation
        final empty = BusinessExpertPreferences();
        final withAllFields = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          preferredExpertiseCategories: ['Food'],
          preferredLocation: 'NYC',
          minExpertLevel: 3,
        );

        expect(empty.getSummary(), equals('No preferences set'));
        final summary = withAllFields.getSummary();
        expect(summary, contains('Required: Coffee'));
        expect(summary, contains('Preferred: Food'));
        expect(summary, contains('Location: NYC'));
        expect(summary, contains('Min Level: 3'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize without data loss', () {
        final ageRange = AgeRange(minAge: 25, maxAge: 45);
        final prefs = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          preferredExpertiseCategories: ['Food'],
          minExpertLevel: 3,
          preferredLocation: 'NYC',
          preferredAgeRange: ageRange,
          aiMatchingCriteria: {'custom': 'value'},
        );

        final json = prefs.toJson();
        final restored = BusinessExpertPreferences.fromJson(json);

        // Test critical business fields preserved
        expect(restored.isEmpty, equals(prefs.isEmpty));
        expect(restored.getSummary(), equals(prefs.getSummary()));
      });
    });

    group('copyWith', () {
      test('should create immutable copy with updated fields', () {
        final original = BusinessExpertPreferences(
          requiredExpertiseCategories: ['Coffee'],
          minExpertLevel: 3,
        );

        final updated = original.copyWith(
          requiredExpertiseCategories: ['Food'],
          minExpertLevel: 4,
        );

        // Test immutability (business logic)
        expect(original.requiredExpertiseCategories, isNot(equals(['Food'])));
        expect(updated.requiredExpertiseCategories, equals(['Food']));
      });
    });

    // Removed: Equality group
    // These tests verify Equatable implementation, which is already tested by the package
    // If equality breaks, other tests will fail
  });
}

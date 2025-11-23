import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/expertise_progress.dart';
import 'package:spots/core/models/expertise_level.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for ExpertiseProgress model
/// Tests progress tracking, JSON serialization, and helper methods
void main() {
  group('ExpertiseProgress Model Tests', () {
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create progress with required fields', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        expect(progress.category, equals('Coffee'));
        expect(progress.currentLevel, equals(ExpertiseLevel.local));
        expect(progress.progressPercentage, equals(50.0));
        expect(progress.lastUpdated, equals(testDate));
        
        // Test default values
        expect(progress.location, isNull);
        expect(progress.nextLevel, isNull);
        expect(progress.nextSteps, isEmpty);
        expect(progress.contributionBreakdown, isEmpty);
        expect(progress.totalContributions, equals(0));
        expect(progress.requiredContributions, equals(0));
      });

      test('should create progress with all fields', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          location: 'Brooklyn',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 75.5,
          nextSteps: ['Create 2 more lists', 'Get 5 more respects'],
          contributionBreakdown: {'lists': 3, 'reviews': 5},
          totalContributions: 8,
          requiredContributions: 10,
          lastUpdated: testDate,
        );

        expect(progress.location, equals('Brooklyn'));
        expect(progress.nextLevel, equals(ExpertiseLevel.city));
        expect(progress.progressPercentage, equals(75.5));
        expect(progress.nextSteps, equals(['Create 2 more lists', 'Get 5 more respects']));
        expect(progress.contributionBreakdown, equals({'lists': 3, 'reviews': 5}));
        expect(progress.totalContributions, equals(8));
        expect(progress.requiredContributions, equals(10));
      });
    });

    group('empty Factory', () {
      test('should create empty progress with defaults', () {
        final progress = ExpertiseProgress.empty(
          category: 'Coffee',
          location: 'Brooklyn',
        );

        expect(progress.category, equals('Coffee'));
        expect(progress.location, equals('Brooklyn'));
        expect(progress.currentLevel, equals(ExpertiseLevel.local));
        expect(progress.nextLevel, equals(ExpertiseLevel.city));
        expect(progress.progressPercentage, equals(0.0));
        expect(progress.nextSteps, isNotEmpty);
        expect(progress.contributionBreakdown, isEmpty);
        expect(progress.totalContributions, equals(0));
        expect(progress.requiredContributions, equals(10));
      });

      test('should create empty progress without location', () {
        final progress = ExpertiseProgress.empty(category: 'Coffee');

        expect(progress.category, equals('Coffee'));
        expect(progress.location, isNull);
        expect(progress.nextSteps, contains('Create your first list in this category'));
      });
    });

    group('Helper Methods', () {
      test('getProgressDescription should show highest level message when nextLevel is null', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.universal,
          progressPercentage: 100.0,
          lastUpdated: testDate,
        );

        expect(progress.getProgressDescription(), contains('highest level'));
      });

      test('getProgressDescription should show ready to advance message', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 100.0,
          totalContributions: 10,
          requiredContributions: 10,
          lastUpdated: testDate,
        );

        expect(progress.getProgressDescription(), contains('Ready to advance'));
        expect(progress.getProgressDescription(), contains('City Level'));
      });

      test('getProgressDescription should show remaining contributions', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 50.0,
          totalContributions: 5,
          requiredContributions: 10,
          lastUpdated: testDate,
        );

        final description = progress.getProgressDescription();
        expect(description, contains('5 more'));
        expect(description, contains('contributions'));
        expect(description, contains('City Level'));
      });

      test('getProgressDescription should use singular for 1 contribution', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 90.0,
          totalContributions: 9,
          requiredContributions: 10,
          lastUpdated: testDate,
        );

        expect(progress.getProgressDescription(), contains('1 more contribution'));
      });

      test('getFormattedProgress should format percentage correctly', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 75.5,
          lastUpdated: testDate,
        );

        expect(progress.getFormattedProgress(), contains('76%'));
        expect(progress.getFormattedProgress(), contains('City Level'));
      });

      test('getFormattedProgress should show "highest" when nextLevel is null', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.universal,
          progressPercentage: 100.0,
          lastUpdated: testDate,
        );

        expect(progress.getFormattedProgress(), contains('highest'));
      });

      test('isReadyToAdvance should return true when progress is 100% and nextLevel exists', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 100.0,
          lastUpdated: testDate,
        );

        expect(progress.isReadyToAdvance, isTrue);
      });

      test('isReadyToAdvance should return false when progress is less than 100%', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 99.9,
          lastUpdated: testDate,
        );

        expect(progress.isReadyToAdvance, isFalse);
      });

      test('isReadyToAdvance should return false when nextLevel is null', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.universal,
          progressPercentage: 100.0,
          lastUpdated: testDate,
        );

        expect(progress.isReadyToAdvance, isFalse);
      });

      test('getContributionSummary should format breakdown correctly', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          contributionBreakdown: {
            'lists': 3,
            'reviews': 5,
            'spots': 2,
          },
          lastUpdated: testDate,
        );

        final summary = progress.getContributionSummary();
        expect(summary, contains('3 lists'));
        expect(summary, contains('5 reviews'));
        expect(summary, contains('2 spots'));
      });

      test('getContributionSummary should use singular for single contributions', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          contributionBreakdown: {
            'lists': 1,
            'reviews': 1,
          },
          lastUpdated: testDate,
        );

        final summary = progress.getContributionSummary();
        expect(summary, contains('1 list'));
        expect(summary, contains('1 review'));
      });

      test('getContributionSummary should return "No contributions yet" when empty', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 0.0,
          lastUpdated: testDate,
        );

        expect(progress.getContributionSummary(), equals('No contributions yet'));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final progress = ExpertiseProgress(
          category: 'Coffee',
          location: 'Brooklyn',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 75.5,
          nextSteps: ['Create 2 more lists'],
          contributionBreakdown: {'lists': 3},
          totalContributions: 8,
          requiredContributions: 10,
          lastUpdated: testDate,
        );

        final json = progress.toJson();

        expect(json['category'], equals('Coffee'));
        expect(json['location'], equals('Brooklyn'));
        expect(json['currentLevel'], equals('local'));
        expect(json['nextLevel'], equals('city'));
        expect(json['progressPercentage'], equals(75.5));
        expect(json['nextSteps'], equals(['Create 2 more lists']));
        expect(json['contributionBreakdown'], equals({'lists': 3}));
        expect(json['totalContributions'], equals(8));
        expect(json['requiredContributions'], equals(10));
        expect(json['lastUpdated'], equals(testDate.toIso8601String()));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'category': 'Coffee',
          'location': 'Brooklyn',
          'currentLevel': 'local',
          'nextLevel': 'city',
          'progressPercentage': 75.5,
          'nextSteps': ['Create 2 more lists'],
          'contributionBreakdown': {'lists': 3, 'reviews': 5},
          'totalContributions': 8,
          'requiredContributions': 10,
          'lastUpdated': testDate.toIso8601String(),
        };

        final progress = ExpertiseProgress.fromJson(json);

        expect(progress.category, equals('Coffee'));
        expect(progress.location, equals('Brooklyn'));
        expect(progress.currentLevel, equals(ExpertiseLevel.local));
        expect(progress.nextLevel, equals(ExpertiseLevel.city));
        expect(progress.progressPercentage, equals(75.5));
        expect(progress.nextSteps, equals(['Create 2 more lists']));
        expect(progress.contributionBreakdown, equals({'lists': 3, 'reviews': 5}));
        expect(progress.totalContributions, equals(8));
        expect(progress.requiredContributions, equals(10));
        expect(progress.lastUpdated, equals(testDate));
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'category': 'Coffee',
          'currentLevel': 'local',
          'progressPercentage': 50.0,
          'lastUpdated': testDate.toIso8601String(),
        };

        final progress = ExpertiseProgress.fromJson(json);

        expect(progress.location, isNull);
        expect(progress.nextLevel, isNull);
        expect(progress.nextSteps, isEmpty);
        expect(progress.contributionBreakdown, isEmpty);
        expect(progress.totalContributions, equals(0));
        expect(progress.requiredContributions, equals(0));
      });

      test('should default to local level for invalid level in JSON', () {
        final json = {
          'category': 'Coffee',
          'currentLevel': 'invalid',
          'progressPercentage': 50.0,
          'lastUpdated': testDate.toIso8601String(),
        };

        final progress = ExpertiseProgress.fromJson(json);

        expect(progress.currentLevel, equals(ExpertiseLevel.local));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        final updated = original.copyWith(
          progressPercentage: 75.0,
          nextLevel: ExpertiseLevel.city,
        );

        expect(updated.category, equals('Coffee')); // Unchanged
        expect(updated.progressPercentage, equals(75.0)); // Changed
        expect(updated.nextLevel, equals(ExpertiseLevel.city)); // Changed
        expect(updated.currentLevel, equals(ExpertiseLevel.local)); // Unchanged
      });

      test('should create copy with null fields', () {
        final original = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          nextLevel: ExpertiseLevel.city,
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        // Note: copyWith doesn't support null values - passing null keeps original value
        // This is standard Dart copyWith behavior using ?? operator
        final updated = original.copyWith(nextLevel: null);

        expect(updated.nextLevel, equals(ExpertiseLevel.city)); // Keeps original value
        expect(updated.category, equals('Coffee')); // Unchanged
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final progress1 = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        final progress2 = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        expect(progress1, equals(progress2));
      });

      test('should not be equal when properties differ', () {
        final progress1 = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.local,
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        final progress2 = ExpertiseProgress(
          category: 'Coffee',
          currentLevel: ExpertiseLevel.city, // Different level
          progressPercentage: 50.0,
          lastUpdated: testDate,
        );

        expect(progress1, isNot(equals(progress2)));
      });
    });
  });
}


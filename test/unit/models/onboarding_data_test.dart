/// SPOTS OnboardingData Model Tests
/// Date: December 15, 2025
/// Purpose: Test OnboardingData model functionality
/// 
/// Test Coverage:
/// - JSON Serialization: toJson and fromJson
/// - Validation: isValid property
/// - CopyWith: Creating modified copies
/// - AgentId Format: Privacy protection validation
/// - Edge Cases: Null values, empty collections, invalid data
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:avrai/core/models/onboarding_data.dart';

void main() {
  group('OnboardingData Model Tests', () {
    late DateTime testDate;
    const String testAgentId = 'agent_abc123def456ghi789jkl012mno345pqr678';

    setUp(() {
      testDate = DateTime.now();
    });

    group('Constructor and Properties', () {
      test('should create OnboardingData with all required fields', () {
        final data = OnboardingData(
          agentId: testAgentId,
          age: 28,
          birthday: DateTime(1995, 1, 1),
          homebase: 'San Francisco, CA',
          favoritePlaces: ['Golden Gate Park', 'Mission District'],
          preferences: {
            'Food & Drink': ['Coffee', 'Craft Beer'],
            'Activities': ['Hiking', 'Live Music'],
          },
          baselineLists: ['My Favorites'],
          respectedFriends: ['friend1', 'friend2'],
          socialMediaConnected: {'google': true, 'instagram': false},
          completedAt: testDate,
        );

        expect(data.agentId, equals(testAgentId));
        expect(data.age, equals(28));
        expect(data.homebase, equals('San Francisco, CA'));
        expect(data.favoritePlaces.length, equals(2));
        expect(data.preferences.length, equals(2));
        expect(data.socialMediaConnected['google'], isTrue);
      });

      test('should create OnboardingData with minimal required fields', () {
        final data = OnboardingData(
          agentId: testAgentId,
          completedAt: testDate,
        );

        expect(data.agentId, equals(testAgentId));
        expect(data.age, isNull);
        expect(data.homebase, isNull);
        expect(data.favoritePlaces, isEmpty);
        expect(data.preferences, isEmpty);
      });

      test('should use default empty collections when not provided', () {
        final data = OnboardingData(
          agentId: testAgentId,
          completedAt: testDate,
        );

        expect(data.favoritePlaces, isEmpty);
        expect(data.preferences, isEmpty);
        expect(data.baselineLists, isEmpty);
        expect(data.respectedFriends, isEmpty);
        expect(data.socialMediaConnected, isEmpty);
      });
    });

    group('JSON Serialization', () {
      test('should serialize OnboardingData to JSON correctly', () {
        final data = OnboardingData(
          agentId: testAgentId,
          age: 28,
          birthday: DateTime(1995, 1, 1),
          homebase: 'San Francisco, CA',
          favoritePlaces: ['Golden Gate Park'],
          preferences: {'Food & Drink': ['Coffee']},
          baselineLists: ['My Favorites'],
          respectedFriends: ['friend1'],
          socialMediaConnected: {'google': true},
          completedAt: testDate,
        );

        final json = data.toJson();

        expect(json['agentId'], equals(testAgentId));
        expect(json['age'], equals(28));
        expect(json['birthday'], equals('1995-01-01T00:00:00.000'));
        expect(json['homebase'], equals('San Francisco, CA'));
        expect(json['favoritePlaces'], isA<List>());
        expect(json['preferences'], isA<Map>());
        expect(json['completedAt'], equals(testDate.toIso8601String()));
      });

      test('should deserialize JSON to OnboardingData correctly', () {
        final json = {
          'agentId': testAgentId,
          'age': 28,
          'birthday': '1995-01-01T00:00:00.000',
          'homebase': 'San Francisco, CA',
          'favoritePlaces': ['Golden Gate Park'],
          'preferences': {'Food & Drink': ['Coffee']},
          'baselineLists': ['My Favorites'],
          'respectedFriends': ['friend1'],
          'socialMediaConnected': {'google': true},
          'completedAt': testDate.toIso8601String(),
        };

        final data = OnboardingData.fromJson(json);

        expect(data.agentId, equals(testAgentId));
        expect(data.age, equals(28));
        expect(data.birthday, equals(DateTime(1995, 1, 1)));
        expect(data.homebase, equals('San Francisco, CA'));
        expect(data.favoritePlaces.length, equals(1));
        expect(data.preferences.length, equals(1));
      });

      test('should handle null values in JSON correctly', () {
        final json = {
          'agentId': testAgentId,
          'completedAt': testDate.toIso8601String(),
        };

        final data = OnboardingData.fromJson(json);

        expect(data.age, isNull);
        expect(data.birthday, isNull);
        expect(data.homebase, isNull);
      });

      test('should handle missing collections in JSON with empty defaults', () {
        final json = {
          'agentId': testAgentId,
          'completedAt': testDate.toIso8601String(),
        };

        final data = OnboardingData.fromJson(json);

        expect(data.favoritePlaces, isEmpty);
        expect(data.preferences, isEmpty);
        expect(data.baselineLists, isEmpty);
        expect(data.respectedFriends, isEmpty);
        expect(data.socialMediaConnected, isEmpty);
      });

      test('should round-trip serialize and deserialize correctly', () {
        final original = OnboardingData(
          agentId: testAgentId,
          age: 28,
          birthday: DateTime(1995, 1, 1),
          homebase: 'San Francisco, CA',
          favoritePlaces: ['Golden Gate Park'],
          preferences: {'Food & Drink': ['Coffee']},
          baselineLists: ['My Favorites'],
          respectedFriends: ['friend1'],
          socialMediaConnected: {'google': true},
          completedAt: testDate,
        );

        final json = original.toJson();
        final restored = OnboardingData.fromJson(json);

        expect(restored.agentId, equals(original.agentId));
        expect(restored.age, equals(original.age));
        expect(restored.birthday, equals(original.birthday));
        expect(restored.homebase, equals(original.homebase));
        expect(restored.favoritePlaces, equals(original.favoritePlaces));
        expect(restored.preferences, equals(original.preferences));
      });
    });

    group('Validation', () {
      test('should validate OnboardingData with valid agentId format', () {
        final data = OnboardingData(
          agentId: testAgentId,
          completedAt: testDate,
        );

        expect(data.isValid, isTrue);
      });

      test('should invalidate OnboardingData with empty agentId', () {
        final data = OnboardingData(
          agentId: '',
          completedAt: testDate,
        );

        expect(data.isValid, isFalse);
      });

      test('should invalidate OnboardingData with agentId not starting with agent_', () {
        final data = OnboardingData(
          agentId: 'user_123',
          completedAt: testDate,
        );

        expect(data.isValid, isFalse);
      });

      test('should invalidate OnboardingData with future completedAt date', () {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        final data = OnboardingData(
          agentId: testAgentId,
          completedAt: futureDate,
        );

        expect(data.isValid, isFalse);
      });

      test('should validate OnboardingData with completedAt one day in future (tolerance)', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final data = OnboardingData(
          agentId: testAgentId,
          completedAt: tomorrow,
        );

        expect(data.isValid, isTrue);
      });

      test('should invalidate OnboardingData with age less than 13', () {
        final data = OnboardingData(
          agentId: testAgentId,
          age: 12,
          completedAt: testDate,
        );

        expect(data.isValid, isFalse);
      });

      test('should invalidate OnboardingData with age greater than 120', () {
        final data = OnboardingData(
          agentId: testAgentId,
          age: 121,
          completedAt: testDate,
        );

        expect(data.isValid, isFalse);
      });

      test('should validate OnboardingData with age between 13 and 120', () {
        final data = OnboardingData(
          agentId: testAgentId,
          age: 28,
          completedAt: testDate,
        );

        expect(data.isValid, isTrue);
      });

      test('should invalidate OnboardingData with future birthday', () {
        final futureBirthday = DateTime.now().add(const Duration(days: 1));
        final data = OnboardingData(
          agentId: testAgentId,
          birthday: futureBirthday,
          completedAt: testDate,
        );

        expect(data.isValid, isFalse);
      });

      test('should validate OnboardingData with past birthday', () {
        final pastBirthday = DateTime(1995, 1, 1);
        final data = OnboardingData(
          agentId: testAgentId,
          birthday: pastBirthday,
          completedAt: testDate,
        );

        expect(data.isValid, isTrue);
      });
    });

    group('CopyWith', () {
      test('should create copy with updated fields', () {
        final original = OnboardingData(
          agentId: testAgentId,
          age: 28,
          homebase: 'San Francisco, CA',
          completedAt: testDate,
        );

        final updated = original.copyWith(
          age: 29,
          homebase: 'New York, NY',
        );

        expect(updated.agentId, equals(original.agentId));
        expect(updated.age, equals(29));
        expect(updated.homebase, equals('New York, NY'));
        expect(updated.completedAt, equals(original.completedAt));
      });

      test('should create copy with null homebase when explicitly set', () {
        final original = OnboardingData(
          agentId: testAgentId,
          homebase: 'San Francisco, CA',
          completedAt: testDate,
        );

        final updated = original.copyWith(homebase: null);

        expect(updated.homebase, isNull);
      });

      test('should preserve original values when copyWith fields not provided', () {
        final original = OnboardingData(
          agentId: testAgentId,
          age: 28,
          homebase: 'San Francisco, CA',
          completedAt: testDate,
        );

        final copy = original.copyWith();

        expect(copy.agentId, equals(original.agentId));
        expect(copy.age, equals(original.age));
        expect(copy.homebase, equals(original.homebase));
        expect(copy.completedAt, equals(original.completedAt));
      });
    });

    group('toAgentInitializationMap', () {
      test('should convert OnboardingData to agent initialization map', () {
        final data = OnboardingData(
          agentId: testAgentId,
          age: 28,
          birthday: DateTime(1995, 1, 1),
          homebase: 'San Francisco, CA',
          favoritePlaces: ['Golden Gate Park'],
          preferences: {'Food & Drink': ['Coffee']},
          baselineLists: ['My Favorites'],
          respectedFriends: ['friend1'],
          socialMediaConnected: {'google': true},
          completedAt: testDate,
        );

        final map = data.toAgentInitializationMap();

        expect(map['age'], equals(28));
        expect(map['homebase'], equals('San Francisco, CA'));
        expect(map['favoritePlaces'], isA<List>());
        expect(map['preferences'], isA<Map>());
        expect(map, isNot(contains('agentId'))); // agentId should not be in map
        expect(map, isNot(contains('completedAt'))); // completedAt should not be in map
      });
    });

    group('Equality and HashCode', () {
      test('should consider two OnboardingData equal with same values', () {
        final data1 = OnboardingData(
          agentId: testAgentId,
          age: 28,
          homebase: 'San Francisco, CA',
          completedAt: testDate,
        );

        final data2 = OnboardingData(
          agentId: testAgentId,
          age: 28,
          homebase: 'San Francisco, CA',
          completedAt: testDate,
        );

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('should consider two OnboardingData different with different agentId', () {
        final data1 = OnboardingData(
          agentId: testAgentId,
          completedAt: testDate,
        );

        final data2 = OnboardingData(
          agentId: 'agent_different123',
          completedAt: testDate,
        );

        expect(data1, isNot(equals(data2)));
      });
    });

    group('Edge Cases', () {
      test('should handle very long favoritePlaces list', () {
        final longList = List.generate(100, (i) => 'Place $i');
        final data = OnboardingData(
          agentId: testAgentId,
          favoritePlaces: longList,
          completedAt: testDate,
        );

        expect(data.favoritePlaces.length, equals(100));
        expect(data.isValid, isTrue);
      });

      test('should handle complex preferences map', () {
        final complexPreferences = {
          'Food & Drink': ['Coffee', 'Craft Beer', 'Wine'],
          'Activities': ['Hiking', 'Live Music', 'Art Galleries'],
          'Outdoor & Nature': ['Parks', 'Beaches', 'Mountains'],
        };

        final data = OnboardingData(
          agentId: testAgentId,
          preferences: complexPreferences,
          completedAt: testDate,
        );

        expect(data.preferences.length, equals(3));
        expect(data.preferences['Food & Drink']?.length, equals(3));
      });

      test('should handle all social media platforms connected', () {
        final allConnected = {
          'google': true,
          'instagram': true,
          'facebook': true,
          'twitter': true,
        };

        final data = OnboardingData(
          agentId: testAgentId,
          socialMediaConnected: allConnected,
          completedAt: testDate,
        );

        expect(data.socialMediaConnected.length, equals(4));
        expect(data.socialMediaConnected.values.every((v) => v == true), isTrue);
      });
    });
  });
}


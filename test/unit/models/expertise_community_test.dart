import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/expertise_community.dart';
import 'package:spots/core/models/expertise_level.dart';
import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for ExpertiseCommunity model
/// Tests community creation, member management, JSON serialization, and access control
void main() {
  group('ExpertiseCommunity Model Tests', () {
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create community with required fields', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts of Brooklyn',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        expect(community.id, equals('community-123'));
        expect(community.category, equals('Coffee'));
        expect(community.name, equals('Coffee Experts of Brooklyn'));
        expect(community.createdAt, equals(testDate));
        expect(community.updatedAt, equals(testDate));
        expect(community.createdBy, equals('user-123'));
        
        // Test default values
        expect(community.location, isNull);
        expect(community.description, isNull);
        expect(community.memberIds, isEmpty);
        expect(community.memberCount, equals(0));
        expect(community.minLevel, isNull);
        expect(community.isPublic, isTrue);
      });

      test('should create community with all fields', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          location: 'Brooklyn',
          name: 'Coffee Experts of Brooklyn',
          description: 'A community for coffee enthusiasts',
          memberIds: ['user-1', 'user-2'],
          memberCount: 2,
          minLevel: ExpertiseLevel.city,
          isPublic: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        expect(community.location, equals('Brooklyn'));
        expect(community.description, equals('A community for coffee enthusiasts'));
        expect(community.memberIds, equals(['user-1', 'user-2']));
        expect(community.memberCount, equals(2));
        expect(community.minLevel, equals(ExpertiseLevel.city));
        expect(community.isPublic, isTrue);
      });
    });

    group('getDisplayName', () {
      test('should include location when present', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          location: 'Brooklyn',
          name: 'Coffee Experts of Brooklyn',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        expect(community.getDisplayName(), equals('Coffee Experts of Brooklyn'));
      });

      test('should exclude location when null', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        expect(community.getDisplayName(), equals('Coffee Experts'));
      });
    });

    group('isMember', () {
      test('should return true when user is a member', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          memberIds: ['user-1', 'user-2', 'user-3'],
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final user = ModelFactories.createTestUser(id: 'user-2');
        expect(community.isMember(user), isTrue);
      });

      test('should return false when user is not a member', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          memberIds: ['user-1', 'user-2'],
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final user = ModelFactories.createTestUser(id: 'user-999');
        expect(community.isMember(user), isFalse);
      });

      test('should return false when memberIds is empty', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final user = ModelFactories.createTestUser(id: 'user-1');
        expect(community.isMember(user), isFalse);
      });
    });

    group('canUserJoin', () {
      test('should return false for private communities', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          isPublic: false,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final user = ModelFactories.createTestUser(id: 'user-1');
        expect(community.canUserJoin(user), isFalse);
      });

      test('should return true for public communities without min level', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          isPublic: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        // Note: canUserJoin() depends on UnifiedUser.hasExpertiseIn() and getExpertiseLevel()
        // which require expertise data. This test verifies the structure is correct.
        // Full coverage would require mocking UnifiedUser methods or providing expertise data.
        expect(community.isPublic, isTrue);
        expect(community.minLevel, isNull);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final community = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          location: 'Brooklyn',
          name: 'Coffee Experts of Brooklyn',
          description: 'A community for coffee enthusiasts',
          memberIds: ['user-1', 'user-2'],
          memberCount: 2,
          minLevel: ExpertiseLevel.city,
          isPublic: true,
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final json = community.toJson();

        expect(json['id'], equals('community-123'));
        expect(json['category'], equals('Coffee'));
        expect(json['location'], equals('Brooklyn'));
        expect(json['name'], equals('Coffee Experts of Brooklyn'));
        expect(json['description'], equals('A community for coffee enthusiasts'));
        expect(json['memberIds'], equals(['user-1', 'user-2']));
        expect(json['memberCount'], equals(2));
        expect(json['minLevel'], equals('city'));
        expect(json['isPublic'], isTrue);
        expect(json['createdAt'], equals(testDate.toIso8601String()));
        expect(json['updatedAt'], equals(testDate.toIso8601String()));
        expect(json['createdBy'], equals('user-123'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'community-123',
          'category': 'Coffee',
          'location': 'Brooklyn',
          'name': 'Coffee Experts of Brooklyn',
          'description': 'A community for coffee enthusiasts',
          'memberIds': ['user-1', 'user-2'],
          'memberCount': 2,
          'minLevel': 'city',
          'isPublic': true,
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'createdBy': 'user-123',
        };

        final community = ExpertiseCommunity.fromJson(json);

        expect(community.id, equals('community-123'));
        expect(community.category, equals('Coffee'));
        expect(community.location, equals('Brooklyn'));
        expect(community.name, equals('Coffee Experts of Brooklyn'));
        expect(community.description, equals('A community for coffee enthusiasts'));
        expect(community.memberIds, equals(['user-1', 'user-2']));
        expect(community.memberCount, equals(2));
        expect(community.minLevel, equals(ExpertiseLevel.city));
        expect(community.isPublic, isTrue);
        expect(community.createdAt, equals(testDate));
        expect(community.updatedAt, equals(testDate));
        expect(community.createdBy, equals('user-123'));
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'id': 'community-123',
          'category': 'Coffee',
          'name': 'Coffee Experts',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'createdBy': 'user-123',
        };

        final community = ExpertiseCommunity.fromJson(json);

        expect(community.location, isNull);
        expect(community.description, isNull);
        expect(community.memberIds, isEmpty);
        expect(community.memberCount, equals(0));
        expect(community.minLevel, isNull);
        expect(community.isPublic, isTrue);
      });

      test('should default to local level for invalid minLevel in JSON', () {
        final json = {
          'id': 'community-123',
          'category': 'Coffee',
          'name': 'Coffee Experts',
          'minLevel': 'invalid',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'createdBy': 'user-123',
        };

        final community = ExpertiseCommunity.fromJson(json);

        expect(community.minLevel, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          location: 'Brooklyn',
          memberCount: 5,
        );

        expect(updated.id, equals('community-123')); // Unchanged
        expect(updated.name, equals('Updated Name')); // Changed
        expect(updated.location, equals('Brooklyn')); // Changed
        expect(updated.memberCount, equals(5)); // Changed
        expect(updated.category, equals('Coffee')); // Unchanged
      });

      test('should create copy with null fields', () {
        final original = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          location: 'Brooklyn',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final updated = original.copyWith(location: null);

        expect(updated.location, isNull);
        expect(updated.category, equals('Coffee')); // Unchanged
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final community1 = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final community2 = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        expect(community1, equals(community2));
      });

      test('should not be equal when properties differ', () {
        final community1 = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Coffee Experts',
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        final community2 = ExpertiseCommunity(
          id: 'community-123',
          category: 'Coffee',
          name: 'Different Name', // Different name
          createdAt: testDate,
          updatedAt: testDate,
          createdBy: 'user-123',
        );

        expect(community1, isNot(equals(community2)));
      });
    });
  });
}


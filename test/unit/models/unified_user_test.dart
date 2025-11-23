import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for UnifiedUser model
/// Tests ALL existing methods and properties as they currently exist
/// Validates role system, age verification, and JSON serialization
void main() {
  group('UnifiedUser Model Tests', () {
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create user with required fields', () {
        final user = UnifiedUser(
          id: 'test-123',
          email: 'test@example.com',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(user.id, equals('test-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.createdAt, equals(testDate));
        expect(user.updatedAt, equals(testDate));
        
        // Test default values
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.location, isNull);
        expect(user.isOnline, isFalse);
        expect(user.hasCompletedOnboarding, isNull);
        expect(user.hasReceivedStarterLists, isNull);
        expect(user.expertise, isNull);
        expect(user.locations, isNull);
        expect(user.hostedEventsCount, isNull);
        expect(user.differentSpotsCount, isNull);
        expect(user.tags, isEmpty);
        expect(user.expertiseMap, isEmpty);
        expect(user.friends, isEmpty);
        expect(user.curatedLists, isEmpty);
        expect(user.collaboratedLists, isEmpty);
        expect(user.followedLists, isEmpty);
        expect(user.primaryRole, equals(UserRole.follower));
        expect(user.isAgeVerified, isFalse);
        expect(user.ageVerificationDate, isNull);
      });

      test('should create user with all optional fields', () {
        final user = UnifiedUser(
          id: 'test-123',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          location: 'New York',
          createdAt: testDate,
          updatedAt: testDate,
          isOnline: true,
          hasCompletedOnboarding: true,
          hasReceivedStarterLists: true,
          expertise: 'Food & Drink',
          locations: ['NYC', 'LA'],
          hostedEventsCount: 5,
          differentSpotsCount: 20,
          tags: ['foodie', 'traveler'],
          expertiseMap: {'restaurants': 'expert', 'bars': 'intermediate'},
          friends: ['friend-1', 'friend-2'],
          curatedLists: ['list-1'],
          collaboratedLists: ['list-2'],
          followedLists: ['list-3'],
          primaryRole: UserRole.curator,
          isAgeVerified: true,
          ageVerificationDate: testDate,
        );

        expect(user.displayName, equals('Test User'));
        expect(user.photoUrl, equals('https://example.com/photo.jpg'));
        expect(user.location, equals('New York'));
        expect(user.isOnline, isTrue);
        expect(user.hasCompletedOnboarding, isTrue);
        expect(user.hasReceivedStarterLists, isTrue);
        expect(user.expertise, equals('Food & Drink'));
        expect(user.locations, equals(['NYC', 'LA']));
        expect(user.hostedEventsCount, equals(5));
        expect(user.differentSpotsCount, equals(20));
        expect(user.tags, equals(['foodie', 'traveler']));
        expect(user.expertiseMap, equals({'restaurants': 'expert', 'bars': 'intermediate'}));
        expect(user.friends, equals(['friend-1', 'friend-2']));
        expect(user.curatedLists, equals(['list-1']));
        expect(user.collaboratedLists, equals(['list-2']));
        expect(user.followedLists, equals(['list-3']));
        expect(user.primaryRole, equals(UserRole.curator));
        expect(user.isAgeVerified, isTrue);
        expect(user.ageVerificationDate, equals(testDate));
      });
    });

    group('Role System Validation', () {
      test('should validate curator role properties', () {
        final curator = ModelFactories.createCuratorUser();
        
        expect(curator.primaryRole, equals(UserRole.curator));
        expect(curator.isCurator, isTrue);
        expect(curator.curatedLists.isNotEmpty, isTrue);
      });

      test('should validate collaborator role properties', () {
        final collaborator = ModelFactories.createCollaboratorUser();
        
        expect(collaborator.primaryRole, equals(UserRole.collaborator));
        expect(collaborator.isCollaborator, isTrue);
        expect(collaborator.collaboratedLists.isNotEmpty, isTrue);
      });

      test('should validate follower role properties', () {
        final follower = ModelFactories.createTestUser(
          primaryRole: UserRole.follower,
          followedLists: ['list-1', 'list-2'],
        );
        
        expect(follower.primaryRole, equals(UserRole.follower));
        expect(follower.isFollower, isTrue);
        expect(follower.followedLists.isNotEmpty, isTrue);
      });

      test('should calculate total list involvement correctly', () {
        final user = ModelFactories.createTestUser(
          curatedLists: ['list-1', 'list-2'],
          collaboratedLists: ['list-3'],
          followedLists: ['list-4', 'list-5', 'list-6'],
        );

        expect(user.totalListInvolvement, equals(6));
      });

      test('should handle user with no list involvement', () {
        final user = ModelFactories.createTestUser();

        expect(user.isCurator, isFalse);
        expect(user.isCollaborator, isFalse);
        expect(user.isFollower, isFalse);
        expect(user.totalListInvolvement, equals(0));
      });
    });

    group('Age Verification Logic', () {
      test('should validate age verification access - verified user', () {
        final verifiedUser = ModelFactories.createAgeVerifiedUser();
        
        expect(verifiedUser.isAgeVerified, isTrue);
        expect(verifiedUser.ageVerificationDate, isNotNull);
        expect(verifiedUser.canAccessAgeRestrictedContent(), isTrue);
      });

      test('should validate age verification access - unverified user', () {
        final unverifiedUser = ModelFactories.createTestUser(isAgeVerified: false);
        
        expect(unverifiedUser.isAgeVerified, isFalse);
        expect(unverifiedUser.ageVerificationDate, isNull);
        expect(unverifiedUser.canAccessAgeRestrictedContent(), isFalse);
      });

      test('should validate edge case - verified but no date', () {
        final user = ModelFactories.createTestUser(
          isAgeVerified: true,
          ageVerificationDate: null,
        );
        
        expect(user.isAgeVerified, isTrue);
        expect(user.ageVerificationDate, isNull);
        expect(user.canAccessAgeRestrictedContent(), isFalse);
      });
    });

    group('JSON Serialization Testing', () {
      test('should serialize to JSON correctly', () {
        final user = ModelFactories.createTestUser(
          displayName: 'Test User',
          isAgeVerified: true,
          ageVerificationDate: testDate,
          tags: ['test', 'user'],
          curatedLists: ['list-1'],
        );

        final json = user.toJson();

        expect(json['id'], equals(user.id));
        expect(json['email'], equals(user.email));
        expect(json['displayName'], equals('Test User'));
        expect(json['createdAt'], equals(user.createdAt.toIso8601String()));
        expect(json['updatedAt'], equals(user.updatedAt.toIso8601String()));
        expect(json['isAgeVerified'], isTrue);
        expect(json['ageVerificationDate'], equals(testDate.toIso8601String()));
        expect(json['tags'], equals(['test', 'user']));
        expect(json['curatedLists'], equals(['list-1']));
        expect(json['primaryRole'], equals('follower'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test-123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'isAgeVerified': true,
          'ageVerificationDate': testDate.toIso8601String(),
          'tags': ['test', 'user'],
          'curatedLists': ['list-1'],
          'primaryRole': 'curator',
        };

        final user = UnifiedUser.fromJson(json);

        expect(user.id, equals('test-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.createdAt, equals(testDate));
        expect(user.updatedAt, equals(testDate));
        expect(user.isAgeVerified, isTrue);
        expect(user.ageVerificationDate, equals(testDate));
        expect(user.tags, equals(['test', 'user']));
        expect(user.curatedLists, equals(['list-1']));
        expect(user.primaryRole, equals(UserRole.curator));
      });

      test('should handle JSON roundtrip correctly', () {
        final originalUser = ModelFactories.createCuratorUser();
        
        TestHelpers.validateJsonRoundtrip(
          originalUser,
          (user) => user.toJson(),
          (json) => UnifiedUser.fromJson(json),
        );
      });

      test('should handle missing fields in JSON gracefully', () {
        final minimalJson = {
          'id': 'test-123',
          'email': 'test@example.com',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        final user = UnifiedUser.fromJson(minimalJson);

        expect(user.id, equals('test-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.isOnline, isFalse);
        expect(user.tags, isEmpty);
        expect(user.primaryRole, equals(UserRole.follower));
        expect(user.isAgeVerified, isFalse);
      });

      test('should handle invalid role in JSON gracefully', () {
        final json = {
          'id': 'test-123',
          'email': 'test@example.com',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'primaryRole': 'invalid_role',
        };

        final user = UnifiedUser.fromJson(json);
        expect(user.primaryRole, equals(UserRole.follower));
      });
    });

    group('Map Serialization Testing', () {
      test('should serialize to Map correctly', () {
        final user = ModelFactories.createTestUser();
        final map = user.toMap();
        
        expect(map['id'], equals(user.id));
        expect(map['email'], equals(user.email));
        expect(map['primaryRole'], equals(user.primaryRole.name));
      });

      test('should deserialize from Map correctly', () {
        final map = {
          'id': 'test-123',
          'email': 'test@example.com',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'primaryRole': 'curator',
        };

        final user = UnifiedUser.fromMap(map);
        
        expect(user.id, equals('test-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.primaryRole, equals(UserRole.curator));
      });
    });

    group('CopyWith Method Testing', () {
      test('should copy user with new values', () {
        final originalUser = ModelFactories.createTestUser();
        final newDate = TestHelpers.createTimestampWithOffset(const Duration(days: 1));
        
        final copiedUser = originalUser.copyWith(
          displayName: 'New Name',
          isOnline: true,
          updatedAt: newDate,
          primaryRole: UserRole.curator,
        );

        expect(copiedUser.id, equals(originalUser.id));
        expect(copiedUser.email, equals(originalUser.email));
        expect(copiedUser.displayName, equals('New Name'));
        expect(copiedUser.isOnline, isTrue);
        expect(copiedUser.updatedAt, equals(newDate));
        expect(copiedUser.primaryRole, equals(UserRole.curator));
        expect(copiedUser.createdAt, equals(originalUser.createdAt));
      });

      test('should copy user without changing original', () {
        final originalUser = ModelFactories.createTestUser();
        final copiedUser = originalUser.copyWith(displayName: 'New Name');

        expect(originalUser.displayName, equals('Test User'));
        expect(copiedUser.displayName, equals('New Name'));
      });
    });

    group('Equatable Implementation', () {
      test('should be equal for identical users', () {
        final user1 = ModelFactories.createTestUser();
        final user2 = ModelFactories.createTestUser();

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal for different users', () {
        final user1 = ModelFactories.createTestUser();
        final user2 = ModelFactories.createTestUser(id: 'different-id');

        expect(user1, isNot(equals(user2)));
      });

      test('should include all properties in props', () {
        final user = ModelFactories.createTestUser();
        final props = user.props;

        // Verify all major properties are included
        expect(props.contains(user.id), isTrue);
        expect(props.contains(user.email), isTrue);
        expect(props.contains(user.primaryRole), isTrue);
        expect(props.contains(user.isAgeVerified), isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty lists properly', () {
        final user = ModelFactories.createTestUser(
          tags: [],
          curatedLists: [],
          collaboratedLists: [],
          followedLists: [],
        );

        expect(user.tags, isEmpty);
        expect(user.totalListInvolvement, equals(0));
        expect(user.isCurator, isFalse);
        expect(user.isCollaborator, isFalse);
        expect(user.isFollower, isFalse);
      });

      test('should handle null optional fields', () {
        final user = UnifiedUser(
          id: 'test',
          email: 'test@example.com',
          createdAt: testDate,
          updatedAt: testDate,
          // All other fields are null/default
        );

        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.expertise, isNull);
        expect(user.canAccessAgeRestrictedContent(), isFalse);
      });
    });
  });

  group('UserRole Enum Tests', () {
    test('should have correct enum values', () {
      expect(UserRole.values.length, equals(3));
      expect(UserRole.values.contains(UserRole.curator), isTrue);
      expect(UserRole.values.contains(UserRole.collaborator), isTrue);
      expect(UserRole.values.contains(UserRole.follower), isTrue);
    });

    test('should have correct descriptions', () {
      expect(UserRole.curator.description, equals('List creator and manager'));
      expect(UserRole.collaborator.description, equals('Can edit spots in lists'));
      expect(UserRole.follower.description, equals('Basic user'));
    });

    test('should have correct short names', () {
      expect(UserRole.curator.shortName, equals('Curator'));
      expect(UserRole.collaborator.shortName, equals('Collaborator'));
      expect(UserRole.follower.shortName, equals('Follower'));
    });
  });
}
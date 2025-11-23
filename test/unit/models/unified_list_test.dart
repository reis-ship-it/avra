import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/unified_list.dart';
import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for UnifiedList model
/// Tests independent node architecture, role-based permissions, and moderation
void main() {
  group('UnifiedList Model Tests', () {
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create list with required fields', () {
        final list = UnifiedList(
          id: 'list-123',
          title: 'Test List',
          category: 'Food',
          createdAt: testDate,
          curatorId: 'curator-123',
        );

        expect(list.id, equals('list-123'));
        expect(list.title, equals('Test List'));
        expect(list.category, equals('Food'));
        expect(list.createdAt, equals(testDate));
        expect(list.curatorId, equals('curator-123'));
        
        // Test default values
        expect(list.description, isNull);
        expect(list.updatedAt, isNull);
        expect(list.lastModified, isNull);
        expect(list.collaboratorIds, isEmpty);
        expect(list.followerIds, isEmpty);
        expect(list.spotIds, isEmpty);
        expect(list.isPublic, isTrue);
        expect(list.isAgeRestricted, isFalse);
        expect(list.permissions, isA<ListPermissions>());
        expect(list.respectCount, equals(0));
        expect(list.viewCount, equals(0));
        expect(list.isStarter, isFalse);
        expect(list.starterType, isNull);
        expect(list.reportCount, equals(0));
        expect(list.isSuspended, isFalse);
        expect(list.suspensionEndDate, isNull);
        expect(list.suspensionReason, isNull);
      });

      test('should create list with all optional fields', () {
        final list = UnifiedList(
          id: 'list-123',
          title: 'Test List',
          description: 'Test Description',
          category: 'Food',
          createdAt: testDate,
          updatedAt: testDate,
          lastModified: testDate,
          curatorId: 'curator-123',
          collaboratorIds: ['collab-1', 'collab-2'],
          followerIds: ['follower-1', 'follower-2', 'follower-3'],
          spotIds: ['spot-1', 'spot-2'],
          isPublic: false,
          isAgeRestricted: true,
          permissions: const ListPermissions(allowCollaborators: false),
          respectCount: 10,
          viewCount: 100,
          isStarter: true,
          starterType: 'beginner',
          reportCount: 2,
          isSuspended: false,
        );

        expect(list.description, equals('Test Description'));
        expect(list.updatedAt, equals(testDate));
        expect(list.lastModified, equals(testDate));
        expect(list.collaboratorIds, equals(['collab-1', 'collab-2']));
        expect(list.followerIds, equals(['follower-1', 'follower-2', 'follower-3']));
        expect(list.spotIds, equals(['spot-1', 'spot-2']));
        expect(list.isPublic, isFalse);
        expect(list.isAgeRestricted, isTrue);
        expect(list.permissions.allowCollaborators, isFalse);
        expect(list.respectCount, equals(10));
        expect(list.viewCount, equals(100));
        expect(list.isStarter, isTrue);
        expect(list.starterType, equals('beginner'));
        expect(list.reportCount, equals(2));
        expect(list.isSuspended, isFalse);
      });
    });

    group('Independent Node Architecture', () {
      test('should validate total user involvement calculation', () {
        final list = ModelFactories.createTestList(
          collaboratorIds: ['user-1', 'user-2'],
          followerIds: ['user-3', 'user-4', 'user-5'],
        );

        // 1 curator + 2 collaborators + 3 followers = 6
        expect(list.totalUserInvolvement, equals(6));
      });

      test('should handle list with only curator', () {
        final list = ModelFactories.createTestList();

        expect(list.totalUserInvolvement, equals(1));
      });

      test('should validate curator relationship', () {
        final list = ModelFactories.createTestList(curatorId: 'curator-123');

        expect(list.isCurator('curator-123'), isTrue);
        expect(list.isCurator('other-user'), isFalse);
      });

      test('should validate collaborator relationships', () {
        final list = ModelFactories.createTestList(
          collaboratorIds: ['collab-1', 'collab-2'],
        );

        expect(list.isCollaborator('collab-1'), isTrue);
        expect(list.isCollaborator('collab-2'), isTrue);
        expect(list.isCollaborator('other-user'), isFalse);
      });

      test('should validate follower relationships', () {
        final list = ModelFactories.createTestList(
          followerIds: ['follower-1', 'follower-2'],
        );

        expect(list.isFollower('follower-1'), isTrue);
        expect(list.isFollower('follower-2'), isTrue);
        expect(list.isFollower('other-user'), isFalse);
      });
    });

    group('Permission System Testing', () {
      test('should validate edit permissions for curator', () {
        final list = ModelFactories.createTestList(curatorId: 'curator-123');

        expect(list.canEdit('curator-123'), isTrue);
      });

      test('should validate edit permissions for collaborator', () {
        final list = ModelFactories.createTestList(
          curatorId: 'curator-123',
          collaboratorIds: ['collab-1'],
        );

        expect(list.canEdit('collab-1'), isTrue);
        expect(list.canEdit('other-user'), isFalse);
      });

      test('should validate delete permissions - curator only', () {
        final list = ModelFactories.createTestList(
          curatorId: 'curator-123',
          collaboratorIds: ['collab-1'],
        );

        expect(list.canDelete('curator-123'), isTrue);
        expect(list.canDelete('collab-1'), isFalse);
        expect(list.canDelete('other-user'), isFalse);
      });

      test('should validate view permissions for public list', () {
        final list = ModelFactories.createTestList(
          curatorId: 'curator-123',
          isPublic: true,
        );

        expect(list.canView('curator-123'), isTrue);
        expect(list.canView('random-user'), isTrue);
      });

      test('should validate view permissions for private list', () {
        final list = ModelFactories.createPrivateList(
          curatorId: 'curator-123',
          collaboratorIds: ['collab-1'],
        );

        expect(list.canView('curator-123'), isTrue);
        expect(list.canView('collab-1'), isTrue);
        expect(list.canView('random-user'), isFalse);
      });

      test('should validate view permissions for followers', () {
        final list = ModelFactories.createTestList(
          curatorId: 'curator-123',
          followerIds: ['follower-1'],
          isPublic: false,
        );

        expect(list.canView('follower-1'), isTrue);
        expect(list.canView('random-user'), isFalse);
      });
    });

    group('Moderation and Reporting System', () {
      test('should validate suspension criteria logic', () {
        final list = UnifiedList(
          id: 'test-list',
          title: 'Test List',
          category: 'General',
          createdAt: testDate,
          curatorId: 'curator-123',
          reportCount: 5,
          respectCount: 3,
        );

        expect(list.meetsSuspensionCriteria, isTrue);
      });

      test('should not meet suspension criteria with insufficient reports', () {
        final list = UnifiedList(
          id: 'test-list',
          title: 'Test List',
          category: 'General',
          createdAt: testDate,
          curatorId: 'curator-123',
          reportCount: 3,
          respectCount: 3,
        );

        expect(list.meetsSuspensionCriteria, isFalse);
      });

      test('should not meet suspension criteria with insufficient respects', () {
        final list = UnifiedList(
          id: 'test-list',
          title: 'Test List',
          category: 'General',
          createdAt: testDate,
          curatorId: 'curator-123',
          reportCount: 5,
          respectCount: 2,
        );

        expect(list.meetsSuspensionCriteria, isFalse);
      });

      test('should validate current suspension status - permanently suspended', () {
        final list = ModelFactories.createSuspendedList(
          suspensionEndDate: null, // Permanent suspension
        );

        expect(list.isCurrentlySuspended, isTrue);
      });

      test('should validate current suspension status - temporary suspension active', () {
        // Create suspension end date in the future (1 day from now)
        final suspensionEndDate = DateTime.now().add(const Duration(days: 1));
        final list = ModelFactories.createSuspendedList(
          suspensionEndDate: suspensionEndDate,
        );

        expect(list.isCurrentlySuspended, isTrue);
      });

      test('should validate current suspension status - suspension expired', () {
        final list = ModelFactories.createSuspendedList(
          suspensionEndDate: TestHelpers.createTimestampWithOffset(const Duration(days: -1)),
        );

        expect(list.isCurrentlySuspended, isFalse);
      });

      test('should validate not suspended', () {
        final list = ModelFactories.createTestList(isSuspended: false);

        expect(list.isCurrentlySuspended, isFalse);
      });
    });

    group('Age Restriction Enforcement', () {
      test('should validate age restricted list properties', () {
        final list = ModelFactories.createAgeRestrictedList();

        expect(list.isAgeRestricted, isTrue);
      });

      test('should validate non-age restricted list properties', () {
        final list = ModelFactories.createTestList(isAgeRestricted: false);

        expect(list.isAgeRestricted, isFalse);
      });
    });

    group('JSON Serialization Testing', () {
      test('should serialize to JSON correctly', () {
        final list = UnifiedList(
          id: 'test-list',
          title: 'Test List',
          description: 'Test Description',
          category: 'General',
          createdAt: testDate,
          curatorId: 'curator-123',
          collaboratorIds: ['collab-1'],
          followerIds: ['follower-1'],
          spotIds: ['spot-1', 'spot-2'],
          isAgeRestricted: true,
        );

        final json = list.toJson();

        expect(json['id'], equals(list.id));
        expect(json['title'], equals('Test List'));
        expect(json['description'], equals('Test Description'));
        expect(json['category'], equals(list.category));
        expect(json['createdAt'], equals(list.createdAt.toIso8601String()));
        expect(json['curatorId'], equals(list.curatorId));
        expect(json['collaboratorIds'], equals(['collab-1']));
        expect(json['followerIds'], equals(['follower-1']));
        expect(json['spotIds'], equals(['spot-1', 'spot-2']));
        expect(json['isAgeRestricted'], isTrue);
        expect(json['permissions'], isA<Map<String, dynamic>>());
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'list-123',
          'title': 'Test List',
          'category': 'Food',
          'createdAt': testDate.toIso8601String(),
          'curatorId': 'curator-123',
          'collaboratorIds': ['collab-1'],
          'followerIds': ['follower-1'],
          'spotIds': ['spot-1'],
          'isAgeRestricted': true,
          'respectCount': 5,
        };

        final list = UnifiedList.fromJson(json);

        expect(list.id, equals('list-123'));
        expect(list.title, equals('Test List'));
        expect(list.category, equals('Food'));
        expect(list.createdAt, equals(testDate));
        expect(list.curatorId, equals('curator-123'));
        expect(list.collaboratorIds, equals(['collab-1']));
        expect(list.followerIds, equals(['follower-1']));
        expect(list.spotIds, equals(['spot-1']));
        expect(list.isAgeRestricted, isTrue);
        expect(list.respectCount, equals(5));
      });

      test('should handle JSON roundtrip correctly', () {
        final originalList = ModelFactories.createTestList(
          collaboratorIds: ['collab-1'],
          followerIds: ['follower-1'],
          spotIds: ['spot-1'],
        );
        
        TestHelpers.validateJsonRoundtrip(
          originalList,
          (list) => list.toJson(),
          (json) => UnifiedList.fromJson(json),
        );
      });

      test('should handle missing fields in JSON gracefully', () {
        final minimalJson = {
          'id': '',
          'title': '',
          'category': 'General',
          'createdAt': testDate.toIso8601String(),
          'curatorId': '',
        };

        final list = UnifiedList.fromJson(minimalJson);

        expect(list.id, equals(''));
        expect(list.title, equals(''));
        expect(list.category, equals('General'));
        expect(list.collaboratorIds, isEmpty);
        expect(list.isPublic, isTrue);
        expect(list.respectCount, equals(0));
      });

      test('should handle alternative field names in JSON', () {
        final json = {
          'id': 'list-123',
          'name': 'Test List', // Alternative to 'title'
          'category': 'Food',
          'createdAt': testDate.toIso8601String(),
          'userId': 'curator-123', // Alternative to 'curatorId'
        };

        final list = UnifiedList.fromJson(json);

        expect(list.title, equals('Test List'));
        expect(list.curatorId, equals('curator-123'));
      });
    });

    group('Map Serialization Testing', () {
      test('should serialize to Map correctly', () {
        final list = ModelFactories.createTestList();
        final map = list.toMap();
        
        expect(map['id'], equals(list.id));
        expect(map['title'], equals(list.title));
        expect(map['curatorId'], equals(list.curatorId));
        expect(map['permissions'], isA<Map<String, dynamic>>());
      });

      test('should deserialize from Map correctly', () {
        final map = {
          'id': 'list-123',
          'title': 'Test List',
          'category': 'Food',
          'createdAt': testDate.toIso8601String(),
          'curatorId': 'curator-123',
        };

        final list = UnifiedList.fromMap(map);
        
        expect(list.id, equals('list-123'));
        expect(list.title, equals('Test List'));
        expect(list.curatorId, equals('curator-123'));
      });
    });

    group('CopyWith Method Testing', () {
      test('should copy list with new values', () {
        final originalList = ModelFactories.createTestList();
        final newDate = TestHelpers.createTimestampWithOffset(const Duration(days: 1));
        
        final copiedList = originalList.copyWith(
          title: 'New Title',
          description: 'New Description',
          lastModified: newDate,
          respectCount: 10,
          isSuspended: true,
        );

        expect(copiedList.id, equals(originalList.id));
        expect(copiedList.curatorId, equals(originalList.curatorId));
        expect(copiedList.title, equals('New Title'));
        expect(copiedList.description, equals('New Description'));
        expect(copiedList.lastModified, equals(newDate));
        expect(copiedList.respectCount, equals(10));
        expect(copiedList.isSuspended, isTrue);
        expect(copiedList.createdAt, equals(originalList.createdAt));
      });

      test('should copy list without changing original', () {
        final originalList = ModelFactories.createTestList();
        final copiedList = originalList.copyWith(title: 'New Title');

        expect(originalList.title, equals('Test List'));
        expect(copiedList.title, equals('New Title'));
      });
    });

    group('Equatable Implementation', () {
      test('should be equal for identical lists', () {
        final list1 = ModelFactories.createTestList();
        final list2 = ModelFactories.createTestList();

        expect(list1, equals(list2));
        expect(list1.hashCode, equals(list2.hashCode));
      });

      test('should not be equal for different lists', () {
        final list1 = ModelFactories.createTestList();
        final list2 = ModelFactories.createTestList(id: 'different-id');

        expect(list1, isNot(equals(list2)));
      });
    });
  });

  group('ListPermissions Model Tests', () {
    test('should create permissions with default values', () {
      const permissions = ListPermissions();

      expect(permissions.allowCollaborators, isTrue);
      expect(permissions.allowPublicViewing, isTrue);
      expect(permissions.requireApproval, isFalse);
      expect(permissions.minRespectsForCollaboration, equals(0));
      expect(permissions.allowAgeRestrictedContent, isFalse);
      expect(permissions.allowReporting, isTrue);
    });

    test('should create permissions with custom values', () {
      const permissions = ListPermissions(
        allowCollaborators: false,
        allowPublicViewing: false,
        requireApproval: true,
        minRespectsForCollaboration: 5,
        allowAgeRestrictedContent: true,
        allowReporting: false,
      );

      expect(permissions.allowCollaborators, isFalse);
      expect(permissions.allowPublicViewing, isFalse);
      expect(permissions.requireApproval, isTrue);
      expect(permissions.minRespectsForCollaboration, equals(5));
      expect(permissions.allowAgeRestrictedContent, isTrue);
      expect(permissions.allowReporting, isFalse);
    });

    test('should serialize permissions to JSON correctly', () {
      const permissions = ListPermissions(
        allowCollaborators: false,
        requireApproval: true,
        minRespectsForCollaboration: 3,
      );

      final json = permissions.toJson();

      expect(json['allowCollaborators'], isFalse);
      expect(json['allowPublicViewing'], isTrue);
      expect(json['requireApproval'], isTrue);
      expect(json['minRespectsForCollaboration'], equals(3));
    });

    test('should deserialize permissions from JSON correctly', () {
      final json = {
        'allowCollaborators': false,
        'requireApproval': true,
        'minRespectsForCollaboration': 5,
      };

      final permissions = ListPermissions.fromJson(json);

      expect(permissions.allowCollaborators, isFalse);
      expect(permissions.requireApproval, isTrue);
      expect(permissions.minRespectsForCollaboration, equals(5));
      expect(permissions.allowPublicViewing, isTrue); // Default value
    });

    test('should copy permissions with new values', () {
      const originalPermissions = ListPermissions();
      
      final copiedPermissions = originalPermissions.copyWith(
        allowCollaborators: false,
        requireApproval: true,
        minRespectsForCollaboration: 10,
      );

      expect(copiedPermissions.allowCollaborators, isFalse);
      expect(copiedPermissions.requireApproval, isTrue);
      expect(copiedPermissions.minRespectsForCollaboration, equals(10));
      expect(copiedPermissions.allowPublicViewing, isTrue); // Unchanged
    });
  });
}
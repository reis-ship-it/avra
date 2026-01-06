import 'package:flutter_test/flutter_test.dart';

import 'package:spots/core/controllers/list_creation_controller.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_database.dart';
import '../../helpers/platform_channel_helper.dart';

/// List Creation Controller Integration Tests
/// 
/// Tests the complete list creation workflow with real service implementations:
/// - List creation with validation
/// - Permission checks
/// - Atomic timestamp usage
/// - Initial spots handling
/// - Error handling
void main() {
  group('ListCreationController Integration Tests', () {
    late ListCreationController controller;
    final DateTime now = DateTime.now();

    setUpAll(() async {
      // Initialize Sembast for tests
      SembastDatabase.useInMemoryForTests();
      await SembastDatabase.database;
      
      // Initialize dependency injection
      await setupTestStorage();
      await di.init();
      
      controller = di.sl<ListCreationController>();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
    });

    group('createList', () {
      test('should successfully create list', () async {
        // Arrange
        final curator = UnifiedUser(
          id: 'curator_${DateTime.now().millisecondsSinceEpoch}',
          email: 'curator@test.com',
          displayName: 'Test Curator',
          createdAt: now,
          updatedAt: now,
        );

        final data = ListFormData(
          title: 'My Test List',
          description: 'A list for testing',
          category: 'General',
          isPublic: true,
          curator: curator,
        );

        // Act
        final result = await controller.createList(
          data: data,
          curator: curator,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.list, isNotNull);
        expect(result.list?.title, equals('My Test List'));
        expect(result.list?.description, equals('A list for testing'));
        expect(result.list?.category, equals('General'));
        expect(result.list?.isPublic, isTrue);
        expect(result.list?.curatorId, equals(curator.id));
        expect(result.list?.spotIds, isEmpty);
      });

      test('should successfully create list with initial spots', () async {
        // Arrange
        final curator = UnifiedUser(
          id: 'curator_${DateTime.now().millisecondsSinceEpoch}',
          email: 'curator2@test.com',
          displayName: 'Test Curator 2',
          createdAt: now,
          updatedAt: now,
        );

        final data = ListFormData(
          title: 'List with Spots',
          description: 'A list with initial spots',
          curator: curator,
        );

        // Act
        final result = await controller.createList(
          data: data,
          curator: curator,
          initialSpotIds: ['spot1', 'spot2', 'spot3'],
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.list, isNotNull);
        expect(result.list?.spotIds, containsAll(['spot1', 'spot2', 'spot3']));
        expect(result.spotsAdded, equals(3));
      });

      test('should return failure for invalid title', () async {
        // Arrange
        final curator = UnifiedUser(
          id: 'curator_${DateTime.now().millisecondsSinceEpoch}',
          email: 'curator3@test.com',
          displayName: 'Test Curator 3',
          createdAt: now,
          updatedAt: now,
        );

        final data = ListFormData(
          title: 'AB', // Too short
          description: 'A test list',
          curator: curator,
        );

        // Act
        final result = await controller.createList(
          data: data,
          curator: curator,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('VALIDATION_ERROR'));
        expect(result.error, anyOf(contains('title'), contains('Title')));
      });

      test('should return failure for empty description', () async {
        // Arrange
        final curator = UnifiedUser(
          id: 'curator_${DateTime.now().millisecondsSinceEpoch}',
          email: 'curator4@test.com',
          displayName: 'Test Curator 4',
          createdAt: now,
          updatedAt: now,
        );

        final data = ListFormData(
          title: 'My List',
          description: '',
          curator: curator,
        );

        // Act
        final result = await controller.createList(
          data: data,
          curator: curator,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('VALIDATION_ERROR'));
        expect(result.error, anyOf(contains('description'), contains('Description')));
      });
    });

    group('validate', () {
      test('should validate input correctly', () {
        // Arrange
        final curator = UnifiedUser(
          id: 'curator_${DateTime.now().millisecondsSinceEpoch}',
          email: 'curator@test.com',
          displayName: 'Test Curator',
          createdAt: now,
          updatedAt: now,
        );

        final validData = ListFormData(
          title: 'My List',
          description: 'A test list',
          curator: curator,
        );

        final invalidData = ListFormData(
          title: '',
          description: 'A test list',
          curator: curator,
        );

        // Act
        final validResult = controller.validate(validData);
        final invalidResult = controller.validate(invalidData);

        // Assert
        expect(validResult.isValid, isTrue);
        expect(invalidResult.isValid, isFalse);
      });
    });
  });
}

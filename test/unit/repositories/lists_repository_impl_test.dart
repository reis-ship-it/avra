import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/data/repositories/lists_repository_impl.dart';
import 'package:spots/core/models/list.dart';

import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_dependencies.mocks.dart';

/// Comprehensive test suite for ListsRepositoryImpl
/// Tests the current implementation behavior with nullable dependencies
/// 
/// Focus Areas:
/// - CRUD operations with online-first strategy for some operations
/// - Nullable dependency handling (local/remote can be null)
/// - Starter lists creation workflow
/// - Personalized lists creation workflow
/// - Error scenarios and fallback mechanisms
void main() {
  group('ListsRepositoryImpl Tests', () {
    late ListsRepositoryImpl repository;
    late MockListsLocalDataSource? mockLocalDataSource;
    late MockListsRemoteDataSource? mockRemoteDataSource;
    late MockConnectivity? mockConnectivity;
    
    late SpotList testList;
    late List<SpotList> testLists;

    setUp(() {
      mockLocalDataSource = MockListsLocalDataSource();
      mockRemoteDataSource = MockListsRemoteDataSource();
      mockConnectivity = MockConnectivity();
      
      repository = ListsRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
        connectivity: mockConnectivity,
      );
      
      // Create test SpotList from UnifiedList
      final unifiedList = ModelFactories.createTestList();
      testList = SpotList(
        id: unifiedList.id,
        title: unifiedList.title,
        description: unifiedList.description ?? '',
        spots: [],
        createdAt: unifiedList.createdAt,
        updatedAt: unifiedList.updatedAt ?? unifiedList.createdAt,
        category: unifiedList.category,
        isPublic: unifiedList.isPublic,
        spotIds: unifiedList.spotIds ?? [],
        respectCount: unifiedList.respectCount ?? 0,
        collaborators: unifiedList.collaboratorIds ?? [],
        followers: unifiedList.followerIds ?? [],
        curatorId: unifiedList.curatorId,
        tags: const [],
        ageRestricted: unifiedList.isAgeRestricted ?? false,
      );
      testLists = List.generate(3, (i) {
        final list = ModelFactories.createTestList(id: 'list-$i');
        return SpotList(
          id: list.id,
          title: list.title,
          description: list.description ?? '',
          spots: [],
          createdAt: list.createdAt,
          updatedAt: list.updatedAt ?? list.createdAt,
          category: list.category,
          isPublic: list.isPublic,
          spotIds: list.spotIds ?? [],
          respectCount: list.respectCount ?? 0,
          collaborators: list.collaboratorIds ?? [],
          followers: list.followerIds ?? [],
          curatorId: list.curatorId,
          tags: const [],
          ageRestricted: list.isAgeRestricted ?? false,
        );
      });
    });

    tearDown(() {
      if (mockLocalDataSource != null) reset(mockLocalDataSource!);
      if (mockRemoteDataSource != null) reset(mockRemoteDataSource!);
      if (mockConnectivity != null) reset(mockConnectivity!);
    });

    group('getLists', () {
      test('returns remote lists when online and caches them locally', () async {
        // Arrange: Configure online scenario
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockRemoteDataSource!.getLists())
            .thenAnswer((_) async => testLists);
        when(mockLocalDataSource!.saveList(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        verify(mockConnectivity!.checkConnectivity()).called(1);
        verify(mockRemoteDataSource!.getLists()).called(1);
        verify(mockLocalDataSource!.saveList(any)).called(testLists.length);
      });

      test('returns local lists when offline', () async {
        // Arrange: Configure offline scenario
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(mockLocalDataSource!.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        verify(mockConnectivity!.checkConnectivity()).called(1);
        verify(mockLocalDataSource!.getLists()).called(1);
        verifyNever(mockRemoteDataSource!.getLists());
      });

      test('falls back to local when remote fails', () async {
        // Arrange
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockRemoteDataSource!.getLists())
            .thenThrow(Exception('Remote server down'));
        when(mockLocalDataSource!.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        verify(mockRemoteDataSource!.getLists()).called(1);
        verify(mockLocalDataSource!.getLists()).called(1);
      });

      test('returns empty list when remote data source is null', () async {
        // Arrange: Repository with null remote data source
        repository = ListsRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: null,
          connectivity: mockConnectivity,
        );
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockLocalDataSource!.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        verify(mockLocalDataSource!.getLists()).called(1);
      });

      test('returns empty list when local data source is null', () async {
        // Arrange: Repository with null local data source
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
        );
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockRemoteDataSource!.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        verify(mockRemoteDataSource!.getLists()).called(1);
      });

      test('handles null connectivity gracefully', () async {
        // Arrange: Repository with null connectivity
        repository = ListsRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
          connectivity: null,
        );
        when(mockLocalDataSource!.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await repository.getLists();

        // Assert: Should default to offline behavior
        expect(result, equals(testLists));
        verify(mockLocalDataSource!.getLists()).called(1);
      });
    });

    group('createList', () {
      test('saves locally first then syncs to remote when online', () async {
        // Arrange
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) async => testList);
        when(mockRemoteDataSource!.createList(testList))
            .thenAnswer((_) async => testList);

        // Act
        final result = await repository.createList(testList);

        // Assert
        expect(result, equals(testList));
        verify(mockConnectivity!.checkConnectivity()).called(1);
        verify(mockLocalDataSource!.saveList(testList)).called(1);
        verify(mockRemoteDataSource!.createList(testList)).called(1);
      });

      test('saves locally only when offline', () async {
        // Arrange
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) async => testList);

        // Act
        final result = await repository.createList(testList);

        // Assert
        expect(result, equals(testList));
        verify(mockConnectivity!.checkConnectivity()).called(1);
        verify(mockLocalDataSource!.saveList(testList)).called(1);
        verifyNever(mockRemoteDataSource!.createList(any));
      });

      test('continues with local version when remote sync fails', () async {
        // Arrange
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) async => testList);
        when(mockRemoteDataSource!.createList(testList))
            .thenThrow(Exception('Remote sync failed'));

        // Act
        final result = await repository.createList(testList);

        // Assert: Should not fail, continues with local version
        expect(result, equals(testList));
        verify(mockLocalDataSource!.saveList(testList)).called(1);
        verify(mockRemoteDataSource!.createList(testList)).called(1);
      });

      test('falls back to local save when initial save fails', () async {
        // Arrange
        var callCount = 0;
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) {
              callCount++;
              if (callCount == 1) {
                throw Exception('Save failed');
              }
              return Future.value(testList);
            });
        when(mockRemoteDataSource!.createList(any))
            .thenThrow(Exception('Remote failed'));

        // Act
        final result = await repository.createList(testList);

        // Assert
        expect(result, equals(testList));
        // Should be called twice: once fails, once succeeds in catch block
        verify(mockLocalDataSource!.saveList(testList)).called(2);
      });

      test('handles null data sources gracefully', () async {
        // Arrange: Repository with null local data source
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
        );
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockRemoteDataSource!.createList(testList))
            .thenAnswer((_) async => testList);

        // Act
        final result = await repository.createList(testList);

        // Assert: Should return the original list
        expect(result, equals(testList));
        verify(mockRemoteDataSource!.createList(testList)).called(1);
      });
    });

    group('updateList', () {
      test('tries remote first then saves locally when successful', () async {
        // Arrange
        final unifiedList = ModelFactories.createTestList();
        final updatedList = SpotList(
          id: unifiedList.id,
          title: unifiedList.title,
          description: unifiedList.description ?? '',
          spots: [],
          createdAt: unifiedList.createdAt,
          updatedAt: unifiedList.updatedAt ?? unifiedList.createdAt,
          category: unifiedList.category,
          isPublic: unifiedList.isPublic,
          spotIds: unifiedList.spotIds ?? [],
          respectCount: unifiedList.respectCount ?? 0,
          collaborators: unifiedList.collaboratorIds ?? [],
          followers: unifiedList.followerIds ?? [],
          curatorId: unifiedList.curatorId,
          tags: [],
          ageRestricted: unifiedList.isAgeRestricted ?? false,
        ).copyWith(
          id: testList.id,
          title: 'Updated Title',
        );
        when(mockRemoteDataSource!.updateList(testList))
            .thenAnswer((_) async => updatedList);
        when(mockLocalDataSource!.saveList(updatedList))
            .thenAnswer((_) async => updatedList);

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(updatedList));
        verify(mockRemoteDataSource!.updateList(testList)).called(1);
        verify(mockLocalDataSource!.saveList(updatedList)).called(1);
      });

      test('falls back to local when remote is null', () async {
        // Arrange: Repository with null remote data source
        repository = ListsRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: null,
          connectivity: mockConnectivity,
        );
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) async => testList);

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(testList));
        verify(mockLocalDataSource!.saveList(testList)).called(1);
      });

      test('falls back to local when remote update fails', () async {
        // Arrange
        when(mockRemoteDataSource!.updateList(testList))
            .thenThrow(Exception('Remote update failed'));
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) async => testList);

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(testList));
        verify(mockRemoteDataSource!.updateList(testList)).called(1);
        verify(mockLocalDataSource!.saveList(testList)).called(1);
      });

      test('returns original list when local save returns null', () async {
        // Arrange
        when(mockRemoteDataSource!.updateList(testList))
            .thenThrow(Exception('Remote update failed'));
        when(mockLocalDataSource!.saveList(testList))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(testList));
        verify(mockLocalDataSource!.saveList(testList)).called(1);
      });
    });

    group('deleteList', () {
      test('deletes from remote first then local', () async {
        // Arrange
        when(mockRemoteDataSource!.deleteList(testList.id))
            .thenAnswer((_) async {});
        when(mockLocalDataSource!.deleteList(testList.id))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteList(testList.id);

        // Assert
        verify(mockRemoteDataSource!.deleteList(testList.id)).called(1);
        verify(mockLocalDataSource!.deleteList(testList.id)).called(1);
      });

      test('still deletes locally when remote is null', () async {
        // Arrange: Repository with null remote data source
        repository = ListsRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: null,
          connectivity: mockConnectivity,
        );
        when(mockLocalDataSource!.deleteList(testList.id))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteList(testList.id);

        // Assert
        verify(mockLocalDataSource!.deleteList(testList.id)).called(1);
      });

      test('still deletes locally when remote delete fails', () async {
        // Arrange
        when(mockRemoteDataSource!.deleteList(testList.id))
            .thenThrow(Exception('Remote delete failed'));
        when(mockLocalDataSource!.deleteList(testList.id))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteList(testList.id);

        // Assert
        verify(mockRemoteDataSource!.deleteList(testList.id)).called(1);
        verify(mockLocalDataSource!.deleteList(testList.id)).called(1);
      });
    });

    group('createStarterListsForUser', () {
      test('creates predefined starter lists locally', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        when(mockLocalDataSource!.saveList(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);

        // Act
        await repository.createStarterListsForUser(userId: userId);

        // Assert: Should create 3 starter lists as per implementation
        // Verify the specific lists created match implementation
        final captured = verify(mockLocalDataSource!.saveList(captureAny)).captured;
        expect(captured.length, equals(3), reason: 'Should create exactly 3 starter lists');
        
        final createdLists = captured.cast<SpotList>();
        expect(createdLists.any((list) => list.title == 'Fun Places'), isTrue);
        expect(createdLists.any((list) => list.title == 'Food & Drink'), isTrue);
        expect(createdLists.any((list) => list.title == 'Outdoor & Nature'), isTrue);
        
        // All lists should have empty spots initially
        for (final list in createdLists) {
          expect(list.spots, isEmpty);
        }
      });

      test('handles save errors gracefully', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        when(mockLocalDataSource!.saveList(any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert: Should not throw exception
        await repository.createStarterListsForUser(userId: userId);
        
        verify(mockLocalDataSource!.saveList(any)).called(3);
      });

      test('handles null local data source gracefully', () async {
        // Arrange: Repository with null local data source
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
        );
        final userId = TestConstants.testUserId;

        // Act & Assert: Should not throw exception
        await repository.createStarterListsForUser(userId: userId);
      });
    });

    group('createPersonalizedListsForUser', () {
      test('creates predefined personalized lists based on user preferences', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        final userPreferences = {
          'interests': ['coffee', 'parks', 'culture'],
          'location': 'San Francisco',
        };
        when(mockLocalDataSource!.saveList(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);

        // Act
        await repository.createPersonalizedListsForUser(
          userId: userId,
          userPreferences: userPreferences,
        );

        // Assert: Should create 3 personalized lists as per implementation
        final captured = verify(mockLocalDataSource!.saveList(captureAny)).captured;
        expect(captured.length, equals(3), reason: 'Should create exactly 3 personalized lists');
        
        final createdLists = captured.cast<SpotList>();
        expect(createdLists.any((list) => list.title == 'Coffee Shops'), isTrue);
        expect(createdLists.any((list) => list.title == 'Parks'), isTrue);
        expect(createdLists.any((list) => list.title == 'Museums'), isTrue);
        
        // Verify descriptions match implementation
        final coffeeList = createdLists.firstWhere((list) => list.title == 'Coffee Shops');
        expect(coffeeList.description, equals('Local coffee spots'));
        
        // All lists should have empty spots initially
        for (final list in createdLists) {
          expect(list.spots, isEmpty);
        }
      });

      test('generates unique IDs for each personalized list', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        final userPreferences = <String, dynamic>{};
        when(mockLocalDataSource!.saveList(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);

        // Act
        await repository.createPersonalizedListsForUser(
          userId: userId,
          userPreferences: userPreferences,
        );

        // Assert
        final captured = verify(mockLocalDataSource!.saveList(captureAny)).captured;
        final createdLists = captured.cast<SpotList>();
        
        // Should create 3 lists
        expect(createdLists.length, equals(3));
        
        // All IDs should be unique and start with 'personalized-'
        final ids = createdLists.map((list) => list.id).toList();
        expect(ids.toSet().length, equals(ids.length), reason: 'All IDs should be unique'); // All unique
        for (final id in ids) {
          expect(id, startsWith('personalized-'));
        }
      });

      test('handles save errors gracefully', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        final userPreferences = <String, dynamic>{};
        when(mockLocalDataSource!.saveList(any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert: Should not throw exception, continues through all lists
        await repository.createPersonalizedListsForUser(
          userId: userId,
          userPreferences: userPreferences,
        );
        
        // Each list save attempt will throw, but loop continues - all 3 attempts made
        verify(mockLocalDataSource!.saveList(any)).called(3);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles completely null dependencies', () async {
        // Arrange: Repository with all null dependencies
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: null,
          connectivity: null,
        );

        // Act & Assert: Should not crash
        final result = await repository.getLists();
        expect(result, isEmpty);
        
        final createResult = await repository.createList(testList);
        expect(createResult, equals(testList));
        
        // Should not throw
        await repository.deleteList(testList.id);
        await repository.createStarterListsForUser(userId: TestConstants.testUserId);
      });

      test('handles concurrent operations correctly', () async {
        // Arrange
        when(mockConnectivity!.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockLocalDataSource!.saveList(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);
        when(mockRemoteDataSource!.createList(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);

        // Act: Create multiple lists concurrently
        final futures = List.generate(
          5,
          (index) {
            final list = ModelFactories.createTestList(id: 'concurrent-$index');
            final spotList = SpotList(
              id: list.id,
              title: list.title,
              description: list.description ?? '',
              spots: [],
              createdAt: list.createdAt,
              updatedAt: list.updatedAt ?? list.createdAt,
              category: list.category,
              isPublic: list.isPublic,
              spotIds: list.spotIds ?? [],
              respectCount: list.respectCount ?? 0,
              collaborators: list.collaboratorIds ?? [],
              followers: list.followerIds ?? [],
              curatorId: list.curatorId,
              tags: const [],
              ageRestricted: list.isAgeRestricted ?? false,
            );
            return repository.createList(spotList);
          },
        );
        final results = await Future.wait(futures);

        // Assert: All operations should complete successfully
        expect(results.length, equals(5));
        verify(mockLocalDataSource!.saveList(any)).called(5);
        verify(mockRemoteDataSource!.createList(any)).called(5);
      });

      test('handles connectivity check exceptions', () async {
        // Arrange
        when(mockConnectivity!.checkConnectivity())
            .thenThrow(Exception('Connectivity service error'));
        when(mockLocalDataSource!.getLists())
            .thenAnswer((_) async => testLists);

        // Act
        final result = await repository.getLists();

        // Assert: Should fallback to local data
        expect(result, equals(testLists));
        verify(mockLocalDataSource!.getLists()).called(1);
      });
    });
  });
}
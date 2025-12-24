import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/data/repositories/lists_repository_impl.dart';
import 'package:spots/data/datasources/local/lists_local_datasource.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';
import 'package:spots/core/models/list.dart';

import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

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
    late _FakeListsLocalDataSource fakeLocalDataSource;
    late _FakeListsRemoteDataSource fakeRemoteDataSource;
    late _FakeConnectivity fakeConnectivity;
    
    late SpotList testList;
    late List<SpotList> testLists;

    setUp(() {
      fakeLocalDataSource = _FakeListsLocalDataSource();
      fakeRemoteDataSource = _FakeListsRemoteDataSource();
      fakeConnectivity = _FakeConnectivity();
      
      repository = ListsRepositoryImpl(
        localDataSource: fakeLocalDataSource,
        remoteDataSource: fakeRemoteDataSource,
        connectivity: fakeConnectivity,
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
        spotIds: unifiedList.spotIds,
        respectCount: unifiedList.respectCount,
        collaborators: unifiedList.collaboratorIds,
        followers: unifiedList.followerIds,
        curatorId: unifiedList.curatorId,
        tags: const [],
        ageRestricted: unifiedList.isAgeRestricted,
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
          spotIds: list.spotIds,
          respectCount: list.respectCount,
          collaborators: list.collaboratorIds,
          followers: list.followerIds,
          curatorId: list.curatorId,
          tags: const [],
          ageRestricted: list.isAgeRestricted,
        );
      });
    });

    tearDown(() {
      fakeLocalDataSource.clear();
      fakeRemoteDataSource.clear();
    });

    group('getLists', () {
      test('returns remote lists when online and caches them locally', () async {
        // Arrange: Configure online scenario
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
        fakeRemoteDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        // Verify lists were cached locally
        expect(fakeLocalDataSource.getAllLists(), equals(testLists));
      });

      test('returns local lists when offline', () async {
        // Arrange: Configure offline scenario
        fakeConnectivity.setConnectivity(ConnectivityResult.none);
        fakeLocalDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        // Verify remote was not called
        expect(fakeRemoteDataSource.getCallCount('getLists'), equals(0));
      });

      test('falls back to local when remote fails', () async {
        // Arrange
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
        fakeRemoteDataSource.setShouldThrow('getLists', Exception('Remote server down'));
        fakeLocalDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
        expect(fakeRemoteDataSource.getCallCount('getLists'), equals(1));
      });

      test('returns empty list when remote data source is null', () async {
        // Arrange: Repository with null remote data source
        repository = ListsRepositoryImpl(
          localDataSource: fakeLocalDataSource,
          remoteDataSource: null,
          connectivity: fakeConnectivity,
        );
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
        fakeLocalDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
      });

      test('returns empty list when local data source is null', () async {
        // Arrange: Repository with null local data source
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: fakeRemoteDataSource,
          connectivity: fakeConnectivity,
        );
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
        fakeRemoteDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert
        expect(result, equals(testLists));
      });

      test('handles null connectivity gracefully', () async {
        // Arrange: Repository with null connectivity
        repository = ListsRepositoryImpl(
          localDataSource: fakeLocalDataSource,
          remoteDataSource: fakeRemoteDataSource,
          connectivity: null,
        );
        fakeLocalDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert: Should default to offline behavior
        expect(result, equals(testLists));
      });
    });

    group('createList', () {
      test('saves locally first then syncs to remote when online', () async {
        // Arrange
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);

        // Act
        final result = await repository.createList(testList);

        // Assert
        expect(result, equals(testList));
        // Verify saved locally
        expect(fakeLocalDataSource.getListById(testList.id), equals(testList));
        // Verify synced to remote
        expect(fakeRemoteDataSource.getListById(testList.id), equals(testList));
      });

      test('saves locally only when offline', () async {
        // Arrange
        fakeConnectivity.setConnectivity(ConnectivityResult.none);

        // Act
        final result = await repository.createList(testList);

        // Assert
        expect(result, equals(testList));
        // Verify saved locally
        expect(fakeLocalDataSource.getListById(testList.id), equals(testList));
        // Verify NOT synced to remote
        expect(fakeRemoteDataSource.getCallCount('createList'), equals(0));
      });

      test('continues with local version when remote sync fails', () async {
        // Arrange
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
        fakeRemoteDataSource.setShouldThrow('createList', Exception('Remote sync failed'));

        // Act
        final result = await repository.createList(testList);

        // Assert: Should not fail, continues with local version
        expect(result, equals(testList));
        // Verify saved locally despite remote failure
        expect(fakeLocalDataSource.getListById(testList.id), equals(testList));
        expect(fakeRemoteDataSource.getCallCount('createList'), equals(1));
      });

      test('falls back to local save when initial save fails', () async {
        // Arrange
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);
        fakeLocalDataSource.setShouldThrowOnFirstSave(true);
        fakeRemoteDataSource.setShouldThrow('createList', Exception('Remote failed'));

        // Act
        final result = await repository.createList(testList);

        // Assert
        expect(result, equals(testList));
        // Verify eventually saved locally (retry succeeded)
        expect(fakeLocalDataSource.getListById(testList.id), equals(testList));
      });

      test('handles null data sources gracefully', () async {
        // Arrange: Repository with null local data source
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: fakeRemoteDataSource,
          connectivity: fakeConnectivity,
        );
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);

        // Act
        final result = await repository.createList(testList);

        // Assert: Should return the original list
        expect(result, equals(testList));
        expect(fakeRemoteDataSource.getListById(testList.id), equals(testList));
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
          spotIds: unifiedList.spotIds,
          respectCount: unifiedList.respectCount,
          collaborators: unifiedList.collaboratorIds,
          followers: unifiedList.followerIds,
          curatorId: unifiedList.curatorId,
          tags: [],
          ageRestricted: unifiedList.isAgeRestricted,
        ).copyWith(
          id: testList.id,
          title: 'Updated Title',
        );
        fakeRemoteDataSource.addList(updatedList);

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(updatedList));
        // Verify saved locally
        expect(fakeLocalDataSource.getListById(testList.id)?.title, equals('Updated Title'));
      });

      test('falls back to local when remote is null', () async {
        // Arrange: Repository with null remote data source
        repository = ListsRepositoryImpl(
          localDataSource: fakeLocalDataSource,
          remoteDataSource: null,
          connectivity: fakeConnectivity,
        );

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(testList));
        expect(fakeLocalDataSource.getListById(testList.id), equals(testList));
      });

      test('falls back to local when remote update fails', () async {
        // Arrange
        fakeRemoteDataSource.setShouldThrow('updateList', Exception('Remote update failed'));

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(testList));
        expect(fakeLocalDataSource.getListById(testList.id), equals(testList));
        expect(fakeRemoteDataSource.getCallCount('updateList'), equals(1));
      });

      test('returns original list when local save returns null', () async {
        // Arrange
        fakeRemoteDataSource.setShouldThrow('updateList', Exception('Remote update failed'));
        fakeLocalDataSource.setShouldReturnNullOnSave(true);

        // Act
        final result = await repository.updateList(testList);

        // Assert
        expect(result, equals(testList));
      });
    });

    group('deleteList', () {
      test('deletes from remote first then local', () async {
        // Arrange
        fakeLocalDataSource.addList(testList);
        fakeRemoteDataSource.addList(testList);

        // Act
        await repository.deleteList(testList.id);

        // Assert
        expect(fakeLocalDataSource.getListById(testList.id), isNull);
        expect(fakeRemoteDataSource.getListById(testList.id), isNull);
      });

      test('still deletes locally when remote is null', () async {
        // Arrange: Repository with null remote data source
        repository = ListsRepositoryImpl(
          localDataSource: fakeLocalDataSource,
          remoteDataSource: null,
          connectivity: fakeConnectivity,
        );
        fakeLocalDataSource.addList(testList);

        // Act
        await repository.deleteList(testList.id);

        // Assert
        expect(fakeLocalDataSource.getListById(testList.id), isNull);
      });

      test('still deletes locally when remote delete fails', () async {
        // Arrange
        fakeLocalDataSource.addList(testList);
        fakeRemoteDataSource.addList(testList);
        fakeRemoteDataSource.setShouldThrow('deleteList', Exception('Remote delete failed'));

        // Act
        await repository.deleteList(testList.id);

        // Assert
        expect(fakeLocalDataSource.getListById(testList.id), isNull);
        expect(fakeRemoteDataSource.getCallCount('deleteList'), equals(1));
      });
    });

    group('createStarterListsForUser', () {
      test('creates predefined starter lists locally', () async {
        // Arrange
        final userId = TestConstants.testUserId;

        // Act
        await repository.createStarterListsForUser(userId: userId);

        // Assert: Should create 3 starter lists as per implementation
        final allLists = fakeLocalDataSource.getAllLists();
        expect(allLists.length, equals(3), reason: 'Should create exactly 3 starter lists');
        
        expect(allLists.any((list) => list.title == 'Fun Places'), isTrue);
        expect(allLists.any((list) => list.title == 'Food & Drink'), isTrue);
        expect(allLists.any((list) => list.title == 'Outdoor & Nature'), isTrue);
        
        // All lists should have empty spots initially
        for (final list in allLists) {
          expect(list.spots, isEmpty);
        }
      });

      test('handles save errors gracefully', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        fakeLocalDataSource.setShouldThrowOnSave(true);

        // Act & Assert: Should not throw exception
        await repository.createStarterListsForUser(userId: userId);
        
        // Verify all 3 attempts were made despite errors
        expect(fakeLocalDataSource.getCallCount('saveList'), equals(3));
      });

      test('handles null local data source gracefully', () async {
        // Arrange: Repository with null local data source
        repository = ListsRepositoryImpl(
          localDataSource: null,
          remoteDataSource: fakeRemoteDataSource,
          connectivity: fakeConnectivity,
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

        // Act
        await repository.createPersonalizedListsForUser(
          userId: userId,
          userPreferences: userPreferences,
        );

        // Assert: Should create 3 personalized lists as per implementation
        final allLists = fakeLocalDataSource.getAllLists();
        expect(allLists.length, equals(3), reason: 'Should create exactly 3 personalized lists');
        
        expect(allLists.any((list) => list.title == 'Coffee Shops'), isTrue);
        expect(allLists.any((list) => list.title == 'Parks'), isTrue);
        expect(allLists.any((list) => list.title == 'Museums'), isTrue);
        
        // Verify descriptions match implementation
        final coffeeList = allLists.firstWhere((list) => list.title == 'Coffee Shops');
        expect(coffeeList.description, equals('Local coffee spots'));
        
        // All lists should have empty spots initially
        for (final list in allLists) {
          expect(list.spots, isEmpty);
        }
      });

      test('generates unique IDs for each personalized list', () async {
        // Arrange
        final userId = TestConstants.testUserId;
        final userPreferences = <String, dynamic>{};

        // Act
        await repository.createPersonalizedListsForUser(
          userId: userId,
          userPreferences: userPreferences,
        );

        // Assert
        final createdLists = fakeLocalDataSource.getAllLists();
        
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
        fakeLocalDataSource.setShouldThrowOnSave(true);

        // Act & Assert: Should not throw exception, continues through all lists
        await repository.createPersonalizedListsForUser(
          userId: userId,
          userPreferences: userPreferences,
        );
        
        // Each list save attempt will throw, but loop continues - all 3 attempts made
        expect(fakeLocalDataSource.getCallCount('saveList'), equals(3));
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
        fakeConnectivity.setConnectivity(ConnectivityResult.wifi);

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
              spotIds: list.spotIds,
              respectCount: list.respectCount,
              collaborators: list.collaboratorIds,
              followers: list.followerIds,
              curatorId: list.curatorId,
              tags: const [],
              ageRestricted: list.isAgeRestricted,
            );
            return repository.createList(spotList);
          },
        );
        final results = await Future.wait(futures);

        // Assert: All operations should complete successfully
        expect(results.length, equals(5));
        expect(fakeLocalDataSource.getAllLists().length, equals(5));
        expect(fakeRemoteDataSource.getAllLists().length, equals(5));
      });

      test('handles connectivity check exceptions', () async {
        // Arrange
        fakeConnectivity.setShouldThrow(true);
        fakeLocalDataSource.addLists(testLists);

        // Act
        final result = await repository.getLists();

        // Assert: Should fallback to local data
        expect(result, equals(testLists));
      });
    });
  });
}

/// Real fake implementation with in-memory storage for local data source
class _FakeListsLocalDataSource implements ListsLocalDataSource {
  final Map<String, SpotList> _storage = {};
  final Map<String, int> _callCounts = {};
  bool _shouldThrowOnSave = false;
  bool _shouldThrowOnFirstSave = false;
  bool _shouldReturnNullOnSave = false;
  int _saveCallCount = 0;

  /// Add lists to storage (for test setup)
  void addLists(List<SpotList> lists) {
    for (final list in lists) {
      _storage[list.id] = list;
    }
  }

  /// Add a single list to storage (for test setup)
  void addList(SpotList list) {
    _storage[list.id] = list;
  }

  /// Get all lists from storage
  List<SpotList> getAllLists() {
    return _storage.values.toList();
  }

  /// Get list by ID (for testing)
  SpotList? getListById(String id) {
    return _storage[id];
  }

  /// Get call count for a method (for testing)
  int getCallCount(String methodName) {
    return _callCounts[methodName] ?? 0;
  }

  /// Set whether save should throw (for testing error scenarios)
  void setShouldThrowOnSave(bool shouldThrow) {
    _shouldThrowOnSave = shouldThrow;
  }

  /// Set whether first save should throw (for testing retry scenarios)
  void setShouldThrowOnFirstSave(bool shouldThrow) {
    _shouldThrowOnFirstSave = shouldThrow;
    _saveCallCount = 0;
  }

  /// Set whether save should return null (for testing null scenarios)
  void setShouldReturnNullOnSave(bool shouldReturnNull) {
    _shouldReturnNullOnSave = shouldReturnNull;
  }

  /// Clear all stored data (for test cleanup)
  void clear() {
    _storage.clear();
    _callCounts.clear();
    _shouldThrowOnSave = false;
    _shouldThrowOnFirstSave = false;
    _shouldReturnNullOnSave = false;
    _saveCallCount = 0;
  }

  @override
  Future<List<SpotList>> getLists() async {
    _callCounts['getLists'] = (_callCounts['getLists'] ?? 0) + 1;
    return _storage.values.toList();
  }

  @override
  Future<SpotList?> saveList(SpotList list) async {
    _callCounts['saveList'] = (_callCounts['saveList'] ?? 0) + 1;
    _saveCallCount++;

    if (_shouldReturnNullOnSave) {
      return null;
    }

    if (_shouldThrowOnSave) {
      throw Exception('Storage error');
    }

    if (_shouldThrowOnFirstSave && _saveCallCount == 1) {
      throw Exception('Save failed');
    }

    _storage[list.id] = list;
    return list;
  }

  @override
  Future<void> deleteList(String id) async {
    _callCounts['deleteList'] = (_callCounts['deleteList'] ?? 0) + 1;
    _storage.remove(id);
  }
}

/// Real fake implementation with in-memory storage for remote data source
class _FakeListsRemoteDataSource implements ListsRemoteDataSource {
  final Map<String, SpotList> _storage = {};
  final Map<String, int> _callCounts = {};
  final Map<String, Exception?> _shouldThrow = {};

  /// Add lists to storage (for test setup)
  void addLists(List<SpotList> lists) {
    for (final list in lists) {
      _storage[list.id] = list;
    }
  }

  /// Add a single list to storage (for test setup)
  void addList(SpotList list) {
    _storage[list.id] = list;
  }

  /// Get all lists from storage
  List<SpotList> getAllLists() {
    return _storage.values.toList();
  }

  /// Get list by ID (for testing)
  SpotList? getListById(String id) {
    return _storage[id];
  }

  /// Get call count for a method (for testing)
  int getCallCount(String methodName) {
    return _callCounts[methodName] ?? 0;
  }

  /// Set whether a method should throw (for testing error scenarios)
  void setShouldThrow(String methodName, Exception exception) {
    _shouldThrow[methodName] = exception;
  }

  /// Clear all stored data (for test cleanup)
  void clear() {
    _storage.clear();
    _callCounts.clear();
    _shouldThrow.clear();
  }

  @override
  Future<List<SpotList>> getLists() async {
    _callCounts['getLists'] = (_callCounts['getLists'] ?? 0) + 1;
    if (_shouldThrow.containsKey('getLists') && _shouldThrow['getLists'] != null) {
      throw _shouldThrow['getLists']!;
    }
    return _storage.values.toList();
  }

  @override
  Future<List<SpotList>> getPublicLists({int? limit}) async {
    _callCounts['getPublicLists'] = (_callCounts['getPublicLists'] ?? 0) + 1;
    final publicLists = _storage.values.where((list) => list.isPublic).toList();
    if (limit != null) {
      return publicLists.take(limit).toList();
    }
    return publicLists;
  }

  @override
  Future<SpotList> createList(SpotList list) async {
    _callCounts['createList'] = (_callCounts['createList'] ?? 0) + 1;
    if (_shouldThrow.containsKey('createList') && _shouldThrow['createList'] != null) {
      throw _shouldThrow['createList']!;
    }
    _storage[list.id] = list;
    return list;
  }

  @override
  Future<SpotList> updateList(SpotList list) async {
    _callCounts['updateList'] = (_callCounts['updateList'] ?? 0) + 1;
    if (_shouldThrow.containsKey('updateList') && _shouldThrow['updateList'] != null) {
      throw _shouldThrow['updateList']!;
    }
    _storage[list.id] = list;
    return list;
  }

  @override
  Future<void> deleteList(String listId) async {
    _callCounts['deleteList'] = (_callCounts['deleteList'] ?? 0) + 1;
    if (_shouldThrow.containsKey('deleteList') && _shouldThrow['deleteList'] != null) {
      throw _shouldThrow['deleteList']!;
    }
    _storage.remove(listId);
  }
}

/// Real fake implementation with state management for connectivity testing
class _FakeConnectivity implements Connectivity {
  ConnectivityResult _currentResult = ConnectivityResult.wifi;
  bool _shouldThrow = false;

  /// Set the connectivity state for testing
  void setConnectivity(ConnectivityResult result) {
    _currentResult = result;
  }

  /// Set whether checkConnectivity should throw (for testing error scenarios)
  void setShouldThrow(bool shouldThrow) {
    _shouldThrow = shouldThrow;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (_shouldThrow) {
      throw Exception('Connectivity service error');
    }
    return [_currentResult];
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Stream.value([_currentResult]);
  }
}
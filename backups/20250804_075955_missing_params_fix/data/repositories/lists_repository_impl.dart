import 'dart:developer' as developer;
import 'package:spots/core/models/unified_models.dart';import 'package:spots/core/models/list.dart';
import 'package:spots/data/datasources/local/sembast/sembast/lists_local_datasource.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';
import 'package:spots/domain/repositories/lists_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ListsRepositoryImpl implements ListsRepository {
  final ListsLocalDataSource? localDataSource;
  final ListsRemoteDataSource? remoteDataSource;
  final Connectivity? connectivity;

  ListsRepositoryImpl({
    this.localDataSource,
    this.remoteDataSource,
    this.connectivity,
  });

  @override
  Future<List<SpotList>> getLists() async {
    try {
      // Check connectivity first - offline-first approach
      final connectivityResult = await connectivity?.checkConnectivity() ?? [ConnectivityResult.none];
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);
      
      if (isOnline && remoteDataSource != null) {
        final lists = await remoteDataSource!.getLists();
        // Cache locally
        for (final list in lists) {
          await localDataSource?.saveList(list);
        }
        return lists;
      }
      
      // Use local data (either offline or remote failed)
      return await localDataSource?.getLists() ?? [];
    } catch (e) {
      developer.log('Error getting remote lists: $e', name: 'ListsRepository');
      // Fallback to local
      return await localDataSource?.getLists() ?? [];
    }
  }

  @override
  Future<SpotList> createList(SpotList list) async {
    try {
      // Check connectivity first - offline-first approach
      final connectivityResult = await connectivity?.checkConnectivity() ?? [ConnectivityResult.none];
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);
      
      // Always save locally first
      final savedList = await localDataSource?.saveList(list) ?? list;
      
      // Try to sync to remote if online
      if (isOnline && remoteDataSource != null) {
        try {
          await remoteDataSource!.createList(savedList);
        } catch (e) {
          developer.log('Failed to sync list to remote: $e', name: 'ListsRepository');
          // Continue with local version - no need to fail the operation
        }
      }
      
      return savedList;
    } catch (e) {
      developer.log('Error creating list: $e', name: 'ListsRepository');
      // Fallback to local only
      return await localDataSource?.saveList(list) ?? list;
    }
  }

  @override
  Future<SpotList> updateList(SpotList list) async {
    try {
      // Try remote first
      if (remoteDataSource != null) {
        final updatedList = await remoteDataSource!.updateList(list);
        await localDataSource?.saveList(updatedList);
        return updatedList;
      }
      
      // Fallback to local
      final updatedList = await localDataSource?.saveList(list);
      return updatedList ?? list;
    } catch (e) {
      developer.log('Error updating remote list: $e', name: 'ListsRepository');
      // Fallback to local
      final updatedList = await localDataSource?.saveList(list);
      return updatedList ?? list;
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      // Try remote first
      if (remoteDataSource != null) {
        await remoteDataSource!.deleteList(id);
      }
      
      // Always delete locally
      await localDataSource?.deleteList(id);
    } catch (e) {
      developer.log('Error deleting remote list: $e', name: 'ListsRepository');
      // Still delete locally
      await localDataSource?.deleteList(id);
    }
  }

  @override
  Future<void> createStarterListsForUser({required String userId}) async {
    try {
      final now = DateTime.now();
      final starterLists = [
        SpotList(
          id: 'starter-1',
          title: 'Fun Places',
          description: 'Places to have fun',
          spots: [],
          createdAt: now,
          updatedAt: now,
        ),
        SpotList(
          id: 'starter-2',
          title: 'Food & Drink',
          description: 'Restaurants and bars',
          spots: [],
          createdAt: now,
          updatedAt: now,
        ),
        SpotList(
          id: 'starter-3',
          title: 'Outdoor & Nature',
          description: 'Parks and outdoor activities',
          spots: [],
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final list in starterLists) {
        await localDataSource?.saveList(list);
      }
    } catch (e) {
      developer.log('Error creating starter lists: $e', name: 'ListsRepository');
    }
  }

  @override
  Future<void> createPersonalizedListsForUser({
    required String userId,
    required Map<String, dynamic> userPreferences,
  }) async {
    try {
      final now = DateTime.now();
      final suggestions = [
        {'name': 'Coffee Shops', 'description': 'Local coffee spots'},
        {'name': 'Parks', 'description': 'Green spaces to relax'},
        {'name': 'Museums', 'description': 'Cultural experiences'},
      ];

      for (final suggestion in suggestions) {
        final list = SpotList(
          id: 'personalized-${DateTime.now().millisecondsSinceEpoch}',
          title: suggestion['name'] ?? 'Unknown',
          description: suggestion['description'] ?? 'No description',
          spots: [],
          createdAt: now,
          updatedAt: now,
        );
        await localDataSource?.saveList(list);
      }
    } catch (e) {
      developer.log('Error creating personalized lists: $e', name: 'ListsRepository');
    }
  }
}

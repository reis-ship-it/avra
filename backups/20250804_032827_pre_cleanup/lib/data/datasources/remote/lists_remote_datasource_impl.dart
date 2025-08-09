import 'package:spots/core/models/list.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';

class ListsRemoteDataSourceImpl implements ListsRemoteDataSource {
  @override
  Future<List<SpotList>> getLists() async {
    // Mock implementation
    final now = DateTime.now();
    return [
      SpotList(
        id: 'remote-list-1',
        title: 'Remote List 1',
        description: 'A remote list',
        spots: [],
        createdAt: now,
        updatedAt: now,
        category: 'Travel',
        isPublic: true,
        spotIds: [],
        respectCount: 2,
      ),
      SpotList(
        id: 'remote-list-2',
        title: 'Remote List 2',
        description: 'Another remote list',
        spots: [],
        createdAt: now,
        updatedAt: now,
        category: 'Food',
        isPublic: false,
        spotIds: [],
        respectCount: 1,
      ),
    ];
  }

  @override
  Future<SpotList> createList(SpotList list) async {
    // Mock implementation
    return list;
  }

  @override
  Future<SpotList> updateList(SpotList list) async {
    // Mock implementation
    return list;
  }

  @override
  Future<void> deleteList(String id) async {
    // Mock implementation
  }
}

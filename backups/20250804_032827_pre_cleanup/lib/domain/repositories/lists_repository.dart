import 'package:spots/core/models/list.dart';

abstract class ListsRepository {
  Future<List<SpotList>> getLists();
  Future<SpotList> createList(SpotList list);
  Future<SpotList> updateList(SpotList list);
  Future<void> deleteList(String id);
  Future<void> createStarterListsForUser({
    required String userId,
  });
  Future<void> createPersonalizedListsForUser({
    required String userId,
    required Map<String, dynamic> userPreferences,
  });
}

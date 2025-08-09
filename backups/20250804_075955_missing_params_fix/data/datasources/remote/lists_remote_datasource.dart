import 'package:spots/core/models/list.dart';
import 'package:spots/core/models/unified_models.dart';
abstract class ListsRemoteDataSource {
  Future<List<SpotList>> getLists();
  Future<SpotList> createList(SpotList list);
  Future<SpotList> updateList(SpotList list);
  Future<void> deleteList(String listId);
}

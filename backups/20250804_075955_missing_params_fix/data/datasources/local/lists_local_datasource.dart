import 'package:spots/core/models/list.dart';
import 'package:spots/core/models/unified_models.dart';
abstract class ListsLocalDataSource {
  Future<List<SpotList>> getLists();
  Future<SpotList?> saveList(SpotList list);
  Future<void> deleteList(String id);
}

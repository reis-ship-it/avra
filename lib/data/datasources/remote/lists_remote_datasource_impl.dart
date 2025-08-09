import 'package:spots/core/models/list.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';
import 'package:spots_network/spots_network.dart';
import 'package:spots_core/spots_core.dart' as spots_core;
import 'package:spots/injection_container.dart' as di;

class ListsRemoteDataSourceImpl implements ListsRemoteDataSource {
  DataBackend get _data => di.sl<DataBackend>();

  static const String _collection = 'spot_lists';

  @override
  Future<List<SpotList>> getLists() async {
    final res = await _data.getSpotLists(limit: 100);
    if (res.hasData && res.data != null) {
      return res.data!
          .map((coreList) => SpotList.fromJson(coreList.toJson()))
          .toList();
    }
    return [];
  }

  @override
  Future<SpotList> createList(SpotList list) async {
    final res = await _data.createSpotList(
      spots_core.SpotList.fromJson(list.toJson()),
    );
    if (res.hasData && res.data != null) {
      return SpotList.fromJson(res.data!.toJson());
    }
    return list;
  }

  @override
  Future<SpotList> updateList(SpotList list) async {
    final res = await _data.updateSpotList(
      spots_core.SpotList.fromJson(list.toJson()),
    );
    if (res.hasData && res.data != null) {
      return SpotList.fromJson(res.data!.toJson());
    }
    return list;
  }

  @override
  Future<void> deleteList(String id) async {
    await _data.deleteSpotList(id);
  }
}

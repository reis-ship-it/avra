import 'package:spots/core/models/spot.dart';
import 'package:spots/data/datasources/remote/spots_remote_datasource.dart';
import 'package:spots_network/spots_network.dart';
import 'package:spots_core/spots_core.dart' as spots_core;
import 'package:spots/injection_container.dart' as di;

class SpotsRemoteDataSourceImpl implements SpotsRemoteDataSource {
  DataBackend get _data => di.sl<DataBackend>();

  static const String _collection = 'spots';

  @override
  Future<List<Spot>> getSpots() async {
    final res = await _data.getSpots(limit: 100);
    if (res.hasData && res.data != null) {
      return res.data!
          .map((coreSpot) => Spot.fromJson(coreSpot.toJson()))
          .toList();
    }
    return [];
  }

  @override
  Future<Spot> createSpot(Spot spot) async {
    final res = await _data.createSpot(
      spots_core.Spot.fromJson(spot.toJson()),
    );
    if (res.hasData && res.data != null) {
      return Spot.fromJson(res.data!.toJson());
    }
    return spot;
  }

  @override
  Future<Spot> updateSpot(Spot spot) async {
    final res = await _data.updateSpot(
      spots_core.Spot.fromJson(spot.toJson()),
    );
    if (res.hasData && res.data != null) {
      return Spot.fromJson(res.data!.toJson());
    }
    return spot;
  }

  @override
  Future<void> deleteSpot(String id) async {
    await _data.deleteSpot(id);
  }
}

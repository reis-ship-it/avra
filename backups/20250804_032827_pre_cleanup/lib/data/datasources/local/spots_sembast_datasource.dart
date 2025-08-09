import 'dart:developer' as developer;
import 'package:spots/core/models/unified_models.dart';import 'package:sembast/sembast.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:spots/data/datasources/local/spots_local_datasource.dart';

class SpotsSembastDataSource implements SpotsLocalDataSource {
  final StoreRef<String, Map<String, dynamic>> _store;

  SpotsSembastDataSource() : _store = SembastDatabase.spotsStore;

  @override
  Future<Spot?> getSpotById(String id) async {
    try {
      final db = await SembastDatabase.database;
      final record = await _store.record(id).get(db);
      if (record != null) {
        return Spot.fromJson(record);
      }
      return null;
    } catch (e) {
      developer.log('Error getting spot: $e', name: 'SpotsSembastDataSource');
      return null;
    }
  }

  @override
  Future<String> createSpot(Spot spot) async {
    try {
      final db = await SembastDatabase.database;
      final spotData = spot.toJson();
      final key = await _store.add(db, spotData);
      return key;
    } catch (e) {
      developer.log('Error creating spot: $e', name: 'SpotsSembastDataSource');
      rethrow;
    }
  }

  @override
  Future<Spot> updateSpot(Spot spot) async {
    try {
      final db = await SembastDatabase.database;
      final spotData = spot.toJson();
      await _store.record(spot.id).put(db, spotData);
      return spot;
    } catch (e) {
      developer.log('Error updating spot: $e', name: 'SpotsSembastDataSource');
      rethrow;
    }
  }

  @override
  Future<void> deleteSpot(String id) async {
    try {
      final db = await SembastDatabase.database;
      await _store.record(id).delete(db);
    } catch (e) {
      developer.log('Error deleting spot: $e', name: 'SpotsSembastDataSource');
      rethrow;
    }
  }

  @override
  Future<List<Spot>> getSpotsByCategory(String category) async {
    try {
      final db = await SembastDatabase.database;
      final finder = Finder(filter: Filter.equals('category', category));
      final records = await _store.find(db, finder: finder);
      return records.map((record) => Spot.fromJson(record.value)).toList();
    } catch (e) {
      developer.log('Error getting spots by category: $e', name: 'SpotsSembastDataSource');
      return [];
    }
  }

  @override
  Future<List<Spot>> getAllSpots() async {
    try {
      final db = await SembastDatabase.database;
      final records = await _store.find(db);
      return records.map((record) {
        final data = record.value;
        final now = DateTime.now();
        return Spot(
          id: record.key,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          latitude: data['latitude']?.toDouble() ?? 0.0,
          longitude: data['longitude']?.toDouble() ?? 0.0,
          category: data['category'] ?? '',
          rating: data['rating']?.toDouble() ?? 0.0,
          createdBy: data['createdBy'] ?? '',
          createdAt: DateTime.parse(data['createdAt'] ?? now.toIso8601String()),
          updatedAt: DateTime.parse(data['updatedAt'] ?? now.toIso8601String()),
        );
      }).toList();
    } catch (e) {
      developer.log('Error getting all spots: $e', name: 'SpotsSembastDataSource');
      return [];
    }
  }

  @override
  Future<List<Spot>> getSpotsFromRespectedLists() async {
    try {
      // Implementation for getting spots from respected lists
      return [];
    } catch (e) {
      developer.log('Error getting spots from respected lists: $e', name: 'SpotsSembastDataSource');
      return [];
    }
  }
}

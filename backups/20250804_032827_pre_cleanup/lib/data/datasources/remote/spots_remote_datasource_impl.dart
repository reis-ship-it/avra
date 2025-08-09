import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:spots/data/datasources/remote/spots_remote_datasource.dart';

class SpotsRemoteDataSourceImpl implements SpotsRemoteDataSource {
  @override
  Future<List<Spot>> getSpots() async {
    // Mock implementation
    final now = DateTime.now();
    return [
      Spot(
        id: 'remote-spot-1',
        name: 'Remote Spot 1',
        description: 'A remote spot',
        latitude: 40.7589,
        longitude: -73.9851,
        category: 'Attractions',
        rating: 4.5,
        createdBy: 'remote-user',
        createdAt: now,
        updatedAt: now,
        address: '123 Remote St',
        tags: ['remote', 'attraction'],
      ),
      Spot(
        id: 'remote-spot-2',
        name: 'Remote Spot 2',
        description: 'Another remote spot',
        latitude: 40.7505,
        longitude: -73.9934,
        category: 'Food',
        rating: 4.2,
        createdBy: 'remote-user',
        createdAt: now,
        updatedAt: now,
        address: '456 Remote Ave',
        tags: ['remote', 'food'],
      ),
    ];
  }

  @override
  Future<Spot> createSpot(Spot spot) async {
    // Mock implementation
    return spot;
  }

  @override
  Future<Spot> updateSpot(Spot spot) async {
    // Mock implementation
    return spot;
  }

  @override
  Future<void> deleteSpot(String id) async {
    // Mock implementation
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:spots/core/models/spot.dart';
import 'package:spots/data/datasources/local/spots_local_datasource.dart';
import 'package:spots/data/datasources/remote/spots_remote_datasource.dart';
import 'package:spots/domain/repositories/spots_repository.dart';

class SpotsRepositoryImpl implements SpotsRepository {
  final SpotsRemoteDataSource remoteDataSource;
  final SpotsLocalDataSource localDataSource;
  final Connectivity connectivity;

  SpotsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Spot>> getSpots() async {
    try {
      // Always try to get from local first
      final localSpots = await localDataSource.getAllSpots();

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return localSpots;
      }

      // If online, try to sync with remote
      try {
        final remoteSpots = await remoteDataSource.getSpots();
        // For now, just return local data since remote is stubbed
        return localSpots;
      } catch (e) {
        // If remote fails, return local data
        return localSpots;
      }
    } catch (e) {
      throw Exception('Failed to get spots: $e');
    }
  }

  @override
  Future<List<Spot>> getSpotsFromRespectedLists() async {
    try {
      // Get spots from respected lists
      final respectedSpots = await localDataSource.getSpotsFromRespectedLists();
      return respectedSpots;
    } catch (e) {
      throw Exception('Failed to get spots from respected lists: $e');
    }
  }

  @override
  Future<Spot> createSpot(Spot spot) async {
    try {
      // Always save locally first
      final spotId = await localDataSource.createSpot(spot);
      final createdSpot = await localDataSource.getSpotById(spotId);

      if (createdSpot == null) {
        throw Exception('Failed to create spot locally');
      }

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return createdSpot;
      }

      // If online, try to sync with remote
      try {
        final remoteSpot = await remoteDataSource.createSpot(spot);
        // Update local with remote data
        await localDataSource.updateSpot(remoteSpot);
        return remoteSpot;
      } catch (e) {
        // If remote fails, return local data
        return createdSpot;
      }
    } catch (e) {
      throw Exception('Failed to create spot: $e');
    }
  }

  @override
  Future<Spot> updateSpot(Spot spot) async {
    try {
      // Always update locally first
      await localDataSource.updateSpot(spot);
      final updatedSpot = await localDataSource.getSpotById(spot.id);

      if (updatedSpot == null) {
        throw Exception('Failed to update spot locally');
      }

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return updatedSpot;
      }

      // If online, try to sync with remote
      try {
        final remoteSpot = await remoteDataSource.updateSpot(spot);
        // Update local with remote data
        await localDataSource.updateSpot(remoteSpot);
        return remoteSpot;
      } catch (e) {
        // If remote fails, return local data
        return updatedSpot;
      }
    } catch (e) {
      throw Exception('Failed to update spot: $e');
    }
  }

  @override
  Future<void> deleteSpot(String spotId) async {
    try {
      // Always delete locally first
      await localDataSource.deleteSpot(spotId);

      // Check connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return;
      }

      // If online, try to sync with remote
      try {
        await remoteDataSource.deleteSpot(spotId);
      } catch (e) {
        // If remote fails, local deletion is already done
      }
    } catch (e) {
      throw Exception('Failed to delete spot: $e');
    }
  }
}

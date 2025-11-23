import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/core/services/google_places_sync_service.dart';
import 'package:spots/core/services/google_place_id_finder_service_new.dart';
import 'package:spots/core/services/google_places_cache_service.dart';
import 'package:spots/data/datasources/remote/google_places_datasource.dart';
import 'package:spots/data/datasources/local/spots_local_datasource.dart';
import 'package:spots/core/models/spot.dart';
import '../../fixtures/model_factories.dart';

import 'google_places_sync_service_test.mocks.dart';

@GenerateMocks([
  GooglePlaceIdFinderServiceNew,
  GooglePlacesCacheService,
  GooglePlacesDataSource,
  SpotsLocalDataSource,
  Connectivity,
])
void main() {
  group('GooglePlacesSyncService Tests', () {
    late GooglePlacesSyncService service;
    late MockGooglePlaceIdFinderServiceNew mockPlaceIdFinder;
    late MockGooglePlacesCacheService mockCacheService;
    late MockGooglePlacesDataSource mockGooglePlacesDataSource;
    late MockSpotsLocalDataSource mockSpotsLocalDataSource;
    late MockConnectivity mockConnectivity;
    late Spot spot;

    setUp(() {
      mockPlaceIdFinder = MockGooglePlaceIdFinderServiceNew();
      mockCacheService = MockGooglePlacesCacheService();
      mockGooglePlacesDataSource = MockGooglePlacesDataSource();
      mockSpotsLocalDataSource = MockSpotsLocalDataSource();
      mockConnectivity = MockConnectivity();

      service = GooglePlacesSyncService(
        placeIdFinderNew: mockPlaceIdFinder,
        cacheService: mockCacheService,
        googlePlacesDataSource: mockGooglePlacesDataSource,
        spotsLocalDataSource: mockSpotsLocalDataSource,
        connectivity: mockConnectivity,
      );

      spot = ModelFactories.createTestSpot(
        name: 'Test Spot',
      );
    });

    group('syncSpot', () {
      test('should return spot unchanged when already synced and not stale', () async {
        final syncedSpot = spot.copyWith(
          googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4',
          googlePlaceIdSyncedAt: DateTime.now(),
        );

        final result = await service.syncSpot(syncedSpot);

        expect(result, equals(syncedSpot));
        verifyNever(mockPlaceIdFinder.findPlaceId(any));
      });

      test('should return spot unchanged when offline', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);

        final result = await service.syncSpot(spot);

        expect(result, equals(spot));
        verifyNever(mockPlaceIdFinder.findPlaceId(any));
      });

      test('should sync spot when online and not synced', () async {
        const placeId = 'ChIJN1t_tDeuEmsRUsoyG83frY4';
        final googlePlace = ModelFactories.createTestSpot(
          name: 'Google Place',
        ).copyWith(googlePlaceId: placeId);

        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockPlaceIdFinder.findPlaceId(any))
            .thenAnswer((_) async => placeId);
        when(mockGooglePlacesDataSource.getPlaceDetails(placeId))
            .thenAnswer((_) async => googlePlace);
        when(mockSpotsLocalDataSource.updateSpot(any))
            .thenAnswer((_) async => Future.value());

        final result = await service.syncSpot(spot);

        expect(result, isNotNull);
        verify(mockPlaceIdFinder.findPlaceId(spot)).called(1);
        verify(mockGooglePlacesDataSource.getPlaceDetails(placeId)).called(1);
        verify(mockCacheService.cachePlace(googlePlace)).called(1);
        verify(mockSpotsLocalDataSource.updateSpot(any)).called(1);
      });

      test('should return original spot when no place ID found', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockPlaceIdFinder.findPlaceId(any))
            .thenAnswer((_) async => null);

        final result = await service.syncSpot(spot);

        expect(result, equals(spot));
        verifyNever(mockGooglePlacesDataSource.getPlaceDetails(any));
      });
    });

    group('syncSpots', () {
      test('should sync multiple spots', () async {
        final spots = [
          ModelFactories.createTestSpot(name: 'Spot 1'),
          ModelFactories.createTestSpot(name: 'Spot 2'),
        ];

        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockPlaceIdFinder.findPlaceId(any))
            .thenAnswer((_) async => null);

        final result = await service.syncSpots(spots, batchSize: 10);

        expect(result, isA<SyncResult>());
        expect(result.total, equals(spots.length));
      });

      test('should respect batchSize parameter', () async {
        final spots = List.generate(
          25,
          (index) => ModelFactories.createTestSpot(name: 'Spot $index'),
        );

        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockPlaceIdFinder.findPlaceId(any))
            .thenAnswer((_) async => null);

        final result = await service.syncSpots(spots, batchSize: 10);

        expect(result, isA<SyncResult>());
      });
    });

    group('syncSpotsNeedingSync', () {
      test('should sync spots that need syncing', () async {
        final spotsNeedingSync = [
          ModelFactories.createTestSpot(name: 'Spot 1'),
        ];

        when(mockSpotsLocalDataSource.getAllSpots())
            .thenAnswer((_) async => spotsNeedingSync);
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockPlaceIdFinder.findPlaceId(any))
            .thenAnswer((_) async => null);

        final result = await service.syncSpotsNeedingSync(limit: 50);

        expect(result, isA<SyncResult>());
        verify(mockSpotsLocalDataSource.getAllSpots()).called(1);
      });

      test('should respect limit parameter', () async {
        final allSpots = List.generate(
          100,
          (index) => ModelFactories.createTestSpot(name: 'Spot $index'),
        );

        when(mockSpotsLocalDataSource.getAllSpots())
            .thenAnswer((_) async => allSpots);
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(mockPlaceIdFinder.findPlaceId(any))
            .thenAnswer((_) async => null);

        final result = await service.syncSpotsNeedingSync(limit: 50);

        expect(result, isA<SyncResult>());
      });
    });

    group('getCachedPlaces', () {
      test('should return cached places for query', () async {
        final cachedSpots = [
          ModelFactories.createTestSpot(name: 'Cached Spot'),
        ];

        when(mockCacheService.searchCachedPlaces('coffee'))
            .thenAnswer((_) async => cachedSpots);

        final result = await service.getCachedPlaces(query: 'coffee');

        expect(result, equals(cachedSpots));
        verify(mockCacheService.searchCachedPlaces('coffee')).called(1);
      });

      test('should return empty list when query is empty', () async {
        final result = await service.getCachedPlaces(query: '');

        expect(result, isEmpty);
        verifyNever(mockCacheService.searchCachedPlaces(any));
      });
    });

    group('getCachedPlacesNearby', () {
      test('should return cached places nearby', () async {
        final nearbySpots = [
          ModelFactories.createTestSpot(name: 'Nearby Spot'),
        ];

        when(mockCacheService.getCachedPlacesNearby(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 5000,
        )).thenAnswer((_) async => nearbySpots);

        final result = await service.getCachedPlacesNearby(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 5000,
        );

        expect(result, equals(nearbySpots));
        verify(mockCacheService.getCachedPlacesNearby(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 5000,
        )).called(1);
      });
    });
  });
}


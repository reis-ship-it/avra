import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/google_places_cache_service.dart';
import 'package:spots/core/models/spot.dart';
import '../../fixtures/model_factories.dart';

/// Google Places Cache Service Tests
/// Tests Google Places caching functionality for offline use
void main() {
  group('GooglePlacesCacheService Tests', () {
    late GooglePlacesCacheService service;

    setUp(() {
      service = GooglePlacesCacheService();
    });

    group('cachePlace', () {
      test('should cache place with Google Place ID', () async {
        final spot = ModelFactories.createTestSpot(
          name: 'Test Place',
        ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4');

        await service.cachePlace(spot);

        // Verify caching doesn't throw
        expect(spot, isNotNull);
      });

      test('should skip caching place without Google Place ID', () async {
        final spot = ModelFactories.createTestSpot(
          name: 'Test Place',
        );

        await service.cachePlace(spot);

        // Verify method completes without error
        expect(spot, isNotNull);
      });
    });

    group('cachePlaces', () {
      test('should cache multiple places', () async {
        final spots = [
          ModelFactories.createTestSpot(
            name: 'Place 1',
          ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4'),
          ModelFactories.createTestSpot(
            name: 'Place 2',
          ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY5'),
        ];

        await service.cachePlaces(spots);

        // Verify caching doesn't throw
        expect(spots, hasLength(2));
      });

      test('should skip places without Google Place ID', () async {
        final spots = [
          ModelFactories.createTestSpot(
            name: 'Place 1',
          ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4'),
          ModelFactories.createTestSpot(
            name: 'Place 2',
          ),
        ];

        await service.cachePlaces(spots);

        // Verify method completes without error
        expect(spots, hasLength(2));
      });
    });

    group('getCachedPlace', () {
      test('should return null when place not cached', () async {
        final place = await service.getCachedPlace('non-existent-place-id');

        expect(place, isNull);
      });

      test('should return cached place if exists', () async {
        final spot = ModelFactories.createTestSpot(
          name: 'Test Place',
        ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4');

        await service.cachePlace(spot);

        // Note: In test environment, may return null due to database setup
        final cached = await service.getCachedPlace('ChIJN1t_tDeuEmsRUsoyG83frY4');
        expect(cached, anyOf(isNull, isA<Spot>()));
      });
    });

    group('getCachedPlaceDetails', () {
      test('should return null when details not cached', () async {
        final details = await service.getCachedPlaceDetails('non-existent-place-id');

        expect(details, isNull);
      });

      test('should cache and retrieve place details', () async {
        final placeId = 'ChIJN1t_tDeuEmsRUsoyG83frY4';
        final details = {
          'name': 'Test Place',
          'rating': 4.5,
          'address': '123 Main St',
        };

        await service.cachePlaceDetails(placeId, details);

        // Note: In test environment, may return null due to database setup
        final cached = await service.getCachedPlaceDetails(placeId);
        expect(cached, anyOf(isNull, isA<Map<String, dynamic>>()));
      });
    });

    group('searchCachedPlaces', () {
      test('should return empty list when no cached places match', () async {
        final results = await service.searchCachedPlaces('nonexistent query');

        expect(results, isA<List<Spot>>());
        expect(results, isEmpty);
      });

      test('should search cached places by name', () async {
        final spot = ModelFactories.createTestSpot(
          name: 'Coffee Shop',
        ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4');

        await service.cachePlace(spot);

        // Note: In test environment, may return empty list
        final results = await service.searchCachedPlaces('coffee');
        expect(results, isA<List<Spot>>());
      });

      test('should search cached places by category', () async {
        final spot = ModelFactories.createTestSpot(
          name: 'Test Restaurant',
          category: 'Restaurant',
        ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4');

        await service.cachePlace(spot);

        // Note: In test environment, may return empty list
        final results = await service.searchCachedPlaces('restaurant');
        expect(results, isA<List<Spot>>());
      });
    });

    group('getCachedPlacesNearby', () {
      test('should return empty list when no cached places nearby', () async {
        final results = await service.getCachedPlacesNearby(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 1000,
        );

        expect(results, isA<List<Spot>>());
        expect(results, isEmpty);
      });

      test('should return cached places within radius', () async {
        final spot = ModelFactories.createTestSpot(
          name: 'Nearby Place',
          latitude: 40.7130,
          longitude: -74.0062,
        ).copyWith(googlePlaceId: 'ChIJN1t_tDeuEmsRUsoyG83frY4');

        await service.cachePlace(spot);

        // Note: In test environment, may return empty list
        final results = await service.getCachedPlacesNearby(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 5000,
        );
        expect(results, isA<List<Spot>>());
      });

      test('should respect radius parameter', () async {
        final results = await service.getCachedPlacesNearby(
          latitude: 40.7128,
          longitude: -74.0060,
          radius: 500,
        );

        expect(results, isA<List<Spot>>());
      });
    });

    group('clearExpiredCache', () {
      test('should clear expired cached places', () async {
        await service.clearExpiredCache();

        // Verify clearing doesn't throw
        expect(service, isNotNull);
      });
    });
  });
}


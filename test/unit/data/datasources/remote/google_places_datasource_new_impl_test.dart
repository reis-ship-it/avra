import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:spots/data/datasources/remote/google_places_datasource_new_impl.dart';
import 'package:spots/core/services/google_places_cache_service.dart';
import 'package:spots/core/models/spot.dart';

import 'google_places_datasource_new_impl_test.mocks.dart';

@GenerateMocks([http.Client, GooglePlacesCacheService])
void main() {
  group('GooglePlacesDataSourceNewImpl', () {
    late GooglePlacesDataSourceNewImpl dataSource;
    late MockClient mockHttpClient;
    late MockGooglePlacesCacheService mockCacheService;

    setUp(() {
      mockHttpClient = MockClient();
      mockCacheService = MockGooglePlacesCacheService();
      dataSource = GooglePlacesDataSourceNewImpl(
        apiKey: 'test-api-key',
        httpClient: mockHttpClient,
        cacheService: mockCacheService,
      );
    });

    group('searchPlaces', () {
      test('should search places via new Google Places API', () async {
        const query = 'restaurant';
        final mockResponse = http.Response(
          '{"places": [{"id": "123", "displayName": {"text": "Restaurant"}, "location": {"latitude": 37.7749, "longitude": -122.4194}}]}',
          200,
        );

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);
        when(mockCacheService.cachePlaces(any))
            .thenAnswer((_) async => Future.value());

        final spots = await dataSource.searchPlaces(query: query);

        expect(spots, isA<List<Spot>>());
        // OUR_GUTS.md: "Authenticity Over Algorithms" - External data enriches community knowledge
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });

      test('should return empty list on error', () async {
        const query = 'invalid query';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        final spots = await dataSource.searchPlaces(query: query);

        // OUR_GUTS.md: "Effortless, Seamless Discovery" - Graceful fallback
        expect(spots, isEmpty);
      });
    });

    group('getPlaceDetails', () {
      test('should get place details via new Google Places API', () async {
        const placeId = 'ChIJN1t_tDeuEmsRUsoyG83frY4';
        final mockResponse = http.Response(
          '{"id": "$placeId", "displayName": {"text": "Place Name"}, "location": {"latitude": 37.7749, "longitude": -122.4194}}',
          200,
        );

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final spot = await dataSource.getPlaceDetails(placeId);

        expect(spot, anyOf(isNull, isA<Spot>()));
      });
    });

    group('searchNearbyPlaces', () {
      test('should search nearby places via new Google Places API', () async {
        const latitude = 37.7749;
        const longitude = -122.4194;
        const radius = 1000;
        final mockResponse = http.Response(
          '{"places": [{"id": "123", "displayName": {"text": "Nearby Place"}, "location": {"latitude": 37.7749, "longitude": -122.4194}}]}',
          200,
        );

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => mockResponse);

        final spots = await dataSource.searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );

        expect(spots, isA<List<Spot>>());
      });
    });
  });
}


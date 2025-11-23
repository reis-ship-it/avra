import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spots/core/services/google_place_id_finder_service_new.dart';
import 'package:spots/core/models/spot.dart';
import '../../fixtures/model_factories.dart';

import 'google_place_id_finder_service_new_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('GooglePlaceIdFinderServiceNew Tests', () {
    late GooglePlaceIdFinderServiceNew service;
    late MockClient mockHttpClient;
    late Spot spot;

    setUp(() {
      mockHttpClient = MockClient();
      service = GooglePlaceIdFinderServiceNew(
        apiKey: 'test-api-key',
        httpClient: mockHttpClient,
      );
      spot = ModelFactories.createTestSpot(
        name: 'Test Restaurant',
        latitude: 40.7128,
        longitude: -74.0060,
      );
    });

    group('findPlaceId', () {
      test('should return null when no place ID found', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
          (_) async => http.Response(
            '{"places": []}',
            200,
          ),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, isNull);
      });

      test('should return place ID when found via nearby search', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'places/ChIJN1t_tDeuEmsRUsoyG83frY4',
                  'displayName': {
                    'text': 'Test Restaurant',
                  },
                  'location': {
                    'latitude': 40.7128,
                    'longitude': -74.0060,
                  },
                },
              ],
            }),
            200,
          ),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, equals('ChIJN1t_tDeuEmsRUsoyG83frY4'));
      });

      test('should remove places/ prefix from place ID', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'places/ChIJN1t_tDeuEmsRUsoyG83frY4',
                  'displayName': {
                    'text': 'Test Restaurant',
                  },
                  'location': {
                    'latitude': 40.7128,
                    'longitude': -74.0060,
                  },
                },
              ],
            }),
            200,
          ),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, isNotNull);
        expect(placeId, isNot(contains('places/')));
      });

      test('should return null when distance exceeds threshold', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'places/ChIJN1t_tDeuEmsRUsoyG83frY4',
                  'displayName': {
                    'text': 'Test Restaurant',
                  },
                  'location': {
                    'latitude': 40.8, // Far away
                    'longitude': -74.1,
                  },
                },
              ],
            }),
            200,
          ),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, isNull);
      });

      test('should return null when name similarity is too low', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'places/ChIJN1t_tDeuEmsRUsoyG83frY4',
                  'displayName': {
                    'text': 'Completely Different Name',
                  },
                  'location': {
                    'latitude': 40.7128,
                    'longitude': -74.0060,
                  },
                },
              ],
            }),
            200,
          ),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, isNull);
      });

      test('should try text search when nearby search fails', () async {
        // First call (nearby search) returns empty
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: argThat(contains('searchNearby'), named: 'body'),
        )).thenAnswer(
          (_) async => http.Response(
            '{"places": []}',
            200,
          ),
        );

        // Second call (text search) returns a match
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: argThat(contains('searchText'), named: 'body'),
        )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'places/ChIJN1t_tDeuEmsRUsoyG83frY4',
                  'displayName': {
                    'text': 'Test Restaurant',
                  },
                  'location': {
                    'latitude': 40.7128,
                    'longitude': -74.0060,
                  },
                },
              ],
            }),
            200,
          ),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, equals('ChIJN1t_tDeuEmsRUsoyG83frY4'));
      });

      test('should handle HTTP errors gracefully', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
          (_) async => http.Response('Error', 500),
        );

        final placeId = await service.findPlaceId(spot);

        expect(placeId, isNull);
      });

      test('should handle network exceptions gracefully', () async {
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        final placeId = await service.findPlaceId(spot);

        expect(placeId, isNull);
      });
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:spots/data/datasources/remote/google_places_datasource_impl.dart';

import 'google_places_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('Google Places API Tests', () {
    late GooglePlacesDataSourceImpl googlePlaces;
    late MockClient mockClient;
    
    setUp(() {
      mockClient = MockClient();
      googlePlaces = GooglePlacesDataSourceImpl(
        apiKey: 'test_api_key',
        httpClient: mockClient,
      );
    });

    group('OUR_GUTS.md Compliance', () {
      test('marks external data with clear source indicators', () async {
        // Mock successful response
        final mockResponse = '''
        {
          "results": [
            {
              "place_id": "test_place_123",
              "name": "Test Restaurant",
              "formatted_address": "123 Test St, Test City",
              "geometry": {
                "location": {
                  "lat": 40.7589,
                  "lng": -73.9851
                }
              },
              "rating": 4.5,
              "types": ["restaurant", "food"]
            }
          ]
        }
        ''';
        
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(mockResponse, 200),
        );

        final spots = await googlePlaces.searchPlaces(query: 'restaurant');
        
        expect(spots.length, 1);
        final spot = spots.first;
        
        // OUR_GUTS.md: "Privacy and Control Are Non-Negotiable"
        expect(spot.tags, contains('external_data'));
        expect(spot.tags, contains('google_places'));
        expect(spot.metadata['source'], 'google_places');
        expect(spot.metadata['is_external'], true);
        expect(spot.createdBy, 'google_places_api');
      });

      test('maintains authenticity over algorithms principle', () async {
        final mockResponse = '''
        {
          "results": [
            {
              "place_id": "test_place_456",
              "name": "Authentic Local Spot",
              "formatted_address": "456 Local Ave",
              "geometry": {
                "location": {
                  "lat": 40.7505,
                  "lng": -73.9934
                }
              },
              "rating": 4.2,
              "types": ["tourist_attraction"]
            }
          ]
        }
        ''';
        
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(mockResponse, 200),
        );

        final spots = await googlePlaces.searchPlaces(query: 'local attraction');
        
        expect(spots.length, 1);
        final spot = spots.first;
        
        // Verify external data doesn't masquerade as community content
        expect(spot.id, startsWith('google_'));
        expect(spot.createdBy, 'google_places_api');
        expect(spot.metadata['source'], 'google_places');
      });
    });

    group('Performance and Reliability', () {
      test('implements caching for performance', () async {
        final mockResponse = '''
        {
          "results": [
            {
              "place_id": "cached_place",
              "name": "Cached Restaurant",
              "formatted_address": "789 Cache St",
              "geometry": {
                "location": {
                  "lat": 40.7600,
                  "lng": -73.9800
                }
              },
              "rating": 4.0,
              "types": ["restaurant"]
            }
          ]
        }
        ''';
        
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(mockResponse, 200),
        );

        // First call should hit the API
        final spots1 = await googlePlaces.searchPlaces(query: 'test restaurant');
        expect(spots1.length, 1);
        
        // Second identical call should use cache (no additional HTTP call)
        final spots2 = await googlePlaces.searchPlaces(query: 'test restaurant');
        expect(spots2.length, 1);
        expect(spots2.first.name, spots1.first.name);
        
        // Verify only one HTTP call was made
        verify(mockClient.get(any)).called(1);
      });

      test('handles API errors gracefully', () async {
        // Mock API error
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('API Error', 500),
        );

        // OUR_GUTS.md: "Effortless, Seamless Discovery"
        final spots = await googlePlaces.searchPlaces(query: 'error test');
        
        // Should return empty list, not throw exception
        expect(spots, isEmpty);
      });

      test('handles network errors gracefully', () async {
        // Mock network error
        when(mockClient.get(any)).thenThrow(Exception('Network error'));

        final spots = await googlePlaces.searchPlaces(query: 'network test');
        
        // Should return empty list, not throw exception
        expect(spots, isEmpty);
      });
    });

    group('Google Places API Functionality', () {
      test('searches places with location bias', () async {
        final mockResponse = '''
        {
          "results": [
            {
              "place_id": "location_biased_place",
              "name": "Nearby Cafe",
              "formatted_address": "Near User Location",
              "geometry": {
                "location": {
                  "lat": 40.7589,
                  "lng": -73.9851
                }
              },
              "rating": 4.3,
              "types": ["cafe"]
            }
          ]
        }
        ''';
        
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(mockResponse, 200),
        );

        final spots = await googlePlaces.searchPlaces(
          query: 'cafe',
          latitude: 40.7589,
          longitude: -73.9851,
          radius: 1000,
        );
        
        expect(spots.length, 1);
        expect(spots.first.name, 'Nearby Cafe');
        expect(spots.first.category, 'Other'); // cafe maps to Other category
      });

      test('searches nearby places', () async {
        final mockResponse = '''
        {
          "results": [
            {
              "place_id": "nearby_place_1",
              "name": "Nearby Restaurant",
              "formatted_address": "Close by",
              "geometry": {
                "location": {
                  "lat": 40.7590,
                  "lng": -73.9850
                }
              },
              "rating": 4.1,
              "types": ["restaurant"]
            }
          ]
        }
        ''';
        
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(mockResponse, 200),
        );

        final spots = await googlePlaces.searchNearbyPlaces(
          latitude: 40.7589,
          longitude: -73.9851,
          radius: 500,
          type: 'restaurant',
        );
        
        expect(spots.length, 1);
        expect(spots.first.name, 'Nearby Restaurant');
        expect(spots.first.category, 'Food');
      });

      test('gets place details', () async {
        final mockResponse = '''
        {
          "result": {
            "place_id": "detailed_place",
            "name": "Detailed Restaurant",
            "formatted_address": "123 Detail St, Detail City",
            "geometry": {
              "location": {
                "lat": 40.7595,
                "lng": -73.9845
              }
            },
            "rating": 4.7,
            "types": ["restaurant"],
            "formatted_phone_number": "(555) 123-4567",
            "website": "https://example.com",
            "opening_hours": {
              "open_now": true
            }
          }
        }
        ''';
        
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response(mockResponse, 200),
        );

        final spot = await googlePlaces.getPlaceDetails('detailed_place');
        
        expect(spot, isNotNull);
        expect(spot!.name, 'Detailed Restaurant');
        expect(spot.metadata['phone'], '(555) 123-4567');
        expect(spot.metadata['website'], 'https://example.com');
        expect(spot.metadata['opening_hours'], isNotNull);
      });
    });

    group('Category Mapping', () {
      test('maps Google types to SPOTS categories correctly', () async {
        final testCases = [
          {'types': ['restaurant'], 'expected': 'Food'},
          {'types': ['tourist_attraction'], 'expected': 'Attractions'},
          {'types': ['shopping_mall'], 'expected': 'Shopping'},
          {'types': ['night_club'], 'expected': 'Nightlife'},
          {'types': ['lodging'], 'expected': 'Stay'},
          {'types': ['unknown_type'], 'expected': 'Other'},
        ];
        
        for (final testCase in testCases) {
          final types = testCase['types'] as List<String>;
          final expected = testCase['expected'] as String;
          
          final mockResponse = '''
          {
            "results": [
              {
                "place_id": "category_test",
                "name": "Test Place",
                "formatted_address": "Test Address",
                "geometry": {
                  "location": {
                    "lat": 40.7589,
                    "lng": -73.9851
                  }
                },
                "rating": 4.0,
                "types": ${types.map((t) => '"$t"').toList()}
              }
            ]
          }
          ''';
          
          when(mockClient.get(any)).thenAnswer(
            (_) async => http.Response(mockResponse, 200),
          );

          final spots = await googlePlaces.searchPlaces(query: 'test');
          expect(spots.first.category, expected);
        }
      });
    });
  });
}
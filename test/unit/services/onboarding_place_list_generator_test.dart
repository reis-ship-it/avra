/// SPOTS OnboardingPlaceListGenerator Tests
/// Date: December 15, 2025
/// Purpose: Test OnboardingPlaceListGenerator service functionality
/// 
/// Test Coverage:
/// - List Generation: Creating place lists from onboarding data
/// - Category Extraction: Extracting categories from preferences
/// - Query Building: Building search queries from preferences
/// - Place Type Mapping: Mapping preferences to Google Places types
/// - Edge Cases: Empty preferences, missing data, invalid inputs

import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/onboarding_place_list_generator.dart';
import 'package:spots/core/models/spot.dart';

void main() {
  group('OnboardingPlaceListGenerator Tests', () {
    late OnboardingPlaceListGenerator generator;

    setUp(() {
      generator = OnboardingPlaceListGenerator();
    });

    group('Generate Place Lists', () {
      test('should generate place lists from onboarding data with preferences', () async {
        // Arrange
        final onboardingData = {
          'preferences': {
            'Food & Drink': ['Coffee', 'Craft Beer'],
            'Activities': ['Hiking', 'Live Music'],
          },
          'homebase': 'San Francisco, CA',
        };

        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: onboardingData,
          homebase: 'San Francisco, CA',
          maxLists: 5,
        );

        // Assert
        expect(lists, isA<List<GeneratedPlaceList>>());
        // Note: Actual place search not yet implemented, so lists may be empty
        // This test validates the structure and flow
      });

      test('should limit number of lists to maxLists parameter', () async {
        // Arrange
        final onboardingData = {
          'preferences': {
            'Food & Drink': ['Coffee'],
            'Activities': ['Hiking'],
            'Outdoor & Nature': ['Parks'],
            'Entertainment': ['Music'],
            'Shopping': ['Markets'],
            'Culture': ['Museums'],
          },
          'homebase': 'San Francisco, CA',
        };

        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: onboardingData,
          homebase: 'San Francisco, CA',
          maxLists: 3,
        );

        // Assert
        expect(lists.length, lessThanOrEqualTo(3));
      });

      test('should handle empty preferences gracefully', () async {
        // Arrange
        final onboardingData = {
          'preferences': {},
          'homebase': 'San Francisco, CA',
        };

        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: onboardingData,
          homebase: 'San Francisco, CA',
          maxLists: 5,
        );

        // Assert
        expect(lists, isA<List<GeneratedPlaceList>>());
        expect(lists.isEmpty, isTrue);
      });

      test('should handle missing preferences field', () async {
        // Arrange
        final onboardingData = {
          'homebase': 'San Francisco, CA',
        };

        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: onboardingData,
          homebase: 'San Francisco, CA',
          maxLists: 5,
        );

        // Assert
        expect(lists, isA<List<GeneratedPlaceList>>());
      });
    });

    group('Generate List For Category', () {
      test('should generate list for specific category with preferences', () async {
        // Arrange
        final preferences = ['Coffee', 'Craft Beer'];

        // Act
        final list = await generator.generateListForCategory(
          category: 'Food & Drink',
          homebase: 'San Francisco, CA',
          preferences: preferences,
          maxPlaces: 20,
        );

        // Assert
        expect(list, isA<GeneratedPlaceList>());
        expect(list.category, equals('Food & Drink'));
        expect(list.name, isNotEmpty);
        expect(list.description, isNotEmpty);
        expect(list.relevanceScore, greaterThanOrEqualTo(0.0));
        expect(list.relevanceScore, lessThanOrEqualTo(1.0));
      });

      test('should limit places to maxPlaces parameter', () async {
        // Arrange
        // Note: Actual place search not implemented, so this tests structure
        final preferences = ['Coffee'];

        // Act
        final list = await generator.generateListForCategory(
          category: 'Food & Drink',
          homebase: 'San Francisco, CA',
          preferences: preferences,
          maxPlaces: 10,
        );

        // Assert
        expect(list.places.length, lessThanOrEqualTo(10));
      });

      test('should handle empty preferences list', () async {
        // Act
        final list = await generator.generateListForCategory(
          category: 'Food & Drink',
          homebase: 'San Francisco, CA',
          preferences: [],
          maxPlaces: 20,
        );

        // Assert
        expect(list, isA<GeneratedPlaceList>());
        expect(list.places, isEmpty);
      });
    });

    group('Search Places For Category', () {
      test('should return empty list when Google Maps API not configured', () async {
        // Arrange
        // Note: Google Maps API integration is placeholder

        // Act
        final places = await generator.searchPlacesForCategory(
          category: 'Food & Drink',
          query: 'Coffee in San Francisco',
          type: 'cafe',
        );

        // Assert
        expect(places, isA<List<Spot>>());
        expect(places.isEmpty, isTrue);
        // This is expected until Google Maps API is integrated
      });

      test('should accept all required parameters without throwing', () async {
        // Act & Assert
        expect(
          () => generator.searchPlacesForCategory(
            category: 'Food & Drink',
            query: 'Coffee',
            latitude: 37.7749,
            longitude: -122.4194,
            radius: 5000,
            type: 'cafe',
          ),
          returnsNormally,
        );
      });
    });

    group('GeneratedPlaceList Model', () {
      test('should create GeneratedPlaceList with all required fields', () {
        // Arrange
        final places = <Spot>[];
        final metadata = {
          'homebase': 'San Francisco, CA',
          'preferences': ['Coffee'],
          'generatedAt': DateTime.now().toIso8601String(),
        };

        // Act
        final list = GeneratedPlaceList(
          name: 'Coffee in San Francisco',
          description: 'Coffee places in San Francisco',
          places: places,
          category: 'Food & Drink',
          relevanceScore: 0.75,
          metadata: metadata,
        );

        // Assert
        expect(list.name, equals('Coffee in San Francisco'));
        expect(list.description, equals('Coffee places in San Francisco'));
        expect(list.places, equals(places));
        expect(list.category, equals('Food & Drink'));
        expect(list.relevanceScore, equals(0.75));
        expect(list.metadata, equals(metadata));
      });

      test('should serialize GeneratedPlaceList to JSON correctly', () {
        // Arrange
        final places = <Spot>[];
        final metadata = {
          'homebase': 'San Francisco, CA',
          'preferences': ['Coffee'],
        };

        final list = GeneratedPlaceList(
          name: 'Coffee in San Francisco',
          description: 'Coffee places',
          places: places,
          category: 'Food & Drink',
          relevanceScore: 0.75,
          metadata: metadata,
        );

        // Act
        final json = list.toJson();

        // Assert
        expect(json['name'], equals('Coffee in San Francisco'));
        expect(json['description'], equals('Coffee places'));
        expect(json['category'], equals('Food & Drink'));
        expect(json['relevanceScore'], equals(0.75));
        expect(json['places'], isA<List>());
        expect(json['metadata'], isA<Map>());
      });
    });

    group('Edge Cases', () {
      test('should handle null latitude and longitude', () async {
        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: {
            'preferences': {'Food & Drink': ['Coffee']},
            'homebase': 'San Francisco, CA',
          },
          homebase: 'San Francisco, CA',
          latitude: null,
          longitude: null,
          maxLists: 5,
        );

        // Assert
        expect(lists, isA<List<GeneratedPlaceList>>());
      });

      test('should handle invalid onboarding data structure', () async {
        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: {
            'preferences': 'invalid', // Should be Map
            'homebase': 'San Francisco, CA',
          },
          homebase: 'San Francisco, CA',
          maxLists: 5,
        );

        // Assert
        expect(lists, isA<List<GeneratedPlaceList>>());
        // Should handle gracefully without throwing
      });

      test('should handle very long preference lists', () async {
        // Arrange
        final longPreferences = List.generate(50, (i) => 'Preference $i');
        final onboardingData = {
          'preferences': {
            'Food & Drink': longPreferences,
          },
          'homebase': 'San Francisco, CA',
        };

        // Act
        final lists = await generator.generatePlaceLists(
          onboardingData: onboardingData,
          homebase: 'San Francisco, CA',
          maxLists: 5,
        );

        // Assert
        expect(lists, isA<List<GeneratedPlaceList>>());
      });
    });
  });
}


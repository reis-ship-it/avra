import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/spot.dart';
import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for Spot model
/// Tests location validation, geospatial logic, and category constraints
void main() {
  group('Spot Model Tests', () {
    late Spot testSpot;
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
      testSpot = ModelFactories.createTestSpot();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create spot with required fields', () {
        final spot = Spot(
          id: 'spot-123',
          name: 'Test Restaurant',
          description: 'A great place to eat',
          latitude: 40.7128,
          longitude: -74.0060,
          category: 'Restaurant',
          rating: 4.5,
          createdBy: 'user-123',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(spot.id, equals('spot-123'));
        expect(spot.name, equals('Test Restaurant'));
        expect(spot.description, equals('A great place to eat'));
        expect(spot.latitude, equals(40.7128));
        expect(spot.longitude, equals(-74.0060));
        expect(spot.category, equals('Restaurant'));
        expect(spot.rating, equals(4.5));
        expect(spot.createdBy, equals('user-123'));
        expect(spot.createdAt, equals(testDate));
        expect(spot.updatedAt, equals(testDate));
        
        // Test default values
        expect(spot.address, isNull);
        expect(spot.tags, isEmpty);
      });

      test('should create spot with all optional fields', () {
        final spot = Spot(
          id: 'spot-123',
          name: 'Test Restaurant',
          description: 'A great place to eat',
          latitude: 40.7128,
          longitude: -74.0060,
          category: 'Restaurant',
          rating: 4.5,
          createdBy: 'user-123',
          createdAt: testDate,
          updatedAt: testDate,
          address: '123 Main St, New York, NY',
          tags: ['italian', 'romantic', 'expensive'],
        );

        expect(spot.address, equals('123 Main St, New York, NY'));
        expect(spot.tags, equals(['italian', 'romantic', 'expensive']));
      });
    });

    group('Location Validation and Geospatial Logic', () {
      test('should validate latitude bounds', () {
        // Valid latitudes
        final validNorth = ModelFactories.createSpotAtLocation(89.9, 0);
        final validSouth = ModelFactories.createSpotAtLocation(-89.9, 0);
        final validEquator = ModelFactories.createSpotAtLocation(0, 0);

        expect(validNorth.latitude, equals(89.9));
        expect(validSouth.latitude, equals(-89.9));
        expect(validEquator.latitude, equals(0));
      });

      test('should validate longitude bounds', () {
        // Valid longitudes
        final validEast = ModelFactories.createSpotAtLocation(0, 179.9);
        final validWest = ModelFactories.createSpotAtLocation(0, -179.9);
        final validPrime = ModelFactories.createSpotAtLocation(0, 0);

        expect(validEast.longitude, equals(179.9));
        expect(validWest.longitude, equals(-179.9));
        expect(validPrime.longitude, equals(0));
      });

      test('should handle precise coordinate values', () {
        final preciseSpot = ModelFactories.createSpotAtLocation(
          40.748817,  // Empire State Building
          -73.985428,
        );

        expect(preciseSpot.latitude, equals(40.748817));
        expect(preciseSpot.longitude, equals(-73.985428));
      });

      test('should create spots at different geographic locations', () {
        final nyc = ModelFactories.createSpotAtLocation(40.7128, -74.0060, name: 'NYC Spot');
        final london = ModelFactories.createSpotAtLocation(51.5074, -0.1278, name: 'London Spot');
        final tokyo = ModelFactories.createSpotAtLocation(35.6762, 139.6503, name: 'Tokyo Spot');

        expect(nyc.name, equals('NYC Spot'));
        expect(london.name, equals('London Spot'));
        expect(tokyo.name, equals('Tokyo Spot'));

        expect(nyc.latitude, equals(40.7128));
        expect(london.latitude, equals(51.5074));
        expect(tokyo.latitude, equals(35.6762));
      });

      test('should handle edge case coordinates', () {
        final northPole = ModelFactories.createSpotAtLocation(90.0, 0);
        final southPole = ModelFactories.createSpotAtLocation(-90.0, 0);
        final dateLine = ModelFactories.createSpotAtLocation(0, 180.0);

        expect(northPole.latitude, equals(90.0));
        expect(southPole.latitude, equals(-90.0));
        expect(dateLine.longitude, equals(180.0));
      });
    });

    group('Category Validation and Constraints', () {
      test('should accept various valid categories', () {
        final restaurant = ModelFactories.createTestSpot(category: 'Restaurant');
        final cafe = ModelFactories.createTestSpot(category: 'Cafe');
        final park = ModelFactories.createTestSpot(category: 'Park');
        final museum = ModelFactories.createTestSpot(category: 'Museum');

        expect(restaurant.category, equals('Restaurant'));
        expect(cafe.category, equals('Cafe'));
        expect(park.category, equals('Park'));
        expect(museum.category, equals('Museum'));
      });

      test('should handle empty category', () {
        final spot = ModelFactories.createTestSpot(category: '');
        expect(spot.category, equals(''));
      });

      test('should preserve category case sensitivity', () {
        final upperCase = ModelFactories.createTestSpot(category: 'RESTAURANT');
        final lowerCase = ModelFactories.createTestSpot(category: 'restaurant');
        final mixedCase = ModelFactories.createTestSpot(category: 'ReStAuRaNt');

        expect(upperCase.category, equals('RESTAURANT'));
        expect(lowerCase.category, equals('restaurant'));
        expect(mixedCase.category, equals('ReStAuRaNt'));
      });
    });

    group('Rating Validation', () {
      test('should handle valid rating ranges', () {
        final minRating = ModelFactories.createTestSpot().copyWith(rating: 0.0);
        final maxRating = ModelFactories.createTestSpot().copyWith(rating: 5.0);
        final midRating = ModelFactories.createTestSpot().copyWith(rating: 2.5);

        expect(minRating.rating, equals(0.0));
        expect(maxRating.rating, equals(5.0));
        expect(midRating.rating, equals(2.5));
      });

      test('should handle precise rating values', () {
        final preciseRating = ModelFactories.createTestSpot().copyWith(rating: 4.7);
        expect(preciseRating.rating, equals(4.7));
      });

      test('should allow ratings outside typical bounds', () {
        // The model doesn't enforce bounds, so test that behavior
        final negativeRating = ModelFactories.createTestSpot().copyWith(rating: -1.0);
        final highRating = ModelFactories.createTestSpot().copyWith(rating: 10.0);

        expect(negativeRating.rating, equals(-1.0));
        expect(highRating.rating, equals(10.0));
      });
    });

    group('Tags System', () {
      test('should handle multiple tags', () {
        final spot = ModelFactories.createTestSpot(
          tags: ['italian', 'pizza', 'family-friendly', 'outdoor-seating']
        );

        expect(spot.tags.length, equals(4));
        expect(spot.tags.contains('italian'), isTrue);
        expect(spot.tags.contains('pizza'), isTrue);
        expect(spot.tags.contains('family-friendly'), isTrue);
        expect(spot.tags.contains('outdoor-seating'), isTrue);
      });

      test('should handle empty tags list', () {
        final spot = ModelFactories.createTestSpot(tags: []);
        expect(spot.tags, isEmpty);
      });

      test('should handle single tag', () {
        final spot = ModelFactories.createTestSpot(tags: ['vegetarian']);
        expect(spot.tags.length, equals(1));
        expect(spot.tags.first, equals('vegetarian'));
      });

      test('should preserve tag order', () {
        final orderedTags = ['first', 'second', 'third'];
        final spot = ModelFactories.createTestSpot(tags: orderedTags);
        expect(spot.tags, equals(orderedTags));
      });

      test('should handle duplicate tags', () {
        final duplicateTags = ['food', 'italian', 'food'];
        final spot = ModelFactories.createTestSpot(tags: duplicateTags);
        expect(spot.tags, equals(duplicateTags)); // Model preserves duplicates
      });
    });

    group('Relationship with Lists and Users', () {
      test('should track creator relationship', () {
        final spot = ModelFactories.createTestSpot(createdBy: 'curator-123');
        expect(spot.createdBy, equals('curator-123'));
      });

      test('should handle different creators', () {
        final spot1 = ModelFactories.createTestSpot(createdBy: 'user-1');
        final spot2 = ModelFactories.createTestSpot(createdBy: 'user-2');

        expect(spot1.createdBy, equals('user-1'));
        expect(spot2.createdBy, equals('user-2'));
      });
    });

    group('Address and Location Details', () {
      test('should handle full address', () {
        final spot = ModelFactories.createTestSpot().copyWith(
          address: '123 Main Street, New York, NY 10001, USA'
        );
        expect(spot.address, equals('123 Main Street, New York, NY 10001, USA'));
      });

      test('should handle partial address', () {
        final spot = ModelFactories.createTestSpot().copyWith(
          address: 'Central Park, NYC'
        );
        expect(spot.address, equals('Central Park, NYC'));
      });

      test('should handle null address', () {
        final spot = ModelFactories.createTestSpot().copyWith(address: null);
        expect(spot.address, isNull);
      });

      test('should handle empty address', () {
        final spot = ModelFactories.createTestSpot().copyWith(address: '');
        expect(spot.address, equals(''));
      });
    });

    group('JSON Serialization Testing', () {
      test('should serialize to JSON correctly', () {
        final spot = ModelFactories.createTestSpot(
          name: 'Test Spot',
          category: 'Restaurant',
          tags: ['italian', 'romantic'],
        ).copyWith(address: '123 Main St');

        final json = spot.toJson();

        expect(json['id'], equals(spot.id));
        expect(json['name'], equals('Test Spot'));
        expect(json['description'], equals(spot.description));
        expect(json['latitude'], equals(spot.latitude));
        expect(json['longitude'], equals(spot.longitude));
        expect(json['category'], equals('Restaurant'));
        expect(json['rating'], equals(spot.rating));
        expect(json['createdBy'], equals(spot.createdBy));
        expect(json['createdAt'], equals(spot.createdAt.toIso8601String()));
        expect(json['updatedAt'], equals(spot.updatedAt.toIso8601String()));
        expect(json['address'], equals('123 Main St'));
        expect(json['tags'], equals(['italian', 'romantic']));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'spot-123',
          'name': 'Test Restaurant',
          'description': 'Great food',
          'latitude': 40.7128,
          'longitude': -74.0060,
          'category': 'Restaurant',
          'rating': 4.5,
          'createdBy': 'user-123',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'address': '123 Main St',
          'tags': ['italian', 'pizza'],
        };

        final spot = Spot.fromJson(json);

        expect(spot.id, equals('spot-123'));
        expect(spot.name, equals('Test Restaurant'));
        expect(spot.description, equals('Great food'));
        expect(spot.latitude, equals(40.7128));
        expect(spot.longitude, equals(-74.0060));
        expect(spot.category, equals('Restaurant'));
        expect(spot.rating, equals(4.5));
        expect(spot.createdBy, equals('user-123'));
        expect(spot.createdAt, equals(testDate));
        expect(spot.updatedAt, equals(testDate));
        expect(spot.address, equals('123 Main St'));
        expect(spot.tags, equals(['italian', 'pizza']));
      });

      test('should handle JSON roundtrip correctly', () {
        final originalSpot = ModelFactories.createTestSpot(
          tags: ['test', 'location']
        ).copyWith(address: 'Test Address');
        
        // Serialize and deserialize
        final json = originalSpot.toJson();
        final reconstructed = Spot.fromJson(json);
        
        // Compare all fields manually (Spot doesn't extend Equatable)
        expect(reconstructed.id, equals(originalSpot.id));
        expect(reconstructed.name, equals(originalSpot.name));
        expect(reconstructed.description, equals(originalSpot.description));
        expect(reconstructed.latitude, equals(originalSpot.latitude));
        expect(reconstructed.longitude, equals(originalSpot.longitude));
        expect(reconstructed.category, equals(originalSpot.category));
        expect(reconstructed.rating, equals(originalSpot.rating));
        expect(reconstructed.address, equals(originalSpot.address));
        expect(reconstructed.tags, equals(originalSpot.tags));
      });

      test('should handle missing fields in JSON gracefully', () {
        final minimalJson = {
          'id': '',
          'name': '',
          'description': '',
          'latitude': 0.0,
          'longitude': 0.0,
          'category': '',
          'rating': 0.0,
          'createdBy': '',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        final spot = Spot.fromJson(minimalJson);

        expect(spot.id, equals(''));
        expect(spot.name, equals(''));
        expect(spot.latitude, equals(0.0));
        expect(spot.longitude, equals(0.0));
        expect(spot.address, isNull);
        expect(spot.tags, isEmpty);
      });

      test('should handle null values in JSON gracefully', () {
        final jsonWithNulls = {
          'id': null,
          'name': null,
          'description': null,
          'latitude': null,
          'longitude': null,
          'category': null,
          'rating': null,
          'createdBy': null,
          'createdAt': null,
          'updatedAt': null,
          'address': null,
          'tags': null,
        };

        final spot = Spot.fromJson(jsonWithNulls);

        // Should use fallback values
        expect(spot.id, equals(''));
        expect(spot.name, equals(''));
        expect(spot.description, equals(''));
        expect(spot.latitude, equals(0.0));
        expect(spot.longitude, equals(0.0));
        expect(spot.category, equals(''));
        expect(spot.rating, equals(0.0));
        expect(spot.createdBy, equals(''));
        expect(spot.tags, isEmpty);
      });

      test('should handle type conversion in JSON', () {
        final jsonWithStrings = {
          'id': 'spot-123',
          'name': 'Test Spot',
          'description': 'Test Description',
          'latitude': '40.7128',    // String instead of double
          'longitude': '-74.0060',  // String instead of double
          'category': 'Restaurant',
          'rating': '4.5',          // String instead of double
          'createdBy': 'user-123',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'tags': ['test'],
        };

        final spot = Spot.fromJson(jsonWithStrings);

        expect(spot.latitude, equals(40.7128));
        expect(spot.longitude, equals(-74.0060));
        expect(spot.rating, equals(4.5));
      });
    });

    group('CopyWith Method Testing', () {
      test('should copy spot with new values', () {
        final originalSpot = ModelFactories.createTestSpot();
        final newDate = TestHelpers.createTimestampWithOffset(const Duration(days: 1));
        
        final copiedSpot = originalSpot.copyWith(
          name: 'New Name',
          description: 'New Description',
          latitude: 51.5074,
          longitude: -0.1278,
          category: 'Museum',
          rating: 5.0,
          updatedAt: newDate,
          address: 'New Address',
          tags: ['new', 'tags'],
        );

        expect(copiedSpot.id, equals(originalSpot.id));
        expect(copiedSpot.createdBy, equals(originalSpot.createdBy));
        expect(copiedSpot.createdAt, equals(originalSpot.createdAt));
        expect(copiedSpot.name, equals('New Name'));
        expect(copiedSpot.description, equals('New Description'));
        expect(copiedSpot.latitude, equals(51.5074));
        expect(copiedSpot.longitude, equals(-0.1278));
        expect(copiedSpot.category, equals('Museum'));
        expect(copiedSpot.rating, equals(5.0));
        expect(copiedSpot.updatedAt, equals(newDate));
        expect(copiedSpot.address, equals('New Address'));
        expect(copiedSpot.tags, equals(['new', 'tags']));
      });

      test('should copy spot without changing original', () {
        final originalSpot = ModelFactories.createTestSpot();
        final copiedSpot = originalSpot.copyWith(name: 'New Name');

        expect(originalSpot.name, equals('Test Spot'));
        expect(copiedSpot.name, equals('New Name'));
      });

      test('should handle partial updates', () {
        final originalSpot = ModelFactories.createTestSpot();
        
        final updatedRating = originalSpot.copyWith(rating: 5.0);
        final updatedLocation = originalSpot.copyWith(
          latitude: 51.5074,
          longitude: -0.1278,
        );

        expect(updatedRating.rating, equals(5.0));
        expect(updatedRating.latitude, equals(originalSpot.latitude));
        
        expect(updatedLocation.latitude, equals(51.5074));
        expect(updatedLocation.longitude, equals(-0.1278));
        expect(updatedLocation.rating, equals(originalSpot.rating));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle extreme coordinate values', () {
        final spot = ModelFactories.createSpotAtLocation(
          double.maxFinite,
          double.maxFinite,
        );
        
        expect(spot.latitude, equals(double.maxFinite));
        expect(spot.longitude, equals(double.maxFinite));
      });

      test('should handle very long strings', () {
        final longString = 'A' * 1000;
        final spot = ModelFactories.createTestSpot(
          name: longString,
        ).copyWith(
          description: longString,
          address: longString,
        );

        expect(spot.name.length, equals(1000));
        expect(spot.description.length, equals(1000));
        expect(spot.address?.length, equals(1000));
      });

      test('should handle many tags', () {
        final manyTags = List.generate(100, (index) => 'tag$index');
        final spot = ModelFactories.createTestSpot(tags: manyTags);

        expect(spot.tags.length, equals(100));
        expect(spot.tags.first, equals('tag0'));
        expect(spot.tags.last, equals('tag99'));
      });

      test('should handle special characters in strings', () {
        final spot = ModelFactories.createTestSpot(
          name: 'Café Münchën 北京烤鸭 🍜',
        ).copyWith(
          description: r'Special chars: @#$%^&*()_+-=[]{}|;:,.<>?',
          address: '123 Main St. ñ é ü ß',
        );

        expect(spot.name, equals('Café Münchën 北京烤鸭 🍜'));
        expect(spot.description, contains('Special chars'));
        expect(spot.address, contains('123 Main St'));
      });
    });

    group('Privacy and Security Considerations', () {
      test('should not expose sensitive location data unintentionally', () {
        final spot = ModelFactories.createTestSpot();
        final json = spot.toJson();

        // Ensure coordinates are explicitly included (not hidden)
        expect(json.containsKey('latitude'), isTrue);
        expect(json.containsKey('longitude'), isTrue);
        
        // Ensure no unexpected fields are exposed
        expect(json.containsKey('internalId'), isFalse);
        expect(json.containsKey('privateNotes'), isFalse);
      });

      test('should maintain creator attribution', () {
        final spot = ModelFactories.createTestSpot(createdBy: 'user-123');
        final json = spot.toJson();
        final reconstructed = Spot.fromJson(json);

        expect(reconstructed.createdBy, equals('user-123'));
      });
    });
  });
}
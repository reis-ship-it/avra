import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/update_spot_usecase.dart';

import 'update_spot_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([SpotsRepository])
void main() {
  group('UpdateSpotUseCase', () {
    late UpdateSpotUseCase usecase;
    late MockSpotsRepository mockRepository;
    late Spot originalSpot;
    late Spot updatedSpot;

    setUp(() {
      mockRepository = MockSpotsRepository();
      usecase = UpdateSpotUseCase(mockRepository);
      
      originalSpot = Spot(
        id: 'test_spot_1',
        name: 'Original Spot',
        description: 'Original description',
        latitude: 40.7128,
        longitude: -74.0060,
        category: 'restaurant',
        rating: 4.0,
        createdBy: 'user123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        address: '123 Original Street, New York, NY',
        tags: ['food'],
        metadata: {'verified': false},
      );

      updatedSpot = originalSpot.copyWith(
        name: 'Updated Spot',
        description: 'Updated description',
        rating: 4.5,
        updatedAt: DateTime(2024, 1, 2),
        tags: ['food', 'outdoor'],
        metadata: {'verified': true, 'updated': true},
      );
    });

    group('Successful updates', () {
      test('should update spot successfully with all fields changed', () async {
        // Arrange
        when(mockRepository.updateSpot(updatedSpot))
            .thenAnswer((_) async => updatedSpot);

        // Act
        final result = await usecase.call(updatedSpot);

        // Assert
        expect(result, equals(updatedSpot));
        expect(result.name, equals('Updated Spot'));
        expect(result.description, equals('Updated description'));
        expect(result.rating, equals(4.5));
        expect(result.tags, contains('outdoor'));
        expect(result.metadata['verified'], isTrue);
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should update only specific fields while preserving others', () async {
        // Arrange
        final partialUpdate = originalSpot.copyWith(
          name: 'Partially Updated Spot',
          updatedAt: DateTime(2024, 1, 3),
        );

        when(mockRepository.updateSpot(partialUpdate))
            .thenAnswer((_) async => partialUpdate);

        // Act
        final result = await usecase.call(partialUpdate);

        // Assert
        expect(result.name, equals('Partially Updated Spot'));
        expect(result.description, equals(originalSpot.description)); // Preserved
        expect(result.latitude, equals(originalSpot.latitude)); // Preserved
        expect(result.longitude, equals(originalSpot.longitude)); // Preserved
        expect(result.category, equals(originalSpot.category)); // Preserved
        expect(result.rating, equals(originalSpot.rating)); // Preserved
        expect(result.createdBy, equals(originalSpot.createdBy)); // Preserved
        expect(result.createdAt, equals(originalSpot.createdAt)); // Preserved
        expect(result.address, equals(originalSpot.address)); // Preserved
        expect(result.tags, equals(originalSpot.tags)); // Preserved
        verify(mockRepository.updateSpot(partialUpdate)).called(1);
      });

      test('should update spot coordinates', () async {
        // Arrange
        final locationUpdate = originalSpot.copyWith(
          latitude: 34.0522,
          longitude: -118.2437,
          address: '456 Updated Street, Los Angeles, CA',
          updatedAt: DateTime(2024, 1, 4),
        );

        when(mockRepository.updateSpot(locationUpdate))
            .thenAnswer((_) async => locationUpdate);

        // Act
        final result = await usecase.call(locationUpdate);

        // Assert
        expect(result.latitude, equals(34.0522));
        expect(result.longitude, equals(-118.2437));
        expect(result.address, equals('456 Updated Street, Los Angeles, CA'));
        verify(mockRepository.updateSpot(locationUpdate)).called(1);
      });

      test('should update spot category', () async {
        // Arrange
        final categoryUpdate = originalSpot.copyWith(
          category: 'park',
          updatedAt: DateTime(2024, 1, 5),
        );

        when(mockRepository.updateSpot(categoryUpdate))
            .thenAnswer((_) async => categoryUpdate);

        // Act
        final result = await usecase.call(categoryUpdate);

        // Assert
        expect(result.category, equals('park'));
        verify(mockRepository.updateSpot(categoryUpdate)).called(1);
      });

      test('should update spot rating', () async {
        // Arrange
        final ratingUpdate = originalSpot.copyWith(
          rating: 5.0,
          updatedAt: DateTime(2024, 1, 6),
        );

        when(mockRepository.updateSpot(ratingUpdate))
            .thenAnswer((_) async => ratingUpdate);

        // Act
        final result = await usecase.call(ratingUpdate);

        // Assert
        expect(result.rating, equals(5.0));
        verify(mockRepository.updateSpot(ratingUpdate)).called(1);
      });

      test('should update spot tags', () async {
        // Arrange
        final newTags = ['food', 'outdoor', 'family-friendly', 'wifi'];
        final tagsUpdate = originalSpot.copyWith(
          tags: newTags,
          updatedAt: DateTime(2024, 1, 7),
        );

        when(mockRepository.updateSpot(tagsUpdate))
            .thenAnswer((_) async => tagsUpdate);

        // Act
        final result = await usecase.call(tagsUpdate);

        // Assert
        expect(result.tags, equals(newTags));
        expect(result.tags, hasLength(4));
        expect(result.tags, contains('wifi'));
        verify(mockRepository.updateSpot(tagsUpdate)).called(1);
      });

      test('should update spot metadata', () async {
        // Arrange
        final newMetadata = {
          'verified': true,
          'price_range': '\$\$\$',
          'wheelchair_accessible': true,
          'last_verified': '2024-01-07',
          'amenities': ['wifi', 'parking', 'outdoor_seating'],
        };
        final metadataUpdate = originalSpot.copyWith(
          metadata: newMetadata,
          updatedAt: DateTime(2024, 1, 7),
        );

        when(mockRepository.updateSpot(metadataUpdate))
            .thenAnswer((_) async => metadataUpdate);

        // Act
        final result = await usecase.call(metadataUpdate);

        // Assert
        expect(result.metadata, equals(newMetadata));
        expect(result.metadata['verified'], isTrue);
        expect(result.metadata['price_range'], equals('\$\$\$'));
        expect(result.metadata['amenities'], isA<List>());
        verify(mockRepository.updateSpot(metadataUpdate)).called(1);
      });
    });

    group('Edge cases and validation', () {
      test('should handle update with same values as original', () async {
        // Arrange
        final sameValuesUpdate = originalSpot.copyWith(
          updatedAt: DateTime(2024, 1, 8),
        );

        when(mockRepository.updateSpot(sameValuesUpdate))
            .thenAnswer((_) async => sameValuesUpdate);

        // Act
        final result = await usecase.call(sameValuesUpdate);

        // Assert
        expect(result.name, equals(originalSpot.name));
        expect(result.description, equals(originalSpot.description));
        expect(result.rating, equals(originalSpot.rating));
        expect(result.updatedAt, isNot(equals(originalSpot.updatedAt)));
        verify(mockRepository.updateSpot(sameValuesUpdate)).called(1);
      });

      test('should handle update with empty tags', () async {
        // Arrange
        final emptyTagsUpdate = originalSpot.copyWith(
          tags: [],
          updatedAt: DateTime(2024, 1, 9),
        );

        when(mockRepository.updateSpot(emptyTagsUpdate))
            .thenAnswer((_) async => emptyTagsUpdate);

        // Act
        final result = await usecase.call(emptyTagsUpdate);

        // Assert
        expect(result.tags, isEmpty);
        verify(mockRepository.updateSpot(emptyTagsUpdate)).called(1);
      });

      test('should handle update with empty metadata', () async {
        // Arrange
        final emptyMetadataUpdate = originalSpot.copyWith(
          metadata: {},
          updatedAt: DateTime(2024, 1, 10),
        );

        when(mockRepository.updateSpot(emptyMetadataUpdate))
            .thenAnswer((_) async => emptyMetadataUpdate);

        // Act
        final result = await usecase.call(emptyMetadataUpdate);

        // Assert
        expect(result.metadata, isEmpty);
        verify(mockRepository.updateSpot(emptyMetadataUpdate)).called(1);
      });

      test('should handle update with null address', () async {
        // Arrange
        final nullAddressUpdate = originalSpot.copyWith(
          address: null,
          updatedAt: DateTime(2024, 1, 11),
        );

        when(mockRepository.updateSpot(nullAddressUpdate))
            .thenAnswer((_) async => nullAddressUpdate);

        // Act
        final result = await usecase.call(nullAddressUpdate);

        // Assert
        expect(result.address, isNull);
        verify(mockRepository.updateSpot(nullAddressUpdate)).called(1);
      });

      test('should handle update with extreme coordinates', () async {
        // Arrange
        final extremeUpdate = originalSpot.copyWith(
          latitude: -90.0,
          longitude: -180.0,
          updatedAt: DateTime(2024, 1, 12),
        );

        when(mockRepository.updateSpot(extremeUpdate))
            .thenAnswer((_) async => extremeUpdate);

        // Act
        final result = await usecase.call(extremeUpdate);

        // Assert
        expect(result.latitude, equals(-90.0));
        expect(result.longitude, equals(-180.0));
        verify(mockRepository.updateSpot(extremeUpdate)).called(1);
      });

      test('should handle update with zero rating', () async {
        // Arrange
        final zeroRatingUpdate = originalSpot.copyWith(
          rating: 0.0,
          updatedAt: DateTime(2024, 1, 13),
        );

        when(mockRepository.updateSpot(zeroRatingUpdate))
            .thenAnswer((_) async => zeroRatingUpdate);

        // Act
        final result = await usecase.call(zeroRatingUpdate);

        // Assert
        expect(result.rating, equals(0.0));
        verify(mockRepository.updateSpot(zeroRatingUpdate)).called(1);
      });

      test('should handle update with maximum rating', () async {
        // Arrange
        final maxRatingUpdate = originalSpot.copyWith(
          rating: 5.0,
          updatedAt: DateTime(2024, 1, 14),
        );

        when(mockRepository.updateSpot(maxRatingUpdate))
            .thenAnswer((_) async => maxRatingUpdate);

        // Act
        final result = await usecase.call(maxRatingUpdate);

        // Assert
        expect(result.rating, equals(5.0));
        verify(mockRepository.updateSpot(maxRatingUpdate)).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Network error during update');
        when(mockRepository.updateSpot(updatedSpot))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(updatedSpot),
          throwsA(exception),
        );
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });

      test('should handle repository throwing not found exception', () async {
        // Arrange
        final notFoundError = Exception('Spot not found');
        when(mockRepository.updateSpot(updatedSpot))
            .thenThrow(notFoundError);

        // Act & Assert
        expect(
          () async => await usecase.call(updatedSpot),
          throwsA(notFoundError),
        );
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });

      test('should handle repository throwing validation exception', () async {
        // Arrange
        final validationError = ArgumentError('Invalid spot data');
        when(mockRepository.updateSpot(updatedSpot))
            .thenThrow(validationError);

        // Act & Assert
        expect(
          () async => await usecase.call(updatedSpot),
          throwsA(validationError),
        );
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });

      test('should handle repository returning modified spot', () async {
        // Arrange
        final serverModifiedSpot = updatedSpot.copyWith(
          updatedAt: DateTime(2024, 1, 15),
          metadata: {'verified': true, 'server_modified': true},
        );

        when(mockRepository.updateSpot(updatedSpot))
            .thenAnswer((_) async => serverModifiedSpot);

        // Act
        final result = await usecase.call(updatedSpot);

        // Assert
        expect(result.updatedAt, isNot(equals(updatedSpot.updatedAt)));
        expect(result.metadata['server_modified'], isTrue);
        expect(result.name, equals(updatedSpot.name)); // Preserve client changes
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });
    });

    group('Business logic validation', () {
      test('should preserve spot ID during update', () async {
        // Arrange
        when(mockRepository.updateSpot(updatedSpot))
            .thenAnswer((_) async => updatedSpot);

        // Act
        final result = await usecase.call(updatedSpot);

        // Assert
        expect(result.id, equals(originalSpot.id));
        expect(result.id, equals(updatedSpot.id));
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });

      test('should preserve createdBy field during update', () async {
        // Arrange
        when(mockRepository.updateSpot(updatedSpot))
            .thenAnswer((_) async => updatedSpot);

        // Act
        final result = await usecase.call(updatedSpot);

        // Assert
        expect(result.createdBy, equals(originalSpot.createdBy));
        expect(result.createdBy, equals(updatedSpot.createdBy));
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });

      test('should preserve createdAt timestamp during update', () async {
        // Arrange
        when(mockRepository.updateSpot(updatedSpot))
            .thenAnswer((_) async => updatedSpot);

        // Act
        final result = await usecase.call(updatedSpot);

        // Assert
        expect(result.createdAt, equals(originalSpot.createdAt));
        expect(result.createdAt, equals(updatedSpot.createdAt));
        verify(mockRepository.updateSpot(updatedSpot)).called(1);
      });

      test('should update updatedAt timestamp', () async {
        // Arrange
        final timestampUpdate = originalSpot.copyWith(
          name: 'Updated Name',
          updatedAt: DateTime(2024, 1, 16),
        );

        when(mockRepository.updateSpot(timestampUpdate))
            .thenAnswer((_) async => timestampUpdate);

        // Act
        final result = await usecase.call(timestampUpdate);

        // Assert
        expect(result.updatedAt, isNot(equals(originalSpot.updatedAt)));
        expect(result.updatedAt, equals(timestampUpdate.updatedAt));
        verify(mockRepository.updateSpot(timestampUpdate)).called(1);
      });

      test('should handle complex metadata updates correctly', () async {
        // Arrange
        final complexMetadata = {
          'verification_status': 'verified',
          'last_verified_by': 'moderator123',
          'verification_date': '2024-01-16T10:30:00Z',
          'amenities': {
            'wifi': true,
            'parking': false,
            'outdoor_seating': true,
          },
          'hours': {
            'monday': '9:00-17:00',
            'tuesday': '9:00-17:00',
            'wednesday': '9:00-17:00',
          },
          'photos': [
            'photo1.jpg',
            'photo2.jpg',
          ],
          'reviews_count': 42,
          'average_rating': 4.3,
        };

        final complexUpdate = originalSpot.copyWith(
          metadata: complexMetadata,
          updatedAt: DateTime(2024, 1, 16),
        );

        when(mockRepository.updateSpot(complexUpdate))
            .thenAnswer((_) async => complexUpdate);

        // Act
        final result = await usecase.call(complexUpdate);

        // Assert
        expect(result.metadata, equals(complexMetadata));
        expect(result.metadata['verification_status'], equals('verified'));
        expect(result.metadata['amenities'], isA<Map>());
        expect(result.metadata['photos'], isA<List>());
        expect(result.metadata['reviews_count'], equals(42));
        verify(mockRepository.updateSpot(complexUpdate)).called(1);
      });
    });
  });
}

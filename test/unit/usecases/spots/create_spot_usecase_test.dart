import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/create_spot_usecase.dart';

import 'create_spot_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([SpotsRepository])
void main() {
  group('CreateSpotUseCase', () {
    late CreateSpotUseCase usecase;
    late MockSpotsRepository mockRepository;
    late Spot testSpot;

    setUp(() {
      mockRepository = MockSpotsRepository();
      usecase = CreateSpotUseCase(mockRepository);
      
      testSpot = Spot(
        id: 'test_spot_1',
        name: 'Test Spot',
        description: 'A test spot for validation',
        latitude: 40.7128,
        longitude: -74.0060,
        category: 'restaurant',
        rating: 4.5,
        createdBy: 'user123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        address: '123 Test Street, New York, NY',
        tags: ['food', 'outdoor'],
        metadata: {'verified': true},
      );
    });

    group('Successful creation', () {
      test('should create spot successfully with all required fields', () async {
        // Arrange
        when(mockRepository.createSpot(testSpot))
            .thenAnswer((_) async => testSpot);

        // Act
        final result = await usecase.call(testSpot);

        // Assert
        expect(result, equals(testSpot));
        verify(mockRepository.createSpot(testSpot)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should create spot with minimal required fields', () async {
        // Arrange
        final minimalSpot = Spot(
          id: 'minimal_spot',
          name: 'Minimal Spot',
          description: 'Minimal description',
          latitude: 0.0,
          longitude: 0.0,
          category: 'other',
          rating: 0.0,
          createdBy: 'user123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockRepository.createSpot(minimalSpot))
            .thenAnswer((_) async => minimalSpot);

        // Act
        final result = await usecase.call(minimalSpot);

        // Assert
        expect(result, equals(minimalSpot));
        expect(result.tags, isEmpty);
        expect(result.metadata, isEmpty);
        expect(result.address, isNull);
        verify(mockRepository.createSpot(minimalSpot)).called(1);
      });

      test('should create spot with tags and metadata', () async {
        // Arrange
        final richSpot = testSpot.copyWith(
          tags: ['food', 'outdoor', 'family-friendly', 'pet-friendly'],
          metadata: {
            'verified': true,
            'price_range': '\$\$',
            'wifi_available': true,
            'accessibility': 'wheelchair_accessible',
          },
        );

        when(mockRepository.createSpot(richSpot))
            .thenAnswer((_) async => richSpot);

        // Act
        final result = await usecase.call(richSpot);

        // Assert
        expect(result, equals(richSpot));
        expect(result.tags, hasLength(4));
        expect(result.metadata, hasLength(4));
        verify(mockRepository.createSpot(richSpot)).called(1);
      });
    });

    group('Edge cases and validation', () {
      test('should handle spot with extreme coordinate values', () async {
        // Arrange
        final extremeSpot = testSpot.copyWith(
          latitude: 90.0, // Max latitude
          longitude: 180.0, // Max longitude
        );

        when(mockRepository.createSpot(extremeSpot))
            .thenAnswer((_) async => extremeSpot);

        // Act
        final result = await usecase.call(extremeSpot);

        // Assert
        expect(result.latitude, equals(90.0));
        expect(result.longitude, equals(180.0));
        verify(mockRepository.createSpot(extremeSpot)).called(1);
      });

      test('should handle spot with negative coordinate values', () async {
        // Arrange
        final negativeSpot = testSpot.copyWith(
          latitude: -85.0, // Near South Pole
          longitude: -179.0, // Near date line
        );

        when(mockRepository.createSpot(negativeSpot))
            .thenAnswer((_) async => negativeSpot);

        // Act
        final result = await usecase.call(negativeSpot);

        // Assert
        expect(result.latitude, equals(-85.0));
        expect(result.longitude, equals(-179.0));
        verify(mockRepository.createSpot(negativeSpot)).called(1);
      });

      test('should handle spot with zero rating', () async {
        // Arrange
        final zeroRatingSpot = testSpot.copyWith(rating: 0.0);

        when(mockRepository.createSpot(zeroRatingSpot))
            .thenAnswer((_) async => zeroRatingSpot);

        // Act
        final result = await usecase.call(zeroRatingSpot);

        // Assert
        expect(result.rating, equals(0.0));
        verify(mockRepository.createSpot(zeroRatingSpot)).called(1);
      });

      test('should handle spot with maximum rating', () async {
        // Arrange
        final maxRatingSpot = testSpot.copyWith(rating: 5.0);

        when(mockRepository.createSpot(maxRatingSpot))
            .thenAnswer((_) async => maxRatingSpot);

        // Act
        final result = await usecase.call(maxRatingSpot);

        // Assert
        expect(result.rating, equals(5.0));
        verify(mockRepository.createSpot(maxRatingSpot)).called(1);
      });

      test('should handle spot with empty strings in optional fields', () async {
        // Arrange
        final emptyStringSpot = testSpot.copyWith(
          address: '',
          category: '',
        );

        when(mockRepository.createSpot(emptyStringSpot))
            .thenAnswer((_) async => emptyStringSpot);

        // Act
        final result = await usecase.call(emptyStringSpot);

        // Assert
        expect(result.address, equals(''));
        expect(result.category, equals(''));
        verify(mockRepository.createSpot(emptyStringSpot)).called(1);
      });

      test('should handle spot with very long description', () async {
        // Arrange
        final longDescription = 'A' * 2000; // Very long description
        final longDescSpot = testSpot.copyWith(description: longDescription);

        when(mockRepository.createSpot(longDescSpot))
            .thenAnswer((_) async => longDescSpot);

        // Act
        final result = await usecase.call(longDescSpot);

        // Assert
        expect(result.description, equals(longDescription));
        verify(mockRepository.createSpot(longDescSpot)).called(1);
      });

      test('should handle spot with many tags', () async {
        // Arrange
        final manyTags = List.generate(50, (index) => 'tag$index');
        final manyTagsSpot = testSpot.copyWith(tags: manyTags);

        when(mockRepository.createSpot(manyTagsSpot))
            .thenAnswer((_) async => manyTagsSpot);

        // Act
        final result = await usecase.call(manyTagsSpot);

        // Assert
        expect(result.tags, hasLength(50));
        expect(result.tags, equals(manyTags));
        verify(mockRepository.createSpot(manyTagsSpot)).called(1);
      });

      test('should handle spot with complex metadata', () async {
        // Arrange
        final complexMetadata = {
          'simple_string': 'value',
          'number': 42,
          'boolean': true,
          'nested_object': {
            'sub_key': 'sub_value',
            'sub_number': 123,
          },
          'array': ['item1', 'item2', 'item3'],
          'null_value': null,
        };
        final complexSpot = testSpot.copyWith(metadata: complexMetadata);

        when(mockRepository.createSpot(complexSpot))
            .thenAnswer((_) async => complexSpot);

        // Act
        final result = await usecase.call(complexSpot);

        // Assert
        expect(result.metadata, equals(complexMetadata));
        verify(mockRepository.createSpot(complexSpot)).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Network error');
        when(mockRepository.createSpot(testSpot))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(testSpot),
          throwsA(exception),
        );
        verify(mockRepository.createSpot(testSpot)).called(1);
      });

      test('should handle repository throwing custom exception', () async {
        // Arrange
        final customError = ArgumentError('Invalid spot data');
        when(mockRepository.createSpot(testSpot))
            .thenThrow(customError);

        // Act & Assert
        expect(
          () async => await usecase.call(testSpot),
          throwsA(customError),
        );
        verify(mockRepository.createSpot(testSpot)).called(1);
      });

      test('should handle repository returning different spot than input', () async {
        // Arrange
        final modifiedSpot = testSpot.copyWith(
          id: 'server_generated_id',
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        );

        when(mockRepository.createSpot(testSpot))
            .thenAnswer((_) async => modifiedSpot);

        // Act
        final result = await usecase.call(testSpot);

        // Assert
        expect(result.id, equals('server_generated_id'));
        expect(result.name, equals(testSpot.name)); // Other fields preserved
        expect(result.createdAt, isNot(equals(testSpot.createdAt)));
        verify(mockRepository.createSpot(testSpot)).called(1);
      });
    });

    group('Business logic validation', () {
      test('should create spot with current timestamps', () async {
        // Arrange
        final now = DateTime.now();
        final currentSpot = testSpot.copyWith(
          createdAt: now,
          updatedAt: now,
        );

        when(mockRepository.createSpot(currentSpot))
            .thenAnswer((_) async => currentSpot);

        // Act
        final result = await usecase.call(currentSpot);

        // Assert
        expect(result.createdAt, equals(now));
        expect(result.updatedAt, equals(now));
        verify(mockRepository.createSpot(currentSpot)).called(1);
      });

      test('should create spot with valid geographic coordinates', () async {
        // Arrange - NYC coordinates
        final nycSpot = testSpot.copyWith(
          latitude: 40.7831,
          longitude: -73.9712,
          name: 'Central Park',
          address: 'Central Park, New York, NY',
        );

        when(mockRepository.createSpot(nycSpot))
            .thenAnswer((_) async => nycSpot);

        // Act
        final result = await usecase.call(nycSpot);

        // Assert
        expect(result.latitude, equals(40.7831));
        expect(result.longitude, equals(-73.9712));
        verify(mockRepository.createSpot(nycSpot)).called(1);
      });

      test('should create spot with valid category', () async {
        // Arrange
        final categories = ['restaurant', 'park', 'museum', 'shopping', 'entertainment'];
        
        for (final category in categories) {
          final categorizedSpot = testSpot.copyWith(
            category: category,
            id: 'spot_$category',
          );

          when(mockRepository.createSpot(categorizedSpot))
              .thenAnswer((_) async => categorizedSpot);

          // Act
          final result = await usecase.call(categorizedSpot);

          // Assert
          expect(result.category, equals(category));
          verify(mockRepository.createSpot(categorizedSpot)).called(1);
        }
      });

      test('should preserve all spot properties during creation', () async {
        // Arrange
        when(mockRepository.createSpot(testSpot))
            .thenAnswer((_) async => testSpot);

        // Act
        final result = await usecase.call(testSpot);

        // Assert - Verify all properties are preserved
        expect(result.id, equals(testSpot.id));
        expect(result.name, equals(testSpot.name));
        expect(result.description, equals(testSpot.description));
        expect(result.latitude, equals(testSpot.latitude));
        expect(result.longitude, equals(testSpot.longitude));
        expect(result.category, equals(testSpot.category));
        expect(result.rating, equals(testSpot.rating));
        expect(result.createdBy, equals(testSpot.createdBy));
        expect(result.createdAt, equals(testSpot.createdAt));
        expect(result.updatedAt, equals(testSpot.updatedAt));
        expect(result.address, equals(testSpot.address));
        expect(result.tags, equals(testSpot.tags));
        expect(result.metadata, equals(testSpot.metadata));
        verify(mockRepository.createSpot(testSpot)).called(1);
      });
    });
  });
}

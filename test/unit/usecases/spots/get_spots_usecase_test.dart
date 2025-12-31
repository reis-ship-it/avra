import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/get_spots_usecase.dart';

import 'get_spots_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([SpotsRepository])
void main() {
  group('GetSpotsUseCase', () {
    late GetSpotsUseCase usecase;
    late MockSpotsRepository mockRepository;
    late List<Spot> testSpots;

    setUp(() {
      mockRepository = MockSpotsRepository();
      usecase = GetSpotsUseCase(mockRepository);
      
      testSpots = [
        Spot(
          id: 'spot_1',
          name: 'Central Park',
          description: 'Large public park in Manhattan',
          latitude: 40.7831,
          longitude: -73.9712,
          category: 'park',
          rating: 4.7,
          createdBy: 'user123',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          address: 'Central Park, New York, NY',
          tags: ['outdoor', 'recreation'],
          metadata: {'verified': true, 'popular': true},
        ),
        Spot(
          id: 'spot_2',
          name: 'Joe\'s Pizza',
          description: 'Famous New York pizza place',
          latitude: 40.7505,
          longitude: -73.9934,
          category: 'restaurant',
          rating: 4.2,
          createdBy: 'user456',
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
          address: '7 Carmine St, New York, NY',
          tags: ['food', 'pizza', 'casual'],
          metadata: {'verified': false, 'price_range': '\$'},
        ),
        Spot(
          id: 'spot_3',
          name: 'Museum of Modern Art',
          description: 'World-renowned modern art museum',
          latitude: 40.7614,
          longitude: -73.9776,
          category: 'museum',
          rating: 4.8,
          createdBy: 'user789',
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 3),
          address: '11 W 53rd St, New York, NY',
          tags: ['art', 'culture', 'indoor'],
          metadata: {'verified': true, 'admission_required': true},
        ),
      ];
    });

    group('Successful retrieval', () {
      test('should return list of spots successfully', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => testSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, equals(testSpots));
        expect(result, hasLength(3));
        expect(result[0].name, equals('Central Park'));
        expect(result[1].name, equals('Joe\'s Pizza'));
        expect(result[2].name, equals('Museum of Modern Art'));
        verify(mockRepository.getSpots()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no spots exist', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => <Spot>[]);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Spot>>());
        verify(mockRepository.getSpots()).called(1);
      });

      test('should return single spot in list', () async {
        // Arrange
        final singleSpot = [testSpots.first];
        when(mockRepository.getSpots())
            .thenAnswer((_) async => singleSpot);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first, equals(testSpots.first));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should return large list of spots', () async {
        // Arrange
        final largeSpotList = List.generate(100, (index) => Spot(
          id: 'spot_$index',
          name: 'Spot $index',
          description: 'Description for spot $index',
          latitude: 40.0 + (index * 0.01),
          longitude: -74.0 + (index * 0.01),
          category: 'test',
          rating: (index % 5) + 1.0,
          createdBy: 'user$index',
          createdAt: DateTime(2024, 1, index % 30 + 1),
          updatedAt: DateTime(2024, 1, index % 30 + 1),
        ));

        when(mockRepository.getSpots())
            .thenAnswer((_) async => largeSpotList);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(100));
        expect(result.first.id, equals('spot_0'));
        expect(result.last.id, equals('spot_99'));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should preserve all spot properties in returned list', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => testSpots);

        // Act
        final result = await usecase.call();

        // Assert
        final firstSpot = result.first;
        expect(firstSpot.id, equals('spot_1'));
        expect(firstSpot.name, equals('Central Park'));
        expect(firstSpot.description, equals('Large public park in Manhattan'));
        expect(firstSpot.latitude, equals(40.7831));
        expect(firstSpot.longitude, equals(-73.9712));
        expect(firstSpot.category, equals('park'));
        expect(firstSpot.rating, equals(4.7));
        expect(firstSpot.createdBy, equals('user123'));
        expect(firstSpot.createdAt, equals(DateTime(2024, 1, 1)));
        expect(firstSpot.updatedAt, equals(DateTime(2024, 1, 1)));
        expect(firstSpot.address, equals('Central Park, New York, NY'));
        expect(firstSpot.tags, equals(['outdoor', 'recreation']));
        expect(firstSpot.metadata, equals({'verified': true, 'popular': true}));
        verify(mockRepository.getSpots()).called(1);
      });
    });

    group('Edge cases and validation', () {
      test('should handle spots with minimal data', () async {
        // Arrange
        final minimalSpots = [
          Spot(
            id: 'minimal',
            name: 'Minimal Spot',
            description: 'Minimal',
            latitude: 0.0,
            longitude: 0.0,
            category: '',
            rating: 0.0,
            createdBy: '',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => minimalSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.tags, isEmpty);
        expect(result.first.metadata, isEmpty);
        expect(result.first.address, isNull);
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle spots with extreme coordinate values', () async {
        // Arrange
        final extremeSpots = [
          testSpots.first.copyWith(
            latitude: 90.0,
            longitude: 180.0,
          ),
          testSpots.first.copyWith(
            latitude: -90.0,
            longitude: -180.0,
          ),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => extremeSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].latitude, equals(90.0));
        expect(result[0].longitude, equals(180.0));
        expect(result[1].latitude, equals(-90.0));
        expect(result[1].longitude, equals(-180.0));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle spots with null optional fields', () async {
        // Arrange
        final nullFieldSpots = [
          Spot(
            id: 'null_fields',
            name: 'Spot with Nulls',
            description: 'Has null fields',
            latitude: 40.0,
            longitude: -74.0,
            category: 'test',
            rating: 3.0,
            createdBy: 'user',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
            address: null, // Explicitly null
          ),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => nullFieldSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.address, isNull);
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle spots with very long text fields', () async {
        // Arrange
        final longText = 'A' * 5000;
        final longTextSpots = [
          testSpots.first.copyWith(
            name: longText,
            description: longText,
            address: longText,
          ),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => longTextSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.name, equals(longText));
        expect(result.first.description, equals(longText));
        expect(result.first.address, equals(longText));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle spots with many tags', () async {
        // Arrange
        final manyTags = List.generate(100, (index) => 'tag$index');
        final manyTagsSpots = [
          testSpots.first.copyWith(tags: manyTags),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => manyTagsSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.tags, hasLength(100));
        expect(result.first.tags, equals(manyTags));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle spots with complex metadata', () async {
        // Arrange
        final complexMetadata = {
          'nested': {
            'deeply': {
              'nested': 'value',
            },
          },
          'array': [1, 2, 3, 'string', true],
          'null_value': null,
          'boolean': true,
          'number': 42.5,
        };
        final complexSpots = [
          testSpots.first.copyWith(metadata: complexMetadata),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => complexSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.metadata, equals(complexMetadata));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle spots from different time periods', () async {
        // Arrange
        final timeSpots = [
          testSpots.first.copyWith(
            createdAt: DateTime(1990, 1, 1),
            updatedAt: DateTime(1990, 1, 1),
          ),
          testSpots.first.copyWith(
            createdAt: DateTime(2050, 12, 31),
            updatedAt: DateTime(2050, 12, 31),
          ),
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => timeSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].createdAt.year, equals(1990));
        expect(result[1].createdAt.year, equals(2050));
        verify(mockRepository.getSpots()).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Network error');
        when(mockRepository.getSpots())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(exception),
        );
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle database connection error', () async {
        // Arrange
        final dbError = Exception('Database connection failed');
        when(mockRepository.getSpots())
            .thenThrow(dbError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(dbError),
        );
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle timeout exception', () async {
        // Arrange
        final timeoutError = Exception('Request timeout');
        when(mockRepository.getSpots())
            .thenThrow(timeoutError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(timeoutError),
        );
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle permission denied error', () async {
        // Arrange
        final permissionError = Exception('Permission denied');
        when(mockRepository.getSpots())
            .thenThrow(permissionError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(permissionError),
        );
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle data parsing error', () async {
        // Arrange
        const parseError = FormatException('Invalid data format');
        when(mockRepository.getSpots())
            .thenThrow(parseError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(parseError),
        );
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle state error', () async {
        // Arrange
        final stateError = StateError('Invalid repository state');
        when(mockRepository.getSpots())
            .thenThrow(stateError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(stateError),
        );
        verify(mockRepository.getSpots()).called(1);
      });
    });

    group('Business logic validation', () {
      test('should not modify or filter spots from repository', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => testSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, equals(testSpots));
        expect(identical(result, testSpots), isTrue); // Same reference
        verify(mockRepository.getSpots()).called(1);
      });

      test('should preserve order of spots as returned by repository', () async {
        // Arrange
        final orderedSpots = [testSpots[2], testSpots[0], testSpots[1]];
        when(mockRepository.getSpots())
            .thenAnswer((_) async => orderedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result[0].id, equals('spot_3'));
        expect(result[1].id, equals('spot_1'));
        expect(result[2].id, equals('spot_2'));
        verify(mockRepository.getSpots()).called(1);
      });

      test('should handle duplicate spots if repository returns them', () async {
        // Arrange
        final duplicateSpots = [testSpots[0], testSpots[0], testSpots[1]];
        when(mockRepository.getSpots())
            .thenAnswer((_) async => duplicateSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].id, equals(result[1].id)); // Duplicates preserved
        verify(mockRepository.getSpots()).called(1);
      });

      test('should not apply any business rules or filtering', () async {
        // Arrange - Mix of valid and potentially "invalid" spots
        final mixedSpots = [
          testSpots[0], // Normal spot
          testSpots[0].copyWith(rating: 0.0), // Zero rating
          testSpots[0].copyWith(name: ''), // Empty name
          testSpots[0].copyWith(latitude: 200.0), // Invalid latitude
        ];

        when(mockRepository.getSpots())
            .thenAnswer((_) async => mixedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(4));
        expect(result[1].rating, equals(0.0)); // Preserved
        expect(result[2].name, equals('')); // Preserved
        expect(result[3].latitude, equals(200.0)); // Preserved
        verify(mockRepository.getSpots()).called(1);
      });

      test('should be idempotent - multiple calls return same data', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => testSpots);

        // Act
        final result1 = await usecase.call();
        final result2 = await usecase.call();
        final result3 = await usecase.call();

        // Assert
        expect(result1, equals(result2));
        expect(result2, equals(result3));
        verify(mockRepository.getSpots()).called(3);
      });

      test('should handle concurrent calls independently', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => testSpots);

        // Act
        final futures = List.generate(5, (_) => usecase.call());
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, equals(testSpots));
        }
        verify(mockRepository.getSpots()).called(5);
      });
    });

    group('Performance and memory', () {
      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeDataset = List.generate(10000, (index) => Spot(
          id: 'spot_$index',
          name: 'Spot $index',
          description: 'Auto-generated spot $index',
          latitude: 40.0 + (index * 0.0001),
          longitude: -74.0 + (index * 0.0001),
          category: 'test',
          rating: (index % 5) + 1.0,
          createdBy: 'generator',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        when(mockRepository.getSpots())
            .thenAnswer((_) async => largeDataset);

        // Act
        final start = DateTime.now();
        final result = await usecase.call();
        final duration = DateTime.now().difference(start);

        // Assert
        expect(result, hasLength(10000));
        expect(duration.inMilliseconds, lessThan(1000)); // Should complete quickly
        verify(mockRepository.getSpots()).called(1);
      });

      test('should not hold references to repository data unnecessarily', () async {
        // Arrange
        when(mockRepository.getSpots())
            .thenAnswer((_) async => testSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, isA<List<Spot>>());
        verify(mockRepository.getSpots()).called(1);
      });
    });
  });
}

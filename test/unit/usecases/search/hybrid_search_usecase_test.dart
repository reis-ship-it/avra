import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/data/repositories/hybrid_search_repository.dart';
import 'package:spots/domain/usecases/search/hybrid_search_usecase.dart';

import 'hybrid_search_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([HybridSearchRepository])
void main() {
  group('HybridSearchUseCase', () {
    late HybridSearchUseCase usecase;
    late MockHybridSearchRepository mockRepository;
    late HybridSearchResult testResult;
    late List<Spot> testSpots;

    setUp(() {
      mockRepository = MockHybridSearchRepository();
      usecase = HybridSearchUseCase(mockRepository);
      
      testSpots = [
        Spot(
          id: 'spot_1',
          name: 'Community Café',
          description: 'Local favorite coffee shop',
          latitude: 40.7128,
          longitude: -74.0060,
          category: 'cafe',
          rating: 4.8,
          createdBy: 'community_member',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          metadata: {'is_external': false, 'community_endorsed': true},
        ),
        Spot(
          id: 'spot_2',
          name: 'External Restaurant',
          description: 'Found via external API',
          latitude: 40.7589,
          longitude: -73.9851,
          category: 'restaurant',
          rating: 4.2,
          createdBy: 'system',
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
          metadata: {'is_external': true, 'source': 'google_places'},
        ),
      ];

      testResult = HybridSearchResult(
        spots: testSpots,
        communityCount: 1,
        externalCount: 1,
        totalCount: 2,
        searchDuration: Duration(milliseconds: 150),
        sources: {'community': 1, 'google_places': 1},
      );
    });

    group('Text search', () {
      test('should search spots successfully with text query', () async {
        // Arrange
        const query = 'coffee';
        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).thenAnswer((_) async => testResult);

        // Act
        final result = await usecase.searchSpots(query: query);

        // Assert
        expect(result, equals(testResult));
        expect(result.spots, hasLength(2));
        expect(result.communityCount, equals(1));
        expect(result.externalCount, equals(1));
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should search with location and custom parameters', () async {
        // Arrange
        const query = 'restaurant';
        const latitude = 40.7128;
        const longitude = -74.0060;
        const maxResults = 20;
        const includeExternal = false;

        when(mockRepository.searchSpots(
          query: query,
          latitude: latitude,
          longitude: longitude,
          maxResults: maxResults,
          includeExternal: includeExternal,
        )).thenAnswer((_) async => testResult);

        // Act
        final result = await usecase.searchSpots(
          query: query,
          latitude: latitude,
          longitude: longitude,
          maxResults: maxResults,
          includeExternal: includeExternal,
        );

        // Assert
        expect(result, equals(testResult));
        verify(mockRepository.searchSpots(
          query: query,
          latitude: latitude,
          longitude: longitude,
          maxResults: maxResults,
          includeExternal: includeExternal,
        )).called(1);
      });

      test('should handle empty search query', () async {
        // Arrange
        const query = '';
        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).thenAnswer((_) async => HybridSearchResult.empty());

        // Act
        final result = await usecase.searchSpots(query: query);

        // Assert
        expect(result.spots, isEmpty);
        expect(result.totalCount, equals(0));
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });
    });

    group('Nearby search', () {
      test('should search nearby spots successfully', () async {
        // Arrange
        const latitude = 40.7128;
        const longitude = -74.0060;
        const radius = 1000;
        const maxResults = 25;

        when(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          maxResults: maxResults,
          includeExternal: true,
        )).thenAnswer((_) async => testResult);

        // Act
        final result = await usecase.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          maxResults: maxResults,
        );

        // Assert
        expect(result, equals(testResult));
        expect(result.spots, hasLength(2));
        verify(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          maxResults: maxResults,
          includeExternal: true,
        )).called(1);
      });

      test('should use default parameters for nearby search', () async {
        // Arrange
        const latitude = 40.7128;
        const longitude = -74.0060;

        when(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: 5000, // Default
          maxResults: 50, // Default
          includeExternal: true, // Default
        )).thenAnswer((_) async => testResult);

        // Act
        final result = await usecase.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
        );

        // Assert
        expect(result, equals(testResult));
        verify(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: 5000,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });

      test('should handle extreme coordinates', () async {
        // Arrange
        const latitude = 90.0; // North pole
        const longitude = -180.0; // Date line

        when(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: 5000,
          maxResults: 50,
          includeExternal: true,
        )).thenAnswer((_) async => HybridSearchResult.empty());

        // Act
        final result = await usecase.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
        );

        // Assert
        expect(result.spots, isEmpty);
        verify(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: 5000,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });
    });

    group('Search analytics', () {
      test('should get search analytics', () async {
        // Arrange
        final analytics = {
          'coffee': 5,
          'restaurant': 3,
          'park': 2,
        };
        when(mockRepository.getSearchAnalytics())
            .thenReturn(analytics);

        // Act
        final result = usecase.getSearchAnalytics();

        // Assert
        expect(result, equals(analytics));
        expect(result['coffee'], equals(5));
        expect(result['restaurant'], equals(3));
        verify(mockRepository.getSearchAnalytics()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should handle empty analytics', () async {
        // Arrange
        when(mockRepository.getSearchAnalytics())
            .thenReturn(<String, int>{});

        // Act
        final result = usecase.getSearchAnalytics();

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getSearchAnalytics()).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when search fails', () async {
        // Arrange
        const query = 'error_query';
        final exception = Exception('Search failed');
        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.searchSpots(query: query),
          throwsA(exception),
        );
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });

      test('should handle nearby search timeout', () async {
        // Arrange
        const latitude = 40.7128;
        const longitude = -74.0060;
        final timeoutError = Exception('Request timeout');
        when(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: 5000,
          maxResults: 50,
          includeExternal: true,
        )).thenThrow(timeoutError);

        // Act & Assert
        expect(
          () async => await usecase.searchNearbySpots(
            latitude: latitude,
            longitude: longitude,
          ),
          throwsA(timeoutError),
        );
        verify(mockRepository.searchNearbySpots(
          latitude: latitude,
          longitude: longitude,
          radius: 5000,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });
    });

    group('Community-first search (OUR_GUTS.md compliance)', () {
      test('should prioritize community results over external', () async {
        // Arrange
        const query = 'coffee';
        final communityFirstResult = testResult.copyWith(
          communityCount: 8,
          externalCount: 2,
        );

        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).thenAnswer((_) async => communityFirstResult);

        // Act
        final result = await usecase.searchSpots(query: query);

        // Assert
        expect(result.isPrimarilyCommunityDriven, isTrue);
        expect(result.communityCount, greaterThan(result.externalCount));
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });

      test('should work with community-only search', () async {
        // Arrange
        const query = 'local_gem';
        final communityOnlyResult = HybridSearchResult(
          spots: [testSpots.first], // Only community spot
          communityCount: 1,
          externalCount: 0,
          totalCount: 1,
          searchDuration: Duration(milliseconds: 100),
          sources: {'community': 1},
        );

        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: false,
        )).thenAnswer((_) async => communityOnlyResult);

        // Act
        final result = await usecase.searchSpots(
          query: query,
          includeExternal: false,
        );

        // Assert
        expect(result.externalCount, equals(0));
        expect(result.communityCount, equals(1));
        expect(result.isPrimarilyCommunityDriven, isTrue);
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: false,
        )).called(1);
      });
    });

    group('Performance and metrics', () {
      test('should track search duration', () async {
        // Arrange
        const query = 'performance_test';
        final performanceResult = testResult.copyWith(
          searchDuration: Duration(milliseconds: 50),
        );

        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).thenAnswer((_) async => performanceResult);

        // Act
        final result = await usecase.searchSpots(query: query);

        // Assert
        expect(result.searchDuration.inMilliseconds, equals(50));
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });

      test('should provide source breakdown', () async {
        // Arrange
        const query = 'source_test';
        final sourceResult = testResult.copyWith(
          sources: {
            'community': 3,
            'google_places': 2,
            'openstreetmap': 1,
          },
        );

        when(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).thenAnswer((_) async => sourceResult);

        // Act
        final result = await usecase.searchSpots(query: query);

        // Assert
        expect(result.sources, hasLength(3));
        expect(result.sources['community'], equals(3));
        expect(result.sources['google_places'], equals(2));
        expect(result.sources['openstreetmap'], equals(1));
        verify(mockRepository.searchSpots(
          query: query,
          latitude: null,
          longitude: null,
          maxResults: 50,
          includeExternal: true,
        )).called(1);
      });
    });
  });
}

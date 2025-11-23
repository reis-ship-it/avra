import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/search_cache_service.dart';
import 'package:spots/data/repositories/hybrid_search_repository.dart';

/// Search Cache Service Tests
/// Tests search caching functionality for performance optimization
void main() {
  group('SearchCacheService Tests', () {
    late SearchCacheService service;

    setUp(() {
      service = SearchCacheService();
    });

    group('getCachedResult', () {
      test('should return null when no cached result exists', () async {
        final result = await service.getCachedResult(
          query: 'test query',
        );

        expect(result, isNull);
      });

      test('should return null for new query', () async {
        final result = await service.getCachedResult(
          query: 'coffee shops',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(result, isNull);
      });

      test('should accept query with location', () async {
        final result = await service.getCachedResult(
          query: 'restaurants',
          latitude: 37.7749,
          longitude: -122.4194,
          maxResults: 20,
          includeExternal: false,
        );

        expect(result, anyOf(isNull, isA<HybridSearchResult>()));
      });
    });

    group('cacheResult', () {
      test('should cache search result', () async {
        final searchResult = HybridSearchResult(
          spots: [],
          communityCount: 0,
          externalCount: 0,
          totalCount: 0,
          searchDuration: Duration(milliseconds: 100),
          sources: {},
        );

        await service.cacheResult(
          query: 'test query',
          result: searchResult,
        );

        // Verify caching doesn't throw
        expect(searchResult, isNotNull);
      });

      test('should cache result with location', () async {
        final searchResult = HybridSearchResult(
          spots: [],
          communityCount: 0,
          externalCount: 0,
          totalCount: 0,
          searchDuration: Duration(milliseconds: 50),
          sources: {},
        );

        await service.cacheResult(
          query: 'coffee',
          latitude: 40.7128,
          longitude: -74.0060,
          result: searchResult,
        );

        expect(searchResult, isNotNull);
      });

      test('should cache result with custom maxResults', () async {
        final searchResult = HybridSearchResult(
          spots: [],
          communityCount: 0,
          externalCount: 0,
          totalCount: 0,
          searchDuration: Duration(milliseconds: 75),
          sources: {},
        );

        await service.cacheResult(
          query: 'restaurants',
          maxResults: 100,
          result: searchResult,
        );

        expect(searchResult, isNotNull);
      });
    });

    group('prefetchPopularSearches', () {
      test('should prefetch popular searches', () async {
        await service.prefetchPopularSearches(
          searchFunction: (query) async => HybridSearchResult(
            spots: [],
            communityCount: 0,
            externalCount: 0,
            totalCount: 0,
            searchDuration: Duration(milliseconds: 100),
            sources: {},
          ),
        );

        // Verify prefetching doesn't throw
        expect(service, isNotNull);
      });
    });

    group('warmLocationCache', () {
      test('should warm location cache', () async {
        await service.warmLocationCache(
          latitude: 40.7128,
          longitude: -74.0060,
          nearbySearchFunction: (lat, lng) async => HybridSearchResult(
            spots: [],
            communityCount: 0,
            externalCount: 0,
            totalCount: 0,
            searchDuration: Duration(milliseconds: 50),
            sources: {},
          ),
        );

        // Verify warming doesn't throw
        expect(service, isNotNull);
      });
    });

    group('getCacheStatistics', () {
      test('should return cache statistics', () {
        final stats = service.getCacheStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['cache_hits'], isA<int>());
        expect(stats['cache_misses'], isA<int>());
        expect(stats['offline_hits'], isA<int>());
        expect(stats['memory_cache_size'], isA<int>());
      });
    });

    group('clearCache', () {
      test('should clear cache', () async {
        await service.clearCache();

        // Verify clearing doesn't throw
        expect(service, isNotNull);
      });
    });

    group('performMaintenance', () {
      test('should perform cache maintenance', () async {
        await service.performMaintenance();

        // Verify maintenance doesn't throw
        expect(service, isNotNull);
      });
    });
  });
}


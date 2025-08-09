import 'dart:developer' as developer;
import 'package:spots/core/models/spot.dart';
import 'package:spots/data/datasources/local/sembast/sembast/spots_local_datasource.dart';
import 'package:spots/data/datasources/remote/spots_remote_datasource.dart';
import 'package:spots/data/datasources/remote/google_places_datasource.dart';
import 'package:spots/data/datasources/remote/openstreetmap_datasource.dart';

/// Hybrid Search Repository
/// OUR_GUTS.md: "Authenticity Over Algorithms" - Community data prioritized over external sources
class HybridSearchRepository {
  static const String _logName = 'HybridSearchRepository';
  
  final SpotsLocalDataSource? _localDataSource;
  final SpotsRemoteDataSource? _remoteDataSource;
  final GooglePlacesDataSource? _googlePlacesDataSource;
  final OpenStreetMapDataSource? _osmDataSource;
  
  // Search analytics tracking (privacy-preserving)
  final Map<String, int> _searchAnalytics = {};
  final Map<String, DateTime> _lastSearchTime = {};
  
  HybridSearchRepository({
    SpotsLocalDataSource? localDataSource,
    SpotsRemoteDataSource? remoteDataSource,
    GooglePlacesDataSource? googlePlacesDataSource,
    OpenStreetMapDataSource? osmDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _googlePlacesDataSource = googlePlacesDataSource,
       _osmDataSource = osmDataSource;

  /// Hybrid search with community-first prioritization
  /// OUR_GUTS.md: "Community, Not Just Places" - Local community knowledge comes first
  Future<HybridSearchResult> searchSpots({
    required String query,
    double? latitude,
    double? longitude,
    int maxResults = 50,
    bool includeExternal = true,
  }) async {
    try {
      developer.log('Hybrid search: $query', name: _logName);
      final startTime = DateTime.now();
      
      // Track search analytics (privacy-preserving)
      _trackSearch(query);
      
      // STEP 1: Search community data first (highest priority)
      final communitySpots = await _searchCommunityData(query);
      developer.log('Found ${communitySpots.length} community spots', name: _logName);
      
      // STEP 2: Search external data if enabled and community results are limited
      List<Spot> externalSpots = [];
      if (includeExternal && communitySpots.length < maxResults) {
        externalSpots = await _searchExternalData(
          query: query,
          latitude: latitude,
          longitude: longitude,
          maxResults: maxResults - communitySpots.length,
        );
        developer.log('Found ${externalSpots.length} external spots', name: _logName);
      }
      
      // STEP 3: Combine and rank results with community-first prioritization
      final rankedResults = _rankAndDeduplicateResults(
        communitySpots: communitySpots,
        externalSpots: externalSpots,
        query: query,
        userLatitude: latitude,
        userLongitude: longitude,
      );
      
      // STEP 4: Apply final result limit
      final finalResults = rankedResults.take(maxResults).toList();
      
      final searchDuration = DateTime.now().difference(startTime);
      developer.log('Hybrid search completed in ${searchDuration.inMilliseconds}ms', name: _logName);
      
      return HybridSearchResult(
        spots: finalResults,
        communityCount: communitySpots.length,
        externalCount: externalSpots.length,
        totalCount: finalResults.length,
        searchDuration: searchDuration,
        sources: _getSourceBreakdown(finalResults),
      );
    } catch (e) {
      developer.log('Error in hybrid search: $e', name: _logName);
      // OUR_GUTS.md: "Effortless, Seamless Discovery" - Graceful fallback
      return HybridSearchResult.empty();
    }
  }

  /// Search nearby spots with hybrid approach
  /// Community data gets priority even for location-based searches
  Future<HybridSearchResult> searchNearbySpots({
    required double latitude,
    required double longitude,
    int radius = 5000,
    int maxResults = 50,
    bool includeExternal = true,
  }) async {
    try {
      developer.log('Hybrid nearby search: $latitude,$longitude', name: _logName);
      final startTime = DateTime.now();
      
      // STEP 1: Get community spots near location (highest priority)
      final communitySpots = await _searchCommunitySpotsNearby(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      
      // STEP 2: Fill gaps with external data if needed
      List<Spot> externalSpots = [];
      if (includeExternal && communitySpots.length < maxResults) {
        externalSpots = await _searchExternalSpotsNearby(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          maxResults: maxResults - communitySpots.length,
        );
      }
      
      // STEP 3: Combine and rank by distance and community priority
      final rankedResults = _rankByDistanceAndCommunityPriority(
        communitySpots: communitySpots,
        externalSpots: externalSpots,
        userLatitude: latitude,
        userLongitude: longitude,
      );
      
      final finalResults = rankedResults.take(maxResults).toList();
      final searchDuration = DateTime.now().difference(startTime);
      
      return HybridSearchResult(
        spots: finalResults,
        communityCount: communitySpots.length,
        externalCount: externalSpots.length,
        totalCount: finalResults.length,
        searchDuration: searchDuration,
        sources: _getSourceBreakdown(finalResults),
      );
    } catch (e) {
      developer.log('Error in hybrid nearby search: $e', name: _logName);
      return HybridSearchResult.empty();
    }
  }

  // Private helper methods

  Future<List<Spot>> _searchCommunityData(String query) async {
    final List<Spot> communitySpots = [];
    
    try {
      // Search local community data first
      if (_localDataSource != null) {
        final localSpots = await _localDataSource!.searchSpots(query);
        communitySpots.addAll(localSpots);
      }
      
      // Search remote community data
      if (_remoteDataSource != null) {
        final remoteSpots = await _remoteDataSource!.getSpots();
        final filteredRemoteSpots = remoteSpots
            .where((spot) => _matchesQuery(spot, query))
            .toList();
        communitySpots.addAll(filteredRemoteSpots);
      }
    } catch (e) {
      developer.log('Error searching community data: $e', name: _logName);
    }
    
    return communitySpots;
  }

  Future<List<Spot>> _searchExternalData({
    required String query,
    double? latitude,
    double? longitude,
    int maxResults = 20,
  }) async {
    final List<Spot> externalSpots = [];
    
    try {
      // Search OpenStreetMap first (community-driven external data)
      if (_osmDataSource != null) {
        final osmSpots = await _osmDataSource!.searchPlaces(
          query: query,
          latitude: latitude,
          longitude: longitude,
          limit: maxResults ~/ 2,
        );
        externalSpots.addAll(osmSpots);
      }
      
      // Search Google Places as fallback
      if (_googlePlacesDataSource != null && externalSpots.length < maxResults) {
        final googleSpots = await _googlePlacesDataSource!.searchPlaces(
          query: query,
          latitude: latitude,
          longitude: longitude,
          radius: 10000,
        );
        externalSpots.addAll(googleSpots);
      }
    } catch (e) {
      developer.log('Error searching external data: $e', name: _logName);
    }
    
    return externalSpots;
  }

  Future<List<Spot>> _searchCommunitySpotsNearby({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    // For now, return filtered community spots
    // In a real implementation, this would use spatial queries
    final communitySpots = await _searchCommunityData('');
    return communitySpots
        .where((spot) => _isWithinRadius(spot, latitude, longitude, radius))
        .toList();
  }

  Future<List<Spot>> _searchExternalSpotsNearby({
    required double latitude,
    required double longitude,
    int radius = 5000,
    int maxResults = 20,
  }) async {
    final List<Spot> externalSpots = [];
    
    try {
      // OpenStreetMap nearby search (community-driven)
      if (_osmDataSource != null) {
        final osmSpots = await _osmDataSource!.searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        externalSpots.addAll(osmSpots);
      }
      
      // Google Places nearby search
      if (_googlePlacesDataSource != null && externalSpots.length < maxResults) {
        final googleSpots = await _googlePlacesDataSource!.searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        externalSpots.addAll(googleSpots);
      }
    } catch (e) {
      developer.log('Error searching external nearby spots: $e', name: _logName);
    }
    
    return externalSpots;
  }

  List<Spot> _rankAndDeduplicateResults({
    required List<Spot> communitySpots,
    required List<Spot> externalSpots,
    required String query,
    double? userLatitude,
    double? userLongitude,
  }) {
    // OUR_GUTS.md: "Authenticity Over Algorithms" - Community data always ranks higher
    final Map<String, Spot> deduplicatedSpots = {};
    
    // PRIORITY 1: Add community spots first (highest ranking)
    for (final spot in communitySpots) {
      final key = _generateDeduplicationKey(spot);
      if (!deduplicatedSpots.containsKey(key)) {
        deduplicatedSpots[key] = spot;
      }
    }
    
    // PRIORITY 2: Add external spots only if not duplicated
    for (final spot in externalSpots) {
      final key = _generateDeduplicationKey(spot);
      if (!deduplicatedSpots.containsKey(key)) {
        deduplicatedSpots[key] = spot;
      }
    }
    
    final results = deduplicatedSpots.values.toList();
    
    // Sort by relevance while maintaining community priority
    results.sort((a, b) {
      // Community spots always rank higher
      final aIsCommunity = _isCommunitySpot(a);
      final bIsCommunity = _isCommunitySpot(b);
      
      if (aIsCommunity && !bIsCommunity) return -1;
      if (!aIsCommunity && bIsCommunity) return 1;
      
      // Within the same source type, rank by relevance
      final aRelevance = _calculateRelevanceScore(a, query, userLatitude, userLongitude);
      final bRelevance = _calculateRelevanceScore(b, query, userLatitude, userLongitude);
      
      return bRelevance.compareTo(aRelevance);
    });
    
    return results;
  }

  List<Spot> _rankByDistanceAndCommunityPriority({
    required List<Spot> communitySpots,
    required List<Spot> externalSpots,
    required double userLatitude,
    required double userLongitude,
  }) {
    final allSpots = [...communitySpots, ...externalSpots];
    
    // Remove duplicates while preserving community priority
    final Map<String, Spot> deduplicatedSpots = {};
    for (final spot in allSpots) {
      final key = _generateDeduplicationKey(spot);
      if (!deduplicatedSpots.containsKey(key)) {
        deduplicatedSpots[key] = spot;
      } else {
        // If duplicate exists, prefer community data
        final existing = deduplicatedSpots[key]!;
        if (_isCommunitySpot(spot) && !_isCommunitySpot(existing)) {
          deduplicatedSpots[key] = spot;
        }
      }
    }
    
    final results = deduplicatedSpots.values.toList();
    
    // Sort by community priority first, then distance
    results.sort((a, b) {
      final aIsCommunity = _isCommunitySpot(a);
      final bIsCommunity = _isCommunitySpot(b);
      
      if (aIsCommunity && !bIsCommunity) return -1;
      if (!aIsCommunity && bIsCommunity) return 1;
      
      // Within same source type, sort by distance
      final aDistance = _calculateDistance(a.latitude, a.longitude, userLatitude, userLongitude);
      final bDistance = _calculateDistance(b.latitude, b.longitude, userLatitude, userLongitude);
      
      return aDistance.compareTo(bDistance);
    });
    
    return results;
  }

  // Utility methods

  bool _matchesQuery(Spot spot, String query) {
    final queryLower = query.toLowerCase();
    return spot.name.toLowerCase().contains(queryLower) ||
           spot.description.toLowerCase().contains(queryLower) ||
           spot.category.toLowerCase().contains(queryLower) ||
           spot.tags.any((tag) => tag.toLowerCase().contains(queryLower));
  }

  bool _isWithinRadius(Spot spot, double latitude, double longitude, int radius) {
    final distance = _calculateDistance(spot.latitude, spot.longitude, latitude, longitude);
    return distance <= radius;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation (Haversine formula would be more accurate)
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return (dLat * dLat + dLon * dLon) * 111320; // Approximate meters
  }

  String _generateDeduplicationKey(Spot spot) {
    // Generate key for deduplication based on location and name similarity
    final latKey = (spot.latitude * 1000).round();
    final lonKey = (spot.longitude * 1000).round();
    final nameKey = spot.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${latKey}_${lonKey}_$nameKey';
  }

  bool _isCommunitySpot(Spot spot) {
    return !spot.metadata.containsKey('is_external') || 
           spot.metadata['is_external'] != true;
  }

  double _calculateRelevanceScore(Spot spot, String query, double? userLat, double? userLon) {
    double score = 0.0;
    
    // Name match score
    if (spot.name.toLowerCase().contains(query.toLowerCase())) {
      score += 10.0;
    }
    
    // Category match score
    if (spot.category.toLowerCase().contains(query.toLowerCase())) {
      score += 5.0;
    }
    
    // Tag match score
    for (final tag in spot.tags) {
      if (tag.toLowerCase().contains(query.toLowerCase())) {
        score += 2.0;
      }
    }
    
    // Community bonus (OUR_GUTS.md: "Authenticity Over Algorithms")
    if (_isCommunitySpot(spot)) {
      score += 20.0;
    }
    
    // Distance penalty (if location available)
    if (userLat != null && userLon != null) {
      final distance = _calculateDistance(spot.latitude, spot.longitude, userLat, userLon);
      score -= distance / 1000.0; // Penalty for each kilometer
    }
    
    // Rating bonus
    score += spot.rating * 2.0;
    
    return score;
  }

  Map<String, int> _getSourceBreakdown(List<Spot> spots) {
    final sources = <String, int>{};
    
    for (final spot in spots) {
      final source = spot.metadata['source']?.toString() ?? 'community';
      sources[source] = (sources[source] ?? 0) + 1;
    }
    
    return sources;
  }

  void _trackSearch(String query) {
    // Privacy-preserving analytics
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isNotEmpty) {
      _searchAnalytics[normalizedQuery] = (_searchAnalytics[normalizedQuery] ?? 0) + 1;
      _lastSearchTime[normalizedQuery] = DateTime.now();
      
      // Keep only recent search data for privacy
      _cleanupOldAnalytics();
    }
  }

  void _cleanupOldAnalytics() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    _lastSearchTime.removeWhere((query, time) => time.isBefore(cutoff));
    _searchAnalytics.removeWhere((query, count) => !_lastSearchTime.containsKey(query));
  }

  /// Get search analytics (privacy-preserving)
  Map<String, int> getSearchAnalytics() {
    return Map.from(_searchAnalytics);
  }
}

/// Hybrid search result with source breakdown
class HybridSearchResult {
  final List<Spot> spots;
  final int communityCount;
  final int externalCount;
  final int totalCount;
  final Duration searchDuration;
  final Map<String, int> sources;

  HybridSearchResult({
    required this.spots,
    required this.communityCount,
    required this.externalCount,
    required this.totalCount,
    required this.searchDuration,
    required this.sources,
  });

  factory HybridSearchResult.empty() {
    return HybridSearchResult(
      spots: [],
      communityCount: 0,
      externalCount: 0,
      totalCount: 0,
      searchDuration: Duration.zero,
      sources: {},
    );
  }

  /// Get community-to-external ratio for quality metrics
  double get communityRatio {
    if (totalCount == 0) return 0.0;
    return communityCount / totalCount;
  }

  /// Check if search is primarily community-driven (OUR_GUTS.md compliance)
  bool get isPrimarilyCommunityDriven {
    return communityRatio >= 0.5;
  }
}
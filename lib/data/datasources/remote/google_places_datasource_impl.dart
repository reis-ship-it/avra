import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:avrai/core/models/spot.dart';
import 'package:avrai/data/datasources/remote/google_places_datasource.dart';
import 'package:avrai/core/services/google_places_cache_service.dart';

/// Google Places API Implementation (LEGACY - DEPRECATED)
/// 
/// ⚠️ DEPRECATED: This implementation uses the legacy Google Places API.
/// Use [GooglePlacesDataSourceNewImpl] instead, which uses the new Places API (New).
/// 
/// This file is kept for reference but is no longer used in production.
/// Migration completed: See [GOOGLE_PLACES_API_NEW_MIGRATION_COMPLETE.md]
/// 
/// OUR_GUTS.md: "Authenticity Over Algorithms" - External data enriches community knowledge
@Deprecated('Use GooglePlacesDataSourceNewImpl instead. This uses the legacy Places API.')
class GooglePlacesDataSourceImpl implements GooglePlacesDataSource {
  static const String _logName = 'GooglePlacesDataSource';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  final http.Client _httpClient;
  final String _apiKey;
  final GooglePlacesCacheService? _cacheService;
  
  // Rate limiting and caching
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _lastRequest = {};
  static const Duration _cacheExpiry = Duration(hours: 1);
  static const Duration _rateLimitDelay = Duration(milliseconds: 100);
  
  GooglePlacesDataSourceImpl({
    required String apiKey,
    http.Client? httpClient,
    GooglePlacesCacheService? cacheService,
  }) : _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client(),
       _cacheService = cacheService;

  @override
  Future<List<Spot>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 5000,
    String? type,
  }) async {
    try {
      developer.log('Searching places: $query', name: _logName);
      
      // Check cache first for performance
      final cacheKey = 'search_${query}_${latitude}_${longitude}_${radius}_$type';
      if (_isCacheValid(cacheKey)) {
        developer.log('Returning cached results for: $query', name: _logName);
        return List<Spot>.from(_cache[cacheKey]);
      }
      
      // Rate limiting
      await _enforceRateLimit();
      
      // Build request URL
      final url = _buildSearchUrl(
        query: query,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: type,
      );
      
      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final spots = _parseSearchResults(data);
        
        // Cache results in memory
        _cache[cacheKey] = spots;
        _lastRequest[cacheKey] = DateTime.now();
        
        // Cache in local database for offline use
        if (_cacheService != null) {
          await _cacheService!.cachePlaces(spots);
        }
        
        developer.log('Found ${spots.length} places for: $query', name: _logName);
        return spots;
      } else {
        throw GooglePlacesException('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error searching places: $e', name: _logName);
      // OUR_GUTS.md: "Effortless, Seamless Discovery" - Graceful fallback
      return [];
    }
  }

  @override
  Future<Spot?> getPlaceDetails(String placeId) async {
    try {
      developer.log('Getting place details: $placeId', name: _logName);
      
      // Check cache first
      final cacheKey = 'details_$placeId';
      if (_isCacheValid(cacheKey)) {
        return _cache[cacheKey] as Spot?;
      }
      
      // Rate limiting
      await _enforceRateLimit();
      
      final url = '$_baseUrl/details/json?place_id=$placeId&key=$_apiKey&fields=place_id,name,formatted_address,geometry,rating,types,opening_hours,formatted_phone_number,website';
      
      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final spot = _parsePlaceDetails(data['result']);
        
        // Cache result in memory
        _cache[cacheKey] = spot;
        _lastRequest[cacheKey] = DateTime.now();
        
        // Cache in local database for offline use
        if (_cacheService != null && spot != null) {
          await _cacheService!.cachePlace(spot);
        }
        
        return spot;
      } else {
        throw GooglePlacesException('Place details failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error getting place details: $e', name: _logName);
      return null;
    }
  }

  @override
  Future<List<Spot>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 5000,
    String? type,
  }) async {
    try {
      developer.log('Searching nearby places: $latitude,$longitude', name: _logName);
      
      // Check cache first
      final cacheKey = 'nearby_${latitude}_${longitude}_${radius}_$type';
      if (_isCacheValid(cacheKey)) {
        return List<Spot>.from(_cache[cacheKey]);
      }
      
      // Rate limiting
      await _enforceRateLimit();
      
      final url = _buildNearbyUrl(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: type,
      );
      
      final response = await _httpClient.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final spots = _parseSearchResults(data);
        
        // Cache results in memory
        _cache[cacheKey] = spots;
        _lastRequest[cacheKey] = DateTime.now();
        
        // Cache in local database for offline use
        if (_cacheService != null) {
          await _cacheService!.cachePlaces(spots);
        }
        
        developer.log('Found ${spots.length} nearby places', name: _logName);
        return spots;
      } else {
        throw GooglePlacesException('Nearby search failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error searching nearby places: $e', name: _logName);
      return [];
    }
  }

  // Helper methods
  
  String _buildSearchUrl({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 5000,
    String? type,
  }) {
    var url = '$_baseUrl/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_apiKey';
    
    if (latitude != null && longitude != null) {
      url += '&location=$latitude,$longitude&radius=$radius';
    }
    
    if (type != null) {
      url += '&type=$type';
    }
    
    return url;
  }
  
  String _buildNearbyUrl({
    required double latitude,
    required double longitude,
    int radius = 5000,
    String? type,
  }) {
    var url = '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&key=$_apiKey';
    
    if (type != null) {
      url += '&type=$type';
    }
    
    return url;
  }
  
  List<Spot> _parseSearchResults(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((result) => _createSpotFromPlace(result)).toList();
  }
  
  Spot? _parsePlaceDetails(Map<String, dynamic>? result) {
    if (result == null) return null;
    return _createSpotFromPlace(result, isDetailed: true);
  }
  
  Spot _createSpotFromPlace(Map<String, dynamic> place, {bool isDetailed = false}) {
    final geometry = place['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final types = place['types'] as List<dynamic>? ?? [];
    
    // OUR_GUTS.md: "Privacy and Control Are Non-Negotiable" - Clear external data marking
    final now = DateTime.now();
    return Spot(
      id: 'google_${place['place_id']}',
      name: place['name'] ?? 'Unknown Place',
      description: place['formatted_address'] ?? '',
      latitude: location?['lat']?.toDouble() ?? 0.0,
      longitude: location?['lng']?.toDouble() ?? 0.0,
      category: _mapGoogleTypeToCategory(types),
      rating: place['rating']?.toDouble() ?? 0.0,
      createdBy: 'google_places_api',
      createdAt: now,
      updatedAt: now,
      address: place['formatted_address'],
      tags: [
        'external_data',
        'google_places',
        ...types.map((type) => type.toString()),
      ],
      metadata: {
        'source': 'google_places',
        'place_id': place['place_id'],
        'is_external': true,
        if (isDetailed) ...{
          'phone': place['formatted_phone_number'],
          'website': place['website'],
          'opening_hours': place['opening_hours'],
        }
      },
    );
  }
  
  String _mapGoogleTypeToCategory(List<dynamic> types) {
    // Map Google Place types to SPOTS categories
    // OUR_GUTS.md: "Authenticity Over Algorithms" - Maintain consistent categorization
    for (final type in types) {
      switch (type.toString()) {
        case 'restaurant':
        case 'food':
        case 'meal_takeaway':
          return 'Food';
        case 'tourist_attraction':
        case 'museum':
        case 'park':
          return 'Attractions';
        case 'shopping_mall':
        case 'store':
          return 'Shopping';
        case 'night_club':
        case 'bar':
          return 'Nightlife';
        case 'lodging':
          return 'Stay';
        default:
          continue;
      }
    }
    return 'Other';
  }
  
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_lastRequest.containsKey(key)) {
      return false;
    }
    
    final lastRequest = _lastRequest[key]!;
    return DateTime.now().difference(lastRequest) < _cacheExpiry;
  }
  
  Future<void> _enforceRateLimit() async {
    final now = DateTime.now();
    final lastRequestTime = _lastRequest['rate_limit'];
    
    if (lastRequestTime != null) {
      final timeSinceLastRequest = now.difference(lastRequestTime);
      if (timeSinceLastRequest < _rateLimitDelay) {
        final delay = _rateLimitDelay - timeSinceLastRequest;
        await Future.delayed(delay);
      }
    }
    
    _lastRequest['rate_limit'] = DateTime.now();
  }
}

class GooglePlacesException implements Exception {
  final String message;
  GooglePlacesException(this.message);
  
  @override
  String toString() => 'GooglePlacesException: $message';
}
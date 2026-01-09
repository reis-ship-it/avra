import 'package:avrai/core/models/spot.dart';

/// Google Places API Data Source Interface
/// OUR_GUTS.md: "Authenticity Over Algorithms" - External data supplements community content
abstract class GooglePlacesDataSource {
  /// Search for places using Google Places API
  /// Results are marked with external data source for transparency
  Future<List<Spot>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 5000,
    String? type,
  });
  
  /// Get place details by Google Place ID
  Future<Spot?> getPlaceDetails(String placeId);
  
  /// Search nearby places around a location
  /// OUR_GUTS.md: "Community, Not Just Places" - Supplement local community knowledge
  Future<List<Spot>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 5000,
    String? type,
  });
}
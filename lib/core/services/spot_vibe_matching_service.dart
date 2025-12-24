import 'dart:developer' as developer;
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/spot_vibe.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:spots/core/models/unified_models.dart' hide UnifiedUser;
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/ai/quantum/location_compatibility_calculator.dart';
import 'package:spots/core/services/calling_score_calculator.dart';
import 'package:spots/core/services/feature_flag_service.dart';
import 'package:geolocator/geolocator.dart';

/// Spot Vibe Matching Service
/// 
/// CORE PHILOSOPHY: Vibe-based matching
/// - Business accounts define their spot's unique vibe
/// - Users are "called" to spots based on vibe compatibility
/// - Spot vibe + User vibe = Better matches, happier everyone
/// 
/// The overall vibe of the spot (defined by business accounts) should match
/// the overall vibe of the user (known through AI2AI system).
/// 
/// Example: Bemelmans might have a sophisticated, art-focused, cultural vibe.
/// Users with matching vibes (sophisticated, art-loving, cultural) are "called" to it.
/// 
/// This is better than matching based on individual behaviors because:
/// - It considers the overall atmosphere and character of the spot
/// - It matches the whole person, not just one trait
/// - Business accounts can accurately represent their spot's vibe
/// - Users get better matches, spots get better customers, everyone is happier
class SpotVibeMatchingService {
  static const String _logName = 'SpotVibeMatchingService';
  
  final UserVibeAnalyzer _vibeAnalyzer;
  final CallingScoreCalculator? _callingScoreCalculator;
  final FeatureFlagService? _featureFlags;
  
  SpotVibeMatchingService({
    required UserVibeAnalyzer vibeAnalyzer,
    CallingScoreCalculator? callingScoreCalculator,
    FeatureFlagService? featureFlags,
  }) : _vibeAnalyzer = vibeAnalyzer,
       _callingScoreCalculator = callingScoreCalculator,
       _featureFlags = featureFlags;
  
  /// Calculate vibe compatibility between a user and a spot
  /// Returns compatibility score (0.0 to 1.0)
  /// Higher = better match, user should be "called" to this spot
  ///
  /// **Enhanced with Location Entanglement:**
  /// If userLocation and spotLocation are provided, uses enhanced formula:
  /// ```
  /// compatibility = 0.5 * vibe_compatibility + 0.3 * location_compatibility + 0.2 * timing_compatibility
  /// ```
  ///
  /// **Parameters:**
  /// - `user`: User to match
  /// - `spot`: Spot to match against
  /// - `userPersonality`: User's personality profile
  /// - `spotVibe`: Optional spot vibe (if not provided, inferred from spot)
  /// - `userLocation`: Optional user location for location entanglement
  /// - `spotLocation`: Optional spot location for location entanglement
  /// - `timingCompatibility`: Optional timing compatibility (0.0 to 1.0)
  Future<double> calculateSpotUserCompatibility({
    required UnifiedUser user,
    required Spot spot,
    required PersonalityProfile userPersonality,
    SpotVibe? spotVibe, // If provided, use it; otherwise infer from spot
    UnifiedLocation? userLocation, // Optional: for location entanglement
    UnifiedLocation? spotLocation, // Optional: for location entanglement
    double? timingCompatibility, // Optional: timing compatibility
  }) async {
    try {
      // Get user vibe from AI2AI system
      final userVibe = await _vibeAnalyzer.compileUserVibe(
        user.id,
        userPersonality,
      );
      
      // Get spot vibe (from business account or inferred)
      final vibe = spotVibe ?? _inferSpotVibe(spot);
      
      // Calculate vibe compatibility (personality compatibility)
      final vibeCompatibility = vibe.calculateVibeCompatibility(userVibe);
      
      // If location information is available and feature flag is enabled, use enhanced compatibility with location entanglement
      final locationEntanglementEnabled = _featureFlags != null
          ? await _featureFlags!.isEnabled(
              QuantumFeatureFlags.locationEntanglement,
              userId: user.id,
              defaultValue: false,
            )
          : false;

      if (locationEntanglementEnabled &&
          userLocation != null &&
          spotLocation != null) {
        // Calculate location compatibility
        final locationCompatibility = LocationCompatibilityCalculator
            .calculateLocationCompatibility(
          locationA: userLocation,
          locationB: spotLocation,
        );
        
        // Use enhanced compatibility formula: 0.5 * vibe + 0.3 * location + 0.2 * timing
        final enhancedCompatibility = LocationCompatibilityCalculator
            .calculateEnhancedCompatibility(
          personalityCompatibility: vibeCompatibility,
          locationCompatibility: locationCompatibility,
          timingCompatibility: timingCompatibility,
        );
        
        developer.log(
          'Spot-User compatibility (with location): ${spot.name} <-> ${user.id}: '
          'vibe=${(vibeCompatibility * 100).toStringAsFixed(1)}%, '
          'location=${(locationCompatibility * 100).toStringAsFixed(1)}%, '
          'total=${(enhancedCompatibility * 100).toStringAsFixed(1)}%',
          name: _logName,
        );
        
        return enhancedCompatibility;
      }
      
      // Fallback to vibe-only compatibility if location not available
      developer.log(
        'Spot-User compatibility: ${spot.name} <-> ${user.id}: '
        '${(vibeCompatibility * 100).toStringAsFixed(1)}%',
        name: _logName,
      );
      
      return vibeCompatibility;
    } catch (e) {
      developer.log('Error calculating spot-user compatibility: $e', name: _logName);
      return 0.5; // Neutral fallback
    }
  }
  
  /// Check if a spot should "call" a user
  /// Returns true if calling score is high enough for recommendation
  /// 
  /// NEW: Uses unified calling score if available, falls back to compatibility
  Future<bool> shouldCallUserToSpot({
    required UnifiedUser user,
    required Spot spot,
    required PersonalityProfile userPersonality,
    SpotVibe? spotVibe,
    Position? currentLocation,
    double threshold = 0.7, // 70% calling score threshold
  }) async {
    // Use calling score calculator if available
    if (_callingScoreCalculator != null) {
      try {
        final userVibe = await _vibeAnalyzer.compileUserVibe(user.id, userPersonality);
        final vibe = spotVibe ?? _inferSpotVibe(spot);
        
        final context = currentLocation != null
            ? CallingContext.fromLocation(
                currentLocation,
                Position(
                  latitude: spot.latitude,
                  longitude: spot.longitude,
                  timestamp: DateTime.now(),
                  accuracy: 0.0,
                  altitude: 0.0,
                  altitudeAccuracy: 0.0,
                  heading: 0.0,
                  headingAccuracy: 0.0,
                  speed: 0.0,
                  speedAccuracy: 0.0,
                ),
              )
            : CallingContext.empty();
        
        final timing = TimingFactors.fromDateTime(DateTime.now());
        
        final callingScore = await _callingScoreCalculator!.calculateCallingScore(
          userVibe: userVibe,
          opportunityVibe: vibe,
          context: context,
          timing: timing,
          userPersonality: userPersonality,
        );
        
        return callingScore.isCalled;
      } catch (e) {
        developer.log('Error calculating calling score, falling back to compatibility: $e', name: _logName);
        // Fall through to compatibility-based check
      }
    }
    
    // Fallback to compatibility-based check
    final compatibility = await calculateSpotUserCompatibility(
      user: user,
      spot: spot,
      userPersonality: userPersonality,
      spotVibe: spotVibe,
    );
    
    return compatibility >= threshold;
  }
  
  /// Find spots that should "call" a user
  /// Returns spots sorted by vibe compatibility (highest first)
  Future<List<SpotMatch>> findMatchingSpots({
    required UnifiedUser user,
    required List<Spot> candidateSpots,
    required PersonalityProfile userPersonality,
    Map<String, SpotVibe>? spotVibes, // Map of spotId -> SpotVibe
    double minCompatibility = 0.7, // Minimum compatibility to include
    int maxResults = 20, // Maximum number of results
  }) async {
    try {
      // Get user vibe from AI2AI system
      final userVibe = await _vibeAnalyzer.compileUserVibe(
        user.id,
        userPersonality,
      );
      
      final matches = <SpotMatch>[];
      
      for (final spot in candidateSpots) {
        // Get spot vibe (from provided map or infer)
        final spotVibe = spotVibes?[spot.id] ?? _inferSpotVibe(spot);
        
        // Calculate compatibility
        final compatibility = spotVibe.calculateVibeCompatibility(userVibe);
        
        if (compatibility >= minCompatibility) {
          matches.add(SpotMatch(
            spot: spot,
            spotVibe: spotVibe,
            compatibility: compatibility,
            shouldCall: true,
          ));
        }
      }
      
      // Sort by compatibility (highest first)
      matches.sort((a, b) => b.compatibility.compareTo(a.compatibility));
      
      // Limit results
      final results = matches.take(maxResults).toList();
      
      developer.log(
        'Found ${results.length} matching spots for user ${user.id} '
        '(min compatibility: ${(minCompatibility * 100).toStringAsFixed(0)}%)',
        name: _logName,
      );
      
      return results;
    } catch (e) {
      developer.log('Error finding matching spots: $e', name: _logName);
      return [];
    }
  }
  
  /// Infer spot vibe from spot characteristics (fallback if no business definition)
  SpotVibe _inferSpotVibe(Spot spot) {
    return SpotVibe.fromSpotCharacteristics(
      spotId: spot.id,
      category: spot.category,
      tags: spot.tags,
      description: spot.description,
      rating: spot.rating,
    );
  }
}

/// Spot Match Result
/// Represents a spot that matches a user's vibe
class SpotMatch {
  final Spot spot;
  final SpotVibe spotVibe;
  final double compatibility; // 0.0 to 1.0
  final bool shouldCall; // Should this spot "call" the user?
  
  SpotMatch({
    required this.spot,
    required this.spotVibe,
    required this.compatibility,
    required this.shouldCall,
  });
  
  /// Get match quality description
  String get matchQuality {
    if (compatibility >= 0.9) return 'Perfect Match';
    if (compatibility >= 0.8) return 'Excellent Match';
    if (compatibility >= 0.7) return 'Great Match';
    if (compatibility >= 0.6) return 'Good Match';
    return 'Moderate Match';
  }
}


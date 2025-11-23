import 'dart:developer' as developer;
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/expertise_pin.dart';
import 'package:spots/core/models/expertise_level.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/expertise_matching_service.dart';

/// Expert Recommendations Service
/// Provides recommendations based on expert preferences and validations
class ExpertRecommendationsService {
  static const String _logName = 'ExpertRecommendationsService';
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  
  final ExpertiseMatchingService _matchingService = ExpertiseMatchingService();

  /// Get spot recommendations from experts
  Future<List<ExpertRecommendation>> getExpertRecommendations(
    UnifiedUser user, {
    String? category,
    int maxResults = 20,
  }) async {
    try {
      _logger.info('Getting expert recommendations for: ${user.id}', tag: _logName);

      // Find similar experts
      final categories = category != null 
          ? [category] 
          : user.getExpertiseCategories();
      
      if (categories.isEmpty) {
        // No expertise yet - use general recommendations
        return await _getGeneralExpertRecommendations(user, maxResults: maxResults);
      }

      // Use a Map to accumulate scores and experts before creating recommendations
      final recommendationData = <String, Map<String, dynamic>>{};

      for (final cat in categories) {
        final similarExperts = await _matchingService.findSimilarExperts(
          user,
          cat,
          maxResults: 5,
        );

        for (final expertMatch in similarExperts) {
          // Get spots recommended by this expert
          final expertSpots = await _getExpertRecommendedSpots(expertMatch.user, cat);
          
          for (final spot in expertSpots) {
            final spotId = spot.id;
            if (recommendationData.containsKey(spotId)) {
              // Update existing recommendation
              final existing = recommendationData[spotId]!;
              (existing['experts'] as List<UnifiedUser>).add(expertMatch.user);
              existing['score'] = (existing['score'] as double) + expertMatch.matchScore * 0.2;
            } else {
              // Create new recommendation entry
              recommendationData[spotId] = {
                'spot': spot,
                'category': cat,
                'score': expertMatch.matchScore * 0.5,
                'experts': <UnifiedUser>[expertMatch.user],
                'reason': 'Recommended by ${expertMatch.user.displayName ?? expertMatch.user.id}',
              };
            }
          }
        }
      }

      // Convert map to list of ExpertRecommendation objects
      final recommendations = recommendationData.values.map((entry) {
        return ExpertRecommendation(
          spot: entry['spot'] as Spot,
          category: entry['category'] as String,
          recommendationScore: entry['score'] as double,
          recommendingExperts: entry['experts'] as List<UnifiedUser>,
          recommendationReason: entry['reason'] as String,
        );
      }).toList();

      // Sort by recommendation score
      recommendations.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));

      _logger.info('Generated ${recommendations.length} expert recommendations', tag: _logName);
      return recommendations.take(maxResults).toList();
    } catch (e) {
      _logger.error('Error getting expert recommendations', error: e, tag: _logName);
      return [];
    }
  }

  /// Get expert-curated lists
  Future<List<ExpertCuratedList>> getExpertCuratedLists(
    UnifiedUser user, {
    String? category,
    int maxResults = 10,
  }) async {
    try {
      _logger.info('Getting expert-curated lists for: ${user.id}', tag: _logName);

      final categories = category != null 
          ? [category] 
          : user.getExpertiseCategories();
      
      if (categories.isEmpty) {
        return [];
      }

      final curatedLists = <ExpertCuratedList>[];

      for (final cat in categories) {
        final experts = await _matchingService.findSimilarExperts(
          user,
          cat,
          maxResults: 10,
        );

        for (final expertMatch in experts) {
          // Get lists curated by this expert
          final expertLists = await _getExpertCuratedListsForCategory(
            expertMatch.user,
            cat,
          );

          for (final list in expertLists) {
            curatedLists.add(ExpertCuratedList(
              list: list,
              curator: expertMatch.user,
              category: cat,
              curatorExpertise: expertMatch.user.getExpertiseLevel(cat),
              respectCount: list.respectCount,
            ));
          }
        }
      }

      // Sort by respect count and expertise level
      curatedLists.sort((a, b) {
        final respectCompare = b.respectCount.compareTo(a.respectCount);
        if (respectCompare != 0) return respectCompare;
        
        final aLevel = a.curatorExpertise?.index ?? 0;
        final bLevel = b.curatorExpertise?.index ?? 0;
        return bLevel.compareTo(aLevel);
      });

      return curatedLists.take(maxResults).toList();
    } catch (e) {
      _logger.error('Error getting expert-curated lists', error: e, tag: _logName);
      return [];
    }
  }

  /// Get expert-validated spots
  Future<List<Spot>> getExpertValidatedSpots({
    String? category,
    String? location,
    int maxResults = 20,
  }) async {
    try {
      _logger.info('Getting expert-validated spots', tag: _logName);

      // In production, this would query spots that have been validated by experts
      // For now, return empty list as placeholder
      return [];
    } catch (e) {
      _logger.error('Error getting expert-validated spots', error: e, tag: _logName);
      return [];
    }
  }

  // Private helper methods

  Future<List<ExpertRecommendation>> _getGeneralExpertRecommendations(
    UnifiedUser user, {
    int maxResults = 20,
  }) async {
    // Get recommendations from top experts in popular categories
    final popularCategories = ['Coffee', 'Restaurants', 'Parks', 'Museums'];
    final recommendations = <ExpertRecommendation>[];

    for (final category in popularCategories) {
      final expertSpots = await _getTopExpertSpots(category);
      for (final spot in expertSpots) {
        recommendations.add(ExpertRecommendation(
          spot: spot,
          category: category,
          recommendationScore: 0.5,
          recommendingExperts: [],
          recommendationReason: 'Popular in $category',
        ));
      }
    }

    return recommendations.take(maxResults).toList();
  }

  Future<List<Spot>> _getExpertRecommendedSpots(
    UnifiedUser expert,
    String category,
  ) async {
    // In production, this would get spots from expert's lists and reviews
    // For now, return empty list as placeholder
    return [];
  }

  Future<List<dynamic>> _getExpertCuratedListsForCategory(
    UnifiedUser expert,
    String category,
  ) async {
    // In production, this would get lists curated by expert in this category
    // For now, return empty list as placeholder
    return [];
  }

  Future<List<Spot>> _getTopExpertSpots(String category) async {
    // In production, this would get top-rated spots in category
    // For now, return empty list as placeholder
    return [];
  }
}

/// Expert Recommendation
class ExpertRecommendation {
  final Spot spot;
  final String category;
  final double recommendationScore;
  final List<UnifiedUser> recommendingExperts;
  final String recommendationReason;

  ExpertRecommendation({
    required this.spot,
    required this.category,
    required this.recommendationScore,
    required this.recommendingExperts,
    required this.recommendationReason,
  });
}

/// Expert Curated List
class ExpertCuratedList {
  final dynamic list; // UnifiedList
  final UnifiedUser curator;
  final String category;
  final ExpertiseLevel? curatorExpertise;
  final int respectCount;

  ExpertCuratedList({
    required this.list,
    required this.curator,
    required this.category,
    this.curatorExpertise,
    required this.respectCount,
  });
}


import 'dart:developer' as developer;
import 'package:spots/core/services/business/ai/personality_learning.dart';
import 'package:spots/core/services/business/ai/advanced_communication.dart';
import 'package:spots/core/services/business/ml/predictive_analytics.dart';

/// AI-powered list generation service for SPOTS
/// Creates personalized list suggestions based on user preferences and AI analysis
class AIListGeneratorService {
  static const String _logName = 'AIListGeneratorService';
  
  // List categories and their associated preferences
  static const Map<String, List<String>> _categoryPreferences = {
    'Food & Drink': [
      'Coffee & Tea',
      'Bars & Pubs',
      'Fine Dining',
      'Casual Restaurants',
      'Food Trucks',
      'Bakeries',
      'Ice Cream',
      'Wine Bars',
      'Craft Beer',
      'Cocktail Bars',
      'Vegan/Vegetarian',
      'Pizza',
      'Sushi',
      'BBQ',
      'Mexican',
      'Italian',
      'Thai',
      'Indian',
      'Mediterranean',
      'Korean',
    ],
    'Activities': [
      'Live Music',
      'Theaters',
      'Sports & Fitness',
      'Shopping',
      'Bookstores',
      'Libraries',
      'Cinemas',
      'Bowling',
      'Escape Rooms',
      'Arcades',
      'Spas & Wellness',
      'Yoga Studios',
      'Rock Climbing',
      'Dance Classes',
      'Art Classes',
      'Cooking Classes',
      'Photography',
      'Gaming',
      'Board Games',
      'Karaoke',
    ],
    'Outdoor & Nature': [
      'Hiking Trails',
      'Beaches',
      'Parks',
      'Gardens',
      'Botanical Gardens',
      'Nature Reserves',
      'Camping',
      'Fishing',
      'Kayaking',
      'Biking Trails',
      'Rock Climbing',
      'Bird Watching',
      'Stargazing',
      'Picnic Spots',
      'Waterfalls',
      'Scenic Views',
      'Wildlife',
      'Farms',
      'Vineyards',
      'Orchards',
    ],
  };

  /// Generates personalized list suggestions based on user preferences
  static Future<List<String>> generatePersonalizedLists({
    required String userName,
    required String? homebase,
    required List<String> favoritePlaces,
    required Map<String, List<String>> preferences,
  }) async {
    try {
      developer.log('Generating personalized lists for user: $userName', name: _logName);
      
      final suggestions = <String>[];
      
      // Generate location-aware suggestions
      if (homebase != null && homebase.isNotEmpty) {
        suggestions.addAll(_generateLocationBasedSuggestions(homebase, preferences));
      }
      
      // Generate preference-based suggestions
      suggestions.addAll(_generatePreferenceBasedSuggestions(preferences));
      
      // Generate personality-based suggestions
      suggestions.addAll(await _generatePersonalityBasedSuggestions(userName, preferences));
      
      // Generate AI-enhanced suggestions
      suggestions.addAll(_generateAIEnhancedSuggestions(homebase));
      
      // Generate favorite places inspired suggestions
      if (favoritePlaces.isNotEmpty) {
        suggestions.addAll(_generateFavoritePlacesSuggestions(favoritePlaces, homebase));
      }
      
      // Remove duplicates and limit to top suggestions
      final uniqueSuggestions = suggestions.toSet().toList();
      final finalSuggestions = uniqueSuggestions.take(8).toList();
      
      developer.log('Generated ${finalSuggestions.length} personalized lists', name: _logName);
      return finalSuggestions;
    } catch (e) {
      developer.log('Error generating personalized lists: $e', name: _logName);
      return _getFallbackSuggestions(userName);
    }
  }

  /// Generates location-based list suggestions
  static List<String> _generateLocationBasedSuggestions(
    String homebase,
    Map<String, List<String>> preferences,
  ) {
    final suggestions = <String>[];
    
    // Food & Drink preferences
    if (preferences.containsKey('Food & Drink')) {
      final foodPrefs = preferences['Food & Drink']!;
      for (final pref in foodPrefs) {
        switch (pref) {
          case 'Coffee & Tea':
            suggestions.add('Coffee & Tea Spots Near $homebase');
            suggestions.add('Hidden Cafes in $homebase');
            break;
          case 'Bars & Pubs':
            suggestions.add('Best Bars in $homebase');
            suggestions.add('Craft Beer Spots in $homebase');
            break;
          case 'Fine Dining':
            suggestions.add('Fine Dining in $homebase');
            suggestions.add('Date Night Restaurants');
            break;
          case 'Food Trucks':
            suggestions.add('Food Truck Hotspots in $homebase');
            suggestions.add('Street Food in $homebase');
            break;
          case 'Vegan/Vegetarian':
            suggestions.add('Vegan & Vegetarian Spots in $homebase');
            suggestions.add('Plant-Based Dining');
            break;
        }
      }
    }
    
    // Activities preferences
    if (preferences.containsKey('Activities')) {
      final activityPrefs = preferences['Activities']!;
      for (final pref in activityPrefs) {
        switch (pref) {
          case 'Live Music':
            suggestions.add('Live Music Venues in $homebase');
            suggestions.add('Jazz & Blues Spots');
            break;
          case 'Theaters':
            suggestions.add('Theater & Performance Venues');
            suggestions.add('Cultural Spots in $homebase');
            break;
          case 'Sports & Fitness':
            suggestions.add('Gyms & Fitness Centers in $homebase');
            suggestions.add('Sports Venues');
            break;
          case 'Shopping':
            suggestions.add('Shopping Districts in $homebase');
            suggestions.add('Local Boutiques');
            break;
          case 'Bookstores':
            suggestions.add('Independent Bookstores in $homebase');
            suggestions.add('Reading Spots');
            break;
        }
      }
    }
    
    // Outdoor & Nature preferences
    if (preferences.containsKey('Outdoor & Nature')) {
      final outdoorPrefs = preferences['Outdoor & Nature']!;
      for (final pref in outdoorPrefs) {
        switch (pref) {
          case 'Hiking Trails':
            suggestions.add('Hiking Trails Near $homebase');
            suggestions.add('Outdoor Adventures');
            break;
          case 'Beaches':
            suggestions.add('Beach Spots Near $homebase');
            suggestions.add('Waterfront Locations');
            break;
          case 'Parks':
            suggestions.add('Parks & Green Spaces in $homebase');
            suggestions.add('Picnic Spots');
            break;
        }
      }
    }
    
    return suggestions;
  }

  /// Generates preference-based list suggestions
  static List<String> _generatePreferenceBasedSuggestions(
    Map<String, List<String>> preferences,
  ) {
    final suggestions = <String>[];
    
    // Count preferences to determine user's interests
    final foodCount = preferences['Food & Drink']?.length ?? 0;
    final activityCount = preferences['Activities']?.length ?? 0;
    final outdoorCount = preferences['Outdoor & Nature']?.length ?? 0;
    
    // Generate suggestions based on preference intensity
    if (foodCount > 3) {
      suggestions.add('Foodie Adventures');
      suggestions.add('Culinary Discoveries');
    }
    
    if (activityCount > 3) {
      suggestions.add('Entertainment Hotspots');
      suggestions.add('Activity Centers');
    }
    
    if (outdoorCount > 3) {
      suggestions.add('Nature Escapes');
      suggestions.add('Outdoor Adventures');
    }
    
    // Mixed preferences
    if (foodCount > 0 && activityCount > 0) {
      suggestions.add('Social Dining Spots');
    }
    
    if (outdoorCount > 0 && foodCount > 0) {
      suggestions.add('Outdoor Dining');
    }
    
    return suggestions;
  }

  /// Generates personality-based suggestions using AI systems
  static Future<List<String>> _generatePersonalityBasedSuggestions(
    String userName,
    Map<String, List<String>> preferences,
  ) async {
    try {
      final suggestions = <String>[];
      
      // Analyze preferences to determine personality traits
      final hasManyFoodPrefs = (preferences['Food & Drink']?.length ?? 0) > 2;
      final hasManyActivityPrefs = (preferences['Activities']?.length ?? 0) > 2;
      final hasManyOutdoorPrefs = (preferences['Outdoor & Nature']?.length ?? 0) > 2;
      
      // Generate personality-based suggestions
      if (hasManyFoodPrefs) {
        suggestions.add('$userName\'s Food Adventures');
        suggestions.add('Culinary Explorer');
      }
      
      if (hasManyActivityPrefs) {
        suggestions.add('$userName\'s Entertainment Guide');
        suggestions.add('Activity Seeker');
      }
      
      if (hasManyOutdoorPrefs) {
        suggestions.add('$userName\'s Nature Trails');
        suggestions.add('Outdoor Enthusiast');
      }
      
      // Balanced personality
      if (hasManyFoodPrefs && hasManyActivityPrefs && hasManyOutdoorPrefs) {
        suggestions.add('$userName\'s Balanced Lifestyle');
        suggestions.add('Versatile Explorer');
      }
      
      return suggestions;
    } catch (e) {
      developer.log('Error generating personality-based suggestions: $e', name: _logName);
      return [];
    }
  }

  /// Generates AI-enhanced suggestions
  static List<String> _generateAIEnhancedSuggestions(String? homebase) {
    final suggestions = <String>[];
    
    if (homebase != null && homebase.isNotEmpty) {
      suggestions.addAll([
        'AI-Curated Local Gems in $homebase',
        'Community-Recommended Spots',
        'Trending in $homebase',
        'Hidden Treasures',
        'Local Expert Picks',
        'Insider Secrets',
        'Off-the-Beaten-Path',
        'Local Favorites',
      ]);
    } else {
      suggestions.addAll([
        'AI-Curated Local Gems',
        'Community-Recommended Spots',
        'Trending in Your Area',
        'Hidden Treasures',
        'Local Expert Picks',
        'Insider Secrets',
        'Off-the-Beaten-Path',
        'Local Favorites',
      ]);
    }
    
    return suggestions;
  }

  /// Generates suggestions based on favorite places
  static List<String> _generateFavoritePlacesSuggestions(
    List<String> favoritePlaces,
    String? homebase,
  ) {
    final suggestions = <String>[];
    
    // Analyze favorite places to generate relevant suggestions
    final hasInternationalPlaces = favoritePlaces.any((place) =>
        place.toLowerCase().contains('paris') ||
        place.toLowerCase().contains('tokyo') ||
        place.toLowerCase().contains('london') ||
        place.toLowerCase().contains('barcelona'));
    
    final hasNaturePlaces = favoritePlaces.any((place) =>
        place.toLowerCase().contains('park') ||
        place.toLowerCase().contains('beach') ||
        place.toLowerCase().contains('mountain') ||
        place.toLowerCase().contains('forest'));
    
    final hasUrbanPlaces = favoritePlaces.any((place) =>
        place.toLowerCase().contains('city') ||
        place.toLowerCase().contains('downtown') ||
        place.toLowerCase().contains('district'));
    
    // Generate suggestions based on favorite place types
    if (hasInternationalPlaces) {
      suggestions.add('International Vibes');
      suggestions.add('Global Flavors');
    }
    
    if (hasNaturePlaces) {
      suggestions.add('Nature Retreats');
      suggestions.add('Peaceful Escapes');
    }
    
    if (hasUrbanPlaces) {
      suggestions.add('Urban Adventures');
      suggestions.add('City Life');
    }
    
    // Mixed preferences
    if (hasInternationalPlaces && hasNaturePlaces) {
      suggestions.add('Cultural Nature Spots');
    }
    
    if (hasUrbanPlaces && hasNaturePlaces) {
      suggestions.add('Urban Nature Oases');
    }
    
    return suggestions;
  }

  /// Fallback suggestions when AI generation fails
  static List<String> _getFallbackSuggestions(String userName) {
    return [
      '$userName\'s Chill Spots',
      '$userName\'s Fun Spots',
      '$userName\'s Recommended Spots',
      'Hidden Gems',
      'Local Favorites',
      'Weekend Adventures',
      'Community Picks',
      'Trending Spots',
    ];
  }
} 
import 'dart:developer' as developer;

/// Maps raw onboarding answers into initial values for the 12 SPOTS dimensions.
///
/// **Source of truth:** on-device.
///
/// This intentionally mirrors the logic used by `PersonalityLearning` so the app
/// can derive dimensions without any network dependency.
///
/// Notes:
/// - This mapper produces *initial insights* for a subset of dimensions. The
///   remaining dimensions stay at their default values and evolve later.
/// - Values are clamped to 0.0–1.0.
final class OnboardingDimensionMapper {
  static const String _logName = 'OnboardingDimensionMapper';

  /// Derive initial dimension insights from onboarding data.
  ///
  /// `onboardingData` is expected to contain keys like:
  /// - `age` (int)
  /// - `homebase` (String)
  /// - `favoritePlaces` (List)
  /// - `preferences` (Map&lt;String, dynamic&gt;)
  /// - `respectedFriends` (List)
  Map<String, double> mapOnboardingToDimensions(
    Map<String, dynamic> onboardingData,
  ) {
    final insights = <String, double>{};

    try {
      // Age adjustments
      final age = onboardingData['age'] as int?;
      if (age != null) {
        if (age < 25) {
          insights['exploration_eagerness'] = 0.6;
          insights['temporal_flexibility'] = 0.65;
        } else if (age > 45) {
          insights['authenticity_preference'] = 0.65;
          insights['trust_network_reliance'] = 0.6;
        }
      }

      // Homebase → location dimensions
      final homebase = onboardingData['homebase'] as String?;
      if (homebase != null && _isUrbanArea(homebase)) {
        insights['location_adventurousness'] =
            (insights['location_adventurousness'] ?? 0.5) + 0.1;
      }

      // Favorite places → exploration, location adventurousness
      final favoritePlaces = onboardingData['favoritePlaces'] as List<dynamic>? ??
          const <dynamic>[];
      if (favoritePlaces.length > 5) {
        insights['exploration_eagerness'] =
            (insights['exploration_eagerness'] ?? 0.5) + 0.1;
        insights['location_adventurousness'] =
            (insights['location_adventurousness'] ?? 0.5) + 0.12;
      }

      // Preferences mapping
      final preferences =
          onboardingData['preferences'] as Map<String, dynamic>? ??
              const <String, dynamic>{};

      // Food & Drink → curation, authenticity
      if (preferences.containsKey('Food & Drink')) {
        final foodPrefs =
            preferences['Food & Drink'] as List<dynamic>? ?? const <dynamic>[];
        if (foodPrefs.isNotEmpty) {
          insights['curation_tendency'] =
              (insights['curation_tendency'] ?? 0.5) + 0.05;
          insights['authenticity_preference'] =
              (insights['authenticity_preference'] ?? 0.5) + 0.03;
        }
      }

      // Activities → exploration, social
      if (preferences.containsKey('Activities')) {
        final activityPrefs =
            preferences['Activities'] as List<dynamic>? ?? const <dynamic>[];
        if (activityPrefs.isNotEmpty) {
          insights['exploration_eagerness'] =
              (insights['exploration_eagerness'] ?? 0.5) + 0.08;
          insights['social_discovery_style'] =
              (insights['social_discovery_style'] ?? 0.5) + 0.05;
        }
      }

      // Outdoor & Nature → location adventurousness, exploration
      if (preferences.containsKey('Outdoor & Nature')) {
        final outdoorPrefs = preferences['Outdoor & Nature'] as List<dynamic>? ??
            const <dynamic>[];
        if (outdoorPrefs.isNotEmpty) {
          insights['location_adventurousness'] =
              (insights['location_adventurousness'] ?? 0.5) + 0.1;
          insights['exploration_eagerness'] =
              (insights['exploration_eagerness'] ?? 0.5) + 0.08;
        }
      }

      // Social preferences → community orientation, social discovery
      if (preferences.containsKey('Social')) {
        final socialPrefs =
            preferences['Social'] as List<dynamic>? ?? const <dynamic>[];
        if (socialPrefs.isNotEmpty) {
          insights['community_orientation'] =
              (insights['community_orientation'] ?? 0.5) + 0.1;
          insights['social_discovery_style'] =
              (insights['social_discovery_style'] ?? 0.5) + 0.08;
        }
      }

      // Friends/Respected Lists → community orientation, trust network
      final respectedFriends =
          onboardingData['respectedFriends'] as List<dynamic>? ??
              const <dynamic>[];
      if (respectedFriends.isNotEmpty) {
        insights['community_orientation'] =
            (insights['community_orientation'] ?? 0.5) + 0.08;
        insights['trust_network_reliance'] =
            (insights['trust_network_reliance'] ?? 0.5) + 0.06;
      }

      // Clamp all values to valid range
      insights.forEach((key, value) {
        insights[key] = value.clamp(0.0, 1.0);
      });

      return insights;
    } catch (e, st) {
      developer.log(
        'Error mapping onboarding data to dimensions: $e',
        name: _logName,
        error: e,
        stackTrace: st,
      );
      return const <String, double>{};
    }
  }

  bool _isUrbanArea(String homebase) {
    // Simple heuristic: check for common urban indicators
    final lowerHomebase = homebase.toLowerCase();
    return lowerHomebase.contains('city') ||
        lowerHomebase.contains('san francisco') ||
        lowerHomebase.contains('new york') ||
        lowerHomebase.contains('los angeles') ||
        lowerHomebase.contains('chicago') ||
        lowerHomebase.contains('boston') ||
        lowerHomebase.contains('seattle') ||
        lowerHomebase.contains('portland') ||
        lowerHomebase.contains('austin') ||
        lowerHomebase.contains('miami') ||
        lowerHomebase.contains('denver');
  }
}


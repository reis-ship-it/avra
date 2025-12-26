import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';

import 'package:spots/core/controllers/base/workflow_controller.dart';
import 'package:spots/core/controllers/base/controller_result.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/services/preferences_profile_service.dart';
import 'package:spots/core/services/event_recommendation_service.dart' as event_rec_service;
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:spots/core/models/preferences_profile.dart';

// Import for SharedPreferencesCompat (matches injection_container.dart)
// This is the type registered in DI container
import 'package:spots/core/services/storage_service.dart' show SharedPreferencesCompat;

/// AI Recommendation Controller
/// 
/// Orchestrates the complete AI recommendation workflow. Coordinates loading
/// of personality and preferences profiles, calculates quantum compatibility,
/// and generates personalized recommendations for events, spots, and lists.
/// 
/// **Responsibilities:**
/// - Load PersonalityProfile (for quantum compatibility with hosts/users)
/// - Load PreferencesProfile (for quantum compatibility with events/spots)
/// - Calculate quantum compatibility scores
/// - Get event recommendations via EventRecommendationService
/// - Rank and filter recommendations
/// - Return unified recommendation results
/// 
/// **Dependencies:**
/// - `PersonalityLearning` - Load personality profiles
/// - `PreferencesProfileService` - Load preferences profiles
/// - `EventRecommendationService` - Get event recommendations
/// - `AgentIdService` - Get agentId for privacy protection
/// 
/// **Usage:**
/// ```dart
/// final controller = AIRecommendationController();
/// final result = await controller.generateRecommendations(
///   userId: 'user_123',
///   context: RecommendationContext(
///     category: 'Coffee',
///     location: 'Greenpoint',
///     maxResults: 20,
///   ),
/// );
/// 
/// if (result.isSuccess) {
///   final recommendations = result.recommendations;
///   final events = recommendations.events;
/// } else {
///   // Handle errors
/// }
/// ```
class AIRecommendationController
    implements WorkflowController<RecommendationInput, RecommendationResult> {
  static const String _logName = 'AIRecommendationController';

  final PersonalityLearning _personalityLearning;
  final PreferencesProfileService _preferencesProfileService;
  final event_rec_service.EventRecommendationService _eventRecommendationService;
  final AgentIdService _agentIdService;

  AIRecommendationController({
    PersonalityLearning? personalityLearning,
    PreferencesProfileService? preferencesProfileService,
    event_rec_service.EventRecommendationService? eventRecommendationService,
    AgentIdService? agentIdService,
  })  : _personalityLearning = personalityLearning ??
            (() {
              // Use same pattern as injection_container.dart
              final prefs = GetIt.instance<SharedPreferencesCompat>();
              // SharedPreferencesCompat implements SharedPreferences interface
              return PersonalityLearning.withPrefs(prefs);
            })(),
        _preferencesProfileService =
            preferencesProfileService ?? PreferencesProfileService(),
        _eventRecommendationService =
            eventRecommendationService ??
            event_rec_service.EventRecommendationService(),
        _agentIdService = agentIdService ?? AgentIdService();

  /// Generate comprehensive recommendations
  /// 
  /// Orchestrates the complete recommendation workflow:
  /// 1. Get agentId for privacy protection
  /// 2. Load PersonalityProfile
  /// 3. Load PreferencesProfile
  /// 4. Get event recommendations
  /// 5. Calculate quantum compatibility scores
  /// 6. Rank and filter results
  /// 
  /// **Parameters:**
  /// - `userId`: User ID to get recommendations for
  /// - `context`: Recommendation context (category, location, maxResults, etc.)
  /// 
  /// **Returns:**
  /// RecommendationResult with event, spot, and list recommendations
  Future<RecommendationResult> generateRecommendations({
    required String userId,
    required RecommendationContext context,
  }) async {
    try {
      developer.log(
        '🎯 Starting AI recommendation generation for user: $userId',
        name: _logName,
      );

      // Step 1: Get agentId for privacy protection
      final agentId = await _agentIdService.getUserAgentId(userId);

      // Step 2: Load PersonalityProfile
      PersonalityProfile? personalityProfile;
      try {
        personalityProfile = await _personalityLearning.initializePersonality(
          userId,
        );
        developer.log(
          '✅ Loaded PersonalityProfile (generation ${personalityProfile.evolutionGeneration})',
          name: _logName,
        );
      } catch (e) {
        developer.log(
          '⚠️ Could not load PersonalityProfile: $e',
          name: _logName,
        );
        // Continue without personality profile - can still generate recommendations
      }

      // Step 3: Load PreferencesProfile
      PreferencesProfile? preferencesProfile;
      try {
        preferencesProfile =
            await _preferencesProfileService.getPreferencesProfile(agentId);
        if (preferencesProfile == null) {
          developer.log(
            '⚠️ No PreferencesProfile found for agentId: ${agentId.substring(0, 10)}...',
            name: _logName,
          );
        } else {
          developer.log(
            '✅ Loaded PreferencesProfile: ${preferencesProfile.categoryPreferences.length} categories, ${preferencesProfile.localityPreferences.length} localities',
            name: _logName,
          );
        }
      } catch (e) {
        developer.log(
          '⚠️ Could not load PreferencesProfile: $e',
          name: _logName,
        );
        // Continue without preferences profile - can still generate recommendations
      }

      // Step 4: Create user object (for recommendation services)
      // Note: EventRecommendationService expects UnifiedUser
      // In a real implementation, you'd load the full user from a service
      // For now, we'll construct a minimal user object
      final user = UnifiedUser(
        id: userId,
        email: '', // Not needed for recommendations
        displayName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Step 5: Get event recommendations
      List<event_rec_service.EventRecommendation> eventRecommendations = [];
      try {
        eventRecommendations =
            await _eventRecommendationService.getPersonalizedRecommendations(
          user: user,
          category: context.category,
          location: context.location,
          maxResults: context.maxResults,
          explorationRatio: context.explorationRatio,
        );
        developer.log(
          '✅ Generated ${eventRecommendations.length} event recommendations',
          name: _logName,
        );
      } catch (e) {
        developer.log(
          '⚠️ Error getting event recommendations: $e',
          name: _logName,
        );
        // Continue without event recommendations
      }

      // Step 6: Enhance recommendations with quantum compatibility scores
      final enhancedEventRecommendations =
          await _enhanceRecommendationsWithQuantumCompatibility(
        eventRecommendations: eventRecommendations,
        personalityProfile: personalityProfile,
        preferencesProfile: preferencesProfile,
      );

      // Step 7: Sort and filter final results
      final filteredEvents = _filterAndSortRecommendations(
        enhancedEventRecommendations,
        minRelevanceScore: context.minRelevanceScore,
        maxResults: context.maxResults,
      );

      developer.log(
        '✅ Recommendation generation completed: ${filteredEvents.length} events',
        name: _logName,
      );

      return RecommendationResult.success(
        events: filteredEvents,
        spots: [], // TODO(Phase 8.11): Implement when SpotRecommendationService is available
        lists: [], // TODO(Phase 8.11): Implement when ListRecommendationService is available
        personalityProfile: personalityProfile,
        preferencesProfile: preferencesProfile,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error generating recommendations: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return RecommendationResult.failure(
        error: 'Failed to generate recommendations: ${e.toString()}',
        errorCode: 'RECOMMENDATION_GENERATION_FAILED',
      );
    }
  }

  /// Enhance event recommendations with quantum compatibility scores
  /// 
  /// Calculates quantum compatibility scores using both PersonalityProfile
  /// (for host compatibility) and PreferencesProfile (for event compatibility).
  Future<List<event_rec_service.EventRecommendation>>
      _enhanceRecommendationsWithQuantumCompatibility({
    required List<event_rec_service.EventRecommendation> eventRecommendations,
    PersonalityProfile? personalityProfile,
    PreferencesProfile? preferencesProfile,
  }) async {
    final enhanced = <event_rec_service.EventRecommendation>[];

    for (final recommendation in eventRecommendations) {
      double quantumCompatibility = recommendation.relevanceScore;

      // Calculate preferences compatibility if PreferencesProfile available
      if (preferencesProfile != null) {
        final preferencesCompat =
            preferencesProfile.calculateQuantumCompatibility(
          recommendation.event,
        );

        // Combine relevance score with preferences compatibility
        // Weight: 60% original relevance, 40% preferences compatibility
        quantumCompatibility = (recommendation.relevanceScore * 0.6 +
                preferencesCompat * 0.4)
            .clamp(0.0, 1.0);
      }

      // TODO(Phase 8.11): Calculate personality compatibility with event host
      // if personalityProfile is available
      // This would use quantum compatibility calculation: |⟨ψ_user|ψ_host⟩|²
      // For now, personality compatibility is not calculated

      // Create enhanced recommendation with quantum compatibility
      enhanced.add(event_rec_service.EventRecommendation(
        event: recommendation.event,
        relevanceScore: quantumCompatibility,
        recommendationReason: recommendation.recommendationReason,
      ));
    }

    return enhanced;
  }

  /// Filter and sort recommendations
  /// 
  /// Filters recommendations by minimum relevance score and sorts by
  /// relevance score (highest first).
  List<event_rec_service.EventRecommendation> _filterAndSortRecommendations(
    List<event_rec_service.EventRecommendation> recommendations, {
    double minRelevanceScore = 0.3,
    int maxResults = 20,
  }) {
    final filtered = recommendations
        .where((r) => r.relevanceScore >= minRelevanceScore)
        .toList();

    // Sort by relevance score (highest first)
    filtered.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return filtered.take(maxResults).toList();
  }

  // WorkflowController interface implementation

  @override
  Future<RecommendationResult> execute(RecommendationInput input) async {
    return generateRecommendations(
      userId: input.userId,
      context: input.context,
    );
  }

  @override
  ValidationResult validate(RecommendationInput input) {
    final errors = <String, String>{};
    final generalErrors = <String>[];

    if (input.userId.isEmpty) {
      errors['userId'] = 'User ID is required';
    }

    if (input.context.maxResults <= 0) {
      errors['maxResults'] = 'Max results must be greater than 0';
    }

    if (input.context.maxResults > 100) {
      errors['maxResults'] = 'Max results cannot exceed 100';
    }

    if (input.context.explorationRatio < 0.0 ||
        input.context.explorationRatio > 1.0) {
      errors['explorationRatio'] = 'Exploration ratio must be between 0.0 and 1.0';
    }

    if (input.context.minRelevanceScore < 0.0 ||
        input.context.minRelevanceScore > 1.0) {
      errors['minRelevanceScore'] =
          'Minimum relevance score must be between 0.0 and 1.0';
    }

    if (errors.isNotEmpty || generalErrors.isNotEmpty) {
      return ValidationResult.invalid(
        fieldErrors: errors,
        generalErrors: generalErrors,
      );
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> rollback(RecommendationResult result) async {
    // Recommendations are read-only, no rollback needed
  }
}

/// Recommendation Input
/// 
/// Input data for recommendation generation.
class RecommendationInput {
  final String userId;
  final RecommendationContext context;

  const RecommendationInput({
    required this.userId,
    required this.context,
  });
}

/// Recommendation Context
/// 
/// Context for generating recommendations (filters, limits, etc.).
class RecommendationContext {
  final String? category;
  final String? location;
  final int maxResults;
  final double explorationRatio;
  final double minRelevanceScore;

  const RecommendationContext({
    this.category,
    this.location,
    this.maxResults = 20,
    this.explorationRatio = 0.3,
    this.minRelevanceScore = 0.3,
  });

  RecommendationContext copyWith({
    String? category,
    String? location,
    int? maxResults,
    double? explorationRatio,
    double? minRelevanceScore,
  }) {
    return RecommendationContext(
      category: category ?? this.category,
      location: location ?? this.location,
      maxResults: maxResults ?? this.maxResults,
      explorationRatio: explorationRatio ?? this.explorationRatio,
      minRelevanceScore: minRelevanceScore ?? this.minRelevanceScore,
    );
  }
}

/// Recommendation Result
/// 
/// Unified result containing all recommendation types.
class RecommendationResult extends ControllerResult {
  final List<event_rec_service.EventRecommendation> events;
  final List<dynamic> spots; // TODO(Phase 8.11): Replace with SpotRecommendation
  final List<dynamic> lists; // TODO(Phase 8.11): Replace with ListRecommendation
  final PersonalityProfile? personalityProfile;
  final PreferencesProfile? preferencesProfile;

  RecommendationResult({
    required super.success,
    super.error,
    super.errorCode,
    super.metadata,
    this.events = const [],
    this.spots = const [],
    this.lists = const [],
    this.personalityProfile,
    this.preferencesProfile,
  });

  /// Create successful recommendation result
  factory RecommendationResult.success({
    required List<event_rec_service.EventRecommendation> events,
    List<dynamic> spots = const [],
    List<dynamic> lists = const [],
    PersonalityProfile? personalityProfile,
    PreferencesProfile? preferencesProfile,
  }) {
    return RecommendationResult(
      success: true,
      events: events,
      spots: spots,
      lists: lists,
      personalityProfile: personalityProfile,
      preferencesProfile: preferencesProfile,
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
        'eventCount': events.length,
        'spotCount': spots.length,
        'listCount': lists.length,
      },
    );
  }

  /// Create failure recommendation result
  factory RecommendationResult.failure({
    required String error,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return RecommendationResult(
      success: false,
      error: error,
      errorCode: errorCode ?? 'RECOMMENDATION_FAILED',
      metadata: metadata,
    );
  }
}



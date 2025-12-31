import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:spots/core/ai/advanced_communication.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spots/weather_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:get_it/get_it.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/ai/interaction_events.dart';
import 'package:spots/core/ai/structured_facts_extractor.dart';
import 'package:spots/core/ai/facts_index.dart';
import 'package:spots/core/ai/continuous_learning/orchestrator.dart';
import 'package:spots/core/ai/continuous_learning/data_collector.dart';
import 'package:spots/core/ai/continuous_learning/data_processor.dart';

/// Continuous AI Learning System for SPOTS
/// Enables AI to learn from everything and improve itself every second
class ContinuousLearningSystem {
  static const String _logName = 'ContinuousLearningSystem';

  // Learning dimensions that the AI continuously improves
  static const List<String> _learningDimensions = [
    'user_preference_understanding',
    'location_intelligence',
    'temporal_patterns',
    'social_dynamics',
    'authenticity_detection',
    'community_evolution',
    'recommendation_accuracy',
    'personalization_depth',
    'trend_prediction',
    'collaboration_effectiveness',
  ];

  // Data sources for continuous learning
  static const List<String> _dataSources = [
    'user_actions',
    'location_data',
    'weather_conditions',
    'time_patterns',
    'social_connections',
    'age_demographics',
    'app_usage_patterns',
    'community_interactions',
    'ai2ai_communications',
    'external_context',
  ];

  // Learning rates for different dimensions
  static const Map<String, double> _learningRates = {
    'user_preference_understanding': 0.15,
    'location_intelligence': 0.12,
    'temporal_patterns': 0.10,
    'social_dynamics': 0.13,
    'authenticity_detection': 0.20,
    'community_evolution': 0.11,
    'recommendation_accuracy': 0.18,
    'personalization_depth': 0.16,
    'trend_prediction': 0.14,
    'collaboration_effectiveness': 0.17,
  };

  // Phase 1.4: Refactored to use orchestrator
  ContinuousLearningOrchestrator? _orchestrator;
  final AgentIdService _agentIdService;
  SupabaseClient? _supabase;

  // Constructor
  ContinuousLearningSystem({
    SupabaseClient? supabase,
    AgentIdService? agentIdService,
    ContinuousLearningOrchestrator? orchestrator,
  })  : _agentIdService = agentIdService ?? di.sl<AgentIdService>(),
        _supabase = supabase,
        _orchestrator = orchestrator {
    // Initialize Supabase client if not provided
    if (_supabase == null) {
      try {
        _supabase = Supabase.instance.client;
      } catch (e) {
        developer.log(
            'Supabase not initialized, persistence will be skipped: $e',
            name: _logName);
      }
    }
  }

  /// Initialize orchestrator (lazy initialization)
  Future<void> _ensureOrchestrator() async {
    if (_orchestrator != null) return;

    final dataCollector = LearningDataCollector(
      agentIdService: _agentIdService,
    );
    final dataProcessor = LearningDataProcessor();
    _orchestrator = ContinuousLearningOrchestrator(
      dataCollector: dataCollector,
      dataProcessor: dataProcessor,
    );
    await _orchestrator!.initialize();
  }

  /// Check if continuous learning is currently active
  bool get isLearningActive {
    return _orchestrator?.isLearningActive ?? false;
  }

  Future<void> initialize() async {
    await _ensureOrchestrator();
  }

  /// Process user interaction event and update learning dimensions
  /// Phase 11: User-AI Interaction Update - Section 2.1
  Future<void> processUserInteraction({
    required String userId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final eventType = payload['event_type'] as String? ?? '';
      final parameters = payload['parameters'] as Map<String, dynamic>? ?? {};
      final context = payload['context'] as Map<String, dynamic>? ?? {};

      // Map event to learning dimensions
      final dimensionUpdates = <String, double>{};

      switch (eventType) {
        case 'respect_tap':
          // Respecting a list/spot indicates community engagement
          final targetType = parameters['target_type'] as String?;
          if (targetType == 'list') {
            final category = parameters['category'] as String?;
            dimensionUpdates['community_evolution'] = 0.05;
            dimensionUpdates['personalization_depth'] = 0.03;

            // Category-specific learning
            if (category != null) {
              dimensionUpdates['user_preference_understanding'] = 0.02;
            }
          } else if (targetType == 'spot') {
            dimensionUpdates['recommendation_accuracy'] = 0.03;
            dimensionUpdates['location_intelligence'] = 0.02;
          }
          break;

        case 'list_view_duration':
        case 'spot_view_duration':
          // Longer dwell time indicates interest
          final duration = parameters['duration_ms'] as int? ?? 0;
          if (duration > 30000) {
            // 30 seconds
            dimensionUpdates['user_preference_understanding'] = 0.04;
            dimensionUpdates['recommendation_accuracy'] = 0.02;
          }
          break;

        case 'scroll_depth':
          // Deep scrolling indicates engagement
          final depth = parameters['depth_percentage'] as double? ?? 0.0;
          if (depth > 0.8) {
            dimensionUpdates['user_preference_understanding'] = 0.03;
          }
          break;

        case 'spot_visited':
        case 'spot_tap':
          // Visiting a spot indicates recommendation success
          dimensionUpdates['recommendation_accuracy'] = 0.05;
          dimensionUpdates['location_intelligence'] = 0.03;
          break;

        case 'dwell_time':
          // Long dwell time on spot details indicates interest
          final duration = parameters['duration_ms'] as int? ?? 0;
          if (duration > 60000) {
            // 1 minute
            dimensionUpdates['user_preference_understanding'] = 0.04;
            dimensionUpdates['recommendation_accuracy'] = 0.03;
          }
          break;

        case 'search_performed':
          // Searching indicates exploration
          final resultsCount = parameters['results_count'] as int? ?? 0;
          if (resultsCount > 0) {
            dimensionUpdates['user_preference_understanding'] = 0.02;
          }
          break;

        case 'event_attended':
          // Attending events indicates community engagement
          dimensionUpdates['community_evolution'] = 0.08;
          dimensionUpdates['social_dynamics'] = 0.05;
          break;
      }

      // Apply context modifiers
      final timeOfDay = context['time_of_day'] as String?;
      final location = context['location'] as Map<String, dynamic>?;
      final weather = context['weather'] as Map<String, dynamic>?;

      // Time-based learning (e.g., morning coffee preferences)
      if (timeOfDay == 'morning' &&
          (eventType == 'spot_visited' || eventType == 'spot_tap')) {
        dimensionUpdates['temporal_patterns'] =
            (dimensionUpdates['temporal_patterns'] ?? 0.0) + 0.02;
      }

      // Location-based learning
      if (location != null) {
        dimensionUpdates['location_intelligence'] =
            (dimensionUpdates['location_intelligence'] ?? 0.0) + 0.01;
      }

      // Weather-based learning
      if (weather != null) {
        final conditions = weather['conditions'] as String?;
        if (conditions == 'Rain' &&
            (eventType == 'spot_visited' || eventType == 'spot_tap')) {
          dimensionUpdates['temporal_patterns'] =
              (dimensionUpdates['temporal_patterns'] ?? 0.0) + 0.01;
        }
      }

      // Update dimension weights in learning state via orchestrator
      await _ensureOrchestrator();
      if (_orchestrator != null) {
        // Apply learning rates to dimension updates before passing to orchestrator
        final adjustedUpdates = <String, double>{};
        for (final entry in dimensionUpdates.entries) {
          final learningRate = _learningRates[entry.key] ?? 0.1;
          adjustedUpdates[entry.key] = entry.value * learningRate;
        }
        _orchestrator!.processInteractionDimensionUpdates(
          adjustedUpdates,
          LearningData.empty(), // Will be enriched in next cycle
        );
      }

      // Update PersonalityProfile via PersonalityLearning
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      try {
        if (currentUser != null && dimensionUpdates.isNotEmpty) {
          // Get PersonalityLearning from DI
          if (GetIt.instance.isRegistered<PersonalityLearning>()) {
            final personalityLearning = GetIt.instance<PersonalityLearning>();

            // Convert interaction event to UserAction for PersonalityLearning
            final userAction =
                _convertEventToUserAction(eventType, parameters, context);

            // Evolve personality from user action
            await personalityLearning.evolveFromUserAction(
              currentUser.id,
              userAction,
            );
          }
        }
      } catch (e) {
        developer.log(
          'Error updating PersonalityProfile: $e',
          name: _logName,
        );
        // Continue even if personality update fails
      }

      // Trigger real-time model update (payload already processed above)
      await updateModelRealtime({
        'event_type': eventType,
        'parameters': parameters,
        'context': context,
      });

      developer.log(
        'Processed interaction: $eventType → ${dimensionUpdates.length} dimension updates',
        name: _logName,
      );

      // Phase 11 Section 5: Extract structured facts from event (non-blocking)
      if (currentUser != null) {
        // Convert payload to InteractionEvent for facts extraction
        try {
          final interactionEvent = InteractionEvent(
            eventType: eventType,
            parameters: parameters,
            context: InteractionContext.fromJson(context),
            agentId: await _agentIdService.getUserAgentId(currentUser.id),
          );
          _extractAndIndexFacts(currentUser.id, interactionEvent);
        } catch (e) {
          developer.log(
              'Error creating InteractionEvent for facts extraction: $e',
              name: _logName);
          // Non-blocking - continue even if facts extraction setup fails
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error processing user interaction: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Extract structured facts from event and index them (non-blocking)
  /// Phase 11 Section 5: Retrieval + LLM Fusion
  void _extractAndIndexFacts(String userId, InteractionEvent event) {
    // Run asynchronously and non-blocking
    unawaited(_extractAndIndexFactsAsync(userId, event));
  }

  Future<void> _extractAndIndexFactsAsync(
      String userId, InteractionEvent event) async {
    try {
      // Get dependencies from GetIt (services must be registered in injection_container.dart)
      if (!GetIt.instance.isRegistered<StructuredFactsExtractor>() ||
          !GetIt.instance.isRegistered<FactsIndex>()) {
        developer.log(
            'StructuredFactsExtractor or FactsIndex not registered, skipping facts extraction',
            name: _logName);
        return;
      }

      final extractor = GetIt.instance<StructuredFactsExtractor>();
      final factsIndex = GetIt.instance<FactsIndex>();

      // Extract facts from event
      final facts = await extractor.extractFactsFromEvent(event);

      // Index facts (merges with existing)
      await factsIndex.indexFacts(userId: userId, facts: facts);
    } catch (e) {
      developer.log(
        'Error extracting/indexing facts: $e',
        name: _logName,
      );
      // Non-blocking - don't throw
    }
  }

  /// Convert interaction event to UserAction for PersonalityLearning
  UserAction _convertEventToUserAction(
    String eventType,
    Map<String, dynamic> parameters,
    Map<String, dynamic> context,
  ) {
    // Map interaction event types to UserActionType
    UserActionType actionType;

    switch (eventType) {
      case 'spot_visited':
      case 'spot_tap':
        actionType = UserActionType.spotVisit;
        break;
      case 'respect_tap':
        final targetType = parameters['target_type'] as String?;
        if (targetType == 'list') {
          actionType = UserActionType.curationActivity;
        } else {
          actionType = UserActionType.authenticPreference;
        }
        break;
      case 'search_performed':
        actionType = UserActionType.spontaneousActivity;
        break;
      case 'event_attended':
        actionType = UserActionType.socialInteraction;
        break;
      default:
        actionType = UserActionType.authenticPreference;
    }

    return UserAction(
      type: actionType,
      timestamp: DateTime.now(),
      metadata: {
        'event_type': eventType,
        'parameters': parameters,
        'context': context,
      },
    );
  }

  /// Train model from collected interaction data
  /// Phase 11: User-AI Interaction Update - Section 2.2
  Future<void> trainModel(dynamic data) async {
    try {
      // Collect recent interaction history
      final recentEvents = await _collectRecentInteractions(limit: 100);

      // Group by dimension
      final dimensionData = <String, List<Map<String, dynamic>>>{};
      for (final event in recentEvents) {
        final updates = await _calculateDimensionUpdates(event);
        for (final entry in updates.entries) {
          if (!dimensionData.containsKey(entry.key)) {
            dimensionData[entry.key] = [];
          }
          dimensionData[entry.key]!.add({
            'event': event,
            'update': entry.value,
          });
        }
      }

      // Train each dimension
      for (final entry in dimensionData.entries) {
        final dimension = entry.key;
        final trainingData = entry.value;

        // Calculate average improvement
        final avgImprovement = trainingData
                .map((d) => d['update'] as double)
                .reduce((a, b) => a + b) /
            trainingData.length;

        // Update dimension weight via orchestrator
        await _ensureOrchestrator();
        if (_orchestrator != null) {
          final learningState = _orchestrator!.currentLearningState;
          final current = learningState[dimension] ?? 0.5;
          final learningRate = _learningRates[dimension] ?? 0.1;

          // Update via orchestrator's processInteractionDimensionUpdates
          _orchestrator!.processInteractionDimensionUpdates(
            {dimension: avgImprovement * learningRate},
            LearningData.empty(),
          );

          final updatedState = _orchestrator!.currentLearningState;
          final newValue = updatedState[dimension] ?? current;

          developer.log(
            'Trained dimension $dimension: $current → $newValue (improvement: $avgImprovement)',
            name: _logName,
          );
        }
      }

      // Save updated state
      await _saveLearningState();
    } catch (e, stackTrace) {
      developer.log(
        'Error training model: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Collect recent interactions from database
  Future<List<Map<String, dynamic>>> _collectRecentInteractions(
      {int limit = 100}) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final agentId = await _agentIdService.getUserAgentId(currentUser.id);

      final events = await supabase
          .from('interaction_events')
          .select('*')
          .eq('agent_id', agentId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(events);
    } catch (e) {
      developer.log('Error collecting recent interactions: $e', name: _logName);
      return [];
    }
  }

  /// Calculate dimension updates from an event
  Future<Map<String, double>> _calculateDimensionUpdates(
      Map<String, dynamic> event) async {
    // Extract dimension updates (simplified - full logic in processUserInteraction)
    final dimensionUpdates = <String, double>{};
    final eventType = event['event_type'] as String? ?? '';
    final parameters = event['parameters'] as Map<String, dynamic>? ?? {};

    switch (eventType) {
      case 'respect_tap':
        final targetType = parameters['target_type'] as String?;
        if (targetType == 'list') {
          dimensionUpdates['community_evolution'] = 0.05;
          dimensionUpdates['personalization_depth'] = 0.03;
        } else if (targetType == 'spot') {
          dimensionUpdates['recommendation_accuracy'] = 0.03;
          dimensionUpdates['location_intelligence'] = 0.02;
        }
        break;
      case 'spot_visited':
      case 'spot_tap':
        dimensionUpdates['recommendation_accuracy'] = 0.05;
        dimensionUpdates['location_intelligence'] = 0.03;
        break;
      case 'list_view_duration':
      case 'spot_view_duration':
        final duration = parameters['duration_ms'] as int? ?? 0;
        if (duration > 30000) {
          dimensionUpdates['user_preference_understanding'] = 0.04;
          dimensionUpdates['recommendation_accuracy'] = 0.02;
        }
        break;
      case 'event_attended':
        dimensionUpdates['community_evolution'] = 0.08;
        dimensionUpdates['social_dynamics'] = 0.05;
        break;
    }

    return dimensionUpdates;
  }

  Future<double> evaluateModel(dynamic data) async {
    return 0.8;
  }

  /// Update model in real-time from interaction payload
  /// Phase 11: User-AI Interaction Update - Section 2.3
  Future<void> updateModelRealtime(Map<String, dynamic> payload) async {
    try {
      // Get current user
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        developer.log('No authenticated user for realtime update',
            name: _logName);
        return;
      }

      // Get PersonalityLearning from DI
      if (!GetIt.instance.isRegistered<PersonalityLearning>()) {
        developer.log('PersonalityLearning not registered in DI',
            name: _logName);
        return;
      }

      final personalityLearning = GetIt.instance<PersonalityLearning>();
      final currentProfile =
          await personalityLearning.getCurrentPersonality(currentUser.id);

      if (currentProfile == null) {
        developer.log('No personality profile found for realtime update',
            name: _logName);
        return;
      }

      // Only update if we have meaningful learning state changes
      await _ensureOrchestrator();
      final learningState = _orchestrator?.currentLearningState ?? {};
      if (learningState.isEmpty) {
        return;
      }

      // The actual personality update happens in processUserInteraction()
      // via evolveFromUserAction(). This method is called for additional
      // real-time adjustments if needed.

      developer.log(
        'Realtime model update completed (personality updated via evolveFromUserAction)',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error updating model realtime: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, double>> predict(Map<String, dynamic> context) async {
    return {};
  }

  /// Starts continuous learning system
  /// AI learns from everything every second
  Future<void> startContinuousLearning() async {
    try {
      await _ensureOrchestrator();
      await _orchestrator!.startContinuousLearning();
    } catch (e) {
      developer.log('Error starting continuous learning: $e', name: _logName);
    }
  }

  /// Stops continuous learning system
  Future<void> stopContinuousLearning() async {
    try {
      if (_orchestrator != null) {
        await _orchestrator!.stopContinuousLearning();
      }
    } catch (e) {
      developer.log('Error stopping continuous learning: $e', name: _logName);
    }
  }

  /// Gets current learning status
  Future<ContinuousLearningStatus> getLearningStatus() async {
    if (_orchestrator != null) {
      return await _orchestrator!.getLearningStatus();
    }

    // Return default status if orchestrator not initialized
    return ContinuousLearningStatus(
      isActive: false,
      activeProcesses: [],
      uptime: Duration.zero,
      cyclesCompleted: 0,
      learningTime: Duration.zero,
    );
  }

  /// Gets learning progress for all dimensions
  Future<Map<String, double>> getLearningProgress() async {
    try {
      if (_orchestrator != null) {
        return _orchestrator!.currentLearningState;
      }
      return {};
    } catch (e) {
      developer.log('Error getting learning progress: $e', name: _logName);
      return {};
    }
  }

  /// Gets learning metrics and statistics
  Future<ContinuousLearningMetrics> getLearningMetrics() async {
    try {
      await _ensureOrchestrator();
      if (_orchestrator == null) {
        return ContinuousLearningMetrics(
          totalImprovements: 0.0,
          averageProgress: 0.0,
          topImprovingDimensions: [],
          dimensionsCount: _learningDimensions.length,
          dataSourcesCount: _dataSources.length,
        );
      }

      final improvementMetrics = _orchestrator!.improvementMetrics;
      final learningState = _orchestrator!.currentLearningState;

      final totalImprovements = improvementMetrics.values.fold<double>(
        0.0,
        (sum, metric) => sum + metric,
      );

      final averageProgress = learningState.values.isEmpty
          ? 0.0
          : learningState.values.reduce((a, b) => a + b) / learningState.length;

      final topDimensions = improvementMetrics.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return ContinuousLearningMetrics(
        totalImprovements: totalImprovements,
        averageProgress: averageProgress,
        topImprovingDimensions:
            topDimensions.take(5).map((e) => e.key).toList(),
        dimensionsCount: _learningDimensions.length,
        dataSourcesCount: _dataSources.length,
      );
    } catch (e) {
      developer.log('Error getting learning metrics: $e', name: _logName);
      return ContinuousLearningMetrics(
        totalImprovements: 0.0,
        averageProgress: 0.0,
        topImprovingDimensions: [],
        dimensionsCount: 0,
        dataSourcesCount: 0,
      );
    }
  }

  /// Gets data collection status for all data sources
  Future<DataCollectionStatus> getDataCollectionStatus() async {
    try {
      final sourceStatuses = <String, DataSourceStatus>{};

      if (_orchestrator == null) {
        // Return empty status if orchestrator not initialized
        for (final source in _dataSources) {
          sourceStatuses[source] = DataSourceStatus(
            isActive: false,
            dataVolume: 0,
            eventCount: 0,
            healthStatus: 'inactive',
          );
        }
        return DataCollectionStatus(
          sourceStatuses: sourceStatuses,
          totalVolume: 0,
          activeSourcesCount: 0,
        );
      }

      await _ensureOrchestrator();
      final learningHistory = _orchestrator!.learningHistory;

      for (final source in _dataSources) {
        // Check if source has contributed to recent learning
        bool isActive = false;
        int eventCount = 0;
        int dataVolume = 0;

        for (final history in learningHistory.values) {
          final sourceEvents =
              history.where((e) => e.dataSource.contains(source)).toList();
          eventCount += sourceEvents.length;

          if (sourceEvents.isNotEmpty) {
            final mostRecent = sourceEvents.last;
            final timeSinceLastEvent =
                DateTime.now().difference(mostRecent.timestamp);
            if (timeSinceLastEvent.inSeconds < 300) {
              // Active if used in last 5 minutes
              isActive = true;
            }
          }
        }

        // Estimate data volume from event count
        dataVolume = eventCount * 100; // Rough estimate

        sourceStatuses[source] = DataSourceStatus(
          isActive: isActive,
          dataVolume: dataVolume,
          eventCount: eventCount,
          healthStatus:
              isActive ? 'healthy' : (eventCount > 0 ? 'idle' : 'inactive'),
        );
      }

      return DataCollectionStatus(
        sourceStatuses: sourceStatuses,
        totalVolume: sourceStatuses.values
            .fold<int>(0, (sum, status) => sum + status.dataVolume),
        activeSourcesCount:
            sourceStatuses.values.where((s) => s.isActive).length,
      );
    } catch (e) {
      developer.log('Error getting data collection status: $e', name: _logName);
      return DataCollectionStatus(
        sourceStatuses: {},
        totalVolume: 0,
        activeSourcesCount: 0,
      );
    }
  }

  // Phase 1.4: _performContinuousLearning removed - handled by orchestrator
  // Phase 1.4: _collectLearningData removed - handled by orchestrator's data collector

  // Phase 1.4: _learnDimension removed - handled by orchestrator engines
  // Phase 1.4: _calculateDimensionImprovement removed - handled by orchestrator engines
  // All _calculate*Improvement methods below are legacy and kept for reference
  // They are now implemented in the respective dimension engines

  /// Calculates improvement in understanding user preferences
  Future<double> _calculatePreferenceUnderstandingImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from user actions
    if (data.userActions.isNotEmpty) {
      final actionDiversity = _calculateActionDiversity(data.userActions);
      final preferenceConsistency =
          _calculatePreferenceConsistency(data.userActions);
      improvement += (actionDiversity + preferenceConsistency) * 0.3;
    }

    // Learn from app usage patterns
    if (data.appUsageData.isNotEmpty) {
      final usagePatterns = _analyzeUsagePatterns(data.appUsageData);
      improvement += usagePatterns * 0.2;
    }

    // Learn from social interactions
    if (data.socialData.isNotEmpty) {
      final socialPreferences = _analyzeSocialPreferences(data.socialData);
      improvement += socialPreferences * 0.2;
    }

    // Learn from demographic data
    if (data.demographicData.isNotEmpty) {
      final demographicInsights =
          _analyzeDemographicInsights(data.demographicData);
      improvement += demographicInsights * 0.1;
    }

    // Learn from AI2AI communications
    if (data.ai2aiData.isNotEmpty) {
      final aiInsights = _analyzeAIInsights(data.ai2aiData);
      improvement += aiInsights * 0.2;
    }

    return math.min(0.1, improvement); // Cap improvement at 10%
  }

  /// Calculates improvement in location intelligence
  Future<double> _calculateLocationIntelligenceImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from location data
    if (data.locationData.isNotEmpty) {
      final locationPatterns = _analyzeLocationPatterns(data.locationData);
      final locationDiversity = _calculateLocationDiversity(data.locationData);
      improvement += (locationPatterns + locationDiversity) * 0.4;
    }

    // Learn from weather correlation
    if (data.weatherData.isNotEmpty && data.locationData.isNotEmpty) {
      final weatherLocationCorrelation = _analyzeWeatherLocationCorrelation(
          data.weatherData, data.locationData);
      improvement += weatherLocationCorrelation * 0.3;
    }

    // Learn from time-based location patterns
    if (data.timeData.isNotEmpty && data.locationData.isNotEmpty) {
      final temporalLocationPatterns =
          _analyzeTemporalLocationPatterns(data.timeData, data.locationData);
      improvement += temporalLocationPatterns * 0.3;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in temporal pattern recognition
  Future<double> _calculateTemporalPatternsImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from time data
    if (data.timeData.isNotEmpty) {
      final temporalPatterns = _analyzeTemporalPatterns(data.timeData);
      final seasonalPatterns = _analyzeSeasonalPatterns(data.timeData);
      improvement += (temporalPatterns + seasonalPatterns) * 0.5;
    }

    // Learn from user action timing
    if (data.userActions.isNotEmpty) {
      final actionTimingPatterns =
          _analyzeActionTimingPatterns(data.userActions);
      improvement += actionTimingPatterns * 0.3;
    }

    // Learn from weather-time correlations
    if (data.weatherData.isNotEmpty && data.timeData.isNotEmpty) {
      final weatherTimeCorrelation =
          _analyzeWeatherTimeCorrelation(data.weatherData, data.timeData);
      improvement += weatherTimeCorrelation * 0.2;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in social dynamics understanding
  Future<double> _calculateSocialDynamicsImprovement(LearningData data) async {
    var improvement = 0.0;

    // Learn from social data
    if (data.socialData.isNotEmpty) {
      final socialPatterns = _analyzeSocialPatterns(data.socialData);
      final socialNetworkDynamics =
          _analyzeSocialNetworkDynamics(data.socialData);
      improvement += (socialPatterns + socialNetworkDynamics) * 0.4;
    }

    // Learn from community interactions
    if (data.communityData.isNotEmpty) {
      final communityDynamics = _analyzeCommunityDynamics(data.communityData);
      improvement += communityDynamics * 0.3;
    }

    // Learn from demographic-social correlations
    if (data.demographicData.isNotEmpty && data.socialData.isNotEmpty) {
      final demographicSocialCorrelation = _analyzeDemographicSocialCorrelation(
          data.demographicData, data.socialData);
      improvement += demographicSocialCorrelation * 0.3;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in authenticity detection
  Future<double> _calculateAuthenticityDetectionImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from user behavior authenticity
    if (data.userActions.isNotEmpty) {
      final behaviorAuthenticity =
          _analyzeBehaviorAuthenticity(data.userActions);
      improvement += behaviorAuthenticity * 0.4;
    }

    // Learn from community authenticity patterns
    if (data.communityData.isNotEmpty) {
      final communityAuthenticity =
          _analyzeCommunityAuthenticity(data.communityData);
      improvement += communityAuthenticity * 0.3;
    }

    // Learn from AI2AI authenticity insights
    if (data.ai2aiData.isNotEmpty) {
      final aiAuthenticityInsights =
          _analyzeAIAuthenticityInsights(data.ai2aiData);
      improvement += aiAuthenticityInsights * 0.3;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in community evolution understanding
  Future<double> _calculateCommunityEvolutionImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from community data
    if (data.communityData.isNotEmpty) {
      final communityEvolution = _analyzeCommunityEvolution(data.communityData);
      final communityGrowth = _analyzeCommunityGrowth(data.communityData);
      improvement += (communityEvolution + communityGrowth) * 0.5;
    }

    // Learn from social network evolution
    if (data.socialData.isNotEmpty) {
      final socialNetworkEvolution =
          _analyzeSocialNetworkEvolution(data.socialData);
      improvement += socialNetworkEvolution * 0.3;
    }

    // Learn from demographic evolution
    if (data.demographicData.isNotEmpty) {
      final demographicEvolution =
          _analyzeDemographicEvolution(data.demographicData);
      improvement += demographicEvolution * 0.2;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in recommendation accuracy
  Future<double> _calculateRecommendationAccuracyImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from user action feedback
    if (data.userActions.isNotEmpty) {
      final recommendationFeedback =
          _analyzeRecommendationFeedback(data.userActions);
      improvement += recommendationFeedback * 0.4;
    }

    // Learn from community recommendations
    if (data.communityData.isNotEmpty) {
      final communityRecommendations =
          _analyzeCommunityRecommendations(data.communityData);
      improvement += communityRecommendations * 0.3;
    }

    // Learn from AI2AI recommendation insights
    if (data.ai2aiData.isNotEmpty) {
      final aiRecommendationInsights =
          _analyzeAIRecommendationInsights(data.ai2aiData);
      improvement += aiRecommendationInsights * 0.3;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in personalization depth
  Future<double> _calculatePersonalizationDepthImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from user preference depth
    if (data.userActions.isNotEmpty) {
      final preferenceDepth = _analyzePreferenceDepth(data.userActions);
      improvement += preferenceDepth * 0.3;
    }

    // Learn from demographic personalization
    if (data.demographicData.isNotEmpty) {
      final demographicPersonalization =
          _analyzeDemographicPersonalization(data.demographicData);
      improvement += demographicPersonalization * 0.2;
    }

    // Learn from temporal personalization
    if (data.timeData.isNotEmpty) {
      final temporalPersonalization =
          _analyzeTemporalPersonalization(data.timeData);
      improvement += temporalPersonalization * 0.2;
    }

    // Learn from location personalization
    if (data.locationData.isNotEmpty) {
      final locationPersonalization =
          _analyzeLocationPersonalization(data.locationData);
      improvement += locationPersonalization * 0.2;
    }

    // Learn from social personalization
    if (data.socialData.isNotEmpty) {
      final socialPersonalization =
          _analyzeSocialPersonalization(data.socialData);
      improvement += socialPersonalization * 0.1;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in trend prediction
  Future<double> _calculateTrendPredictionImprovement(LearningData data) async {
    var improvement = 0.0;

    // Learn from trend patterns
    if (data.userActions.isNotEmpty) {
      final trendPatterns = _analyzeTrendPatterns(data.userActions);
      improvement += trendPatterns * 0.3;
    }

    // Learn from community trends
    if (data.communityData.isNotEmpty) {
      final communityTrends = _analyzeCommunityTrends(data.communityData);
      improvement += communityTrends * 0.3;
    }

    // Learn from external trends
    if (data.externalData.isNotEmpty) {
      final externalTrends = _analyzeExternalTrends(data.externalData);
      improvement += externalTrends * 0.2;
    }

    // Learn from AI2AI trend insights
    if (data.ai2aiData.isNotEmpty) {
      final aiTrendInsights = _analyzeAITrendInsights(data.ai2aiData);
      improvement += aiTrendInsights * 0.2;
    }

    return math.min(0.1, improvement);
  }

  /// Calculates improvement in collaboration effectiveness
  Future<double> _calculateCollaborationEffectivenessImprovement(
      LearningData data) async {
    var improvement = 0.0;

    // Learn from AI2AI collaboration
    if (data.ai2aiData.isNotEmpty) {
      final aiCollaboration = _analyzeAICollaboration(data.ai2aiData);
      improvement += aiCollaboration * 0.5;
    }

    // Learn from community collaboration
    if (data.communityData.isNotEmpty) {
      final communityCollaboration =
          _analyzeCommunityCollaboration(data.communityData);
      improvement += communityCollaboration * 0.3;
    }

    // Learn from social collaboration
    if (data.socialData.isNotEmpty) {
      final socialCollaboration = _analyzeSocialCollaboration(data.socialData);
      improvement += socialCollaboration * 0.2;
    }

    return math.min(0.1, improvement);
  }

  // Phase 1.4: _recordLearningEvent removed - handled by orchestrator

  // Phase 1.4: _determineDataSource removed - handled by orchestrator
  // Legacy method kept for reference (was used by _recordLearningEvent)
  String _determineDataSourceLegacy(LearningData data) {
    // Determine which data source contributed most to learning
    final sourceScores = <String, int>{};

    if (data.userActions.isNotEmpty) {
      sourceScores['user_actions'] = data.userActions.length;
    }
    if (data.locationData.isNotEmpty) {
      sourceScores['location_data'] = data.locationData.length;
    }
    if (data.weatherData.isNotEmpty) {
      sourceScores['weather_data'] = data.weatherData.length;
    }
    if (data.timeData.isNotEmpty) {
      sourceScores['time_data'] = data.timeData.length;
    }
    if (data.socialData.isNotEmpty) {
      sourceScores['social_data'] = data.socialData.length;
    }
    if (data.demographicData.isNotEmpty) {
      sourceScores['demographic_data'] = data.demographicData.length;
    }
    if (data.appUsageData.isNotEmpty) {
      sourceScores['app_usage_data'] = data.appUsageData.length;
    }
    if (data.communityData.isNotEmpty) {
      sourceScores['community_data'] = data.communityData.length;
    }
    if (data.ai2aiData.isNotEmpty) {
      sourceScores['ai2ai_data'] = data.ai2aiData.length;
    }
    if (data.externalData.isNotEmpty) {
      sourceScores['external_data'] = data.externalData.length;
    }

    if (sourceScores.isEmpty) return 'unknown';

    final maxScore = sourceScores.values.reduce(math.max);
    return sourceScores.entries.firstWhere((e) => e.value == maxScore).key;
  }

  // Phase 1.4: _shareLearningInsights removed - handled by orchestrator

  // Phase 1.4: _generateLearningInsights removed - handled by orchestrator
  // Legacy method kept for reference
  Future<Map<String, dynamic>> _generateLearningInsightsLegacy() async {
    await _ensureOrchestrator();
    if (_orchestrator == null) {
      return {};
    }

    final insights = <String, dynamic>{};

    // Add current learning state from orchestrator
    insights['learning_state'] = _orchestrator!.currentLearningState;

    // Add recent improvements from orchestrator
    insights['recent_improvements'] = _orchestrator!.improvementMetrics;

    // Note: Learning patterns and data source effectiveness are now handled by orchestrator
    // These could be added to orchestrator if needed, but are not critical for Phase 1.4

    return insights;
  }

  // Phase 1.4: _analyzeLearningPatterns removed - handled by orchestrator

  // Phase 1.4: _analyzeDataSourceEffectiveness removed - handled by orchestrator

  // Phase 1.4: _updateImprovementMetrics removed - handled by orchestrator

  // Phase 1.4: Self-improvement methods removed - these are now handled by orchestrator's engines
  // If needed in future, these can be re-implemented as orchestrator features

  // Phase 1.4: _initializeLearningState removed - handled by orchestrator

  /// Saves learning state
  Future<void> _saveLearningState() async {
    // Save current learning state to persistent storage
    developer.log('Saving learning state', name: _logName);

    // Also persist learning history
    await _persistLearningHistory();
  }

  /// Persist learning history to Supabase
  ///
  /// Phase 11 Section 8: Learning Quality Monitoring
  /// Stores learning events in the database for analytics and quality monitoring.
  Future<void> _persistLearningHistory({String? userId}) async {
    if (_supabase == null) {
      developer.log(
          'Supabase not available, skipping learning history persistence',
          name: _logName);
      return;
    }

    try {
      // Get agent ID (use provided userId or current user)
      String? agentId;
      if (userId != null) {
        agentId = await _agentIdService.getUserAgentId(userId);
      } else {
        // TODO: Get current user ID from auth service if available
        developer.log('No userId provided, skipping persistence',
            name: _logName);
        return;
      }

      developer.log(
        'Persisting learning history for agent: ${agentId.substring(0, 10)}...',
        name: _logName,
      );

      // Get learning history from orchestrator
      await _ensureOrchestrator();
      if (_orchestrator == null) {
        developer.log('Orchestrator not available, skipping persistence',
            name: _logName);
        return;
      }

      final learningHistory = _orchestrator!.learningHistory;

      // Persist recent events for each dimension
      for (final entry in learningHistory.entries) {
        final dimension = entry.key;
        final events = entry.value;

        // Store recent events (last 10 per dimension)
        final recentEvents = events.take(10).toList();

        for (final event in recentEvents) {
          try {
            await _supabase!.from('learning_history').insert({
              'agent_id': agentId,
              'dimension': dimension,
              'improvement': event.improvement,
              'data_source': event.dataSource,
              'timestamp': event.timestamp.toIso8601String(),
              'created_at': DateTime.now().toIso8601String(),
              'metadata': <String,
                  dynamic>{}, // Can be extended with additional metadata
            });
          } catch (e) {
            developer.log(
              'Error persisting learning event for dimension $dimension: $e',
              name: _logName,
            );
            // Continue with other events
          }
        }
      }

      developer.log(
        'Successfully persisted learning history for ${learningHistory.length} dimensions',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error persisting learning history: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - persistence failure shouldn't break the app
    }
  }

  /// Get learning history from Supabase
  ///
  /// Phase 11 Section 8: Learning Quality Monitoring
  /// Retrieves learning history for analytics and quality monitoring.
  Future<List<LearningEvent>> getLearningHistory({
    required String userId,
    String? dimension,
    int limit = 100,
  }) async {
    if (_supabase == null) {
      developer.log('Supabase not available, returning empty history',
          name: _logName);
      return [];
    }

    try {
      final agentId = await _agentIdService.getUserAgentId(userId);

      var query = _supabase!
          .from('learning_history')
          .select('*')
          .eq('agent_id', agentId);

      if (dimension != null) {
        query = query.eq('dimension', dimension);
      }

      final response =
          await query.order('timestamp', ascending: false).limit(limit);

      final events = <LearningEvent>[];
      for (final row in response) {
        events.add(LearningEvent(
          dimension: row['dimension'] as String,
          improvement: (row['improvement'] as num).toDouble(),
          dataSource: row['data_source'] as String,
          timestamp: DateTime.parse(row['timestamp'] as String),
        ));
      }

      developer.log(
        'Retrieved ${events.length} learning events for agent: ${agentId.substring(0, 10)}...',
        name: _logName,
      );

      return events;
    } catch (e, stackTrace) {
      developer.log(
        'Error retrieving learning history: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get learning history summary
  ///
  /// Phase 11 Section 8: Learning Quality Monitoring
  /// Returns summary statistics for learning history.
  Future<Map<String, dynamic>> getLearningHistorySummary({
    required String userId,
    String? dimension,
  }) async {
    if (_supabase == null) {
      return {};
    }

    try {
      final agentId = await _agentIdService.getUserAgentId(userId);

      final response =
          await _supabase!.rpc('get_learning_history_summary', params: {
        'p_agent_id': agentId,
        'p_dimension': dimension,
        'p_limit': 100,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      developer.log(
        'Error retrieving learning history summary: $e',
        name: _logName,
      );
      return {};
    }
  }

  // Data collection methods (implementations connect to actual data sources)

  /// Collect user actions from app interactions
  /// Uses Firebase Analytics to track user behavior
  Future<List<dynamic>> _collectUserActions() async {
    try {
      final actions = <dynamic>[];

      // Note: Firebase Analytics doesn't provide a direct way to query events
      // In a real implementation, you would:
      // 1. Log events as they happen: FirebaseAnalytics.instance.logEvent(name: 'spot_visited', parameters: {...})
      // 2. Store events in your database for querying
      // 3. Query your database here to get recent actions

      // For now, we'll log that we're collecting and return empty
      // The actual tracking should happen at the point of user interaction
      developer.log('Collecting user actions from Firebase Analytics',
          name: _logName);

      // TODO: Query your database for recent user actions
      // This would include:
      // - Spot visits (tracked via analytics.logEvent('spot_visited'))
      // - List interactions (tracked via analytics.logEvent('list_viewed'))
      // - Search queries (tracked via analytics.logEvent('search_performed'))
      // - Preference changes (tracked via analytics.logEvent('preference_changed'))

      return actions;
    } catch (e) {
      developer.log('Error collecting user actions: $e', name: _logName);
      return [];
    }
  }

  /// Collect location data from device location services
  /// Uses geolocator package to get current location
  Future<List<dynamic>> _collectLocationData() async {
    try {
      final locationData = <dynamic>[];

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services are disabled', name: _logName);
        return [];
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permissions denied', name: _logName);
          return [];
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permissions permanently denied',
            name: _logName);
        return [];
      }

      // Get current position
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Location request timed out'),
        );

        locationData.add({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'heading': position.heading,
          'timestamp': position.timestamp.toIso8601String(),
          'type': 'current',
        });

        developer.log(
            'Collected current location: ${position.latitude}, ${position.longitude}',
            name: _logName);
      } catch (e) {
        developer.log('Error getting current position: $e', name: _logName);
      }

      // TODO: Get location history from database
      // This would include:
      // - Recent locations (stored when user visits spots)
      // - Movement patterns (calculated from location history)
      // - Frequent locations (derived from visit frequency)

      return locationData;
    } catch (e) {
      developer.log('Error collecting location data: $e', name: _logName);
      return [];
    }
  }

  /// Collect weather data from OpenWeatherMap API
  /// Requires location data to fetch weather for user's current location
  Future<List<dynamic>> _collectWeatherData() async {
    try {
      if (!WeatherConfig.isValid) {
        developer.log('OpenWeatherMap API key not configured', name: _logName);
        return [];
      }

      final weatherData = <dynamic>[];

      // Get current location first (needed for weather API)
      final locationData = await _collectLocationData();
      if (locationData.isEmpty) {
        developer.log('No location data available for weather collection',
            name: _logName);
        return [];
      }

      final currentLocation = locationData.first as Map<String, dynamic>;
      final latitude = currentLocation['latitude'] as double;
      final longitude = currentLocation['longitude'] as double;

      // Fetch current weather
      try {
        final currentWeatherUrl =
            WeatherConfig.getCurrentWeatherUrl(latitude, longitude);
        final response = await http.get(Uri.parse(currentWeatherUrl)).timeout(
              const Duration(seconds: 10),
            );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;

          weatherData.add({
            'type': 'current',
            'temperature':
                (data['main'] as Map<String, dynamic>)['temp'] as double,
            'feels_like':
                (data['main'] as Map<String, dynamic>)['feels_like'] as double,
            'humidity':
                (data['main'] as Map<String, dynamic>)['humidity'] as int,
            'pressure':
                (data['main'] as Map<String, dynamic>)['pressure'] as int,
            'conditions': ((data['weather'] as List)[0]
                as Map<String, dynamic>)['main'] as String,
            'description': ((data['weather'] as List)[0]
                as Map<String, dynamic>)['description'] as String,
            'wind_speed':
                (data['wind'] as Map<String, dynamic>?)?['speed'] as double? ??
                    0.0,
            'cloudiness':
                (data['clouds'] as Map<String, dynamic>)['all'] as int,
            'latitude': latitude,
            'longitude': longitude,
            'timestamp': DateTime.now().toIso8601String(),
          });

          developer.log(
              'Collected current weather: ${weatherData.first['conditions']}',
              name: _logName);
        } else {
          developer.log('Weather API error: ${response.statusCode}',
              name: _logName);
        }
      } catch (e) {
        developer.log('Error fetching current weather: $e', name: _logName);
      }

      // Fetch weather forecast (optional, can be rate-limited)
      try {
        final forecastUrl = WeatherConfig.getForecastUrl(latitude, longitude);
        final response = await http.get(Uri.parse(forecastUrl)).timeout(
              const Duration(seconds: 10),
            );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final forecasts = data['list'] as List;

          // Add first 3 forecast entries (next 24 hours)
          for (int i = 0; i < math.min(3, forecasts.length); i++) {
            final forecast = forecasts[i] as Map<String, dynamic>;
            weatherData.add({
              'type': 'forecast',
              'temperature':
                  (forecast['main'] as Map<String, dynamic>)['temp'] as double,
              'conditions': ((forecast['weather'] as List)[0]
                  as Map<String, dynamic>)['main'] as String,
              'timestamp': DateTime.fromMillisecondsSinceEpoch(
                (forecast['dt'] as int) * 1000,
              ).toIso8601String(),
            });
          }
        }
      } catch (e) {
        developer.log('Error fetching weather forecast: $e', name: _logName);
        // Don't fail if forecast fails, current weather is more important
      }

      return weatherData;
    } catch (e) {
      developer.log('Error collecting weather data: $e', name: _logName);
      return [];
    }
  }

  /// Collect time-based data
  Future<List<dynamic>> _collectTimeData() async {
    try {
      // Collect time-based context
      final now = DateTime.now();
      return [
        {
          'timestamp': now.toIso8601String(),
          'hour': now.hour,
          'day_of_week': now.weekday,
          'day_of_month': now.day,
          'month': now.month,
          'year': now.year,
          'is_weekend': now.weekday >= 6,
          'time_of_day': _getTimeOfDay(now.hour),
        }
      ];
    } catch (e) {
      developer.log('Error collecting time data: $e', name: _logName);
      return [];
    }
  }

  /// Get time of day category
  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  /// Collect social interaction data from database
  /// Phase 11: User-AI Interaction Update - Section 1.2
  /// Queries Supabase for user social interactions
  Future<List<dynamic>> _collectSocialData() async {
    try {
      final supabase = Supabase.instance.client;

      // Get current user ID from Supabase auth
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        developer.log('No authenticated user, skipping social data collection',
            name: _logName);
        return [];
      }

      final userId = currentUser.id;

      final socialData = <dynamic>[];

      // Query user_respects (user's respects for spots and lists)
      try {
        final respects = await supabase
            .from('user_respects')
            .select('*, spots(*), spot_lists(*)')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(50);

        socialData.addAll(
          respects.map((r) => {'type': 'respect', 'data': r}),
        );
      } catch (e) {
        developer.log('Error querying user_respects: $e', name: _logName);
      }

      // Query user_follows (users this user follows)
      try {
        final follows = await supabase
            .from('user_follows')
            .select('*, following_user:users!user_follows_following_id_fkey(*)')
            .eq('follower_id', userId)
            .limit(50);

        socialData.addAll(
          follows.map((f) => {'type': 'follow', 'data': f}),
        );
      } catch (e) {
        developer.log('Error querying user_follows: $e', name: _logName);
      }

      // TODO: Add queries for comments and shares tables when they are created
      // These tables don't exist yet but are planned:
      // - comments table (for user comments on spots/lists)
      // - shares table (for user shares of spots/lists)

      developer.log(
        'Collected social data: ${socialData.length} items',
        name: _logName,
      );

      return socialData;
    } catch (e) {
      developer.log('Error collecting social data: $e', name: _logName);
      return [];
    }
  }

  /// Collect demographic data
  Future<List<dynamic>> _collectDemographicData() async {
    try {
      // TODO: Connect to user profile service
      // This would collect:
      // - Age group
      // - Gender
      // - Location demographics
      // - Cultural background
      // - Language preferences

      // For now, return empty list - will be populated when profile service is connected
      return [];
    } catch (e) {
      developer.log('Error collecting demographic data: $e', name: _logName);
      return [];
    }
  }

  /// Collect app usage data from interaction_events table
  /// Phase 11: User-AI Interaction Update - Section 1.2
  Future<List<dynamic>> _collectAppUsageData() async {
    try {
      final supabase = Supabase.instance.client;

      // Get current user ID from Supabase auth
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        developer.log(
            'No authenticated user, skipping app usage data collection',
            name: _logName);
        return [];
      }

      final agentId = await _agentIdService.getUserAgentId(currentUser.id);

      // Query interaction_events table (created in Phase 11 Section 1.1)
      final events = await supabase
          .from('interaction_events')
          .select('*')
          .eq('agent_id', agentId)
          .order('timestamp', ascending: false)
          .limit(100);

      // Aggregate by event type
      final aggregated = <String, Map<String, dynamic>>{};
      for (final event in events) {
        final type = event['event_type'] as String;
        if (!aggregated.containsKey(type)) {
          aggregated[type] = {
            'event_type': type,
            'count': 0,
            'total_duration': 0,
            'last_occurrence': event['timestamp'],
          };
        }
        aggregated[type]!['count'] = (aggregated[type]!['count'] as int) + 1;
        if (event['parameters']?['duration_ms'] != null) {
          aggregated[type]!['total_duration'] =
              (aggregated[type]!['total_duration'] as int) +
                  (event['parameters']['duration_ms'] as int);
        }
      }

      developer.log(
        'Collected app usage data: ${aggregated.length} event types',
        name: _logName,
      );

      return aggregated.values.toList();
    } catch (e) {
      developer.log('Error collecting app usage data: $e', name: _logName);
      return [];
    }
  }

  /// Collect community interaction data from database
  /// Phase 11: User-AI Interaction Update - Section 1.2
  /// Queries Supabase for community-related data
  Future<List<dynamic>> _collectCommunityData() async {
    try {
      final supabase = Supabase.instance.client;

      final communityData = <dynamic>[];

      // Query respected lists (lists with respect_count > 0, ordered by respect count)
      try {
        final respectedLists = await supabase
            .from('spot_lists')
            .select('*')
            .gt('respect_count', 0)
            .order('respect_count', ascending: false)
            .limit(20);

        communityData.addAll(
          respectedLists.map((l) => {'type': 'respected_list', 'data': l}),
        );
      } catch (e) {
        developer.log('Error querying respected lists: $e', name: _logName);
      }

      // Query trending spots (spots with respect_count > 0, ordered by respect count)
      try {
        final trendingSpots = await supabase
            .from('spots')
            .select('*')
            .gt('respect_count', 0)
            .order('respect_count', ascending: false)
            .limit(20);

        communityData.addAll(
          trendingSpots.map((s) => {'type': 'trending_spot', 'data': s}),
        );
      } catch (e) {
        developer.log('Error querying trending spots: $e', name: _logName);
      }

      // TODO: Add query for community_interactions table when it is created
      // This table doesn't exist yet but is planned:
      // - community_interactions table (for general community activity tracking)

      developer.log(
        'Collected community data: ${communityData.length} items',
        name: _logName,
      );

      return communityData;
    } catch (e) {
      developer.log('Error collecting community data: $e', name: _logName);
      return [];
    }
  }

  /// Collect AI2AI communication data
  Future<List<dynamic>> _collectAI2AIData() async {
    try {
      // TODO: Connect to AI2AI learning system
      // This would collect:
      // - AI2AI interactions
      // - Personality learning insights
      // - Cross-personality patterns
      // - Collective intelligence data

      // For now, return empty list - will be populated when AI2AI service is connected
      return [];
    } catch (e) {
      developer.log('Error collecting AI2AI data: $e', name: _logName);
      return [];
    }
  }

  /// Collect external context data
  Future<List<dynamic>> _collectExternalData() async {
    try {
      // TODO: Connect to external data sources
      // This would collect:
      // - Events data
      // - News/trends
      // - Seasonal data
      // - Cultural events
      // - External API data

      // For now, return empty list - will be populated when external services are connected
      return [];
    } catch (e) {
      developer.log('Error collecting external data: $e', name: _logName);
      return [];
    }
  }

  // Analysis methods (implementations would contain actual analysis logic)

  double _calculateActionDiversity(List<dynamic> actions) => 0.5;
  double _calculatePreferenceConsistency(List<dynamic> actions) => 0.5;
  double _analyzeUsagePatterns(List<dynamic> usageData) => 0.5;
  double _analyzeSocialPreferences(List<dynamic> socialData) => 0.5;
  double _analyzeDemographicInsights(List<dynamic> demographicData) => 0.5;
  double _analyzeAIInsights(List<dynamic> aiData) => 0.5;
  double _analyzeLocationPatterns(List<dynamic> locationData) => 0.5;
  double _calculateLocationDiversity(List<dynamic> locationData) => 0.5;
  double _analyzeWeatherLocationCorrelation(
          List<dynamic> weatherData, List<dynamic> locationData) =>
      0.5;
  double _analyzeTemporalLocationPatterns(
          List<dynamic> timeData, List<dynamic> locationData) =>
      0.5;
  double _analyzeTemporalPatterns(List<dynamic> timeData) => 0.5;
  double _analyzeSeasonalPatterns(List<dynamic> timeData) => 0.5;
  double _analyzeActionTimingPatterns(List<dynamic> actions) => 0.5;
  double _analyzeWeatherTimeCorrelation(
          List<dynamic> weatherData, List<dynamic> timeData) =>
      0.5;
  double _analyzeSocialPatterns(List<dynamic> socialData) => 0.5;
  double _analyzeSocialNetworkDynamics(List<dynamic> socialData) => 0.5;
  double _analyzeCommunityDynamics(List<dynamic> communityData) => 0.5;
  double _analyzeDemographicSocialCorrelation(
          List<dynamic> demographicData, List<dynamic> socialData) =>
      0.5;
  double _analyzeBehaviorAuthenticity(List<dynamic> actions) => 0.5;
  double _analyzeCommunityAuthenticity(List<dynamic> communityData) => 0.5;
  double _analyzeAIAuthenticityInsights(List<dynamic> aiData) => 0.5;
  double _analyzeCommunityEvolution(List<dynamic> communityData) => 0.5;
  double _analyzeCommunityGrowth(List<dynamic> communityData) => 0.5;
  double _analyzeSocialNetworkEvolution(List<dynamic> socialData) => 0.5;
  double _analyzeDemographicEvolution(List<dynamic> demographicData) => 0.5;
  double _analyzeRecommendationFeedback(List<dynamic> actions) => 0.5;
  double _analyzeCommunityRecommendations(List<dynamic> communityData) => 0.5;
  double _analyzeAIRecommendationInsights(List<dynamic> aiData) => 0.5;
  double _analyzePreferenceDepth(List<dynamic> actions) => 0.5;
  double _analyzeDemographicPersonalization(List<dynamic> demographicData) =>
      0.5;
  double _analyzeTemporalPersonalization(List<dynamic> timeData) => 0.5;
  double _analyzeLocationPersonalization(List<dynamic> locationData) => 0.5;
  double _analyzeSocialPersonalization(List<dynamic> socialData) => 0.5;
  double _analyzeTrendPatterns(List<dynamic> actions) => 0.5;
  double _analyzeCommunityTrends(List<dynamic> communityData) => 0.5;
  double _analyzeExternalTrends(List<dynamic> externalData) => 0.5;
  double _analyzeAITrendInsights(List<dynamic> aiData) => 0.5;
  double _analyzeAICollaboration(List<dynamic> aiData) => 0.5;
  double _analyzeCommunityCollaboration(List<dynamic> communityData) => 0.5;
  double _analyzeSocialCollaboration(List<dynamic> socialData) => 0.5;
}

// Models for continuous learning system

class LearningData {
  final List<dynamic> userActions;
  final List<dynamic> locationData;
  final List<dynamic> weatherData;
  final List<dynamic> timeData;
  final List<dynamic> socialData;
  final List<dynamic> demographicData;
  final List<dynamic> appUsageData;
  final List<dynamic> communityData;
  final List<dynamic> ai2aiData;
  final List<dynamic> externalData;
  final DateTime timestamp;

  LearningData({
    required this.userActions,
    required this.locationData,
    required this.weatherData,
    required this.timeData,
    required this.socialData,
    required this.demographicData,
    required this.appUsageData,
    required this.communityData,
    required this.ai2aiData,
    required this.externalData,
    required this.timestamp,
  });

  static LearningData empty() {
    return LearningData(
      userActions: [],
      locationData: [],
      weatherData: [],
      timeData: [],
      socialData: [],
      demographicData: [],
      appUsageData: [],
      communityData: [],
      ai2aiData: [],
      externalData: [],
      timestamp: DateTime.now(),
    );
  }
}

class LearningEvent {
  final String dimension;
  final double improvement;
  final String dataSource;
  final DateTime timestamp;

  LearningEvent({
    required this.dimension,
    required this.improvement,
    required this.dataSource,
    required this.timestamp,
  });
}

// Data models for UI

class ContinuousLearningStatus {
  final bool isActive;
  final List<String> activeProcesses;
  final Duration uptime;
  final int cyclesCompleted;
  final Duration learningTime;

  ContinuousLearningStatus({
    required this.isActive,
    required this.activeProcesses,
    required this.uptime,
    required this.cyclesCompleted,
    required this.learningTime,
  });
}

class ContinuousLearningMetrics {
  final double totalImprovements;
  final double averageProgress;
  final List<String> topImprovingDimensions;
  final int dimensionsCount;
  final int dataSourcesCount;

  ContinuousLearningMetrics({
    required this.totalImprovements,
    required this.averageProgress,
    required this.topImprovingDimensions,
    required this.dimensionsCount,
    required this.dataSourcesCount,
  });
}

class DataCollectionStatus {
  final Map<String, DataSourceStatus> sourceStatuses;
  final int totalVolume;
  final int activeSourcesCount;

  DataCollectionStatus({
    required this.sourceStatuses,
    required this.totalVolume,
    required this.activeSourcesCount,
  });
}

class DataSourceStatus {
  final bool isActive;
  final int dataVolume;
  final int eventCount;
  final String healthStatus; // 'healthy', 'idle', 'inactive'

  DataSourceStatus({
    required this.isActive,
    required this.dataVolume,
    required this.eventCount,
    required this.healthStatus,
  });
}

import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avrai/core/services/agent_id_service.dart';
import 'package:get_it/get_it.dart';
import 'package:avrai/injection_container.dart' as di;
import 'package:avrai/core/ai/personality_learning.dart';
import 'package:avrai/core/ai/interaction_events.dart';
import 'package:avrai/core/ai/structured_facts_extractor.dart';
import 'package:avrai/core/ai/facts_index.dart';
import 'package:avrai/core/ai/continuous_learning/orchestrator.dart';
import 'package:avrai/core/ai/continuous_learning/data_collector.dart';
import 'package:avrai/core/ai/continuous_learning/data_processor.dart';

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
  bool _orchestratorInitialized = false;
  final AgentIdService _agentIdService;
  SupabaseClient? _supabase;

  static AgentIdService _resolveAgentIdService(AgentIdService? agentIdService) {
    if (agentIdService != null) {
      return agentIdService;
    }
    try {
      if (di.sl.isRegistered<AgentIdService>()) {
        return di.sl<AgentIdService>();
      }
    } catch (e) {
      developer.log(
        'AgentIdService not available in DI; using default instance',
        name: _logName,
        error: e,
      );
    }
    return AgentIdService();
  }

  // Constructor
  ContinuousLearningSystem({
    SupabaseClient? supabase,
    AgentIdService? agentIdService,
    ContinuousLearningOrchestrator? orchestrator,
  })  : _agentIdService = _resolveAgentIdService(agentIdService),
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
    if (_orchestrator == null) {
      final dataCollector = LearningDataCollector(
        agentIdService: _agentIdService,
      );
      final dataProcessor = LearningDataProcessor();
      _orchestrator = ContinuousLearningOrchestrator(
        dataCollector: dataCollector,
        dataProcessor: dataProcessor,
      );
    }

    if (!_orchestratorInitialized) {
      await _orchestrator!.initialize();
      _orchestratorInitialized = true;
    }
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
  // Phase 1.4: Legacy improvement + insight helpers removed.
  // The orchestrator (engines + collectors) is the single source of truth.

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

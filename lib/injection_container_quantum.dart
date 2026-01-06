import 'package:get_it/get_it.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/feature_flag_service.dart';
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots/core/services/event_success_analysis_service.dart';
import 'package:spots/core/ai/quantum/quantum_vibe_engine.dart';
import 'package:spots/core/ai/quantum/quantum_feature_extractor.dart';
import 'package:spots/core/services/quantum_prediction_enhancer.dart';
import 'package:spots/core/ml/training/quantum_prediction_training_pipeline.dart';
import 'package:spots/core/ai/quantum/quantum_satisfaction_feature_extractor.dart';
import 'package:spots/core/services/quantum_satisfaction_enhancer.dart';
import 'package:spots/core/services/decoherence_tracking_service.dart';
import 'package:spots/data/datasources/local/decoherence_pattern_local_datasource.dart';
import 'package:spots/data/datasources/local/decoherence_pattern_sembast_datasource.dart';
import 'package:spots/data/repositories/decoherence_pattern_repository_impl.dart';
import 'package:spots/domain/repositories/decoherence_pattern_repository.dart';
import 'package:spots/core/services/reservation_quantum_service.dart';
import 'package:spots_quantum/services/quantum/quantum_entanglement_service.dart';
import 'package:spots_quantum/services/quantum/entanglement_coefficient_optimizer.dart';
import 'package:spots_quantum/services/quantum/location_timing_quantum_state_service.dart';
import 'package:spots/core/services/quantum/real_time_user_calling_service.dart';
import 'package:spots/core/services/quantum/meaningful_experience_calculator.dart';
import 'package:spots/core/services/quantum/meaningful_connection_metrics_service.dart';
import 'package:spots/core/services/quantum/user_journey_tracking_service.dart';
import 'package:spots/core/services/quantum/quantum_outcome_learning_service.dart';
import 'package:spots/core/services/quantum/ideal_state_learning_service.dart';
import 'package:spots/core/controllers/quantum_matching_controller.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/preferences_profile_service.dart';
import 'package:spots_knot/services/knot/integrated_knot_recommendation_engine.dart';
import 'package:spots_knot/services/knot/cross_entity_compatibility_service.dart';
import 'package:spots_knot/services/knot/personality_knot_service.dart';
import 'package:spots_knot/services/knot/quantum_state_knot_service.dart';

/// Quantum Services Registration Module
///
/// Registers all quantum-related services.
/// This includes:
/// - Decoherence tracking services
/// - Quantum vibe engine
/// - Quantum entanglement services
/// - Quantum prediction and satisfaction enhancement
/// - Quantum matching controller
/// - Reservation quantum services
Future<void> registerQuantumServices(GetIt sl) async {
  const logger =
      AppLogger(defaultTag: 'DI-Quantum', minimumLevel: LogLevel.debug);
  logger.debug('⚛️ [DI-Quantum] Registering quantum services...');

  // Quantum Enhancement Implementation Plan - Phase 2.1: Decoherence Tracking
  // Register Decoherence Pattern Repository
  sl.registerLazySingleton<DecoherencePatternLocalDataSource>(
    () => DecoherencePatternSembastDataSource(),
  );
  sl.registerLazySingleton<DecoherencePatternRepository>(
    () => DecoherencePatternRepositoryImpl(
      localDataSource: sl<DecoherencePatternLocalDataSource>(),
    ),
  );

  // Register Decoherence Tracking Service
  sl.registerLazySingleton<DecoherenceTrackingService>(
    () => DecoherenceTrackingService(
      repository: sl<DecoherencePatternRepository>(),
      atomicClock: sl<AtomicClockService>(),
    ),
  );

  // Quantum Vibe Engine (Phase 4: Quantum Analysis)
  // Enhanced with Decoherence Tracking (Phase 2.1)
  sl.registerLazySingleton(() => QuantumVibeEngine(
        decoherenceTracking: sl<DecoherenceTrackingService>(),
        featureFlags: sl<FeatureFlagService>(),
      ));

  // Phase 19: Multi-Entity Quantum Entanglement Matching System
  // Section 19.1: N-Way Quantum Entanglement Framework
  sl.registerLazySingleton<QuantumEntanglementService>(
    () => QuantumEntanglementService(
      atomicClock: sl<AtomicClockService>(),
      knotEngine: sl<IntegratedKnotRecommendationEngine>(),
      knotCompatibilityService: sl<CrossEntityCompatibilityService>(),
      quantumStateKnotService: sl<QuantumStateKnotService>(),
    ),
  );

  // Section 19.2: Dynamic Entanglement Coefficient Optimization
  sl.registerLazySingleton<EntanglementCoefficientOptimizer>(
    () => EntanglementCoefficientOptimizer(
      atomicClock: sl<AtomicClockService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      knotEngine: sl<IntegratedKnotRecommendationEngine>(),
      knotCompatibilityService: sl<CrossEntityCompatibilityService>(),
    ),
  );

  // Section 19.3: Location and Timing Quantum States
  sl.registerLazySingleton<LocationTimingQuantumStateService>(
    () => LocationTimingQuantumStateService(
      atomicClock: sl<AtomicClockService>(),
    ),
  );

  // Section 19.4: Dynamic Real-Time User Calling System
  // Section 19.6: Meaningful Experience Calculator
  sl.registerLazySingleton<MeaningfulExperienceCalculator>(
    () => MeaningfulExperienceCalculator(
      atomicClock: sl<AtomicClockService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      locationTimingService: sl<LocationTimingQuantumStateService>(),
    ),
  );

  // Section 19.8: User Journey Tracking Service (registered before RealTimeUserCallingService)
  sl.registerLazySingleton<UserJourneyTrackingService>(
    () => UserJourneyTrackingService(
      atomicClock: sl<AtomicClockService>(),
      personalityLearning: sl<PersonalityLearning>(),
      vibeAnalyzer: sl<UserVibeAnalyzer>(),
      agentIdService: sl<AgentIdService>(),
      supabaseService: sl<SupabaseService>(),
    ),
  );

  sl.registerLazySingleton<RealTimeUserCallingService>(
    () => RealTimeUserCallingService(
      atomicClock: sl<AtomicClockService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      locationTimingService: sl<LocationTimingQuantumStateService>(),
      personalityLearning: sl<PersonalityLearning>(),
      vibeAnalyzer: sl<UserVibeAnalyzer>(),
      agentIdService: sl<AgentIdService>(),
      knotCompatibilityService: sl<CrossEntityCompatibilityService>(),
      supabaseService: sl<SupabaseService>(),
      preferencesProfileService: sl<PreferencesProfileService>(),
      personalityKnotService: sl<PersonalityKnotService>(),
      meaningfulExperienceCalculator: sl<MeaningfulExperienceCalculator>(),
      journeyTrackingService: sl<UserJourneyTrackingService>(),
    ),
  );

  // Section 19.7: Meaningful Connection Metrics Service
  sl.registerLazySingleton<MeaningfulConnectionMetricsService>(
    () => MeaningfulConnectionMetricsService(
      atomicClock: sl<AtomicClockService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      personalityLearning: sl<PersonalityLearning>(),
      vibeAnalyzer: sl<UserVibeAnalyzer>(),
      agentIdService: sl<AgentIdService>(),
      supabaseService: sl<SupabaseService>(),
    ),
  );

  // Section 19.9: Quantum Outcome-Based Learning Service
  sl.registerLazySingleton<QuantumOutcomeLearningService>(
    () => QuantumOutcomeLearningService(
      atomicClock: sl<AtomicClockService>(),
      successAnalysisService: sl<EventSuccessAnalysisService>(),
      meaningfulMetricsService: sl<MeaningfulConnectionMetricsService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      locationTimingService: sl<LocationTimingQuantumStateService>(),
    ),
  );

  // Section 19.10: Ideal State Learning Service
  sl.registerLazySingleton<IdealStateLearningService>(
    () => IdealStateLearningService(
      atomicClock: sl<AtomicClockService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      outcomeLearningService: sl<QuantumOutcomeLearningService>(),
    ),
  );

  // Section 19.5: Quantum Matching Controller
  sl.registerLazySingleton<QuantumMatchingController>(
    () => QuantumMatchingController(
      atomicClock: sl<AtomicClockService>(),
      entanglementService: sl<QuantumEntanglementService>(),
      locationTimingService: sl<LocationTimingQuantumStateService>(),
      personalityLearning: sl<PersonalityLearning>(),
      vibeAnalyzer: sl<UserVibeAnalyzer>(),
      agentIdService: sl<AgentIdService>(),
      preferencesProfileService: sl<PreferencesProfileService>(),
      knotEngine: sl<IntegratedKnotRecommendationEngine>(),
      knotCompatibilityService: sl<CrossEntityCompatibilityService>(),
      meaningfulConnectionMetricsService:
          sl<MeaningfulConnectionMetricsService>(),
    ),
  );

  // Quantum Enhancement Implementation Plan - Phase 3.1: Quantum Prediction Features
  // Register Quantum Feature Extractor
  sl.registerLazySingleton<QuantumFeatureExtractor>(
    () => QuantumFeatureExtractor(
      decoherenceTracking: sl<DecoherenceTrackingService>(),
    ),
  );

  // Register Quantum Prediction Training Pipeline
  sl.registerLazySingleton<QuantumPredictionTrainingPipeline>(
    () => QuantumPredictionTrainingPipeline(),
  );

  // Register Quantum Prediction Enhancer
  sl.registerLazySingleton<QuantumPredictionEnhancer>(
    () => QuantumPredictionEnhancer(
      featureExtractor: sl<QuantumFeatureExtractor>(),
      trainingPipeline: sl<QuantumPredictionTrainingPipeline>(),
      featureFlags: sl<FeatureFlagService>(),
    ),
  );

  // Quantum Enhancement Implementation Plan - Phase 4.1: Quantum Satisfaction Enhancement
  // Register Quantum Satisfaction Feature Extractor
  sl.registerLazySingleton<QuantumSatisfactionFeatureExtractor>(
    () => QuantumSatisfactionFeatureExtractor(
      decoherenceTracking: sl<DecoherenceTrackingService>(),
    ),
  );

  // Register Quantum Satisfaction Enhancer
  sl.registerLazySingleton<QuantumSatisfactionEnhancer>(
    () => QuantumSatisfactionEnhancer(
      featureExtractor: sl<QuantumSatisfactionFeatureExtractor>(),
      featureFlags: sl<FeatureFlagService>(),
    ),
  );

  // Phase 15: Reservation System with Quantum Integration
  // Phase 15 Section 15.1: Foundation - Quantum Integration
  sl.registerLazySingleton(() => ReservationQuantumService(
        atomicClock: sl<AtomicClockService>(),
        quantumVibeEngine: sl<QuantumVibeEngine>(),
        vibeAnalyzer: sl<UserVibeAnalyzer>(),
        personalityLearning: sl<PersonalityLearning>(),
        locationTimingService: sl<LocationTimingQuantumStateService>(),
        entanglementService:
            sl<QuantumEntanglementService>(), // Optional, graceful degradation
      ));

  logger.debug('✅ [DI-Quantum] Quantum services registered');
}

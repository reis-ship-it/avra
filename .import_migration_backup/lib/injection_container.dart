import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sembast/sembast.dart';

// Database
import 'package:spots/data/datasources/local/sembast_database.dart';

// Auth
import 'package:spots/data/datasources/remote/auth_remote_datasource.dart';
import 'package:spots/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/auth_local_datasource.dart';
import 'package:spots/data/datasources/local/auth_sembast_datasource.dart';
import 'package:spots/data/repositories/auth_repository_impl.dart';
import 'package:spots/domain/repositories/auth_repository.dart';
import 'package:spots/domain/usecases/auth/sign_in_usecase.dart';
import 'package:spots/domain/usecases/auth/sign_up_usecase.dart';
import 'package:spots/domain/usecases/auth/sign_out_usecase.dart';
import 'package:spots/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:spots/domain/usecases/auth/update_password_usecase.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';

// Spots
import 'package:spots/data/datasources/remote/spots_remote_datasource.dart';
import 'package:spots/data/datasources/remote/spots_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/spots_local_datasource.dart';
import 'package:spots/data/datasources/local/spots_sembast_datasource.dart';
import 'package:spots/data/repositories/spots_repository_impl.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/get_spots_usecase.dart';
import 'package:spots/domain/usecases/spots/get_spots_from_respected_lists_usecase.dart';
import 'package:spots/domain/usecases/spots/create_spot_usecase.dart';
import 'package:spots/domain/usecases/spots/update_spot_usecase.dart';
import 'package:spots/domain/usecases/spots/delete_spot_usecase.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';

// Lists
import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/lists_local_datasource.dart';
import 'package:spots/data/datasources/local/lists_sembast_datasource.dart';
import 'package:spots/data/repositories/lists_repository_impl.dart';
import 'package:spots/domain/repositories/lists_repository.dart';
import 'package:spots/domain/usecases/lists/get_lists_usecase.dart';
import 'package:spots/domain/usecases/lists/create_list_usecase.dart';
import 'package:spots/domain/usecases/lists/update_list_usecase.dart';
import 'package:spots/domain/usecases/lists/delete_list_usecase.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';

// Hybrid Search (Phase 2: External Data Integration)
import 'package:spots/data/datasources/remote/google_places_datasource.dart';
import 'package:spots/data/datasources/remote/openstreetmap_datasource.dart';
import 'package:spots/data/datasources/remote/openstreetmap_datasource_impl.dart';
import 'package:spots/data/repositories/hybrid_search_repository.dart';
import 'package:spots/domain/usecases/search/hybrid_search_usecase.dart';
import 'package:spots/presentation/blocs/search/hybrid_search_bloc.dart';

// Phase 4: Performance Optimization & AI Features
import 'package:spots/core/services/search_cache_service.dart';
import 'package:spots/core/services/ai_search_suggestions_service.dart';

// Phase 2: Missing Services
import 'package:spots/core/services/role_management_service.dart';
import 'package:spots/core/models/user_role.dart';
import 'package:spots/core/services/community_validation_service.dart';
import 'package:spots/core/services/performance_monitor.dart';
import 'package:spots/core/services/security_validator.dart';
import 'package:spots/core/services/deployment_validator.dart';

// Patent #30: Quantum Atomic Clock System
import 'package:spots/core/services/atomic_clock_service.dart';

// Patent #31: Topological Knot Theory for Personality Representation
import 'package:spots/core/services/knot/personality_knot_service.dart';
import 'package:spots/core/services/knot/knot_storage_service.dart';
import 'package:spots/core/services/knot/knot_cache_service.dart';
import 'package:spots/core/services/knot/entity_knot_service.dart';
import 'package:spots/core/services/knot/cross_entity_compatibility_service.dart';
import 'package:spots/core/services/knot/network_cross_pollination_service.dart';
import 'package:spots/core/services/knot/knot_weaving_service.dart';
import 'package:spots/core/services/knot/knot_community_service.dart';
import 'package:spots/core/services/knot/dynamic_knot_service.dart';
import 'package:spots/core/services/knot/knot_fabric_service.dart';
import 'package:spots/core/services/knot/prominence_calculator.dart';
import 'package:spots/core/services/knot/hierarchical_layout_service.dart';
import 'package:spots/core/services/knot/glue_visualization_service.dart';
import 'package:spots/core/services/knot/integrated_knot_recommendation_engine.dart';
import 'package:spots/core/services/knot/knot_audio_service.dart';
import 'package:spots/core/services/knot/knot_privacy_service.dart';
import 'package:spots/core/services/knot/knot_data_api_service.dart';
import 'package:spots/core/services/admin/knot_admin_service.dart';
import 'package:spots/core/services/wearable_data_service.dart';

// Quantum Enhancement Implementation Plan - Phase 2.1: Decoherence Tracking
import 'package:spots/data/datasources/local/decoherence_pattern_local_datasource.dart';
import 'package:spots/data/datasources/local/decoherence_pattern_sembast_datasource.dart';
import 'package:spots/data/repositories/decoherence_pattern_repository_impl.dart';
import 'package:spots/domain/repositories/decoherence_pattern_repository.dart';
import 'package:spots/core/services/decoherence_tracking_service.dart';

// Quantum Enhancement Implementation Plan - Phase 3.1: Quantum Prediction Features
import 'package:spots/core/ai/quantum/quantum_feature_extractor.dart';
import 'package:spots/core/services/quantum_prediction_enhancer.dart';
import 'package:spots/core/ml/training/quantum_prediction_training_pipeline.dart';

// Quantum Enhancement Implementation Plan - Phase 4.1: Quantum Satisfaction Enhancement
import 'package:spots/core/ai/quantum/quantum_satisfaction_feature_extractor.dart';
import 'package:spots/core/services/quantum_satisfaction_enhancer.dart';

// Feature Flag System
import 'package:spots/core/services/feature_flag_service.dart';

// Supabase Backend Integration
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/ai2ai_realtime_service.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/ai/feedback_learning.dart';
import 'package:spots/core/ml/nlp_processor.dart';
import 'package:spots/core/services/usage_pattern_tracker.dart';
import 'package:spots/core/services/ai2ai_learning_service.dart';
import 'package:spots/core/ai2ai/connection_log_queue.dart';
import 'package:spots/core/ai2ai/cloud_intelligence_sync.dart';
import 'package:spots/core/network/ai2ai_protocol.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots/core/services/ai_improvement_tracking_service.dart';
import 'package:spots/core/services/action_history_service.dart';
import 'package:spots/core/services/contextual_personality_service.dart';
import 'package:spots/core/services/enhanced_connectivity_service.dart';
import 'package:spots/core/p2p/federated_learning.dart';
import 'package:spots/core/p2p/node_manager.dart';
import 'package:spots/core/services/large_city_detection_service.dart';
import 'package:spots/core/services/neighborhood_boundary_service.dart';
import 'package:spots/core/services/geographic_scope_service.dart';
// Business Chat Services (AI2AI routing)
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/message_encryption_service.dart';
import 'package:spots/core/services/business_expert_chat_service_ai2ai.dart';
import 'package:spots/core/services/business_business_chat_service_ai2ai.dart';
import 'package:spots/core/ai2ai/anonymous_communication.dart' as ai2ai;
import 'package:spots/core/services/business_expert_outreach_service.dart';
import 'package:spots/core/services/business_business_outreach_service.dart';
import 'package:spots/core/services/business_member_service.dart';
import 'package:spots/core/services/business_shared_agent_service.dart';
// Onboarding & Agent Creation Services (Phase 1: Foundation)
import 'package:spots/core/services/onboarding_data_service.dart';
import 'package:spots/core/services/edge_function_service.dart';
import 'package:spots/core/services/onboarding_aggregation_service.dart';
import 'package:spots/core/services/social_enrichment_service.dart';
import 'package:spots/core/services/social_media_vibe_analyzer.dart';
import 'package:spots/core/services/social_media_connection_service.dart';
import 'package:spots/core/services/social_media_insight_service.dart';
import 'package:spots/core/services/social_media_sharing_service.dart';
import 'package:spots/core/services/social_media_discovery_service.dart';
import 'package:spots/core/services/public_profile_analysis_service.dart';
import 'package:spots/core/services/oauth_deep_link_handler.dart';
import 'package:spots/core/services/onboarding_place_list_generator.dart';
import 'package:spots/core/services/onboarding_recommendation_service.dart';
import 'package:spots/core/services/preferences_profile_service.dart';
import 'package:spots/core/services/event_recommendation_service.dart' as event_rec_service;
// Controllers (Phase 8.11)
import 'package:spots/core/controllers/onboarding_flow_controller.dart';
import 'package:spots/core/controllers/agent_initialization_controller.dart';
import 'package:spots/core/controllers/event_creation_controller.dart';
import 'package:spots/core/controllers/social_media_data_collection_controller.dart';
import 'package:spots/core/controllers/payment_processing_controller.dart';
import 'package:spots/core/controllers/ai_recommendation_controller.dart';
import 'package:spots/core/controllers/business_onboarding_controller.dart';
import 'package:spots/core/controllers/event_attendance_controller.dart';
import 'package:spots/core/controllers/list_creation_controller.dart';
import 'package:spots/core/controllers/quantum_matching_controller.dart';
import 'package:spots/core/controllers/checkout_controller.dart';
import 'package:spots/core/controllers/event_cancellation_controller.dart';
import 'package:spots/core/controllers/partnership_checkout_controller.dart';
import 'package:spots/core/controllers/partnership_proposal_controller.dart';
import 'package:spots/core/controllers/profile_update_controller.dart';
import 'package:spots/core/controllers/sponsorship_checkout_controller.dart';
import 'package:spots/core/services/cancellation_service.dart';
import 'package:spots/core/services/refund_service.dart';
import 'package:spots/core/controllers/sync_controller.dart';
import 'package:spots/core/ai/quantum/quantum_vibe_engine.dart';

// Phase 19: Multi-Entity Quantum Entanglement Matching System
import 'package:spots/core/services/quantum/quantum_entanglement_service.dart';
import 'package:spots/core/services/quantum/entanglement_coefficient_optimizer.dart';
import 'package:spots/core/services/quantum/location_timing_quantum_state_service.dart';

// Phase 15: Reservation System with Quantum Integration
import 'package:spots/core/services/reservation_quantum_service.dart';
import 'package:spots/core/services/reservation_service.dart';
import 'package:spots/core/services/reservation_recommendation_service.dart';
import 'package:spots/core/services/quantum/real_time_user_calling_service.dart';
import 'package:spots/core/services/quantum/meaningful_experience_calculator.dart';
import 'package:spots/core/services/quantum/meaningful_connection_metrics_service.dart';
import 'package:spots/core/services/quantum/user_journey_tracking_service.dart';
import 'package:spots/core/services/quantum/quantum_outcome_learning_service.dart';
import 'package:spots/core/services/quantum/ideal_state_learning_service.dart';
import 'package:spots/core/services/event_success_analysis_service.dart';
import 'package:http/http.dart' as http;
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/config_service.dart';
// Device Discovery & Advertising
import 'package:spots/core/network/device_discovery.dart';
import 'package:spots/core/network/device_discovery_factory.dart';
import 'package:spots/core/network/personality_advertising_service.dart';
// Single integration boundary
import 'package:spots_network/spots_network.dart';
import 'package:spots/supabase_config.dart';
// ML (cloud-only, simplified)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spots/core/ml/embedding_cloud_client.dart';
import 'package:spots/core/services/llm_service.dart';
// Google Places integration
import 'package:spots/core/services/google_places_cache_service.dart';
import 'package:spots/core/services/google_place_id_finder_service_new.dart';
import 'package:spots/core/services/google_places_sync_service.dart';
import 'package:spots/data/datasources/remote/google_places_datasource_new_impl.dart';
import 'package:spots/google_places_config.dart';

// Admin Services (God-Mode Admin System)
import 'package:spots/core/services/admin_auth_service.dart';
import 'package:spots/core/services/business_auth_service.dart';
import 'package:spots/core/services/admin_god_mode_service.dart';
import 'package:spots/core/services/admin_communication_service.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:spots/core/services/business_service.dart';
import 'package:spots/core/ml/predictive_analytics.dart';
import 'package:spots/core/monitoring/connection_monitor.dart';
import 'package:spots/core/services/expertise_service.dart';
// Payment Processing - Agent 1: Payment Processing & Revenue
import 'package:spots/core/services/stripe_service.dart';
import 'package:spots/core/services/payment_service.dart';
import 'package:spots/core/services/payment_event_service.dart';
import 'package:spots/core/services/payout_service.dart';
import 'package:spots/core/services/revenue_split_service.dart';
import 'package:spots/core/services/partnership_service.dart';
import 'package:spots/core/services/sponsorship_service.dart';
import 'package:spots/core/services/product_tracking_service.dart';
import 'package:spots/core/services/product_sales_service.dart';
import 'package:spots/core/services/brand_analytics_service.dart';
import 'package:spots/core/services/brand_discovery_service.dart';
import 'package:spots/core/config/stripe_config.dart';
import 'package:spots/core/services/location_obfuscation_service.dart';
import 'package:spots/core/services/user_anonymization_service.dart';
import 'package:spots/core/services/field_encryption_service.dart';
import 'package:spots/core/services/audit_log_service.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/services/event_matching_service.dart';
import 'package:spots/core/services/spot_vibe_matching_service.dart';
import 'package:spots/core/services/legal_document_service.dart';
import 'package:spots/core/services/sales_tax_service.dart';
import 'package:spots/core/services/permissions_persistence_service.dart';
import 'package:spots/core/services/personality_sync_service.dart';
import 'package:spots/core/services/user_name_resolution_service.dart';
import 'package:spots/core/services/personality_agent_chat_service.dart';
import 'package:spots/core/services/friend_chat_service.dart';
import 'package:spots/core/services/community_chat_service.dart';
import 'package:spots/core/services/community_service.dart';
import 'package:spots/core/services/geographic_expansion_service.dart';
import 'package:spots/core/ai/continuous_learning_system.dart';
import 'package:spots/core/ai/event_queue.dart';
import 'package:spots/core/ai/event_logger.dart';
import 'package:spots/core/ai/structured_facts_extractor.dart';
import 'package:spots/core/ai/facts_index.dart';
import 'package:spots/core/ai/decision_coordinator.dart';
import 'package:spots/core/ai2ai/embedding_delta_collector.dart';
import 'package:spots/core/ai2ai/federated_learning_hooks.dart';
import 'package:spots/core/ml/inference_orchestrator.dart';
import 'package:spots/core/ml/onnx_dimension_scorer.dart';
// Phase 12: Neural Network Implementation
import 'package:spots/core/services/calling_score_data_collector.dart';
import 'package:spots/core/services/calling_score_calculator.dart';
import 'package:spots/core/services/calling_score_baseline_metrics.dart';
import 'package:spots/core/services/calling_score_training_data_preparer.dart';
import 'package:spots/core/services/calling_score_ab_testing_service.dart';
import 'package:spots/core/ml/calling_score_neural_model.dart';
import 'package:spots/core/services/behavior_assessment_service.dart';
import 'package:spots/core/ml/outcome_prediction_model.dart';
import 'package:spots/core/services/outcome_prediction_service.dart';
import 'package:spots/core/services/model_version_manager.dart';
import 'package:spots/core/services/online_learning_service.dart';
import 'package:spots/core/services/model_retraining_service.dart';
import 'package:spots/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:spots/core/crypto/signal/signal_key_manager.dart';
import 'package:spots/core/crypto/signal/signal_session_manager.dart';
import 'package:spots/core/crypto/signal/signal_protocol_service.dart';
import 'package:spots/core/crypto/signal/signal_platform_bridge_bindings.dart';
import 'package:spots/core/crypto/signal/signal_rust_wrapper_bindings.dart';
import 'package:spots/core/crypto/signal/signal_ffi_store_callbacks.dart';
import 'package:spots/core/services/signal_protocol_initialization_service.dart';
import 'package:spots/core/services/hybrid_encryption_service.dart';
import 'package:spots/core/services/signal_protocol_encryption_service.dart';
import 'package:spots/core/services/secure_mapping_encryption_service.dart';
import 'package:spots/core/services/agent_id_migration_service.dart';
import 'package:spots/core/services/mapping_key_rotation_service.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  const logger = AppLogger(defaultTag: 'DI', minimumLevel: LogLevel.debug);
  logger.info('🔧 [DI] Starting dependency injection initialization...');

  // External
  logger.debug('📡 [DI] Registering Connectivity...');
  sl.registerLazySingleton(() => Connectivity());

  // Permissions Persistence Service
  sl.registerLazySingleton(() => PermissionsPersistenceService());

  // Initialize Sembast Database (works on both web and mobile now)
  try {
    logger.debug('💾 [DI] Initializing Sembast database...');
    final sembastDb = await SembastDatabase.database;
    sl.registerLazySingleton(() => sembastDb);
    logger.debug('✅ [DI] Sembast database registered');
  } catch (e) {
    logger.warn('⚠️ [DI] Sembast database initialization failed: $e');
    // Continue even if database initialization fails
  }

  // Data Sources - Local (Offline-First)
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthSembastDataSource());
  sl.registerLazySingleton<SpotsLocalDataSource>(
      () => SpotsSembastDataSource());
  sl.registerLazySingleton<ListsLocalDataSource>(
      () => ListsSembastDataSource());

  // Data Sources - Remote (Optional, for online features)
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl());
  sl.registerLazySingleton<SpotsRemoteDataSource>(
      () => SpotsRemoteDataSourceImpl());
  sl.registerLazySingleton<ListsRemoteDataSource>(
      () => ListsRemoteDataSourceImpl());

  // Google Places Cache Service (for offline caching)
  sl.registerLazySingleton<GooglePlacesCacheService>(
      () => GooglePlacesCacheService());

  // Get Google Places API key from config
  final googlePlacesApiKey = GooglePlacesConfig.getApiKey();

  // Google Place ID Finder Service (New API)
  sl.registerLazySingleton<GooglePlaceIdFinderServiceNew>(
      () => GooglePlaceIdFinderServiceNew(
            apiKey: googlePlacesApiKey.isNotEmpty
                ? googlePlacesApiKey
                : 'demo_key', // Fallback for development
          ));

  // External Data Sources - Using New Places API (New)
  sl.registerLazySingleton<GooglePlacesDataSource>(
      () => GooglePlacesDataSourceNewImpl(
            apiKey: googlePlacesApiKey.isNotEmpty
                ? googlePlacesApiKey
                : 'demo_key', // Fallback for development
            httpClient: sl<http.Client>(),
            cacheService: sl<GooglePlacesCacheService>(),
          ));
  sl.registerLazySingleton<OpenStreetMapDataSource>(
      () => OpenStreetMapDataSourceImpl(
            httpClient: sl<http.Client>(),
          ));

  // Google Places Sync Service (using New API)
  sl.registerLazySingleton<GooglePlacesSyncService>(
      () => GooglePlacesSyncService(
            placeIdFinderNew: sl<GooglePlaceIdFinderServiceNew>(),
            cacheService: sl<GooglePlacesCacheService>(),
            googlePlacesDataSource: sl<GooglePlacesDataSource>(),
            spotsLocalDataSource: sl<SpotsLocalDataSource>(),
            connectivity: sl<Connectivity>(),
          ));

  // Repositories (Register first)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  sl.registerLazySingleton<SpotsRepository>(
    () => SpotsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  sl.registerLazySingleton<ListsRepository>(
    () => ListsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Hybrid Search Repository (Phase 2) - Always available for offline search
  sl.registerLazySingleton(() => HybridSearchRepository(
        localDataSource: sl<SpotsLocalDataSource>(),
        remoteDataSource: sl<SpotsRemoteDataSource>(),
        googlePlacesDataSource: sl<GooglePlacesDataSource>(),
        osmDataSource: sl<OpenStreetMapDataSource>(),
        googlePlacesCache: sl<GooglePlacesCacheService>(),
        connectivity: sl<Connectivity>(),
      ));

  // Auth Use cases (Register after repositories)
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));

  // Spots Use cases (Register after repositories)
  sl.registerLazySingleton(() => GetSpotsUseCase(sl()));
  sl.registerLazySingleton(() => GetSpotsFromRespectedListsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSpotUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSpotUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSpotUseCase(sl()));

  // Lists Use cases (Register after repositories)
  sl.registerLazySingleton(() => GetListsUseCase(sl()));
  sl.registerLazySingleton(() => CreateListUseCase(sl()));
  sl.registerLazySingleton(() => UpdateListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteListUseCase(sl()));

  // Hybrid Search Use case (Phase 2)
  sl.registerLazySingleton(() => HybridSearchUseCase(sl()));

  // Services
  sl.registerLazySingleton(() => SearchCacheService());
  sl.registerLazySingleton(() => AISearchSuggestionsService());
  // Storage service for UserVibeAnalyzer
  final sharedPrefs = await StorageService.getInstance();
  // Expose SharedPreferences so UI/services can use via DI
  // Note: SharedPreferencesCompat is typedef'd as SharedPreferences
  sl.registerLazySingleton<SharedPreferencesCompat>(() => sharedPrefs);
  // Register both types for compatibility
  // Note: SharedPreferencesCompat implements the same interface, but some services need the original type
  // We'll register both and services can use whichever they need
  // For services that require the original SharedPreferences type, we need to use SharedPreferencesCompat
  // since we're using get_storage instead of shared_preferences
  // Note: The cast below will fail at runtime - services should be updated to use SharedPreferencesCompat
  // sl.registerLazySingleton<sp.SharedPreferences>(
  //     () => sharedPrefs as sp.SharedPreferences); // REMOVED: Invalid cast causes runtime errors
  sl.registerLazySingleton(() => UserVibeAnalyzer(prefs: sharedPrefs));

  // Storage Service (needed by Phase 2 services)
  // Initialize StorageService instance
  final storageService = StorageService.instance;
  await storageService.init();
  sl.registerLazySingleton<StorageService>(() => storageService);

  // Feature Flag Service (for gradual rollout and A/B testing)
  sl.registerLazySingleton<FeatureFlagService>(
    () => FeatureFlagService(
      storage: sl<StorageService>(),
    ),
  );

  // Geographic Services (Phase 6: Local Expert System Redesign)
  sl.registerLazySingleton<LargeCityDetectionService>(
      () => LargeCityDetectionService());
  sl.registerLazySingleton<GeographicScopeService>(
      () => GeographicScopeService(
            largeCityService: sl<LargeCityDetectionService>(),
          ));
  sl.registerLazySingleton<NeighborhoodBoundaryService>(
      () => NeighborhoodBoundaryService(
            largeCityService: sl<LargeCityDetectionService>(),
            storageService: sl<StorageService>(),
          ));

  // Phase 2: Missing Services
  // Register Phase 2 services (dependencies first)
  sl.registerLazySingleton<RoleManagementService>(
      () => RoleManagementServiceImpl(
            storageService: sl<StorageService>(),
            prefs: sl<SharedPreferencesCompat>(),
          ));

  sl.registerLazySingleton(() => CommunityValidationService(
        storageService: sl<StorageService>(),
        prefs: sl<SharedPreferencesCompat>(),
      ));

  // Patent #30: Quantum Atomic Clock System
  // Register AtomicClockService (foundation for all quantum temporal calculations)
  sl.registerLazySingleton<AtomicClockService>(() => AtomicClockService());

  // Patent #31: Topological Knot Theory for Personality Representation
  // Register Knot Storage Service (must be registered before PersonalityKnotService)
  sl.registerLazySingleton<KnotStorageService>(
    () => KnotStorageService(storageService: sl<StorageService>()),
  );

  // Register Knot Cache Service (for performance optimization)
  sl.registerLazySingleton<KnotCacheService>(
    () => KnotCacheService(),
  );

  // Register Knot Community Service (Phase 3: Onboarding Integration)
  sl.registerLazySingleton<KnotCommunityService>(
    () => KnotCommunityService(
      personalityKnotService: sl<PersonalityKnotService>(),
      knotStorageService: sl<KnotStorageService>(),
      communityService: sl<CommunityService>(),
    ),
  );
  
  // Register Personality Knot Service (core knot generation)
  sl.registerLazySingleton<PersonalityKnotService>(
    () => PersonalityKnotService(),
  );
  
  // Register Entity Knot Service (knots for all entity types)
  sl.registerLazySingleton<EntityKnotService>(
    () => EntityKnotService(
      personalityKnotService: sl<PersonalityKnotService>(),
    ),
  );
  
  // Register Cross-Entity Compatibility Service
  sl.registerLazySingleton<CrossEntityCompatibilityService>(
    () => CrossEntityCompatibilityService(
      knotService: sl<PersonalityKnotService>(),
    ),
  );
  
  // Register Network Cross-Pollination Service
  sl.registerLazySingleton<NetworkCrossPollinationService>(
    () => NetworkCrossPollinationService(
      compatibilityService: sl<CrossEntityCompatibilityService>(),
    ),
  );
  
  // Register Knot Weaving Service (Phase 2: Knot Weaving)
  sl.registerLazySingleton<KnotWeavingService>(
    () => KnotWeavingService(
      personalityKnotService: sl<PersonalityKnotService>(),
    ),
  );
  
  // Register Dynamic Knot Service (Phase 4: Dynamic Knots)
  sl.registerLazySingleton<DynamicKnotService>(
    () => DynamicKnotService(),
  );
  
  // Register Wearable Data Service (Phase 4: Dynamic Knots with Wearables)
  sl.registerLazySingleton<WearableDataService>(
    () => WearableDataService(
      dynamicKnotService: sl<DynamicKnotService>(),
    ),
  );
  
  // Register Knot Fabric Service (Phase 5: Knot Fabric for Community Representation)
  sl.registerLazySingleton<KnotFabricService>(
    () => KnotFabricService(),
  );

  // Register Phase 5.5: Hierarchical Fabric Visualization System
  // Register Prominence Calculator
  sl.registerLazySingleton<ProminenceCalculator>(
    () => ProminenceCalculator(
      atomicClock: sl<AtomicClockService>(),
    ),
  );

  // Register Glue Visualization Service
  sl.registerLazySingleton<GlueVisualizationService>(
    () => GlueVisualizationService(
      compatibilityService: sl<CrossEntityCompatibilityService>(),
    ),
  );

  // Register Hierarchical Layout Service
  sl.registerLazySingleton<HierarchicalLayoutService>(
    () => HierarchicalLayoutService(
      prominenceCalculator: sl<ProminenceCalculator>(),
      compatibilityService: sl<CrossEntityCompatibilityService>(),
    ),
  );

  // Register Integrated Knot Recommendation Engine (Phase 6: Integrated Recommendations)
  sl.registerLazySingleton<IntegratedKnotRecommendationEngine>(
    () => IntegratedKnotRecommendationEngine(
      knotService: sl<PersonalityKnotService>(),
    ),
  );

  // Register Phase 7: Audio & Privacy Services
  // Register Knot Audio Service
  sl.registerLazySingleton<KnotAudioService>(
    () => KnotAudioService(),
  );

  // Register Knot Privacy Service
  sl.registerLazySingleton<KnotPrivacyService>(
    () => KnotPrivacyService(),
  );

  // Register Knot Admin Service (Phase 9: Admin Knot Visualizer)
  sl.registerLazySingleton<KnotAdminService>(
    () => KnotAdminService(
      knotStorageService: sl<KnotStorageService>(),
      knotDataAPI: sl<KnotDataAPI>(),
      knotService: sl<PersonalityKnotService>(),
      adminAuthService: sl<AdminAuthService>(),
    ),
  );

  // Register Knot Data API Service (Phase 8: Data Sale & Research Integration)
  sl.registerLazySingleton<KnotDataAPI>(
    () => KnotDataAPI(
      knotStorageService: sl<KnotStorageService>(),
      privacyService: sl<KnotPrivacyService>(),
    ),
  );

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

  sl.registerLazySingleton(() => PerformanceMonitor(
        storageService: sl<StorageService>(),
        prefs: sl<SharedPreferencesCompat>(),
      ));

  sl.registerLazySingleton(() => SecurityValidator());

  sl.registerLazySingleton(() => DeploymentValidator(
        performanceMonitor: sl<PerformanceMonitor>(),
        securityValidator: sl<SecurityValidator>(),
      ));

  // Supabase Service (kept for internal tooling/debug; app uses spots_network boundary)
  sl.registerLazySingleton(() => SupabaseService());

  // Admin Services (God-Mode Admin System)
  sl.registerLazySingleton(
      () => ConnectionMonitor(prefs: sl<SharedPreferencesCompat>()));
  sl.registerLazySingleton(() => PredictiveAnalytics());
  sl.registerLazySingleton(() => BusinessAccountService());
  sl.registerLazySingleton(
      () => AdminAuthService(sl<SharedPreferencesCompat>()));
  sl.registerLazySingleton(
      () => BusinessAuthService(sl<SharedPreferencesCompat>()));

  // Secure Mapping Encryption Service (for encrypting userId ↔ agentId mappings)
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );
  sl.registerLazySingleton<SecureMappingEncryptionService>(
    () => SecureMappingEncryptionService(
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );

  // Agent ID Migration Service (for migrating plaintext mappings to encrypted)
  sl.registerLazySingleton<AgentIdMigrationService>(
    () => AgentIdMigrationService(
      supabaseService: sl<SupabaseService>(),
      encryptionService: sl<SecureMappingEncryptionService>(),
    ),
  );

  // Agent ID Service (for ai2ai network routing)
  sl.registerLazySingleton(() => AgentIdService(
        encryptionService: sl<SecureMappingEncryptionService>(),
        businessService: sl<BusinessAccountService>(),
      ));

  // Mapping Key Rotation Service (for rotating encryption keys)
  sl.registerLazySingleton<MappingKeyRotationService>(
    () => MappingKeyRotationService(
      supabaseService: sl<SupabaseService>(),
      encryptionService: sl<SecureMappingEncryptionService>(),
      agentIdService: sl<AgentIdService>(),
    ),
  );

  // Onboarding & Agent Creation Services (Phase 1: Foundation)
  // Note: OnboardingAggregationService is registered later (after SupabaseClient)
  // We pass null here and it will be resolved lazily if needed
  sl.registerLazySingleton(() => OnboardingDataService(
        agentIdService: sl<AgentIdService>(),
        onboardingAggregationService: null, // Will be resolved lazily if available
      ));
  sl.registerLazySingleton(() => SocialMediaVibeAnalyzer());
  // Phase 8.5: Onboarding Place List Generator (integrated with Google Places API)
  sl.registerLazySingleton<OnboardingPlaceListGenerator>(
    () => OnboardingPlaceListGenerator(
      placesDataSource: sl<GooglePlacesDataSource>(),
    ),
  );
  // Controllers (Phase 8.11)
  sl.registerLazySingleton(() => OnboardingFlowController(
    onboardingDataService: sl<OnboardingDataService>(),
    agentIdService: sl<AgentIdService>(),
    legalDocumentService: sl<LegalDocumentService>(),
  ));

  // Agent Initialization Controller (Phase 8.11)
  sl.registerLazySingleton(() => AgentInitializationController(
    socialMediaDataController: sl<SocialMediaDataCollectionController>(),
    personalityLearning: sl<PersonalityLearning>(),
    preferencesService: sl<PreferencesProfileService>(),
    placeListGenerator: sl<OnboardingPlaceListGenerator>(),
    recommendationService: sl<OnboardingRecommendationService>(),
    syncService: sl<PersonalitySyncService>(),
    agentIdService: sl<AgentIdService>(),
  ));

  // Event Creation Controller (Phase 8.11)
  sl.registerLazySingleton(() => EventCreationController(
    eventService: sl<ExpertiseEventService>(),
    geographicScopeService: sl<GeographicScopeService>(),
  ));

  // Social Media Data Collection Controller (Phase 8.11)
  sl.registerLazySingleton(() => SocialMediaDataCollectionController(
    socialMediaService: sl<SocialMediaConnectionService>(),
  ));

  // Payment Processing Controller (Phase 8.11)
  sl.registerLazySingleton(() => PaymentProcessingController(
    salesTaxService: sl<SalesTaxService>(),
    paymentEventService: sl<PaymentEventService>(),
  ));

  // AI Recommendation Controller (Phase 8.11)
  sl.registerLazySingleton(() => AIRecommendationController(
        personalityLearning: sl<PersonalityLearning>(),
        preferencesProfileService: sl<PreferencesProfileService>(),
        eventRecommendationService: sl<event_rec_service.EventRecommendationService>(),
        agentIdService: sl<AgentIdService>(),
      ));

  // Sync Controller (Phase 8.11)
  // Register BusinessOnboardingController (Phase 8.11)
  sl.registerLazySingleton(() => BusinessOnboardingController(
        businessAccountService: sl<BusinessAccountService>(),
        sharedAgentService: sl<BusinessSharedAgentService>(),
      ));

  // Register EventAttendanceController (Phase 8.11)
  sl.registerLazySingleton(() => EventAttendanceController(
        eventService: sl<ExpertiseEventService>(),
        paymentController: sl<PaymentProcessingController>(),
        preferencesService: sl<PreferencesProfileService>(),
        agentIdService: sl<AgentIdService>(),
      ));

  // Register ListCreationController (Phase 8.11)
  sl.registerLazySingleton(() => ListCreationController(
        listsRepository: sl<ListsRepository>(),
        atomicClock: sl<AtomicClockService>(),
      ));

  // Register ProfileUpdateController (Phase 8.11)
  sl.registerLazySingleton(() => ProfileUpdateController(
        authRepository: sl<AuthRepository>(),
        atomicClock: sl<AtomicClockService>(),
      ));

  // Register EventCancellationController (Phase 8.11)
  sl.registerLazySingleton(() => EventCancellationController(
        cancellationService: sl<CancellationService>(),
        eventService: sl<ExpertiseEventService>(),
        paymentService: sl<PaymentService>(),
      ));

  // Register PartnershipProposalController (Phase 8.11)
  sl.registerLazySingleton(() => PartnershipProposalController(
        partnershipService: sl<PartnershipService>(),
        businessService: sl<BusinessService>(),
      ));

  // Register CheckoutController (Phase 8.11)
  sl.registerLazySingleton(() => CheckoutController(
        paymentController: sl<PaymentProcessingController>(),
        salesTaxService: sl<SalesTaxService>(),
        legalService: LegalDocumentService(
          eventService: sl<ExpertiseEventService>(),
        ),
        eventService: sl<ExpertiseEventService>(),
      ));

  // Register PartnershipCheckoutController (Phase 8.11)
  sl.registerLazySingleton(() => PartnershipCheckoutController(
        paymentController: sl<PaymentProcessingController>(),
        revenueSplitService: sl<RevenueSplitService>(),
        partnershipService: sl<PartnershipService>(),
        eventService: sl<ExpertiseEventService>(),
        salesTaxService: sl<SalesTaxService>(),
      ));

  // Register SponsorshipCheckoutController (Phase 8.11)
  sl.registerLazySingleton(() => SponsorshipCheckoutController(
        sponsorshipService: sl<SponsorshipService>(),
        eventService: sl<ExpertiseEventService>(),
        productTrackingService: sl<ProductTrackingService>(),
      ));

  sl.registerLazySingleton(() => SyncController(
        connectivityService: sl<EnhancedConnectivityService>(),
        personalitySyncService: sl<PersonalitySyncService>(),
        personalityLearning: sl<PersonalityLearning>(),
      ));

  sl.registerLazySingleton(() => OnboardingRecommendationService(
        agentIdService: sl<AgentIdService>(),
      ));
  // Phase 8.8: PreferencesProfile Service (for preference learning and quantum recommendations)
  sl.registerLazySingleton<PreferencesProfileService>(() => PreferencesProfileService(
    storage: sl<StorageService>(),
  ));

  // Event Recommendation Service (for AI recommendations)
  // Note: EventRecommendationService has optional dependencies with defaults
  // It can be instantiated without explicit dependencies, but we register with DI for consistency
  // Phase 6: Integrated Knot Recommendations - Added knot services integration
  sl.registerLazySingleton<event_rec_service.EventRecommendationService>(
    () => event_rec_service.EventRecommendationService(
      eventService: sl<ExpertiseEventService>(),
      knotRecommendationEngine: sl<IntegratedKnotRecommendationEngine>(),
      personalityLearning: sl<PersonalityLearning>(),
    ),
  );
  
  // Event Matching Service (for event matching signals)
  // Phase 6: Integrated Knot Recommendations - Added knot services integration
  sl.registerLazySingleton<EventMatchingService>(
    () => EventMatchingService(
      knotRecommendationEngine: sl<IntegratedKnotRecommendationEngine>(),
      personalityLearning: sl<PersonalityLearning>(),
    ),
  );
  
  // Spot Vibe Matching Service (for spot-user vibe matching)
  // Phase 6: Integrated Knot Recommendations - Added knot services integration
  sl.registerLazySingleton<SpotVibeMatchingService>(
    () => SpotVibeMatchingService(
      vibeAnalyzer: sl<UserVibeAnalyzer>(),
      crossEntityCompatibilityService: sl<CrossEntityCompatibilityService>(),
      entityKnotService: sl<EntityKnotService>(),
      personalityKnotService: sl<PersonalityKnotService>(),
    ),
  );
  
  // OAuth Deep Link Handler (Phase 8.2: OAuth Implementation)
  sl.registerLazySingleton<OAuthDeepLinkHandler>(
    () => OAuthDeepLinkHandler(),
  );

  // Social Media Connection Service (Phase 8.2: Social Media Data Collection)
  // Note: SocialMediaConnectionService is registered before SocialMediaInsightService
  // to avoid circular dependency. SocialMediaInsightService depends on SocialMediaConnectionService,
  // but SocialMediaConnectionService can optionally use SocialMediaInsightService via lazy injection.
  sl.registerLazySingleton<SocialMediaConnectionService>(
    () => SocialMediaConnectionService(
      sl<StorageService>(),
      sl<AgentIdService>(),
      sl<OAuthDeepLinkHandler>(),
    ),
  );

  // Social Media Insight Service (Phase 10: Personality Learning Integration)
  sl.registerLazySingleton<SocialMediaInsightService>(
    () => SocialMediaInsightService(
      storageService: sl<StorageService>(),
      connectionService: sl<SocialMediaConnectionService>(),
      vibeAnalyzer: sl<SocialMediaVibeAnalyzer>(),
      atomicClock: sl<AtomicClockService>(),
    ),
  );

  // Social Media Sharing Service (Phase 10: Sharing System)
  sl.registerLazySingleton<SocialMediaSharingService>(
    () => SocialMediaSharingService(
      connectionService: sl<SocialMediaConnectionService>(),
    ),
  );

  // Social Media Discovery Service (Phase 10: Friend Discovery)
  sl.registerLazySingleton<SocialMediaDiscoveryService>(
    () => SocialMediaDiscoveryService(
      storageService: sl<StorageService>(),
      connectionService: sl<SocialMediaConnectionService>(),
      supabaseService: sl<SupabaseService>(),
    ),
  );

  // Public Profile Analysis Service (Phase 10: User-Provided Handles)
  sl.registerLazySingleton<PublicProfileAnalysisService>(
    () => PublicProfileAnalysisService(
      storageService: sl<StorageService>(),
      vibeAnalyzer: sl<SocialMediaVibeAnalyzer>(),
      insightService: sl<SocialMediaInsightService>(),
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

  // Section 19.8: User Journey Tracking Service
  sl.registerLazySingleton<UserJourneyTrackingService>(
    () => UserJourneyTrackingService(
      atomicClock: sl<AtomicClockService>(),
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
      meaningfulConnectionMetricsService: sl<MeaningfulConnectionMetricsService>(),
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

  // Message Encryption Service (Phase 14.4: Signal Protocol Integration)
  // Uses HybridEncryptionService which tries Signal Protocol first, falls back to AES-256-GCM
  sl.registerLazySingleton<MessageEncryptionService>(
    () {
      // Get Signal Protocol service (may not be initialized yet)
      final signalProtocolService = sl<SignalProtocolService>();
      
      // Get services needed for agent ID resolution
      final agentIdService = sl<AgentIdService>();
      final supabaseService = sl<SupabaseService>();
      
      // Create Signal Protocol Encryption Service (will be used if Signal Protocol is available)
      // Agent ID is resolved lazily from the current authenticated user
      SignalProtocolEncryptionService? signalProtocolEncryptionService;
      try {
        signalProtocolEncryptionService = SignalProtocolEncryptionService(
          signalProtocol: signalProtocolService,
          agentIdService: agentIdService,
          supabaseService: supabaseService,
        );
      } catch (e) {
        logger.warn('⚠️ [DI] Signal Protocol Encryption Service creation failed: $e');
        signalProtocolEncryptionService = null;
      }
      
      // Create hybrid service that tries Signal Protocol first, falls back to AES-256-GCM
      return HybridEncryptionService(
        signalProtocolService: signalProtocolEncryptionService,
      );
    },
  );

  // Phase 3: Unified Chat Services
  sl.registerLazySingleton(() => UserNameResolutionService());
  sl.registerLazySingleton(() => PersonalityAgentChatService(
        llmService: sl<LLMService>(),
        encryptionService: sl<MessageEncryptionService>(),
        agentIdService: sl<AgentIdService>(),
        personalityLearning: sl<PersonalityLearning>(),
        searchRepository: sl<HybridSearchRepository>(),
      ));
  sl.registerLazySingleton(() => FriendChatService(
        encryptionService: sl<MessageEncryptionService>(),
      ));
  sl.registerLazySingleton(() => CommunityChatService(
        encryptionService: sl<MessageEncryptionService>(),
      ));
  
  // Community Service (for community chat member lists)
  // Phase 5: Knot Fabric Integration - Add optional knot fabric services
  sl.registerLazySingleton(() => CommunityService(
        expansionService: GeographicExpansionService(),
        knotFabricService: sl<KnotFabricService>(),
        knotStorageService: sl<KnotStorageService>(),
      ));

  // Anonymous Communication Protocol (Phase 14: Signal Protocol ready)
  sl.registerLazySingleton(() => ai2ai.AnonymousCommunicationProtocol(
    encryptionService: sl<MessageEncryptionService>(),
    supabase: sl<SupabaseClient>(),
    atomicClock: sl<AtomicClockService>(),
    anonymizationService: sl<UserAnonymizationService>(),
  ));

  // Business-Expert Chat Service (AI2AI routing)
  sl.registerLazySingleton(() => BusinessExpertChatServiceAI2AI(
        ai2aiProtocol: sl<ai2ai.AnonymousCommunicationProtocol>(),
        encryptionService: sl<MessageEncryptionService>(),
        businessService: sl<BusinessAccountService>(),
        agentIdService: sl<AgentIdService>(),
      ));

  // Business-Business Chat Service (AI2AI routing)
  sl.registerLazySingleton(() => BusinessBusinessChatServiceAI2AI(
        ai2aiProtocol: sl<ai2ai.AnonymousCommunicationProtocol>(),
        encryptionService: sl<MessageEncryptionService>(),
        businessService: sl<BusinessAccountService>(),
        agentIdService: sl<AgentIdService>(),
      ));

  // Business-Expert Outreach Service (vibe-based matching)
  sl.registerLazySingleton(() => BusinessExpertOutreachService(
        partnershipService: sl<PartnershipService>(),
        chatService: sl<BusinessExpertChatServiceAI2AI>(),
      ));

  // Business-Business Outreach Service (partnership discovery)
  sl.registerLazySingleton(() => BusinessBusinessOutreachService(
        partnershipService: sl<PartnershipService>(),
        businessService: sl<BusinessAccountService>(),
        chatService: sl<BusinessBusinessChatServiceAI2AI>(),
      ));
  
  // Business Member Service (multi-user support)
  sl.registerLazySingleton(() => BusinessMemberService(
        businessAccountService: sl<BusinessAccountService>(),
      ));
  
  // Business Shared Agent Service (neural network of agents)
  sl.registerLazySingleton(() => BusinessSharedAgentService(
        businessAccountService: sl<BusinessAccountService>(),
        memberService: sl<BusinessMemberService>(),
        personalityLearning: sl<PersonalityLearning>(),
      ));
  sl.registerLazySingleton(() => AdminCommunicationService(
        connectionMonitor: sl<ConnectionMonitor>(),
        chatAnalyzer: null, // Optional - can be registered later if needed
      ));
  sl.registerLazySingleton(() => AdminGodModeService(
        authService: sl<AdminAuthService>(),
        communicationService: sl<AdminCommunicationService>(),
        businessService: sl<BusinessAccountService>(),
        predictiveAnalytics: sl<PredictiveAnalytics>(),
        connectionMonitor: sl<ConnectionMonitor>(),
        chatAnalyzer: null, // Optional - can be registered later if needed
        supabaseService: sl<SupabaseService>(),
        expertiseService: ExpertiseService(),
      ));

  // Payment Processing Services - Agent 1: Payment Processing & Revenue
  // Register StripeConfig first (using test config for now)
  sl.registerLazySingleton<StripeConfig>(() => StripeConfig.test());

  // Register StripeService with StripeConfig
  sl.registerLazySingleton<StripeService>(
      () => StripeService(sl<StripeConfig>()));

  // Register ExpertiseEventService (if not already registered)
  if (!sl.isRegistered<ExpertiseEventService>()) {
    sl.registerLazySingleton<ExpertiseEventService>(
        () => ExpertiseEventService());
  }

  // Register PaymentService with StripeService and ExpertiseEventService
  sl.registerLazySingleton<PaymentService>(() => PaymentService(
        sl<StripeService>(),
        sl<ExpertiseEventService>(),
      ));

  // Register PaymentEventService (bridge between payment and event services)
  sl.registerLazySingleton<PaymentEventService>(() => PaymentEventService(
        sl<PaymentService>(),
        sl<ExpertiseEventService>(),
      ));

  // Register SalesTaxService (for tax calculation on events)
  sl.registerLazySingleton<SalesTaxService>(() => SalesTaxService(
        eventService: sl<ExpertiseEventService>(),
        paymentService: sl<PaymentService>(),
      ));

  // Register BusinessService (required by PartnershipService)
  if (!sl.isRegistered<BusinessService>()) {
    sl.registerLazySingleton<BusinessService>(() => BusinessService(
          accountService: sl<BusinessAccountService>(),
        ));
  }

  // Register PartnershipService (required by RevenueSplitService)
  sl.registerLazySingleton<PartnershipService>(() => PartnershipService(
        eventService: sl<ExpertiseEventService>(),
        businessService: sl<BusinessService>(),
      ));

  // Register SponsorshipService (required by ProductTrackingService and BrandAnalyticsService)
  sl.registerLazySingleton(() => SponsorshipService(
        eventService: sl<ExpertiseEventService>(),
        partnershipService: sl<PartnershipService>(),
        businessService: sl<BusinessService>(),
      ));

  // Register RevenueSplitService (required by PayoutService)
  sl.registerLazySingleton<RevenueSplitService>(() => RevenueSplitService(
        partnershipService: sl<PartnershipService>(),
        sponsorshipService: sl<SponsorshipService>(),
      ));

  // Register PayoutService
  sl.registerLazySingleton<PayoutService>(() => PayoutService(
        revenueSplitService: sl<RevenueSplitService>(),
      ));

  // Register RefundService (required by CancellationService)
  sl.registerLazySingleton<RefundService>(() => RefundService(
        paymentService: sl<PaymentService>(),
        stripeService: sl<StripeService>(),
      ));

  // Register CancellationService (required by EventCancellationController)
  sl.registerLazySingleton<CancellationService>(() => CancellationService(
        paymentService: sl<PaymentService>(),
        eventService: sl<ExpertiseEventService>(),
        refundService: sl<RefundService>(),
      ));

  // Product Tracking & Sales Services (required by BrandAnalyticsService)
  sl.registerLazySingleton(() => ProductTrackingService(
        sponsorshipService: sl<SponsorshipService>(),
        revenueSplitService: sl<RevenueSplitService>(),
      ));

  sl.registerLazySingleton(() => ProductSalesService(
        productTrackingService: sl<ProductTrackingService>(),
        revenueSplitService: sl<RevenueSplitService>(),
        paymentService: sl<PaymentService>(),
      ));

  // Brand Analytics Service
  sl.registerLazySingleton(() => BrandAnalyticsService(
        sponsorshipService: sl<SponsorshipService>(),
        productTrackingService: sl<ProductTrackingService>(),
        productSalesService: sl<ProductSalesService>(),
        revenueSplitService: sl<RevenueSplitService>(),
      ));

  // Brand Discovery Service
  sl.registerLazySingleton(() => BrandDiscoveryService(
        eventService: sl<ExpertiseEventService>(),
        sponsorshipService: sl<SponsorshipService>(),
      ));

  // Security & Anonymization Services (Phase 7.3.5-6)
  sl.registerLazySingleton<LocationObfuscationService>(
      () => LocationObfuscationService());
  sl.registerLazySingleton<UserAnonymizationService>(
      () => UserAnonymizationService(
            locationObfuscationService: sl<LocationObfuscationService>(),
          ));
  sl.registerLazySingleton<FieldEncryptionService>(
      () => FieldEncryptionService());
  sl.registerLazySingleton<AuditLogService>(() => AuditLogService());

  // Legal Document Service (for Terms of Service and Privacy Policy acceptance)
  sl.registerLazySingleton<LegalDocumentService>(() => LegalDocumentService(
        eventService: sl<ExpertiseEventService>(),
      ));

  sl.registerLazySingleton<DeviceDiscoveryService>(() {
    final platform = DeviceDiscoveryFactory.createPlatformDiscovery();
    return DeviceDiscoveryService(platform: platform);
  });

  // Personality Advertising Service
  sl.registerLazySingleton<PersonalityAdvertisingService>(() {
    // PersonalityAdvertisingService handles platform-specific discovery internally
    // No need to pass platform discovery objects - service will use factory when needed
    // Pass UserAnonymizationService for UnifiedUser to AnonymousUser conversion
    final anonymizationService = sl<UserAnonymizationService>();
    return PersonalityAdvertisingService(
      anonymizationService: anonymizationService,
    );
  });

  // PersonalityLearning (Philosophy: "Always Learning With You")
  // On-device AI learning that works offline
  sl.registerLazySingleton(() {
    final prefs = sl<SharedPreferencesCompat>();
    // SharedPreferencesCompat implements SharedPreferences interface
    return PersonalityLearning.withPrefs(prefs);
  });

  // AI2AI Learning Service (Phase 7, Week 38)
  // Wrapper service for AI2AI learning methods UI
  sl.registerLazySingleton(() {
    final prefs = sl<SharedPreferencesCompat>();
    final personalityLearning = sl<PersonalityLearning>();
    return AI2AILearning.create(
      prefs: prefs,
      personalityLearning: personalityLearning,
    );
  });

  // UserFeedbackAnalyzer (Philosophy: "Dynamic dimension discovery through user feedback analysis")
  // Advanced feedback learning system that extracts implicit personality dimensions
  // Enhanced with Quantum Satisfaction Enhancement (Phase 4.1)
  sl.registerLazySingleton(() {
    final prefs = sl<SharedPreferencesCompat>();
    final personalityLearning = sl<PersonalityLearning>();
    final quantumSatisfactionEnhancer = sl<QuantumSatisfactionEnhancer>();
    final atomicClock = sl<AtomicClockService>();
    // SharedPreferencesCompat implements SharedPreferences interface
    return UserFeedbackAnalyzer(
      prefs: prefs,
      personalityLearning: personalityLearning,
      quantumSatisfactionEnhancer: quantumSatisfactionEnhancer,
      atomicClock: atomicClock,
    );
  });

  // NLPProcessor (Natural Language Processing for text analysis)
  // Provides sentiment analysis, search intent detection, content moderation, and privacy preservation
  sl.registerLazySingleton(() => NLPProcessor());

  // PersonalitySyncService (Philosophy: "Cloud sync is optional and encrypted")
  // Secure cross-device personality profile sync with password-derived encryption
  sl.registerLazySingleton(() {
    final supabaseService = sl<SupabaseService>();
    return PersonalitySyncService(supabaseService: supabaseService);
  });

  // UsagePatternTracker (Philosophy: "The key adapts to YOUR usage")
  // Tracks how users engage with SPOTS (community vs recommendations)
  sl.registerLazySingleton(() {
    final prefs = sl<SharedPreferencesCompat>();
    return UsagePatternTracker(prefs);
  });

  // AI2AI Protocol (Philosophy: "The Key Works Everywhere")
  // Handles peer-to-peer AI2AI communication
  // Phase 14: Updated to use MessageEncryptionService (Signal Protocol ready)
  sl.registerLazySingleton(() => AI2AIProtocol(
    encryptionService: sl<MessageEncryptionService>(),
    anonymizationService: sl<UserAnonymizationService>(),
  ));

  // Connection Log Queue (Philosophy: "Cloud is optional enhancement")
  // Queues AI2AI logs for cloud sync when online
  sl.registerLazySingleton(
      () => ConnectionLogQueue(sl<SharedPreferencesCompat>()));

  // Cloud Intelligence Sync (Philosophy: "Cloud adds network wisdom")
  // Syncs offline connections to cloud for collective learning
  sl.registerLazySingleton(() => CloudIntelligenceSync(
        queue: sl<ConnectionLogQueue>(),
        connectivity: sl<Connectivity>(),
      ));

  // VibeConnectionOrchestrator + AI2AIRealtimeService wiring
  // Philosophy: "The Key Works Everywhere" - offline AI2AI via PersonalityLearning
  sl.registerLazySingleton<VibeConnectionOrchestrator>(() {
    final connectivity = sl<Connectivity>();
    final vibeAnalyzer = sl<UserVibeAnalyzer>();
    final deviceDiscovery = sl<DeviceDiscoveryService>();
    final advertisingService = sl<PersonalityAdvertisingService>();
    final personalityLearning = sl<PersonalityLearning>();
    final ai2aiProtocol = sl<AI2AIProtocol>();

    final orchestrator = VibeConnectionOrchestrator(
      vibeAnalyzer: vibeAnalyzer,
      connectivity: connectivity,
      deviceDiscovery: deviceDiscovery,
      advertisingService: advertisingService,
      personalityLearning: personalityLearning, // NEW: For offline AI learning
      protocol: ai2aiProtocol, // Now passed to ConnectionManager
    );
    // Build realtime with orchestrator and register it for app-wide access
    final realtimeBackend = sl<RealtimeBackend>();
    final realtime = AI2AIRealtimeService(realtimeBackend, orchestrator);
    orchestrator.setRealtimeService(realtime);
    // Expose realtime service via DI for UI pages/debug tools
    if (!sl.isRegistered<AI2AIRealtimeService>()) {
      sl.registerSingleton<AI2AIRealtimeService>(realtime);
    }
    return orchestrator;
  });

  // HTTP Client (shared across datasources)
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Logger
  sl.registerLazySingleton<AppLogger>(
      () => const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug));

  // AI Improvement Tracking Service
  sl.registerLazySingleton(() {
    final storageService = sl<StorageService>();
    return AIImprovementTrackingService(storage: storageService.defaultStorage);
  });

  // Action History Service
  sl.registerLazySingleton(() {
    final storageService = sl<StorageService>();
    return ActionHistoryService(storage: storageService.defaultStorage);
  });

  // Contextual Personality Service
  // Philosophy: "Your doors stay yours" - resist homogenization while allowing authentic transformation
  sl.registerLazySingleton(() => ContextualPersonalityService());

  // Enhanced Connectivity Service
  // Optional Enhancement: Goes beyond basic WiFi/mobile connectivity to verify actual internet access
  sl.registerLazySingleton(() {
    final httpClient = sl<http.Client>();
    return EnhancedConnectivityService(httpClient: httpClient);
  });

  // Federated Learning System
  sl.registerLazySingleton<FederatedLearningSystem>(() {
    final storageService = sl<StorageService>();
    return FederatedLearningSystem(storage: storageService.defaultStorage);
  });

  // Continuous Learning System
  // Phase 7, Section 39 (7.4.1): Continuous Learning UI
  // Singleton instance shared across app - pages should use this, not create their own
  // Phase 11 Section 8: Learning Quality Monitoring - Add agentIdService for persistence
  sl.registerLazySingleton<ContinuousLearningSystem>(() {
    final agentIdService = sl<AgentIdService>();
    return ContinuousLearningSystem(
      agentIdService: agentIdService,
    );
  });

  // Phase 11: User-AI Interaction Update - Section 1.1
  // Event Queue (offline-capable event queuing)
  sl.registerLazySingleton(() {
    return EventQueue();
  });

  // Event Logger (context-enriched event logging)
  sl.registerLazySingleton(() {
    final agentIdService = sl<AgentIdService>();
    final supabaseService = sl<SupabaseService>();
    final eventQueue = sl<EventQueue>();
    final learningSystem = sl<ContinuousLearningSystem>();
    return EventLogger(
      agentIdService: agentIdService,
      supabaseService: supabaseService,
      eventQueue: eventQueue,
      learningSystem: learningSystem,
    );
  });
  
  // Structured Facts Extractor (Phase 11 Section 5: Retrieval + LLM Fusion)
  sl.registerLazySingleton(() => StructuredFactsExtractor());
  logger.debug('✅ [DI] StructuredFactsExtractor registered');

  // P2P Node Manager
  // OUR_GUTS.md: "Decentralized community networks with privacy protection"
  // Manages P2P nodes for university/company private networks
  sl.registerLazySingleton(() => P2PNodeManager());

  // Config (must be registered before InferenceOrchestrator)
  sl.registerLazySingleton<ConfigService>(() => ConfigService(
        environment: 'development',
        supabaseUrl: SupabaseConfig.url,
        supabaseAnonKey: SupabaseConfig.anonKey,
        googlePlacesApiKey: GooglePlacesConfig.getApiKey(),
        debug: SupabaseConfig.debug,
        // Phase 11: Re-enable ONNX for device-first inference
        inferenceBackend: 'onnx',
        orchestrationStrategy: 'device_first',
      ));

  // ONNX Dimension Scorer (Phase 11: Layered Inference Path)
  // Optional service - provides fast, privacy-sensitive dimension scoring
  sl.registerLazySingleton<OnnxDimensionScorer>(() => OnnxDimensionScorer());

  // Inference Orchestrator (Phase 11: Layered Inference Path)
  // Device-first: ONNX for dimension scoring, Gemini for complex reasoning
  sl.registerLazySingleton(() {
    final config = sl<ConfigService>();
    final llmService = sl<LLMService>();
    final onnxScorer = sl<OnnxDimensionScorer>();
    return InferenceOrchestrator(
      onnxScorer: onnxScorer,
      llmService: llmService,
      config: config,
    );
  });
  
  // Decision Coordinator (Phase 11 Section 6: Decision Fabric)
  // Chooses optimal inference pathway based on context
  sl.registerLazySingleton(() {
    final orchestrator = sl<InferenceOrchestrator>();
    final config = sl<ConfigService>();
    return DecisionCoordinator(
      orchestrator: orchestrator,
      config: config,
    );
  });
  logger.debug('✅ [DI] DecisionCoordinator registered');

  // Embedding Delta Collector (Phase 11 Section 7: Federated Learning Hooks)
  sl.registerLazySingleton(() => EmbeddingDeltaCollector());
  logger.debug('✅ [DI] EmbeddingDeltaCollector registered');

  // Federated Learning Hooks (Phase 11 Section 7: Federated Learning Hooks)
  sl.registerLazySingleton(() {
    final deltaCollector = sl<EmbeddingDeltaCollector>();
    return FederatedLearningHooks(
      deltaCollector: deltaCollector,
    );
  });
  logger.debug('✅ [DI] FederatedLearningHooks registered');

  // Backend (Single Integration Boundary): initialize and expose spots_network
  try {
    logger.info('🔌 [DI] Initializing Supabase backend...');

    if (!SupabaseConfig.isValid) {
      logger
          .warn('⚠️ [DI] SupabaseConfig is invalid. URL or anonKey is empty.');
      logger.warn(
          '⚠️ [DI] Make sure to run with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...');
      throw Exception('Supabase configuration is invalid');
    }

    final backend = await BackendFactory.create(
      BackendConfig.supabase(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        serviceRoleKey: SupabaseConfig.serviceRoleKey.isNotEmpty
            ? SupabaseConfig.serviceRoleKey
            : null,
        name: 'Supabase',
        isDefault: true,
      ),
    );
    logger.info('✅ [DI] Supabase backend created successfully');

    // Expose the unified backend and its components
    logger.debug('📝 [DI] Registering backend components...');
    sl.registerSingleton<BackendInterface>(backend);
    sl.registerLazySingleton<AuthBackend>(() => backend.auth);
    sl.registerLazySingleton<DataBackend>(() => backend.data);
    sl.registerLazySingleton<RealtimeBackend>(() => backend.realtime);
    logger.debug('✅ [DI] Backend components registered');

    // Register Supabase Client for LLM service
    try {
      logger.debug('🤖 [DI] Registering LLM service...');
      // Only register if Supabase is initialized
      try {
        final supabaseClient = Supabase.instance.client;
        sl.registerLazySingleton<SupabaseClient>(() => supabaseClient);

        // Register Edge Function Service (Phase 11 Section 4: Edge Mesh Functions)
        sl.registerLazySingleton(() => EdgeFunctionService(
          client: supabaseClient,
        ));
        logger.debug('✅ [DI] EdgeFunctionService registered');

        // Register Onboarding Aggregation Service (Phase 11 Section 4: Edge Mesh Functions)
        sl.registerLazySingleton(() => OnboardingAggregationService(
          edgeFunctionService: sl<EdgeFunctionService>(),
          agentIdService: sl<AgentIdService>(),
        ));
        logger.debug('✅ [DI] OnboardingAggregationService registered');

        // Register Social Enrichment Service (Phase 11 Section 4: Edge Mesh Functions)
        sl.registerLazySingleton(() => SocialEnrichmentService(
          edgeFunctionService: sl<EdgeFunctionService>(),
          agentIdService: sl<AgentIdService>(),
        ));
        logger.debug('✅ [DI] SocialEnrichmentService registered');
        
        // Register FactsIndex (Phase 11 Section 5: Retrieval + LLM Fusion)
        // Requires SupabaseClient to be available
        sl.registerLazySingleton(() => FactsIndex(
              supabase: supabaseClient,
              agentIdService: sl<AgentIdService>(),
            ));
        logger.debug('✅ [DI] FactsIndex registered');

        // Register Calling Score Data Collector (Phase 12 Section 1: Foundation & Data Collection)
        // Note: Register BehaviorAssessmentService first (if not already registered)
        if (!sl.isRegistered<BehaviorAssessmentService>()) {
          sl.registerLazySingleton<BehaviorAssessmentService>(() => BehaviorAssessmentService());
          logger.debug('✅ [DI] BehaviorAssessmentService registered');
        }
        
        // Register Calling Score Data Collector
        sl.registerLazySingleton(() => CallingScoreDataCollector(
          supabase: supabaseClient,
          agentIdService: sl<AgentIdService>(),
          enabled: true, // Enable data collection for neural network training
        ));
        logger.debug('✅ [DI] CallingScoreDataCollector registered');
        
        // Register Calling Score Baseline Metrics (Phase 12 Section 1.2: Baseline Metrics)
        sl.registerLazySingleton(() => CallingScoreBaselineMetrics(
          supabase: supabaseClient,
        ));
        logger.debug('✅ [DI] CallingScoreBaselineMetrics registered');
        
        // Register Calling Score Neural Model (Phase 12 Section 2.1: Calling Score Prediction Model)
        // Register ModelVersionManager (Phase 12 Section 3.2.2: Model Versioning)
        sl.registerLazySingleton(() => ModelVersionManager());
        logger.debug('✅ [DI] ModelVersionManager registered');
        
        // Register ModelRetrainingService (Phase 12 Section 3.2.1: Backend Integration)
        sl.registerLazySingleton(() => ModelRetrainingService(
          versionManager: sl<ModelVersionManager>(),
        ));
        logger.debug('✅ [DI] ModelRetrainingService registered');
        
        // Register OnlineLearningService (Phase 12 Section 3.2.1: Continuous Learning)
        sl.registerLazySingleton(() => OnlineLearningService(
          supabase: supabaseClient,
          dataCollector: sl<CallingScoreDataCollector>(),
          versionManager: sl<ModelVersionManager>(),
          retrainingService: sl<ModelRetrainingService>(),
        ));
        logger.debug('✅ [DI] OnlineLearningService registered');
        
        sl.registerLazySingleton(() => CallingScoreNeuralModel());
        logger.debug('✅ [DI] CallingScoreNeuralModel registered');
        
        // Register Calling Score Training Data Preparer (Phase 12 Section 2.1)
        sl.registerLazySingleton(() => CallingScoreTrainingDataPreparer(
          supabase: supabaseClient,
          agentIdService: sl<AgentIdService>(),
          neuralModel: sl<CallingScoreNeuralModel>(),
        ));
        logger.debug('✅ [DI] CallingScoreTrainingDataPreparer registered');
        
        // Register Calling Score A/B Testing Service (Phase 12 Section 2.3: A/B Testing Framework)
        sl.registerLazySingleton(() => CallingScoreABTestingService(
          supabase: supabaseClient,
          agentIdService: sl<AgentIdService>(),
        ));
        logger.debug('✅ [DI] CallingScoreABTestingService registered');
        
        // Register Outcome Prediction Model (Phase 12 Section 3.1: Outcome Prediction Model)
        sl.registerLazySingleton(() => OutcomePredictionModel());
        logger.debug('✅ [DI] OutcomePredictionModel registered');
        
        // Register Outcome Prediction Service (Phase 12 Section 3.1: Outcome Prediction Model)
        sl.registerLazySingleton(() => OutcomePredictionService(
          model: sl<OutcomePredictionModel>(),
          supabase: supabaseClient,
          dataCollector: sl<CallingScoreDataCollector>(),
        ));
        logger.debug('✅ [DI] OutcomePredictionService registered');
        
        // Register Calling Score Calculator (Phase 12: Neural Network Implementation)
        // Phase 12 Section 2.2: Hybrid calling score calculation
        // Phase 12 Section 2.3: A/B testing integration
        // Phase 12 Section 3.1: Outcome prediction integration
        sl.registerLazySingleton(() => CallingScoreCalculator(
          behaviorAssessment: sl<BehaviorAssessmentService>(),
          dataCollector: sl<CallingScoreDataCollector>(),
          neuralModel: sl<CallingScoreNeuralModel>(), // Optional: Hybrid calculation
          abTestingService: sl<CallingScoreABTestingService>(), // Optional: A/B testing
          outcomePredictionService: sl<OutcomePredictionService>(), // Optional: Outcome prediction
        ));
        logger.debug('✅ [DI] CallingScoreCalculator registered (with neural model, A/B testing, and outcome prediction support)');
        
        // Register Signal Protocol Services (Phase 14: Signal Protocol Implementation - Option 1)
        sl.registerLazySingleton(() => SignalFFIBindings());
        logger.debug('✅ [DI] SignalFFIBindings registered');
        
        // Register Platform Bridge Bindings (Phase 14: Platform Bridge)
        // Must be registered before Rust Wrapper and Store Callbacks
        sl.registerLazySingleton(() => SignalPlatformBridgeBindings());
        logger.debug('✅ [DI] SignalPlatformBridgeBindings registered');
        
        // Register Rust Wrapper Bindings (Phase 14: Rust Wrapper)
        // Must be registered before Store Callbacks
        sl.registerLazySingleton(() => SignalRustWrapperBindings());
        logger.debug('✅ [DI] SignalRustWrapperBindings registered');
        
        sl.registerLazySingleton(() => SignalKeyManager(
          secureStorage: sl<FlutterSecureStorage>(),
          ffiBindings: sl<SignalFFIBindings>(),
          supabaseService: sl<SupabaseService>(),
        ));
        logger.debug('✅ [DI] SignalKeyManager registered');
        
        sl.registerLazySingleton(() => SignalSessionManager(
          database: sl<Database>(),
          ffiBindings: sl<SignalFFIBindings>(),
          keyManager: sl<SignalKeyManager>(),
        ));
        logger.debug('✅ [DI] SignalSessionManager registered');
        
        // Register Store Callbacks (Phase 14: Store Callbacks)
        // Requires Platform Bridge and Rust Wrapper
        sl.registerLazySingleton(() => SignalFFIStoreCallbacks(
          keyManager: sl<SignalKeyManager>(),
          sessionManager: sl<SignalSessionManager>(),
          ffiBindings: sl<SignalFFIBindings>(),
          rustWrapper: sl<SignalRustWrapperBindings>(),
          platformBridge: sl<SignalPlatformBridgeBindings>(),
        ));
        logger.debug('✅ [DI] SignalFFIStoreCallbacks registered');
        
        sl.registerLazySingleton(() => SignalProtocolService(
          ffiBindings: sl<SignalFFIBindings>(),
          storeCallbacks: sl<SignalFFIStoreCallbacks>(),
          keyManager: sl<SignalKeyManager>(),
          sessionManager: sl<SignalSessionManager>(),
          atomicClock: sl<AtomicClockService>(),
        ));
        logger.debug('✅ [DI] SignalProtocolService registered');
        
        // Register Signal Protocol Initialization Service (Phase 14)
        // Pass dependencies for proper initialization sequence
        sl.registerLazySingleton(() => SignalProtocolInitializationService(
          signalProtocol: sl<SignalProtocolService>(),
          platformBridge: sl<SignalPlatformBridgeBindings>(),
          rustWrapper: sl<SignalRustWrapperBindings>(),
          storeCallbacks: sl<SignalFFIStoreCallbacks>(),
        ));
        logger.debug('✅ [DI] SignalProtocolInitializationService registered');

        // Register Reservation Services (Phase 15: Reservation System with Quantum Integration)
        // Phase 15 Section 15.1: Foundation - Quantum Integration
        sl.registerLazySingleton(() => ReservationQuantumService(
          atomicClock: sl<AtomicClockService>(),
          quantumVibeEngine: sl<QuantumVibeEngine>(),
          vibeAnalyzer: sl<UserVibeAnalyzer>(),
          personalityLearning: sl<PersonalityLearning>(),
          locationTimingService: sl<LocationTimingQuantumStateService>(),
          entanglementService: sl<QuantumEntanglementService>(), // Optional, graceful degradation
        ));
        logger.debug('✅ [DI] ReservationQuantumService registered');

        sl.registerLazySingleton(() => ReservationService(
          atomicClock: sl<AtomicClockService>(),
          quantumService: sl<ReservationQuantumService>(),
          agentIdService: sl<AgentIdService>(),
          storageService: sl<StorageService>(),
          supabaseService: sl<SupabaseService>(),
        ));
        logger.debug('✅ [DI] ReservationService registered');

        sl.registerLazySingleton(() => ReservationRecommendationService(
          quantumService: sl<ReservationQuantumService>(),
          atomicClock: sl<AtomicClockService>(),
          entanglementService: sl<QuantumEntanglementService>(), // Optional, graceful degradation
          eventService: sl<ExpertiseEventService>(),
          agentIdService: sl<AgentIdService>(),
        ));
        logger.debug('✅ [DI] ReservationRecommendationService registered');

        // Register LLM Service (Google Gemini) with connectivity check
        sl.registerLazySingleton<LLMService>(() => LLMService(
              supabaseClient,
              connectivity: sl<Connectivity>(),
            ));
        logger.debug('✅ [DI] LLM service registered');
      } catch (e) {
        logger.warn(
            '⚠️ [DI] Supabase not initialized, skipping LLM service registration');
      }
    } catch (e, stackTrace) {
      logger.warn('⚠️ [DI] LLM service registration failed (optional): $e');
      logger.debug('Stack trace: $stackTrace');
      // LLM service optional - app can work without it
    }
  } catch (e, stackTrace) {
    logger.error('❌ [DI] Backend initialization failed', error: e);
    logger.debug('Stack trace: $stackTrace');
    // Continue without backend on web if initialization fails
  }

  logger.info('✅ [DI] Dependency injection initialization complete');

  // ===========================
  // Cloud Embeddings (Simplified - No ONNX)
  // ===========================
  // Note: Embeddings are now cloud-only via Supabase Edge Function
  // ONNX infrastructure removed - use Gemini/cloud embeddings instead
  try {
    // Only register if Supabase is initialized
    try {
      final supabaseClient = Supabase.instance.client;
      sl.registerLazySingleton<EmbeddingCloudClient>(
          () => EmbeddingCloudClient(client: supabaseClient));
    } catch (_) {
      logger.warn(
          '⚠️ [DI] Supabase not initialized, skipping EmbeddingCloudClient registration');
    }
  } catch (_) {
    // Embeddings optional - app works without them
  }

  // Blocs (Register last, after all dependencies)
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        updatePasswordUseCase: sl(),
      ));

  sl.registerFactory(() => SpotsBloc(
        getSpotsUseCase: sl(),
        getSpotsFromRespectedListsUseCase: sl(),
        createSpotUseCase: sl(),
        updateSpotUseCase: sl(),
        deleteSpotUseCase: sl(),
      ));

  sl.registerFactory(() => ListsBloc(
        getListsUseCase: sl(),
        createListUseCase: sl(),
        updateListUseCase: sl(),
        deleteListUseCase: sl(),
      ));

  // Hybrid Search Bloc (Phase 2)
  sl.registerFactory(() => HybridSearchBloc(
        hybridSearchUseCase: sl(),
        cacheService: sl(),
        suggestionsService: sl(),
      ));
}

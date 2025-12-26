import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
import 'package:spots/core/services/business_expert_outreach_service.dart';
import 'package:spots/core/services/business_business_outreach_service.dart';
import 'package:spots/core/services/business_member_service.dart';
import 'package:spots/core/services/business_shared_agent_service.dart';
// Onboarding & Agent Creation Services (Phase 1: Foundation)
import 'package:spots/core/services/onboarding_data_service.dart';
import 'package:spots/core/services/social_media_vibe_analyzer.dart';
import 'package:spots/core/services/social_media_connection_service.dart';
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

  // Agent ID Service (for ai2ai network routing)
  sl.registerLazySingleton(() => AgentIdService(
        businessService: sl<BusinessAccountService>(),
      ));

  // Onboarding & Agent Creation Services (Phase 1: Foundation)
  sl.registerLazySingleton(() => OnboardingDataService(
        agentIdService: sl<AgentIdService>(),
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
  sl.registerLazySingleton<event_rec_service.EventRecommendationService>(
    () => event_rec_service.EventRecommendationService(
      eventService: sl<ExpertiseEventService>(),
    ),
  );
  
  // OAuth Deep Link Handler (Phase 8.2: OAuth Implementation)
  sl.registerLazySingleton<OAuthDeepLinkHandler>(
    () => OAuthDeepLinkHandler(),
  );

  // Social Media Connection Service (Phase 8.2: Social Media Data Collection)
  sl.registerLazySingleton<SocialMediaConnectionService>(
    () => SocialMediaConnectionService(
      sl<StorageService>(),
      sl<AgentIdService>(),
      sl<OAuthDeepLinkHandler>(),
    ),
  );

  // Quantum Vibe Engine (Phase 4: Quantum Analysis)
  // Enhanced with Decoherence Tracking (Phase 2.1)
  sl.registerLazySingleton(() => QuantumVibeEngine(
        decoherenceTracking: sl<DecoherenceTrackingService>(),
        featureFlags: sl<FeatureFlagService>(),
      ));

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

  // Message Encryption Service (Signal Protocol ready)
  sl.registerLazySingleton<MessageEncryptionService>(
      () => AES256GCMEncryptionService());

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
  sl.registerLazySingleton(() => CommunityService(
        expansionService: GeographicExpansionService(),
      ));

  // Business-Expert Chat Service (AI2AI routing)
  sl.registerLazySingleton(() => BusinessExpertChatServiceAI2AI(
        encryptionService: sl<MessageEncryptionService>(),
        businessService: sl<BusinessAccountService>(),
        agentIdService: sl<AgentIdService>(),
      ));

  // Business-Business Chat Service (AI2AI routing)
  sl.registerLazySingleton(() => BusinessBusinessChatServiceAI2AI(
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
  sl.registerLazySingleton(() => AI2AIProtocol());

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
  sl.registerLazySingleton<ContinuousLearningSystem>(
    () => ContinuousLearningSystem(),
  );

  // P2P Node Manager
  // OUR_GUTS.md: "Decentralized community networks with privacy protection"
  // Manages P2P nodes for university/company private networks
  sl.registerLazySingleton(() => P2PNodeManager());

  // Config
  sl.registerLazySingleton<ConfigService>(() => ConfigService(
        environment: 'development',
        supabaseUrl: SupabaseConfig.url,
        supabaseAnonKey: SupabaseConfig.anonKey,
        googlePlacesApiKey: GooglePlacesConfig.getApiKey(),
        debug: SupabaseConfig.debug,
        // ONNX removed - using cloud-only (Gemini/cloud embeddings)
        inferenceBackend: 'cloud',
        orchestrationStrategy: 'device_first',
      ));

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

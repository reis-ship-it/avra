import 'package:get_it/get_it.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/storage_service.dart' show StorageService, SharedPreferencesCompat;
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/services/ai2ai_learning_service.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/services/quantum_satisfaction_enhancer.dart';
import 'package:spots/core/ai/feedback_learning.dart' show UserFeedbackAnalyzer;
import 'package:spots/core/ml/nlp_processor.dart';
import 'package:spots_ai/services/personality_sync_service.dart';
import 'package:spots/core/services/usage_pattern_tracker.dart';
import 'package:spots/core/ai2ai/connection_log_queue.dart';
import 'package:spots/core/ai2ai/cloud_intelligence_sync.dart';
import 'package:spots/core/network/ai2ai_protocol.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:spots_ai/services/ai2ai_realtime_service.dart';
import 'package:spots_ai/services/contextual_personality_service.dart';
import 'package:spots/core/services/enhanced_connectivity_service.dart';
import 'package:spots/core/p2p/federated_learning.dart';
import 'package:spots/core/ai/continuous_learning_system.dart';
import 'package:spots/core/ai/event_queue.dart';
import 'package:spots/core/ai/event_logger.dart';
import 'package:spots/core/ai/structured_facts_extractor.dart';
import 'package:spots/core/p2p/node_manager.dart';
import 'package:spots/core/services/config_service.dart';
import 'package:spots/core/ml/onnx_dimension_scorer.dart';
import 'package:spots/core/ml/inference_orchestrator.dart';
import 'package:spots/core/ai/decision_coordinator.dart';
import 'package:spots/core/ai2ai/embedding_delta_collector.dart';
import 'package:spots/core/ai2ai/federated_learning_hooks.dart';
import 'package:spots/core/services/user_name_resolution_service.dart';
import 'package:spots/core/services/personality_agent_chat_service.dart';
import 'package:spots/core/services/friend_chat_service.dart';
import 'package:spots/core/services/community_chat_service.dart';
import 'package:spots/core/ai2ai/anonymous_communication.dart' as ai2ai;
import 'package:spots/core/services/business_expert_chat_service_ai2ai.dart';
import 'package:spots/core/services/business_business_chat_service_ai2ai.dart';
import 'package:spots/core/services/business_expert_outreach_service.dart';
import 'package:spots/core/services/business_business_outreach_service.dart';
import 'package:spots/core/services/business_member_service.dart';
import 'package:spots/core/services/business_shared_agent_service.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:spots/core/services/community_service.dart';
import 'package:spots/core/services/geographic_expansion_service.dart';
import 'package:spots/core/services/message_encryption_service.dart';
import 'package:spots/core/services/user_anonymization_service.dart';
import 'package:spots/core/services/event_recommendation_service.dart' as event_rec_service;
import 'package:spots/core/services/event_matching_service.dart';
import 'package:spots/core/services/spot_vibe_matching_service.dart';
import 'package:spots/core/services/oauth_deep_link_handler.dart';
import 'package:spots/core/services/social_media_connection_service.dart';
import 'package:spots/core/services/social_media/base/social_media_common_utils.dart';
import 'package:spots/core/services/social_media/social_media_service_factory.dart';
import 'package:spots/core/services/social_media/platforms/google_platform_service.dart';
import 'package:spots/core/services/social_media/platforms/instagram_platform_service.dart';
import 'package:spots/core/services/social_media/platforms/facebook_platform_service.dart';
import 'package:spots/core/services/social_media/platforms/twitter_platform_service.dart';
import 'package:spots/core/services/social_media/platforms/linkedin_platform_service.dart';
import 'package:spots/core/services/partnership_service.dart';
import 'package:spots/core/services/social_media_insight_service.dart';
import 'package:spots/core/services/social_media_sharing_service.dart';
import 'package:spots/core/services/social_media_discovery_service.dart';
import 'package:spots/core/services/public_profile_analysis_service.dart';
import 'package:spots/core/services/social_media_vibe_analyzer.dart';
import 'package:spots/core/services/preferences_profile_service.dart';
import 'package:spots/core/services/onboarding_data_service.dart';
import 'package:spots/core/services/onboarding_place_list_generator.dart';
import 'package:spots/core/services/onboarding_recommendation_service.dart';
import 'package:spots/data/datasources/remote/google_places_datasource.dart';
import 'package:spots/core/services/llm_service.dart';
import 'package:spots/core/services/legal_document_service.dart';
import 'package:spots/core/network/device_discovery.dart';
import 'package:spots/core/network/device_discovery_factory.dart';
import 'package:spots/core/network/personality_advertising_service.dart';
import 'package:spots/core/services/ai_improvement_tracking_service.dart';
import 'package:spots/core/services/action_history_service.dart';
import 'package:spots/core/services/location_obfuscation_service.dart';
import 'package:spots/core/services/field_encryption_service.dart';
import 'package:spots/core/services/audit_log_service.dart';
import 'package:spots_knot/services/knot/integrated_knot_recommendation_engine.dart';
import 'package:spots_knot/services/knot/cross_entity_compatibility_service.dart';
import 'package:spots_knot/services/knot/entity_knot_service.dart';
import 'package:spots_knot/services/knot/personality_knot_service.dart';
import 'package:spots_knot/services/knot/knot_fabric_service.dart';
import 'package:spots_knot/services/knot/knot_storage_service.dart';
import 'package:spots/data/repositories/hybrid_search_repository.dart';
import 'package:spots_network/spots_network.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:spots/supabase_config.dart';
import 'package:spots/google_places_config.dart';

/// AI/Network Services Registration Module
///
/// Registers all AI and network-related services.
/// This includes:
/// - Personality learning and AI services
/// - AI2AI communication services
/// - Social media services
/// - Chat services
/// - Event/spot matching services
/// - Message encryption and anonymous communication
/// - Network services (connection, discovery, advertising)
/// - Learning systems (continuous, federated)
Future<void> registerAIServices(GetIt sl) async {
  const logger = AppLogger(defaultTag: 'DI-AI', minimumLevel: LogLevel.debug);
  logger.debug('🤖 [DI-AI] Registering AI/network services...');

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
    final anonymizationService = sl<UserAnonymizationService>();
    return PersonalityAdvertisingService(
      anonymizationService: anonymizationService,
    );
  });

  // PersonalityLearning (Philosophy: "Always Learning With You")
  // On-device AI learning that works offline
  sl.registerLazySingleton(() {
    final prefs = sl<SharedPreferencesCompat>();
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
    return UserFeedbackAnalyzer(
      prefs: prefs,
      personalityLearning: personalityLearning,
      quantumSatisfactionEnhancer: quantumSatisfactionEnhancer,
      atomicClock: atomicClock,
    );
  });

  // NLPProcessor (Natural Language Processing for text analysis)
  sl.registerLazySingleton(() => NLPProcessor());

  // PersonalitySyncService (Philosophy: "Cloud sync is optional and encrypted")
  sl.registerLazySingleton(() {
    final supabaseService = sl<SupabaseService>();
    return PersonalitySyncService(supabaseService: supabaseService);
  });

  // UsagePatternTracker (Philosophy: "The key adapts to YOUR usage")
  sl.registerLazySingleton(() {
    final prefs = sl<SharedPreferencesCompat>();
    return UsagePatternTracker(prefs);
  });

  // AI2AI Protocol (Philosophy: "The Key Works Everywhere")
  // Phase 14: Updated to use MessageEncryptionService (Signal Protocol ready)
  sl.registerLazySingleton(() => AI2AIProtocol(
        encryptionService: sl<MessageEncryptionService>(),
        anonymizationService: sl<UserAnonymizationService>(),
      ));

  // Connection Log Queue (Philosophy: "Cloud is optional enhancement")
  sl.registerLazySingleton(
      () => ConnectionLogQueue(sl<SharedPreferencesCompat>()));

  // Cloud Intelligence Sync (Philosophy: "Cloud adds network wisdom")
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
      personalityLearning: personalityLearning,
      protocol: ai2aiProtocol,
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

  // AI Improvement Tracking Service
  sl.registerLazySingleton(() {
    final storageService = sl<StorageService>();
    return AIImprovementTrackingService(
        storage: storageService.defaultStorage);
  });

  // Action History Service
  sl.registerLazySingleton(() {
    final storageService = sl<StorageService>();
    return ActionHistoryService(storage: storageService.defaultStorage);
  });

  // Contextual Personality Service
  sl.registerLazySingleton(() => ContextualPersonalityService());

  // Enhanced Connectivity Service
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
  sl.registerLazySingleton<ContinuousLearningSystem>(() {
    final agentIdService = sl<AgentIdService>();
    return ContinuousLearningSystem(
      agentIdService: agentIdService,
    );
  });

  // Event Queue (offline-capable event queuing)
  sl.registerLazySingleton(() => EventQueue());

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

  // Structured Facts Extractor
  sl.registerLazySingleton(() => StructuredFactsExtractor());

  // P2P Node Manager
  sl.registerLazySingleton(() => P2PNodeManager());

  // Config (must be registered before InferenceOrchestrator)
  sl.registerLazySingleton<ConfigService>(() => ConfigService(
        environment: 'development',
        supabaseUrl: SupabaseConfig.url,
        supabaseAnonKey: SupabaseConfig.anonKey,
        googlePlacesApiKey: GooglePlacesConfig.getApiKey(),
        debug: SupabaseConfig.debug,
        inferenceBackend: 'onnx',
        orchestrationStrategy: 'device_first',
      ));

  // ONNX Dimension Scorer
  sl.registerLazySingleton<OnnxDimensionScorer>(() => OnnxDimensionScorer());

  // Inference Orchestrator
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

  // Decision Coordinator
  sl.registerLazySingleton(() {
    final orchestrator = sl<InferenceOrchestrator>();
    final config = sl<ConfigService>();
    return DecisionCoordinator(
      orchestrator: orchestrator,
      config: config,
    );
  });

  // Embedding Delta Collector
  sl.registerLazySingleton(() => EmbeddingDeltaCollector());

  // Federated Learning Hooks
  sl.registerLazySingleton(() {
    final deltaCollector = sl<EmbeddingDeltaCollector>();
    return FederatedLearningHooks(
      deltaCollector: deltaCollector,
    );
  });

  // PreferencesProfile Service (for preference learning and quantum recommendations)
  sl.registerLazySingleton<PreferencesProfileService>(
      () => PreferencesProfileService(
            storage: sl<StorageService>(),
          ));

  // Event Recommendation Service (for AI recommendations)
  sl.registerLazySingleton<event_rec_service.EventRecommendationService>(
    () => event_rec_service.EventRecommendationService(
      eventService: sl<ExpertiseEventService>(),
      knotRecommendationEngine: sl<IntegratedKnotRecommendationEngine>(),
      personalityLearning: sl<PersonalityLearning>(),
    ),
  );

  // Event Matching Service (for event matching signals)
  sl.registerLazySingleton<EventMatchingService>(
    () => EventMatchingService(
      knotRecommendationEngine: sl<IntegratedKnotRecommendationEngine>(),
      personalityLearning: sl<PersonalityLearning>(),
    ),
  );

  // Spot Vibe Matching Service (for spot-user vibe matching)
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
  // Phase 1.3: Refactored to use platform-specific services
  // Register common utilities first
  sl.registerLazySingleton<SocialMediaCommonUtils>(
    () => SocialMediaCommonUtils(sl<StorageService>()),
  );

  // Register platform services
  sl.registerLazySingleton<GooglePlatformService>(
    () => GooglePlatformService(
      storageService: sl<StorageService>(),
      commonUtils: sl<SocialMediaCommonUtils>(),
    ),
  );
  sl.registerLazySingleton<InstagramPlatformService>(
    () => InstagramPlatformService(
      storageService: sl<StorageService>(),
      commonUtils: sl<SocialMediaCommonUtils>(),
    ),
  );
  sl.registerLazySingleton<FacebookPlatformService>(
    () => FacebookPlatformService(
      storageService: sl<StorageService>(),
      commonUtils: sl<SocialMediaCommonUtils>(),
    ),
  );
  sl.registerLazySingleton<TwitterPlatformService>(
    () => TwitterPlatformService(
      storageService: sl<StorageService>(),
      commonUtils: sl<SocialMediaCommonUtils>(),
    ),
  );
  sl.registerLazySingleton<LinkedInPlatformService>(
    () => LinkedInPlatformService(
      storageService: sl<StorageService>(),
      commonUtils: sl<SocialMediaCommonUtils>(),
    ),
  );

  // Register factory with platform services
  sl.registerLazySingleton<SocialMediaServiceFactory>(
    () => SocialMediaServiceFactory(
      services: {
        'google': sl<GooglePlatformService>(),
        'instagram': sl<InstagramPlatformService>(),
        'facebook': sl<FacebookPlatformService>(),
        'twitter': sl<TwitterPlatformService>(),
        'linkedin': sl<LinkedInPlatformService>(),
      },
    ),
  );

  // Register main service with factory
  sl.registerLazySingleton<SocialMediaConnectionService>(
    () => SocialMediaConnectionService(
      sl<StorageService>(),
      sl<AgentIdService>(),
      sl<OAuthDeepLinkHandler>(),
      serviceFactory: sl<SocialMediaServiceFactory>(),
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

  // Social Media Vibe Analyzer
  sl.registerLazySingleton(() => SocialMediaVibeAnalyzer());

  // Onboarding & Agent Creation Services
  sl.registerLazySingleton(() => OnboardingDataService(
        agentIdService: sl<AgentIdService>(),
        onboardingAggregationService: null, // Will be resolved lazily if available
      ));

  // Phase 8.5: Onboarding Place List Generator
  sl.registerLazySingleton<OnboardingPlaceListGenerator>(
    () => OnboardingPlaceListGenerator(
      placesDataSource: sl<GooglePlacesDataSource>(),
    ),
  );

  // Onboarding Recommendation Service
  sl.registerLazySingleton(() => OnboardingRecommendationService(
        agentIdService: sl<AgentIdService>(),
      ));

  logger.debug('✅ [DI-AI] AI/network services registered');
}

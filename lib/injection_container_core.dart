import 'package:get_it/get_it.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots/core/services/feature_flag_service.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots/core/services/large_city_detection_service.dart';
import 'package:spots/core/services/neighborhood_boundary_service.dart';
import 'package:spots/core/services/geographic_scope_service.dart';
import 'package:spots/core/services/role_management_service.dart';
import 'package:spots/core/services/community_validation_service.dart';
import 'package:spots/core/services/performance_monitor.dart';
import 'package:spots/core/services/security_validator.dart';
import 'package:spots/core/services/deployment_validator.dart';
import 'package:spots/core/services/search_cache_service.dart';
import 'package:spots/core/services/ai_search_suggestions_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import 'package:spots/core/services/permissions_persistence_service.dart';
import 'package:spots/core/services/storage_service.dart' show SharedPreferencesCompat;
import 'package:spots/core/ai/vibe_analysis_engine.dart';

/// Core Services Registration Module
/// 
/// Registers foundational services that other modules depend on.
/// This includes:
/// - Storage and database services
/// - Core infrastructure services
/// - Geographic services
/// - Security and validation services
Future<void> registerCoreServices(GetIt sl) async {
  const logger = AppLogger(defaultTag: 'DI-Core', minimumLevel: LogLevel.debug);
  logger.debug('📦 [DI-Core] Registering core services...');

  // External dependencies
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => PermissionsPersistenceService());

  // Initialize Sembast Database
  try {
    logger.debug('💾 [DI-Core] Initializing Sembast database...');
    final sembastDb = await SembastDatabase.database;
    sl.registerLazySingleton(() => sembastDb);
    logger.debug('✅ [DI-Core] Sembast database registered');
  } catch (e) {
    logger.warn('⚠️ [DI-Core] Sembast database initialization failed: $e');
  }

  // Storage Service (foundation for many services)
  final storageService = StorageService.instance;
  await storageService.init();
  sl.registerLazySingleton<StorageService>(() => storageService);
  logger.debug('✅ [DI-Core] StorageService registered');

  // Feature Flag Service
  sl.registerLazySingleton<FeatureFlagService>(
    () => FeatureFlagService(storage: sl<StorageService>()),
  );
  logger.debug('✅ [DI-Core] FeatureFlagService registered');

  // Geographic Services
  sl.registerLazySingleton<LargeCityDetectionService>(
    () => LargeCityDetectionService(),
  );
  sl.registerLazySingleton<GeographicScopeService>(
    () => GeographicScopeService(
      largeCityService: sl<LargeCityDetectionService>(),
    ),
  );
  sl.registerLazySingleton<NeighborhoodBoundaryService>(
    () => NeighborhoodBoundaryService(
      largeCityService: sl<LargeCityDetectionService>(),
      storageService: sl<StorageService>(),
    ),
  );
  logger.debug('✅ [DI-Core] Geographic services registered');

  // Phase 2: Missing Services
  // Note: RoleManagementService requires interface import - using implementation directly
  sl.registerLazySingleton(
    () => RoleManagementServiceImpl(
      storageService: sl<StorageService>(),
      prefs: sl<SharedPreferencesCompat>(),
    ),
  );
  sl.registerLazySingleton(() => CommunityValidationService(
    storageService: sl<StorageService>(),
    prefs: sl<SharedPreferencesCompat>(),
  ));
  logger.debug('✅ [DI-Core] Phase 2 services registered');

  // Patent #30: Quantum Atomic Clock System
  sl.registerLazySingleton<AtomicClockService>(() => AtomicClockService());
  logger.debug('✅ [DI-Core] AtomicClockService registered');

  // Agent ID Service (privacy protection)
  // Note: AgentIdService requires SecureMappingEncryptionService and BusinessAccountService
  // Registration deferred to main container where these dependencies are available
  logger.debug('✅ [DI-Core] AgentIdService registration deferred to main container');

  // Supabase Service (if available)
  try {
    sl.registerLazySingleton<SupabaseService>(() => SupabaseService());
    logger.debug('✅ [DI-Core] SupabaseService registered');
  } catch (e) {
    logger.warn('⚠️ [DI-Core] SupabaseService registration skipped: $e');
  }

  // Performance and Validation Services
  // Note: These require SharedPreferences, so register after sharedPrefs
  sl.registerLazySingleton(() => PerformanceMonitor(
    storageService: sl<StorageService>(),
    prefs: sl<SharedPreferencesCompat>(),
  ));
  sl.registerLazySingleton(() => SecurityValidator());
  sl.registerLazySingleton(() => DeploymentValidator(
    performanceMonitor: sl<PerformanceMonitor>(),
    securityValidator: sl<SecurityValidator>(),
  ));
  logger.debug('✅ [DI-Core] Performance and validation services registered');

  // Search Services
  sl.registerLazySingleton(() => SearchCacheService());
  sl.registerLazySingleton(() => AISearchSuggestionsService());
  logger.debug('✅ [DI-Core] Search services registered');

  // UserVibeAnalyzer (depends on SharedPreferences)
  final sharedPrefsForVibe = await StorageService.getInstance();
  sl.registerLazySingleton(() => UserVibeAnalyzer(prefs: sharedPrefsForVibe));
  logger.debug('✅ [DI-Core] UserVibeAnalyzer registered');

  logger.debug('✅ [DI-Core] Core services registration complete');
}

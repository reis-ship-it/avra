import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

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
import 'package:spots/data/datasources/remote/google_places_datasource_impl.dart';
import 'package:spots/data/datasources/remote/openstreetmap_datasource.dart';
import 'package:spots/data/datasources/remote/openstreetmap_datasource_impl.dart';
import 'package:spots/data/repositories/hybrid_search_repository.dart';
import 'package:spots/domain/usecases/search/hybrid_search_usecase.dart';
import 'package:spots/presentation/blocs/search/hybrid_search_bloc.dart';

// Phase 4: Performance Optimization & AI Features
import 'package:spots/core/services/search_cache_service.dart';
import 'package:spots/core/services/ai_search_suggestions_service.dart';

// Supabase Backend Integration
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/ai2ai_realtime_service.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/config_service.dart';
// Single integration boundary
import 'package:spots_network/spots_network.dart';
import 'package:spots/supabase_config.dart';
// ML (universal inference)
import 'package:spots/core/ml/inference_backend.dart';
import 'package:spots/core/ml/onnx_backend.dart';
import 'package:spots/core/ml/inference_orchestrator.dart';
import 'package:spots/core/ml/tokenization/wordpiece_tokenizer.dart';
import 'package:spots/core/ml/embedding_service.dart';
import 'package:spots/core/services/model_bootstrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spots/core/ml/embedding_cloud_client.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Connectivity());

  // Initialize Sembast Database (works on both web and mobile now)
  try {
    final sembastDb = await SembastDatabase.database;
    sl.registerLazySingleton(() => sembastDb);
  } catch (e) {
    // Continue even if database initialization fails
  }

  // Data Sources - Local (Offline-First)
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthSembastDataSource());
  sl.registerLazySingleton<SpotsLocalDataSource>(() => SpotsSembastDataSource());
  sl.registerLazySingleton<ListsLocalDataSource>(() => ListsSembastDataSource());

  // Data Sources - Remote (Optional, for online features)
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  sl.registerLazySingleton<SpotsRemoteDataSource>(() => SpotsRemoteDataSourceImpl());
  sl.registerLazySingleton<ListsRemoteDataSource>(() => ListsRemoteDataSourceImpl());

  // External Data Sources (Optional) with DI-provided HTTP client
  sl.registerLazySingleton<GooglePlacesDataSource>(() => GooglePlacesDataSourceImpl(
        apiKey: 'demo_key',
        httpClient: sl<http.Client>(),
      ));
  sl.registerLazySingleton<OpenStreetMapDataSource>(() => OpenStreetMapDataSourceImpl(
        httpClient: sl<http.Client>(),
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
      ));

  // Auth Use cases (Register after repositories)
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

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
  // SharedPreferences for UserVibeAnalyzer
  final sharedPrefs = await SharedPreferences.getInstance();
  // Expose SharedPreferences so UI/services can use via DI
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton(() => UserVibeAnalyzer(prefs: sharedPrefs));
  
  // Supabase Service (kept for internal tooling/debug; app uses spots_network boundary)
  sl.registerLazySingleton(() => SupabaseService());

  // VibeConnectionOrchestrator + AI2AIRealtimeService wiring
  sl.registerLazySingleton<VibeConnectionOrchestrator>(() {
    final connectivity = sl<Connectivity>();
    final vibeAnalyzer = sl<UserVibeAnalyzer>();
    final orchestrator = VibeConnectionOrchestrator(
      vibeAnalyzer: vibeAnalyzer,
      connectivity: connectivity,
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
  sl.registerLazySingleton<AppLogger>(() => const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug));

  // Config
  sl.registerLazySingleton<ConfigService>(() => ConfigService(
        environment: 'development',
        supabaseUrl: SupabaseConfig.url,
        supabaseAnonKey: SupabaseConfig.anonKey,
        debug: SupabaseConfig.debug,
        // Defaults can be overridden by remote config later
        inferenceBackend: 'onnx',
        orchestrationStrategy: 'device_first',
        // Sample MLP model generated via scripts/ml/export_sample_onnx.py
        modelAssetPath: 'assets/models/default.onnx',
        modelInputName: 'input',
        modelOutputName: 'output',
        modelInputShape: [1, 4],
      ));

  // Backend (Single Integration Boundary): initialize and expose spots_network
  try {
    final backend = await BackendFactory.create(
      BackendConfig.supabase(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        serviceRoleKey: SupabaseConfig.serviceRoleKey,
        name: 'Supabase',
        isDefault: true,
      ),
    );
    // Expose the unified backend and its components
    sl.registerSingleton<BackendInterface>(backend);
    sl.registerLazySingleton<AuthBackend>(() => backend.auth);
    sl.registerLazySingleton<DataBackend>(() => backend.data);
    sl.registerLazySingleton<RealtimeBackend>(() => backend.realtime);
  } catch (e) {
    // Continue without backend on web if initialization fails
  }

  // ===========================
  // ML Inference & Orchestration
  // ===========================
  final config = sl<ConfigService>();

  // Inference backend selection (default: ONNX stub)
  sl.registerLazySingleton<InferenceBackend>(() {
    switch (config.inferenceBackend.toLowerCase()) {
      case 'onnx':
      default:
        return OnnxRuntimeBackend();
    }
  });

  // Orchestration strategy selection with cloud fallback stub
  sl.registerLazySingleton<InferenceOrchestrator>(() {
    final backend = sl<InferenceBackend>();
    final strategy = config.orchestrationStrategy.toLowerCase() == 'edge_prefetch'
        ? OrchestrationStrategy.edgePrefetch
        : OrchestrationStrategy.deviceFirst;
    return InferenceOrchestrator(
      backend: backend,
      strategy: strategy,
      cloudFallback: (inputs) async {
        // Web fallback placeholder: echo request keys
        return {'fallback': true, 'keys': inputs.keys.toList()};
      },
    );
  });

  // Try initializing the orchestrator with a default model from assets.
  // This is optional and will not crash the app if the model is missing.
  try {
    final orchestrator = sl<InferenceOrchestrator>();
    // Use a bootstrapper to load from asset or optional remote URL
    final bootstrapper = ModelBootstrapper(httpClient: sl<http.Client>());
    await bootstrapper.ensureModelInitialized(orchestrator: orchestrator, config: config);
  } catch (_) {
    // Safe to ignore; model can be provided/updated later via remote config.
  }

  // Tokenizer + Embedding service (multilingual BERT)
  sl.registerLazySingletonAsync<WordPieceTokenizer>(() async {
    // Expect vocab at assets/tokenizers/vocab.txt
    return WordPieceTokenizer.fromAsset('assets/tokenizers/vocab.txt', doLowerCase: config.nlpDoLowerCase);
  });
  sl.registerLazySingletonAsync<EmbeddingService>(() async {
    final tok = await sl.getAsync<WordPieceTokenizer>();
    EmbeddingCloudClient? cloud;
    try {
      cloud = EmbeddingCloudClient(client: Supabase.instance.client);
    } catch (_) {}
    return EmbeddingService(orchestrator: sl<InferenceOrchestrator>(), tokenizer: tok, config: config, cloudClient: cloud);
  });

  // ML Inference Backend & Orchestrator
  // Keep behind a simple config switch for wiggle room on orchestration.
  // Uses ONNX stub by default; can be replaced with real implementation later.
  // Late import block was invalid Dart. Removing no-op block.

  // Blocs (Register last, after all dependencies)
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
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

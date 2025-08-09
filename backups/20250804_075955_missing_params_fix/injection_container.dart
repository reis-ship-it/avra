import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

// Database
import 'package:spots/data/datasources/local/sembast/sembast/sembast_database.dart';

// Auth
import 'package:spots/data/datasources/remote/auth_remote_datasource.dart';
import 'package:spots/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/sembast/sembast/auth_local_datasource.dart';
import 'package:spots/data/datasources/local/sembast/sembast/auth_sembast_datasource.dart';
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
import 'package:spots/data/datasources/local/sembast/sembast/spots_local_datasource.dart';
import 'package:spots/data/datasources/local/sembast/sembast/spots_sembast_datasource.dart';
import 'package:spots/data/repositories/spots_repository_impl.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/get_spots_usecase.dart';
import 'package:spots/domain/usecases/spots/get_spots_from_respected_lists_usecase.dart';
import 'package:spots/domain/usecases/spots/create_spot_usecase.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';

// Lists
import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/sembast/sembast/lists_local_datasource.dart';
import 'package:spots/data/datasources/local/sembast/sembast/lists_sembast_datasource.dart';
import 'package:spots/data/repositories/lists_repository_impl.dart';
import 'package:spots/domain/repositories/lists_repository.dart';
import 'package:spots/domain/usecases/lists/get_lists_usecase.dart';
import 'package:spots/domain/usecases/lists/create_list_usecase.dart';
import 'package:spots/domain/usecases/lists/update_list_usecase.dart';
import 'package:spots/domain/usecases/lists/delete_list_usecase.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Connectivity());

  // Database
  // sl.registerLazySingleton(() => DatabaseHelper());

  // Initialize Sembast Database (skip on web for now)
  if (!kIsWeb) {
    try {
      final sembastDb = await SembastDatabase.database;
      sl.registerLazySingleton(() => sembastDb);
    } catch (e) {
      // Skip database initialization if it fails
    }
  }

  // Blocs
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
      ));

  sl.registerFactory(() => ListsBloc(
        getListsUseCase: sl(),
        createListUseCase: sl(),
        updateListUseCase: sl(),
        deleteListUseCase: sl(),
      ));

  // Auth Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Spots Use cases
  sl.registerLazySingleton(() => GetSpotsUseCase(sl()));
  sl.registerLazySingleton(() => GetSpotsFromRespectedListsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSpotUseCase(sl()));

  // Lists Use cases
  sl.registerLazySingleton(() => GetListsUseCase(sl()));
  sl.registerLazySingleton(() => CreateListUseCase(sl()));
  sl.registerLazySingleton(() => UpdateListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteListUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      
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
      
    ),
  );

  // Auth Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  if (!kIsWeb) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthSembastDataSource(),
    );
  }

  // Spots Data sources
  sl.registerLazySingleton<SpotsRemoteDataSource>(
    () => SpotsRemoteDataSourceImpl(),
  );
  if (!kIsWeb) {
    sl.registerLazySingleton<SpotsLocalDataSource>(
      () => SpotsSembastDataSource(),
    );
  }

  // Lists Data sources
  sl.registerLazySingleton<ListsRemoteDataSource>(
    () => ListsRemoteDataSourceImpl(),
  );
  if (!kIsWeb) {
    sl.registerLazySingleton<ListsLocalDataSource>(
      () => ListsSembastDataSource(),
    );
  }
}

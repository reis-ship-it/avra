import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/routes/app_router.dart';
import 'package:spots/domain/usecases/auth/sign_in_usecase.dart';
import 'package:spots/domain/usecases/auth/sign_up_usecase.dart';
import 'package:spots/domain/usecases/auth/sign_out_usecase.dart';
import 'package:spots/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:spots/domain/usecases/spots/get_spots_usecase.dart';
import 'package:spots/domain/usecases/spots/get_spots_from_respected_lists_usecase.dart';
import 'package:spots/domain/usecases/spots/create_spot_usecase.dart';
import 'package:spots/domain/usecases/lists/get_lists_usecase.dart';
import 'package:spots/domain/usecases/lists/create_list_usecase.dart';
import 'package:spots/domain/usecases/lists/update_list_usecase.dart';
import 'package:spots/domain/usecases/lists/delete_list_usecase.dart';
import 'package:spots/data/repositories/auth_repository_impl.dart';
import 'package:spots/data/repositories/spots_repository_impl.dart';
import 'package:spots/data/repositories/lists_repository_impl.dart';
import 'package:spots/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/sembast/sembast/auth_sembast_datasource.dart';
import 'package:spots/data/datasources/remote/spots_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/sembast/sembast/spots_sembast_datasource.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource_impl.dart';
import 'package:spots/data/datasources/local/sembast/sembast/lists_sembast_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class SpotsApp extends StatelessWidget {
  const SpotsApp({super.key});

  Future<void> _initializeDatabase() async {
    try {
      // Just wait a moment to ensure database is initialized from main.dart
      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      developer.log('Error in app initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
                return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                signInUseCase: SignInUseCase(AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(),
                  localDataSource: AuthSembastDataSource(),
                )),
                signUpUseCase: SignUpUseCase(AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(),
                  localDataSource: AuthSembastDataSource(),
                )),
                signOutUseCase: SignOutUseCase(AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(),
                  localDataSource: AuthSembastDataSource(),
                )),
                getCurrentUserUseCase: GetCurrentUserUseCase(AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(),
                  localDataSource: AuthSembastDataSource(),
                )),
              ),
            ),
            BlocProvider<SpotsBloc>(
              create: (context) => SpotsBloc(
                getSpotsUseCase: GetSpotsUseCase(SpotsRepositoryImpl(
                  remoteDataSource: SpotsRemoteDataSourceImpl(),
                  localDataSource: SpotsSembastDataSource(),
                  connectivity: Connectivity(),
                )),
                getSpotsFromRespectedListsUseCase: GetSpotsFromRespectedListsUseCase(SpotsRepositoryImpl(
                  remoteDataSource: SpotsRemoteDataSourceImpl(),
                  localDataSource: SpotsSembastDataSource(),
                  connectivity: Connectivity(),
                )),
                createSpotUseCase: CreateSpotUseCase(SpotsRepositoryImpl(
                  remoteDataSource: SpotsRemoteDataSourceImpl(),
                  localDataSource: SpotsSembastDataSource(),
                  connectivity: Connectivity(),
                )),
              ),
            ),
            BlocProvider<ListsBloc>(
              create: (context) => ListsBloc(
                getListsUseCase: GetListsUseCase(ListsRepositoryImpl(
                  remoteDataSource: ListsRemoteDataSourceImpl(),
                  localDataSource: ListsSembastDataSource(),
                )),
                createListUseCase: CreateListUseCase(ListsRepositoryImpl(
                  remoteDataSource: ListsRemoteDataSourceImpl(),
                  localDataSource: ListsSembastDataSource(),
                )),
                updateListUseCase: UpdateListUseCase(ListsRepositoryImpl(
                  remoteDataSource: ListsRemoteDataSourceImpl(),
                  localDataSource: ListsSembastDataSource(),
                )),
                deleteListUseCase: DeleteListUseCase(ListsRepositoryImpl(
                  remoteDataSource: ListsRemoteDataSourceImpl(),
                  localDataSource: ListsSembastDataSource(),
                )),
              ),
            ),
          ],
          child: MaterialApp(
            title: 'SPOTS',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.initial,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/onboarding/ai_loading_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/domain/usecases/lists/create_list_usecase.dart';
import 'package:spots/domain/usecases/lists/get_lists_usecase.dart';
import 'package:spots/data/repositories/lists_repository_impl.dart';
import 'package:spots/data/datasources/local/lists_local_datasource.dart';
import 'package:spots/data/datasources/remote/lists_remote_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spots/core/theme/app_theme.dart';

/// Widget tests for AILoadingPage
/// Tests AI loading page that generates personalized lists
/// Uses real implementations with in-memory storage
void main() {
  group('AILoadingPage Widget Tests', () {
    late _FakeListsLocalDataSource fakeLocalDataSource;
    late _FakeListsRemoteDataSource fakeRemoteDataSource;
    late _FakeConnectivity fakeConnectivity;
    late ListsRepositoryImpl listsRepository;
    late GetListsUseCase getListsUseCase;
    late CreateListUseCase createListUseCase;
    late _FakeAuthBloc fakeAuthBloc;
    late _FakeListsBloc fakeListsBloc;

    setUp(() {
      fakeLocalDataSource = _FakeListsLocalDataSource();
      fakeRemoteDataSource = _FakeListsRemoteDataSource();
      fakeConnectivity = _FakeConnectivity();
      fakeConnectivity.setConnectivity(ConnectivityResult.wifi);

      listsRepository = ListsRepositoryImpl(
        localDataSource: fakeLocalDataSource,
        remoteDataSource: fakeRemoteDataSource,
        connectivity: fakeConnectivity,
      );

      getListsUseCase = GetListsUseCase(listsRepository);
      createListUseCase = CreateListUseCase(listsRepository);

      fakeAuthBloc = _FakeAuthBloc();
      fakeListsBloc = _FakeListsBloc(
        getListsUseCase: getListsUseCase,
        createListUseCase: createListUseCase,
      );
    });

    tearDown(() {
      fakeAuthBloc.close();
      fakeListsBloc.close();
      fakeLocalDataSource.clear();
      fakeRemoteDataSource.clear();
    });

    testWidgets('should display loading page with user information', (WidgetTester tester) async {
      // Arrange
      final widget = _createTestableWidgetWithRealBlocs(
        child: AILoadingPage(
          userName: 'Test User',
          homebase: 'New York',
          favoritePlaces: ['Central Park', 'Brooklyn Bridge'],
          preferences: {
            'Food & Drink': ['Coffee & Tea'],
          },
          onLoadingComplete: () {},
        ),
        authBloc: fakeAuthBloc,
        listsBloc: fakeListsBloc,
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump(); // Initial frame

      // Assert: Widget should be displayed
      expect(find.byType(AILoadingPage), findsOneWidget);
    });

    testWidgets('should display loading indicator', (WidgetTester tester) async {
      // Arrange
      final widget = _createTestableWidgetWithRealBlocs(
        child: AILoadingPage(
          userName: 'Test User',
          onLoadingComplete: () {},
        ),
        authBloc: fakeAuthBloc,
        listsBloc: fakeListsBloc,
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump(); // Initial frame

      // Assert: Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle minimal user data', (WidgetTester tester) async {
      // Arrange
      final widget = _createTestableWidgetWithRealBlocs(
        child: AILoadingPage(
          userName: 'Test User',
          onLoadingComplete: () {},
        ),
        authBloc: fakeAuthBloc,
        listsBloc: fakeListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert: Widget should render without errors
      expect(find.byType(AILoadingPage), findsOneWidget);
    });

    testWidgets('should handle extended user data', (WidgetTester tester) async {
      // Arrange
      final widget = _createTestableWidgetWithRealBlocs(
        child: AILoadingPage(
          userName: 'John Doe',
          age: 25,
          birthday: DateTime(2000, 1, 1),
          homebase: 'Brooklyn',
          favoritePlaces: ['Park', 'Bridge'],
          preferences: {
            'Activities': ['Music', 'Art'],
          },
          onLoadingComplete: () {},
        ),
        authBloc: fakeAuthBloc,
        listsBloc: fakeListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert: Widget should render without errors
      expect(find.byType(AILoadingPage), findsOneWidget);
    });

    testWidgets('should render successfully with callback', (WidgetTester tester) async {
      // Arrange
      final widget = _createTestableWidgetWithRealBlocs(
        child: AILoadingPage(
          userName: 'Test User',
          onLoadingComplete: () {},
        ),
        authBloc: fakeAuthBloc,
        listsBloc: fakeListsBloc,
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump(); // Initial frame

      // Assert: Widget should render successfully
      expect(find.byType(AILoadingPage), findsOneWidget);
    });
  });
}

/// Real fake implementation with in-memory storage for local data source
class _FakeListsLocalDataSource implements ListsLocalDataSource {
  final Map<String, SpotList> _storage = {};

  void clear() {
    _storage.clear();
  }

  @override
  Future<List<SpotList>> getLists() async {
    return _storage.values.toList();
  }

  @override
  Future<SpotList?> saveList(SpotList list) async {
    _storage[list.id] = list;
    return list;
  }

  @override
  Future<void> deleteList(String id) async {
    _storage.remove(id);
  }
}

/// Real fake implementation with in-memory storage for remote data source
class _FakeListsRemoteDataSource implements ListsRemoteDataSource {
  final Map<String, SpotList> _storage = {};

  void clear() {
    _storage.clear();
  }

  @override
  Future<List<SpotList>> getLists() async {
    return _storage.values.toList();
  }

  @override
  Future<List<SpotList>> getPublicLists({int? limit}) async {
    final publicLists = _storage.values.where((list) => list.isPublic).toList();
    if (limit != null) {
      return publicLists.take(limit).toList();
    }
    return publicLists;
  }

  @override
  Future<SpotList> createList(SpotList list) async {
    _storage[list.id] = list;
    return list;
  }

  @override
  Future<SpotList> updateList(SpotList list) async {
    _storage[list.id] = list;
    return list;
  }

  @override
  Future<void> deleteList(String listId) async {
    _storage.remove(listId);
  }
}

/// Real fake implementation with state management for connectivity testing
class _FakeConnectivity implements Connectivity {
  ConnectivityResult _currentResult = ConnectivityResult.wifi;

  void setConnectivity(ConnectivityResult result) {
    _currentResult = result;
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return [_currentResult];
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Stream.value([_currentResult]);
  }
}

/// Real fake AuthBloc with actual state management
/// Minimal implementation - AILoadingPage doesn't heavily use AuthBloc
class _FakeAuthBloc extends Bloc<AuthEvent, AuthState> {
  _FakeAuthBloc() : super(AuthInitial()) {
    // Handle events without throwing
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    emit(Unauthenticated());
  }
}

/// Real fake ListsBloc with actual state management and use cases
class _FakeListsBloc extends Bloc<ListsEvent, ListsState> {
  final GetListsUseCase getListsUseCase;
  final CreateListUseCase createListUseCase;

  _FakeListsBloc({
    required this.getListsUseCase,
    required this.createListUseCase,
  }) : super(ListsInitial()) {
    on<LoadLists>(_onLoadLists);
    on<CreateList>(_onCreateList);
    // Stub other events to prevent errors
    on<UpdateList>(_onUpdateList);
    on<DeleteList>(_onDeleteList);
    on<SearchLists>(_onSearchLists);
  }

  Future<void> _onLoadLists(
    LoadLists event,
    Emitter<ListsState> emit,
  ) async {
    emit(ListsLoading());
    try {
      final lists = await getListsUseCase();
      emit(ListsLoaded(lists, lists));
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onCreateList(
    CreateList event,
    Emitter<ListsState> emit,
  ) async {
    try {
      await createListUseCase(event.list);
      add(LoadLists());
    } catch (e) {
      emit(ListsError(e.toString()));
    }
  }

  Future<void> _onUpdateList(
    UpdateList event,
    Emitter<ListsState> emit,
  ) async {
    // Not used by AILoadingPage, but needed for interface
    emit(ListsError('UpdateList not implemented'));
  }

  Future<void> _onDeleteList(
    DeleteList event,
    Emitter<ListsState> emit,
  ) async {
    // Not used by AILoadingPage, but needed for interface
    emit(ListsError('DeleteList not implemented'));
  }

  Future<void> _onSearchLists(
    SearchLists event,
    Emitter<ListsState> emit,
  ) async {
    // Not used by AILoadingPage, but needed for interface
    add(LoadLists());
  }
}

/// Helper to create testable widget with real BLoCs
Widget _createTestableWidgetWithRealBlocs({
  required Widget child,
  required Bloc<AuthEvent, AuthState> authBloc,
  required Bloc<ListsEvent, ListsState> listsBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc as AuthBloc),
      BlocProvider<ListsBloc>.value(value: listsBloc as ListsBloc),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

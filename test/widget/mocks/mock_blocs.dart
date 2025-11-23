import 'package:mockito/mockito.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/blocs/search/hybrid_search_bloc.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/list.dart';
import 'package:spots/core/models/user.dart';

/// Mock AuthBloc for widget testing
class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Stream<AuthState> get stream => Stream.value(AuthInitial());

  @override
  AuthState get state => AuthInitial();

  @override
  void add(AuthEvent event) {}

  @override
  Future<void> close() async {}

  @override
  bool get isClosed => false;
}

/// Mock ListsBloc for widget testing
class MockListsBloc extends Mock implements ListsBloc {
  @override
  Stream<ListsState> get stream => Stream.value(ListsInitial());

  @override
  ListsState get state => ListsInitial();

  @override
  void add(ListsEvent event) {}

  @override
  Future<void> close() async {}

  @override
  bool get isClosed => false;
}

/// Mock SpotsBloc for widget testing
class MockSpotsBloc extends Mock implements SpotsBloc {
  @override
  Stream<SpotsState> get stream => Stream.value(SpotsInitial());

  @override
  SpotsState get state => SpotsInitial();

  @override
  void add(SpotsEvent event) {}

  @override
  Future<void> close() async {}

  @override
  bool get isClosed => false;
}

/// Mock HybridSearchBloc for widget testing
class MockHybridSearchBloc extends Mock implements HybridSearchBloc {
  @override
  Stream<HybridSearchState> get stream => Stream.value(HybridSearchInitial());

  @override
  HybridSearchState get state => HybridSearchInitial();

  @override
  void add(HybridSearchEvent event) {}

  @override
  Future<void> close() async {}

  @override
  bool get isClosed => false;
}

/// Helper class to create mock blocs with predefined states
class MockBlocFactory {
  /// Creates an authenticated mock auth bloc
  static MockAuthBloc createAuthenticatedAuthBloc() {
    final mockBloc = MockAuthBloc();
    when(mockBloc.state).thenReturn(Authenticated(
      user: MockBlocFactory._createTestUser(),
    ));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(Authenticated(
      user: MockBlocFactory._createTestUser(),
    )));
    return mockBloc;
  }

  /// Creates an unauthenticated mock auth bloc
  static MockAuthBloc createUnauthenticatedAuthBloc() {
    final mockBloc = MockAuthBloc();
    when(mockBloc.state).thenReturn(Unauthenticated());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(Unauthenticated()));
    return mockBloc;
  }

  /// Creates a loading mock auth bloc
  static MockAuthBloc createLoadingAuthBloc() {
    final mockBloc = MockAuthBloc();
    when(mockBloc.state).thenReturn(AuthLoading());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));
    return mockBloc;
  }

  /// Creates an error mock auth bloc
  static MockAuthBloc createErrorAuthBloc(String message) {
    final mockBloc = MockAuthBloc();
    when(mockBloc.state).thenReturn(AuthError(message));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(AuthError(message)));
    return mockBloc;
  }

  /// Creates a mock lists bloc with loaded state
  static MockListsBloc createLoadedListsBloc(List<SpotList> lists) {
    final mockBloc = MockListsBloc();
    when(mockBloc.state).thenReturn(ListsLoaded(lists, lists));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(ListsLoaded(lists, lists)));
    return mockBloc;
  }

  /// Creates a mock lists bloc with loading state
  static MockListsBloc createLoadingListsBloc() {
    final mockBloc = MockListsBloc();
    when(mockBloc.state).thenReturn(ListsLoading());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(ListsLoading()));
    return mockBloc;
  }

  /// Creates a mock lists bloc with error state
  static MockListsBloc createErrorListsBloc(String message) {
    final mockBloc = MockListsBloc();
    when(mockBloc.state).thenReturn(ListsError(message));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(ListsError(message)));
    return mockBloc;
  }

  /// Creates a mock spots bloc with loaded state
  static MockSpotsBloc createLoadedSpotsBloc(List<Spot> spots) {
    final mockBloc = MockSpotsBloc();
    when(mockBloc.state).thenReturn(SpotsLoaded(spots));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(SpotsLoaded(spots)));
    return mockBloc;
  }

  /// Creates a mock spots bloc with loading state
  static MockSpotsBloc createLoadingSpotsBloc() {
    final mockBloc = MockSpotsBloc();
    when(mockBloc.state).thenReturn(SpotsLoading());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(SpotsLoading()));
    return mockBloc;
  }

  /// Creates a mock search bloc with results
  static MockHybridSearchBloc createSearchResultsBloc(List<Spot> results) {
    final mockBloc = MockHybridSearchBloc();
    when(mockBloc.state).thenReturn(HybridSearchLoaded(
      spots: results,
      communityCount: results.length,
      externalCount: 0,
      totalCount: results.length,
      searchDuration: const Duration(milliseconds: 100),
      sources: const {},
    ));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(HybridSearchLoaded(
      spots: results,
      communityCount: results.length,
      externalCount: 0,
      totalCount: results.length,
      searchDuration: const Duration(milliseconds: 100),
      sources: const {},
    )));
    return mockBloc;
  }

  /// Creates a test user for mocking purposes
  static User _createTestUser() {
    final now = DateTime.now();
    return User(
      id: 'test-user-id',
      email: 'test@example.com',
      name: 'Test User',
      role: UserRole.user,
      createdAt: now,
      updatedAt: now,
    );
  }
}

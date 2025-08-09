import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/blocs/search/hybrid_search_bloc.dart';

/// Mock AuthBloc for widget testing
class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Stream<AuthState> get stream => Stream.value(const AuthInitial());

  @override
  AuthState get state => const AuthInitial();

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
  Stream<ListsState> get stream => Stream.value(const ListsInitial());

  @override
  ListsState get state => const ListsInitial();

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
  Stream<SpotsState> get stream => Stream.value(const SpotsInitial());

  @override
  SpotsState get state => const SpotsInitial();

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
  Stream<HybridSearchState> get stream => Stream.value(const HybridSearchInitial());

  @override
  HybridSearchState get state => const HybridSearchInitial();

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
    when(mockBloc.state).thenReturn(const Unauthenticated());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(const Unauthenticated()));
    return mockBloc;
  }

  /// Creates a loading mock auth bloc
  static MockAuthBloc createLoadingAuthBloc() {
    final mockBloc = MockAuthBloc();
    when(mockBloc.state).thenReturn(const AuthLoading());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(const AuthLoading()));
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
  static MockListsBloc createLoadedListsBloc(List<dynamic> lists) {
    final mockBloc = MockListsBloc();
    when(mockBloc.state).thenReturn(ListsLoaded(lists));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(ListsLoaded(lists)));
    return mockBloc;
  }

  /// Creates a mock lists bloc with loading state
  static MockListsBloc createLoadingListsBloc() {
    final mockBloc = MockListsBloc();
    when(mockBloc.state).thenReturn(const ListsLoading());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(const ListsLoading()));
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
  static MockSpotsBloc createLoadedSpotsBloc(List<dynamic> spots) {
    final mockBloc = MockSpotsBloc();
    when(mockBloc.state).thenReturn(SpotsLoaded(spots));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(SpotsLoaded(spots)));
    return mockBloc;
  }

  /// Creates a mock spots bloc with loading state
  static MockSpotsBloc createLoadingSpotsBloc() {
    final mockBloc = MockSpotsBloc();
    when(mockBloc.state).thenReturn(const SpotsLoading());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(const SpotsLoading()));
    return mockBloc;
  }

  /// Creates a mock search bloc with results
  static MockHybridSearchBloc createSearchResultsBloc(List<dynamic> results) {
    final mockBloc = MockHybridSearchBloc();
    when(mockBloc.state).thenReturn(HybridSearchLoaded(results));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(HybridSearchLoaded(results)));
    return mockBloc;
  }

  /// Creates a test user for mocking purposes
  static dynamic _createTestUser() {
    // This would return a properly constructed UnifiedUser
    // For now, return a simple map structure that tests can use
    return {
      'id': 'test-user-id',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'role': 'follower',
      'isVerifiedAge': true,
    };
  }
}

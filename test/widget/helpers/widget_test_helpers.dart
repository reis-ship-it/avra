import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:spots/core/models/unified_models.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/presentation/blocs/search/hybrid_search_bloc.dart';
import 'package:spots/core/theme/app_theme.dart';
import '../mocks/mock_blocs.dart';

/// Helper utilities for widget testing to ensure consistent test setup
class WidgetTestHelpers {
  /// Creates a testable widget wrapped with necessary providers and theme
  static Widget createTestableWidget({
    required Widget child,
    MockAuthBloc? authBloc,
    MockListsBloc? listsBloc,
    MockSpotsBloc? spotsBloc,
    MockHybridSearchBloc? hybridSearchBloc,
    NavigatorObserver? navigatorObserver,
    RouteSettings? routeSettings,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: authBloc ?? MockAuthBloc(),
        ),
        BlocProvider<ListsBloc>.value(
          value: listsBloc ?? MockListsBloc(),
        ),
        BlocProvider<SpotsBloc>.value(
          value: spotsBloc ?? MockSpotsBloc(),
        ),
        BlocProvider<HybridSearchBloc>.value(
          value: hybridSearchBloc ?? MockHybridSearchBloc(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
        navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      ),
    );
  }

  /// Creates a testable widget with router support
  static Widget createTestableWidgetWithRouter({
    required Widget child,
    MockAuthBloc? authBloc,
    MockListsBloc? listsBloc,
    MockSpotsBloc? spotsBloc,
    MockHybridSearchBloc? hybridSearchBloc,
    NavigatorObserver? navigatorObserver,
    String initialRoute = '/',
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: authBloc ?? MockAuthBloc(),
        ),
        BlocProvider<ListsBloc>.value(
          value: listsBloc ?? MockListsBloc(),
        ),
        BlocProvider<SpotsBloc>.value(
          value: spotsBloc ?? MockSpotsBloc(),
        ),
        BlocProvider<HybridSearchBloc>.value(
          value: hybridSearchBloc ?? MockHybridSearchBloc(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => child,
          settings: settings,
        ),
        navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      ),
    );
  }

  /// Pumps widget and settles all animations
  static Future<void> pumpAndSettle(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration);
  }

  /// Verifies that a widget displays the expected loading state
  static void verifyLoadingState(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verifies that a widget displays an error state with a specific message
  static void verifyErrorState(WidgetTester tester, String errorMessage) {
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  }

  /// Verifies navigation occurred to a specific route
  static void verifyNavigationTo(NavigatorObserver observer, String routeName) {
    verify(observer.didPush(any, any));
  }

  /// Creates test user data
  static UnifiedUser createTestUser({
    String id = 'test-user-id',
    String email = 'test@example.com',
    String displayName = 'Test User',
    UserRole role = UserRole.follower,
    bool isVerifiedAge = true,
  }) {
    return UnifiedUser(
      id: id,
      email: email,
      displayName: displayName,
      role: role,
      isVerifiedAge: isVerifiedAge,
      profileImageUrl: null,
      bio: null,
      homebase: 'Test City',
      privacySettings: PrivacySettings(
        showEmail: false,
        showLocation: true,
        showLists: true,
        allowDirectMessages: true,
      ),
      permissions: UserPermissions(
        canCreateLists: true,
        canModerateLists: role == UserRole.curator,
        canAccessAgeRestrictedContent: isVerifiedAge,
      ),
      listMemberships: [],
      authoredLists: [],
      curatedLists: [],
      favoritePlaces: [],
      blockedUsers: [],
      reportHistory: [],
      activityHistory: [],
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  /// Creates test spot data
  static Spot createTestSpot({
    String id = 'test-spot-id',
    String name = 'Test Spot',
    double latitude = 40.7128,
    double longitude = -74.0060,
    SpotCategory category = SpotCategory.restaurant,
  }) {
    return Spot(
      id: id,
      name: name,
      description: 'A test spot for widget testing',
      latitude: latitude,
      longitude: longitude,
      address: '123 Test St, Test City',
      category: category,
      tags: ['test', 'widget'],
      rating: 4.5,
      priceLevel: PriceLevel.moderate,
      phoneNumber: '+1-555-0123',
      website: 'https://test.example.com',
      hours: {},
      amenities: [],
      ageRestrictions: AgeRestrictions(
        isAgeRestricted: false,
        minimumAge: null,
        requiresVerification: false,
      ),
      accessibilityInfo: AccessibilityInfo(
        isWheelchairAccessible: true,
        hasAudioAssistance: false,
        hasVisualAssistance: false,
        additionalInfo: null,
      ),
      createdBy: 'test-user-id',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: false,
      verificationLevel: VerificationLevel.none,
      moderationStatus: ModerationStatus.approved,
      reportCount: 0,
    );
  }

  /// Creates test list data
  static SpotList createTestList({
    String id = 'test-list-id',
    String name = 'Test List',
    String curatorId = 'test-user-id',
    ListType type = ListType.public,
  }) {
    return SpotList(
      id: id,
      name: name,
      description: 'A test list for widget testing',
      curatorId: curatorId,
      type: type,
      category: ListCategory.general,
      tags: ['test', 'widget'],
      spots: [],
      members: [
        ListMember(
          userId: curatorId,
          role: ListRole.curator,
          joinedAt: DateTime.now(),
          permissions: MemberPermissions(
            canAddSpots: true,
            canRemoveSpots: true,
            canEditSpots: true,
            canInviteMembers: true,
            canModerate: true,
          ),
        ),
      ],
      settings: ListSettings(
        isPrivate: type == ListType.private,
        requiresApproval: true,
        allowsComments: true,
        allowsRatings: true,
        moderationLevel: ModerationLevel.standard,
      ),
      ageRestrictions: AgeRestrictions(
        isAgeRestricted: false,
        minimumAge: null,
        requiresVerification: false,
      ),
      analytics: ListAnalytics(
        viewCount: 0,
        memberCount: 1,
        spotCount: 0,
        averageRating: 0.0,
        engagementScore: 0.0,
        lastActivityAt: DateTime.now(),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      moderationStatus: ModerationStatus.approved,
      reportCount: 0,
    );
  }

  /// Verifies that form validation works correctly
  static Future<void> verifyFormValidation(
    WidgetTester tester, {
    required String formKey,
    required Map<String, String> invalidInputs,
    required Map<String, String> expectedErrors,
  }) async {
    // Input invalid data
    for (final entry in invalidInputs.entries) {
      await tester.enterText(find.byKey(Key(entry.key)), entry.value);
    }

    // Try to submit form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify validation errors appear
    for (final entry in expectedErrors.entries) {
      expect(find.text(entry.value), findsOneWidget);
    }
  }

  /// Simulates user interaction delays
  static Future<void> simulateUserDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 100));
  }

  /// Finds widgets by accessibility semantics
  static Finder findBySemantics(String label) {
    return find.bySemanticsLabel(label);
  }

  /// Verifies accessibility requirements
  static void verifyAccessibility(WidgetTester tester) {
    // Verify semantic labels exist for important elements
    expect(find.bySemanticsLabel(RegExp(r'.*')), findsWidgets);
    
    // Could add more accessibility checks here like:
    // - Minimum touch target sizes
    // - Contrast ratios
    // - Screen reader compatibility
  }
}

/// Test data factory for creating consistent test objects
class TestDataFactory {
  static const String defaultUserId = 'test-user-id';
  static const String defaultEmail = 'test@example.com';
  static const String defaultSpotId = 'test-spot-id';
  static const String defaultListId = 'test-list-id';

  /// Creates a complete user profile for testing
  static UnifiedUser createCompleteUserProfile({
    UserRole role = UserRole.follower,
  }) {
    return WidgetTestHelpers.createTestUser(
      id: defaultUserId,
      email: defaultEmail,
      role: role,
    );
  }

  /// Creates multiple test spots for list testing
  static List<Spot> createTestSpots(int count) {
    return List.generate(count, (index) {
      return WidgetTestHelpers.createTestSpot(
        id: 'test-spot-$index',
        name: 'Test Spot $index',
        latitude: 40.7128 + (index * 0.001),
        longitude: -74.0060 + (index * 0.001),
      );
    });
  }

  /// Creates multiple test lists for testing
  static List<SpotList> createTestLists(int count) {
    return List.generate(count, (index) {
      return WidgetTestHelpers.createTestList(
        id: 'test-list-$index',
        name: 'Test List $index',
      );
    });
  }
}

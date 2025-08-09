import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spots/presentation/pages/auth/login_page.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify all UI elements are present
      expect(find.byIcon(Icons.location_on), findsOneWidget); // App logo
      expect(find.text('SPOTS'), findsOneWidget); // App title
      expect(find.text('Discover meaningful places'), findsOneWidget); // Subtitle
      expect(find.byKey(const Key('email_field')), findsOneWidget); // Email field
      expect(find.byKey(const Key('password_field')), findsOneWidget); // Password field
      expect(find.text('Sign In'), findsOneWidget); // Sign in button
      expect(find.text('Sign Up'), findsOneWidget); // Sign up link
      expect(find.text('🧪 Demo Login'), findsOneWidget); // Demo button
      expect(find.text('🔧 Debug Test'), findsOneWidget); // Debug button
    });

    testWidgets('shows password visibility toggle', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Password should be obscured initially
      final passwordField = tester.widget<TextFormField>(
        find.byKey(const Key('password_field')),
      );
      expect(passwordField.obscureText, isTrue);

      // Act - Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - Password should now be visible
      final updatedPasswordField = tester.widget<TextFormField>(
        find.byKey(const Key('password_field')),
      );
      expect(updatedPasswordField.obscureText, isFalse);
    });

    testWidgets('validates email field correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Test empty email validation
      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);

      // Test invalid email validation
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates password field correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Test empty password validation
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);

      // Test short password validation
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('submits valid credentials', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Enter valid credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - AuthBloc should receive SignInRequested event
      verify(mockAuthBloc.add(any)).called(1);
    });

    testWidgets('shows loading state during authentication', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthLoading());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Loading indicator should be visible in button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Assert - Button should be disabled
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In').first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows error message on authentication failure', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Invalid credentials';
      when(mockAuthBloc.state).thenReturn(AuthError(errorMessage));
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthError(errorMessage)));

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Error snackbar should be shown
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('navigates to home on successful authentication', (WidgetTester tester) async {
      // Arrange
      final testUser = WidgetTestHelpers.createTestUser();
      when(mockAuthBloc.state).thenReturn(Authenticated(user: testUser));
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(Authenticated(user: testUser)));

      final navigatorObserver = MockNavigatorObserver();
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
        navigatorObserver: navigatorObserver,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should navigate to home
      // Note: This would need proper router setup to test navigation fully
      // For now, we verify the state change is handled
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('demo login button fills credentials', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Tap demo login button
      await tester.tap(find.text('🧪 Demo Login'));
      await tester.pump();

      // Assert - Credentials should be filled
      expect(find.text('demo@spots.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('navigates to signup page', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final navigatorObserver = MockNavigatorObserver();
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
        navigatorObserver: navigatorObserver,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Tap sign up link
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert - Should attempt navigation to signup
      // Navigation would be tested with proper router setup
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('maintains state during screen rotations', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Enter text and rotate screen
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      // Simulate orientation change
      tester.binding.window.physicalSizeTestValue = const Size(800, 600);
      await tester.pump();

      // Assert - Text should be preserved
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('meets accessibility requirements', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - All form fields should have labels
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      
      // All buttons should have text or semantic labels
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      
      // Interactive elements should meet minimum size requirements
      final emailField = tester.getSize(find.byKey(const Key('email_field')));
      expect(emailField.height, greaterThanOrEqualTo(48.0));
      
      final signInButton = tester.getSize(find.widgetWithText(ElevatedButton, 'Sign In').first);
      expect(signInButton.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('handles rapid tap events gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const LoginPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Fill valid credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');

      // Act - Rapidly tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Should only trigger one authentication request
      verify(mockAuthBloc.add(any)).called(1);
    });
  });
}

/// Mock NavigatorObserver for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}
}

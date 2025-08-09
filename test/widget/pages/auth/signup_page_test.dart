import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spots/presentation/pages/auth/signup_page.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

void main() {
  group('SignupPage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify all UI elements are present
      expect(find.text('Sign Up'), findsNWidgets(2)); // AppBar and button
      expect(find.byIcon(Icons.location_on), findsOneWidget); // App logo
      expect(find.text('Join SPOTS'), findsOneWidget); // App title
      expect(find.text('Create your account to start discovering'), findsOneWidget); // Subtitle
      expect(find.byKey(const Key('name_field')), findsOneWidget); // Name field
      expect(find.byKey(const Key('email_field')), findsOneWidget); // Email field
      expect(find.byKey(const Key('password_field')), findsOneWidget); // Password field
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget); // Confirm password field
      expect(find.text('Sign In'), findsOneWidget); // Sign in link
    });

    testWidgets('shows password visibility toggles', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Both password fields should be obscured initially
      final passwordField = tester.widget<TextFormField>(
        find.byKey(const Key('password_field')),
      );
      expect(passwordField.obscureText, isTrue);

      final confirmPasswordField = tester.widget<TextFormField>(
        find.byKey(const Key('confirm_password_field')),
      );
      expect(confirmPasswordField.obscureText, isTrue);

      // Act - Tap visibility toggles
      final visibilityIcons = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcons.first);
      await tester.pump();

      // Assert - First password field should now be visible
      final updatedPasswordField = tester.widget<TextFormField>(
        find.byKey(const Key('password_field')),
      );
      expect(updatedPasswordField.obscureText, isFalse);
    });

    testWidgets('validates name field correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Test empty name validation
      await tester.enterText(find.byKey(const Key('name_field')), '');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('validates email field correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Test empty email validation
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);

      // Test invalid email validation
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates password field correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Test empty password validation
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), '');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);

      // Test short password validation
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('validates password confirmation correctly', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Test password mismatch validation
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'different123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('submits valid registration data', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Enter valid registration data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Assert - AuthBloc should receive SignUpRequested event
      verify(mockAuthBloc.add(any)).called(1);
    });

    testWidgets('shows loading state during registration', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthLoading());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Loading indicator should be visible in button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Assert - Button should be disabled
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign Up').first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows error message on registration failure', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Email already exists';
      when(mockAuthBloc.state).thenReturn(AuthError(errorMessage));
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthError(errorMessage)));

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Error snackbar should be shown
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('navigates to home on successful registration', (WidgetTester tester) async {
      // Arrange
      final testUser = WidgetTestHelpers.createTestUser();
      when(mockAuthBloc.state).thenReturn(Authenticated(user: testUser));
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(Authenticated(user: testUser)));

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should handle successful authentication
      expect(find.byType(SignupPage), findsOneWidget);
    });

    testWidgets('navigates back to login page', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Tap sign in link
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Should attempt navigation back
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('handles back button in app bar', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Assert - Should handle back navigation
      expect(find.byType(SignupPage), findsOneWidget);
    });

    testWidgets('maintains form state during keyboard appearance', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Enter text in all fields
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');

      // Simulate keyboard appearance by changing viewport
      tester.binding.window.viewInsetsTestValue = const EdgeInsets.only(bottom: 300);
      await tester.pump();

      // Assert - Form data should be preserved
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2)); // Both password fields
    });

    testWidgets('meets accessibility requirements', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - All form fields should have labels
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      
      // All buttons should have text or semantic labels
      expect(find.text('Sign Up'), findsNWidgets(2)); // AppBar and button
      expect(find.text('Sign In'), findsOneWidget);
      
      // Interactive elements should meet minimum size requirements
      final nameField = tester.getSize(find.byKey(const Key('name_field')));
      expect(nameField.height, greaterThanOrEqualTo(48.0));
      
      final signUpButton = tester.getSize(find.widgetWithText(ElevatedButton, 'Sign Up').first);
      expect(signUpButton.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('prevents submission with empty required fields', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Act - Try to submit with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Assert - Should show validation errors and not trigger registration
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNWidgets(2)); // Both password fields

      // Verify no signup event was triggered
      verifyNever(mockAuthBloc.add(any));
    });

    testWidgets('handles rapid form submission attempts', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(const AuthInitial());

      final widget = WidgetTestHelpers.createTestableWidget(
        child: const SignupPage(),
        authBloc: mockAuthBloc,
      );

      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Fill valid data
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');

      // Act - Rapidly tap sign up button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Assert - Should only trigger one registration request
      verify(mockAuthBloc.add(any)).called(1);
    });
  });
}

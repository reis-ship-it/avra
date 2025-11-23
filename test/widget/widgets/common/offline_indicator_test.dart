import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spots/presentation/widgets/common/offline_indicator.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/core/models/user.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for OfflineIndicator
/// Tests offline indicator display based on auth state
void main() {
  group('OfflineIndicator Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('displays offline indicator when user is offline', (WidgetTester tester) async {
      // Arrange
      final testUser = User(
        id: 'test-user',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
      );
      when(mockAuthBloc.state).thenReturn(Authenticated(user: testUser, isOffline: true));
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OfflineIndicator(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show offline indicator
      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('does not display when user is online', (WidgetTester tester) async {
      // Arrange
      final testUser = User(
        id: 'test-user',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
      );
      when(mockAuthBloc.state).thenReturn(Authenticated(user: testUser, isOffline: false));
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OfflineIndicator(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should not show offline indicator
      expect(find.text('Offline'), findsNothing);
    });

    testWidgets('does not display when user is not authenticated', (WidgetTester tester) async {
      // Arrange
      when(mockAuthBloc.state).thenReturn(Unauthenticated());
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const OfflineIndicator(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should not show offline indicator
      expect(find.text('Offline'), findsNothing);
    });
  });
}


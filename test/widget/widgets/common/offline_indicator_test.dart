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

    // Removed: Property assignment tests
    // Offline indicator tests focus on business logic (offline indicator display based on auth state), not property assignment

    testWidgets(
        'should display offline indicator when user is offline, not display when user is online, or not display when user is not authenticated',
        (WidgetTester tester) async {
      // Test business logic: Offline indicator display based on auth state
      final testUser = User(
        id: 'test-user',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
      );
      when(mockAuthBloc.state)
          .thenReturn(Authenticated(user: testUser, isOffline: true));
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const OfflineIndicator(),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      when(mockAuthBloc.state)
          .thenReturn(Authenticated(user: testUser, isOffline: false));
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const OfflineIndicator(),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Offline'), findsNothing);

      when(mockAuthBloc.state).thenReturn(Unauthenticated());
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const OfflineIndicator(),
        authBloc: mockAuthBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('Offline'), findsNothing);
    });
  });
}

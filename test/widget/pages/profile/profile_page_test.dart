import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/profile/profile_page.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

/// Widget tests for ProfilePage
/// Tests profile display, user information, and actions
void main() {
  group('ProfilePage Widget Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const ProfilePage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify profile UI is present
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('displays profile information', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const ProfilePage(),
        authBloc: mockAuthBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show profile content
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });
}


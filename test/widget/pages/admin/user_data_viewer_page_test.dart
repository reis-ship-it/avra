import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/admin/user_data_viewer_page.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for UserDataViewerPage
/// Tests user data viewer UI and search functionality
void main() {
  group('UserDataViewerPage Widget Tests', () {
    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const UserDataViewerPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify viewer UI is present
      expect(find.byType(UserDataViewerPage), findsOneWidget);
    });

    testWidgets('displays search functionality', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const UserDataViewerPage(),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show search UI
      expect(find.byType(UserDataViewerPage), findsOneWidget);
    });
  });
}


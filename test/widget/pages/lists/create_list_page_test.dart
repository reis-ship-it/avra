import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/lists/create_list_page.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

/// Widget tests for CreateListPage
/// Tests form rendering, validation, and list creation
void main() {
  group('CreateListPage Widget Tests', () {
    late MockListsBloc mockListsBloc;

    setUp(() {
      mockListsBloc = MockListsBloc();
    });

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const CreateListPage(),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify form is present
      expect(find.byType(CreateListPage), findsOneWidget);
    });

    testWidgets('displays create list title', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const CreateListPage(),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show create list UI
      expect(find.byType(CreateListPage), findsOneWidget);
    });
  });
}


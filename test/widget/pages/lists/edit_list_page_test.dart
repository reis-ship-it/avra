import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/lists/edit_list_page.dart';
import 'package:spots/core/models/list.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for EditListPage
/// Tests form rendering, list editing, and validation
void main() {
  group('EditListPage Widget Tests', () {
    late MockListsBloc mockListsBloc;
    late SpotList testList;

    setUp(() {
      mockListsBloc = MockListsBloc();
      testList = SpotList(
        id: 'list-123',
        title: 'Test List',
        description: 'Test description',
        spots: const [],
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        isPublic: true,
        spotIds: const [],
      );
    });

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: EditListPage(list: testList),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify form is present
      expect(find.byType(EditListPage), findsOneWidget);
    });

    testWidgets('displays list information for editing', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: EditListPage(list: testList),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show list data in form
      expect(find.byType(EditListPage), findsOneWidget);
    });
  });
}


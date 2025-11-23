import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/lists/list_details_page.dart';
import 'package:spots/core/models/list.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for ListDetailsPage
/// Tests list details display, actions, and navigation
void main() {
  group('ListDetailsPage Widget Tests', () {
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

    testWidgets('displays list title in app bar', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: ListDetailsPage(list: testList),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show list title
      expect(find.text('Test List'), findsOneWidget);
    });

    testWidgets('displays list details', (WidgetTester tester) async {
      // Arrange
      final detailedList = SpotList(
        id: 'list-456',
        title: 'Detailed List',
        description: 'Detailed description',
        spots: const [],
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        isPublic: true,
        spotIds: const [],
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: ListDetailsPage(list: detailedList),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show list details
      expect(find.text('Detailed List'), findsOneWidget);
    });
  });
}


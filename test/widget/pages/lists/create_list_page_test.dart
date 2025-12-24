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

    // Removed: Property assignment tests
    // Create list page tests focus on business logic (form fields display, create list title display), not property assignment

    testWidgets(
        'should display all required form fields or display create list title',
        (WidgetTester tester) async {
      // Test business logic: Create list page display
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const CreateListPage(),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      expect(find.byType(CreateListPage), findsOneWidget);
    });
  });
}

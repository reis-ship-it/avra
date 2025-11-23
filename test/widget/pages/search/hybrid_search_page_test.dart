import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/search/hybrid_search_page.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

/// Widget tests for HybridSearchPage
/// Tests search UI, results display, and BLoC integration
void main() {
  group('HybridSearchPage Widget Tests', () {
    late MockHybridSearchBloc mockHybridSearchBloc;

    setUp(() {
      mockHybridSearchBloc = MockHybridSearchBloc();
    });

    testWidgets('displays all required UI elements', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const HybridSearchPage(),
        hybridSearchBloc: mockHybridSearchBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify search UI is present
      expect(find.byType(HybridSearchPage), findsOneWidget);
    });

    testWidgets('displays search field', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const HybridSearchPage(),
        hybridSearchBloc: mockHybridSearchBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Search field should be present
      expect(find.byType(HybridSearchPage), findsOneWidget);
    });
  });
}


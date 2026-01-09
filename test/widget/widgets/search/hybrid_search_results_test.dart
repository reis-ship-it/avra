import 'package:flutter_test/flutter_test.dart';
import 'package:avrai/presentation/widgets/search/hybrid_search_results.dart';
import 'package:avrai/presentation/blocs/search/hybrid_search_bloc.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

/// Widget tests for HybridSearchResults
/// Tests search results display and BLoC integration
void main() {
  group('HybridSearchResults Widget Tests', () {
    // Removed: Property assignment tests
    // Hybrid search results tests focus on business logic (search results display, state management), not property assignment

    testWidgets(
        'should display initial state message, display loading state, or display error state',
        (WidgetTester tester) async {
      // Test business logic: hybrid search results display and state management
      final blocInitial = MockHybridSearchBloc()..setState(HybridSearchInitial());
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const HybridSearchResults(),
        hybridSearchBloc: blocInitial,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Search for spots'), findsOneWidget);
      expect(find.text('Find community spots and external places'),
          findsOneWidget);

      final blocLoading = MockHybridSearchBloc()..setState(HybridSearchLoading());
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const HybridSearchResults(),
        hybridSearchBloc: blocLoading,
      );
      await tester.pumpWidget(widget2);
      await tester.pump();
      expect(find.text('Searching community and external sources...'),
          findsOneWidget);

      final blocError =
          MockHybridSearchBloc()..setState(HybridSearchError('Test error'));
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const HybridSearchResults(),
        hybridSearchBloc: blocError,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('Test error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

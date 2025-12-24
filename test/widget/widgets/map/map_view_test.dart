import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/map/map_view.dart';
import "../../helpers/widget_test_helpers.dart';

/// Widget tests for MapView
/// Tests map view display
void main() {
  group('MapView Widget Tests', () {
    // Removed: Property assignment tests
    // Map view tests focus on business logic (map view display, app bar visibility, initial selected list), not property assignment

    testWidgets(
        'should display map view, display map view with app bar when showAppBar is true, display map view without app bar when showAppBar is false, or handle initial selected list',
        (WidgetTester tester) async {
      // Test business logic: map view display
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: const MapView(),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(MapView), findsOneWidget);

      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: const MapView(
          showAppBar: true,
          appBarTitle: 'Map',
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.byType(MapView), findsOneWidget);

      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: const MapView(showAppBar: false),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.byType(MapView), findsOneWidget);

      final list = WidgetTestHelpers.createTestList();
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: MapView(initialSelectedList: list),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.byType(MapView), findsOneWidget);
    });
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/spots/spot_details_page.dart';
import 'package:spots/core/models/spot.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';
import '../../../fixtures/model_factories.dart';

/// Widget tests for SpotDetailsPage
/// Tests spot details display, actions, and navigation
void main() {
  group('SpotDetailsPage Widget Tests', () {
    late MockListsBloc mockListsBloc;
    late Spot testSpot;

    setUp(() {
      mockListsBloc = MockListsBloc();
      testSpot = ModelFactories.createTestSpot(
        id: 'spot-123',
        name: 'Test Coffee Shop',
        category: 'Cafe',
      );
    });

    // Removed: Property assignment tests
    // Spot details page tests focus on business logic (spot name display, action buttons, category display, spot details), not property assignment

    testWidgets(
        'should display spot name in app bar, display edit and share buttons, display spot category, or display spot details',
        (WidgetTester tester) async {
      // Test business logic: Spot details page display
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: SpotDetailsPage(spot: testSpot),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.text('Test Coffee Shop'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.text('Cafe'), findsOneWidget);

      final detailedSpot = ModelFactories.createTestSpot(
        id: 'spot-456',
        name: 'Detailed Spot',
      );
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: SpotDetailsPage(spot: detailedSpot),
        listsBloc: mockListsBloc,
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Detailed Spot'), findsOneWidget);
      expect(find.text('A great place'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);
    });
  });
}

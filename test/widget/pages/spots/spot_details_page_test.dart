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

    testWidgets('displays spot name in app bar', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotDetailsPage(spot: testSpot),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show spot name
      expect(find.text('Test Coffee Shop'), findsOneWidget);
    });

    testWidgets('displays edit and share buttons', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotDetailsPage(spot: testSpot),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show action buttons
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('displays spot category', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotDetailsPage(spot: testSpot),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show category
      expect(find.text('Cafe'), findsOneWidget);
    });

    testWidgets('displays spot details', (WidgetTester tester) async {
      // Arrange
      final detailedSpot = ModelFactories.createTestSpot(
        id: 'spot-456',
        name: 'Detailed Spot',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotDetailsPage(spot: detailedSpot),
        listsBloc: mockListsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show spot details
      expect(find.text('Detailed Spot'), findsOneWidget);
      expect(find.text('A great place'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);
    });
  });
}


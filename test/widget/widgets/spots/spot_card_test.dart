import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/spots/spot_card.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../fixtures/model_factories.dart';

/// Widget tests for SpotCard
/// Tests spot card display and interactions
void main() {
  group('SpotCard Widget Tests', () {
    testWidgets('displays spot information correctly', (WidgetTester tester) async {
      // Arrange
      final testSpot = ModelFactories.createTestSpot(
        id: 'spot-123',
        name: 'Test Coffee Shop',
        category: 'Cafe',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotCard(spot: testSpot),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show spot information
      expect(find.text('Test Coffee Shop'), findsOneWidget);
      expect(find.text('Cafe'), findsOneWidget);
    });

    testWidgets('displays spot rating when available', (WidgetTester tester) async {
      // Arrange
      final testSpot = ModelFactories.createTestSpot(
        id: 'spot-123',
        name: 'Rated Spot',
        category: 'Restaurant',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotCard(spot: testSpot),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show rating
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final testSpot = ModelFactories.createTestSpot(id: 'spot-123');
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotCard(
          spot: testSpot,
          onTap: () => wasTapped = true,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      await tester.tap(find.byType(SpotCard));
      await tester.pump();

      // Assert - Callback should be called
      expect(wasTapped, isTrue);
    });

    testWidgets('displays custom trailing widget', (WidgetTester tester) async {
      // Arrange
      final testSpot = ModelFactories.createTestSpot(id: 'spot-123');
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotCard(
          spot: testSpot,
          trailing: const Icon(Icons.favorite),
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show custom trailing widget
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}


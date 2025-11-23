import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/lists/spot_list_card.dart';
import 'package:spots/core/models/list.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for SpotListCard
/// Tests list card display and interactions
void main() {
  group('SpotListCard Widget Tests', () {
    testWidgets('displays list information correctly', (WidgetTester tester) async {
      // Arrange
      final testList = SpotList(
        id: 'list-123',
        title: 'Test List',
        description: 'Test description',
        spots: const [],
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        spotIds: const ['spot-1', 'spot-2'],
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotListCard(list: testList),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show list information
      expect(find.text('Test List'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('2 spots'), findsOneWidget);
    });

    testWidgets('displays category when available', (WidgetTester tester) async {
      // Arrange
      final testList = SpotList(
        id: 'list-123',
        title: 'Test List',
        description: 'Test description',
        category: 'Food & Dining',
        spots: const [],
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        spotIds: const [],
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotListCard(list: testList),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show category
      expect(find.text('Food & Dining'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final testList = SpotList(
        id: 'list-123',
        title: 'Test List',
        description: 'Test description',
        spots: const [],
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        spotIds: const [],
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotListCard(
          list: testList,
          onTap: () => wasTapped = true,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      await tester.tap(find.byType(SpotListCard));
      await tester.pump();

      // Assert - Callback should be called
      expect(wasTapped, isTrue);
    });

    testWidgets('displays custom trailing widget', (WidgetTester tester) async {
      // Arrange
      final testList = SpotList(
        id: 'list-123',
        title: 'Test List',
        description: 'Test description',
        spots: const [],
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        spotIds: const [],
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: SpotListCard(
          list: testList,
          trailing: const Icon(Icons.more_vert),
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show custom trailing widget
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/expertise/expertise_badge_widget.dart';
import 'package:spots/core/models/expertise_pin.dart';
import 'package:spots/core/models/expertise_level.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for ExpertiseBadgeWidget
/// Tests expertise badge display
void main() {
  group('ExpertiseBadgeWidget Widget Tests', () {
    testWidgets('displays badge when expert pins are provided', (WidgetTester tester) async {
      // Arrange
      final testPin = ExpertisePin(
        id: 'pin-123',
        userId: 'user-123',
        category: 'Coffee',
        level: ExpertiseLevel.city,
        earnedAt: TestHelpers.createTestDateTime(),
        earnedReason: 'Test',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseBadgeWidget(
          expertPins: [testPin],
          category: 'Coffee',
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show badge
      expect(find.text('Expert'), findsOneWidget);
    });

    testWidgets('does not display when no relevant pins', (WidgetTester tester) async {
      // Arrange
      final testPin = ExpertisePin(
        id: 'pin-123',
        userId: 'user-123',
        category: 'Coffee',
        level: ExpertiseLevel.city,
        earnedAt: TestHelpers.createTestDateTime(),
        earnedReason: 'Test',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseBadgeWidget(
          expertPins: [testPin],
          category: 'Restaurant', // Different category
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should not show badge
      expect(find.text('Expert'), findsNothing);
    });

    testWidgets('displays compact badge when compact is true', (WidgetTester tester) async {
      // Arrange
      final testPin = ExpertisePin(
        id: 'pin-123',
        userId: 'user-123',
        category: 'Coffee',
        level: ExpertiseLevel.city,
        earnedAt: TestHelpers.createTestDateTime(),
        earnedReason: 'Test',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseBadgeWidget(
          expertPins: [testPin],
          category: 'Coffee',
          compact: true,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show compact badge
      expect(find.text('Expert'), findsOneWidget);
    });
  });
}


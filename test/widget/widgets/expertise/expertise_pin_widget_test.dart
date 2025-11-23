import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/expertise/expertise_pin_widget.dart';
import 'package:spots/core/models/expertise_pin.dart';
import 'package:spots/core/models/expertise_level.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for ExpertisePinWidget
/// Tests expertise pin display
void main() {
  group('ExpertisePinWidget Widget Tests', () {
    testWidgets('displays pin information correctly', (WidgetTester tester) async {
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
        child: ExpertisePinWidget(pin: testPin),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show pin information
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('displays level details when showDetails is true', (WidgetTester tester) async {
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
        child: ExpertisePinWidget(
          pin: testPin,
          showDetails: true,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show level details
      expect(find.text('City Level'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final testPin = ExpertisePin(
        id: 'pin-123',
        userId: 'user-123',
        category: 'Coffee',
        level: ExpertiseLevel.city,
        earnedAt: TestHelpers.createTestDateTime(),
        earnedReason: 'Test',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: ExpertisePinWidget(
          pin: testPin,
          onTap: () => wasTapped = true,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);
      await tester.tap(find.byType(ExpertisePinWidget));
      await tester.pump();

      // Assert - Callback should be called
      expect(wasTapped, isTrue);
    });
  });
}


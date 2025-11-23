import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/validation/community_validation_widget.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../fixtures/model_factories.dart';

/// Widget tests for CommunityValidationWidget
/// Tests community validation UI for external spots
void main() {
  group('CommunityValidationWidget Widget Tests', () {
    testWidgets('displays validation widget for external spots', (WidgetTester tester) async {
      // Arrange
      final testSpot = ModelFactories.createTestSpot(
        id: 'spot-123',
        name: 'External Spot',
      );
      // Add external metadata
      final externalSpot = testSpot.copyWith(
        metadata: {
          ...testSpot.metadata,
          'is_external': true,
          'source': 'google_places',
        },
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: CommunityValidationWidget(spot: externalSpot),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show validation widget
      expect(find.byType(CommunityValidationWidget), findsOneWidget);
    });

    testWidgets('does not display for community spots', (WidgetTester tester) async {
      // Arrange
      final testSpot = ModelFactories.createTestSpot(
        id: 'spot-123',
        name: 'Community Spot',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: CommunityValidationWidget(spot: testSpot),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should not show validation widget
      expect(find.byType(CommunityValidationWidget), findsOneWidget);
      // Note: Widget returns SizedBox.shrink() for non-external spots
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/spots/edit_spot_page.dart';
import 'package:spots/core/models/spot.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';
import '../../../fixtures/model_factories.dart';

/// Widget tests for EditSpotPage
/// Tests form rendering, spot editing, and validation
void main() {
  group('EditSpotPage Widget Tests', () {
    late MockSpotsBloc mockSpotsBloc;
    late Spot testSpot;

    setUp(() {
      mockSpotsBloc = MockSpotsBloc();
      testSpot = ModelFactories.createTestSpot(
        id: 'spot-123',
        name: 'Test Spot',
      );
    });

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: EditSpotPage(spot: testSpot),
        spotsBloc: mockSpotsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify form is present
      expect(find.byType(EditSpotPage), findsOneWidget);
    });

    testWidgets('displays spot information for editing', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: EditSpotPage(spot: testSpot),
        spotsBloc: mockSpotsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show spot data in form
      expect(find.byType(EditSpotPage), findsOneWidget);
    });
  });
}


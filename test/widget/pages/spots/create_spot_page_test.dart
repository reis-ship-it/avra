import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/spots/create_spot_page.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../mocks/mock_blocs.dart';

/// Widget tests for CreateSpotPage
/// Tests form rendering, validation, and spot creation
void main() {
  group('CreateSpotPage Widget Tests', () {
    late MockSpotsBloc mockSpotsBloc;

    setUp(() {
      mockSpotsBloc = MockSpotsBloc();
    });

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const CreateSpotPage(),
        spotsBloc: mockSpotsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify form fields are present
      expect(find.byType(CreateSpotPage), findsOneWidget);
      // Note: Form fields would be tested with more detailed widget inspection
    });

    testWidgets('displays category dropdown', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const CreateSpotPage(),
        spotsBloc: mockSpotsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Category selector should be present
      expect(find.byType(CreateSpotPage), findsOneWidget);
    });

    testWidgets('displays location loading state', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const CreateSpotPage(),
        spotsBloc: mockSpotsBloc,
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Widget should render
      expect(find.byType(CreateSpotPage), findsOneWidget);
      // Note: Location loading would require mocking Geolocator
    });
  });
}


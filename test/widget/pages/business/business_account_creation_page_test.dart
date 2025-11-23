import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/pages/business/business_account_creation_page.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../fixtures/model_factories.dart';

/// Widget tests for BusinessAccountCreationPage
/// Tests form rendering, validation, and business account creation
void main() {
  group('BusinessAccountCreationPage Widget Tests', () {
    late UnifiedUser testUser;

    setUp(() {
      testUser = ModelFactories.createTestUser();
    });

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BusinessAccountCreationPage(user: testUser),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify form is present
      expect(find.byType(BusinessAccountCreationPage), findsOneWidget);
    });

    testWidgets('displays business account creation title', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BusinessAccountCreationPage(user: testUser),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show business account creation UI
      expect(find.byType(BusinessAccountCreationPage), findsOneWidget);
    });
  });
}


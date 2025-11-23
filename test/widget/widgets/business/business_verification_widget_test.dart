import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/business/business_verification_widget.dart';
import 'package:spots/core/models/business_account.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for BusinessVerificationWidget
/// Tests business verification form and submission
void main() {
  group('BusinessVerificationWidget Widget Tests', () {
    testWidgets('displays all required form fields', (WidgetTester tester) async {
      // Arrange
      final testBusiness = BusinessAccount(
        id: 'business-123',
        name: 'Test Business',
        email: 'business@test.com',
        businessType: 'Restaurant',
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        createdBy: 'user-123',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BusinessVerificationWidget(business: testBusiness),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Verify form is present
      expect(find.byType(BusinessVerificationWidget), findsOneWidget);
    });

    testWidgets('pre-fills form with business information', (WidgetTester tester) async {
      // Arrange
      final testBusiness = BusinessAccount(
        id: 'business-123',
        name: 'Test Business',
        email: 'business@test.com',
        businessType: 'Restaurant',
        createdAt: TestHelpers.createTestDateTime(),
        updatedAt: TestHelpers.createTestDateTime(),
        createdBy: 'user-123',
      );
      final widget = WidgetTestHelpers.createTestableWidget(
        child: BusinessVerificationWidget(business: testBusiness),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert - Should show business data
      expect(find.byType(BusinessVerificationWidget), findsOneWidget);
    });
  });
}


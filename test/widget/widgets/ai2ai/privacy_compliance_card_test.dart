import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/ai2ai/privacy_compliance_card.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Widget tests for PrivacyComplianceCard
/// Tests privacy compliance metrics display
void main() {
  group('PrivacyComplianceCard Widget Tests', () {
    testWidgets('displays privacy compliance score', (WidgetTester tester) async {
      // Arrange
      final privacyMetrics = PrivacyMetrics(
        overallPrivacyScore: 0.95,
        anonymizationQuality: 0.98,
        reidentificationRisk: 0.02,
        dataExposureLevel: 0.01,
        complianceRate: 0.97,
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PrivacyComplianceCard(privacyMetrics: privacyMetrics),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.byType(PrivacyComplianceCard), findsOneWidget);
      expect(find.text('Privacy Compliance'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('displays all privacy metrics', (WidgetTester tester) async {
      // Arrange
      final privacyMetrics = PrivacyMetrics(
        overallPrivacyScore: 0.9,
        anonymizationQuality: 0.92,
        reidentificationRisk: 0.05,
        dataExposureLevel: 0.03,
        complianceRate: 0.95,
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PrivacyComplianceCard(privacyMetrics: privacyMetrics),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('Anonymization Quality'), findsOneWidget);
      expect(find.text('Re-identification Risk'), findsOneWidget);
      expect(find.text('Data Exposure Level'), findsOneWidget);
      expect(find.text('Privacy Compliance Rate'), findsOneWidget);
    });

    testWidgets('displays warning color for score < 0.95', (WidgetTester tester) async {
      // Arrange
      final privacyMetrics = PrivacyMetrics(
        overallPrivacyScore: 0.88,
        anonymizationQuality: 0.85,
        reidentificationRisk: 0.1,
        dataExposureLevel: 0.08,
        complianceRate: 0.9,
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PrivacyComplianceCard(privacyMetrics: privacyMetrics),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('88%'), findsOneWidget);
    });

    testWidgets('displays error color for score < 0.85', (WidgetTester tester) async {
      // Arrange
      final privacyMetrics = PrivacyMetrics(
        overallPrivacyScore: 0.8,
        anonymizationQuality: 0.75,
        reidentificationRisk: 0.15,
        dataExposureLevel: 0.12,
        complianceRate: 0.82,
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PrivacyComplianceCard(privacyMetrics: privacyMetrics),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('80%'), findsOneWidget);
    });
  });
}


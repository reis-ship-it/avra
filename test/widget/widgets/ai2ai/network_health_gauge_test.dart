import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/ai2ai/network_health_gauge.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for NetworkHealthGauge
/// Tests network health score display
void main() {
  group('NetworkHealthGauge Widget Tests', () {
    testWidgets('displays network health score', (WidgetTester tester) async {
      // Arrange
      final healthReport = NetworkHealthReport(
        overallHealthScore: 0.85,
        totalActiveConnections: 10,
        networkUtilization: 0.6,
        averageLatency: Duration(milliseconds: 50),
        averageThroughput: 1000.0,
        connectionQualityDistribution: {},
        performanceMetrics: {},
        privacyMetrics: PrivacyMetrics.empty(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: NetworkHealthGauge(healthReport: healthReport),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.byType(NetworkHealthGauge), findsOneWidget);
      expect(find.text('Network Health'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('displays good health label for score >= 0.6', (WidgetTester tester) async {
      // Arrange
      final healthReport = NetworkHealthReport(
        overallHealthScore: 0.7,
        totalActiveConnections: 5,
        networkUtilization: 0.5,
        averageLatency: Duration(milliseconds: 100),
        averageThroughput: 800.0,
        connectionQualityDistribution: {},
        performanceMetrics: {},
        privacyMetrics: PrivacyMetrics.empty(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: NetworkHealthGauge(healthReport: healthReport),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
    });

    testWidgets('displays poor health label for score < 0.6', (WidgetTester tester) async {
      // Arrange
      final healthReport = NetworkHealthReport(
        overallHealthScore: 0.4,
        totalActiveConnections: 2,
        networkUtilization: 0.3,
        averageLatency: Duration(milliseconds: 500),
        averageThroughput: 200.0,
        connectionQualityDistribution: {},
        performanceMetrics: {},
        privacyMetrics: PrivacyMetrics.empty(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: NetworkHealthGauge(healthReport: healthReport),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Poor'), findsOneWidget);
    });

    testWidgets('displays network statistics', (WidgetTester tester) async {
      // Arrange
      final healthReport = NetworkHealthReport(
        overallHealthScore: 0.8,
        totalActiveConnections: 15,
        networkUtilization: 0.75,
        averageLatency: Duration(milliseconds: 50),
        averageThroughput: 1500.0,
        connectionQualityDistribution: {},
        performanceMetrics: {},
        privacyMetrics: PrivacyMetrics.empty(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: NetworkHealthGauge(healthReport: healthReport),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('Active Connections'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Network Utilization'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });
  });
}


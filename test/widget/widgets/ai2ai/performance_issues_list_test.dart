import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/ai2ai/performance_issues_list.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for PerformanceIssuesList
/// Tests performance issues and recommendations display
void main() {
  group('PerformanceIssuesList Widget Tests', () {
    testWidgets('displays empty state when no issues or recommendations', (WidgetTester tester) async {
      // Arrange
      final widget = WidgetTestHelpers.createTestableWidget(
        child: const PerformanceIssuesList(
          issues: [],
          recommendations: [],
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.byType(PerformanceIssuesList), findsOneWidget);
      expect(find.text('Performance & Optimization'), findsOneWidget);
      expect(find.text('No issues detected. Network operating optimally.'), findsOneWidget);
    });

    testWidgets('displays performance issues', (WidgetTester tester) async {
      // Arrange
      final issues = [
        PerformanceIssue(
          id: 'issue-1',
          description: 'High latency detected',
          severity: IssueSeverity.high,
          detectedAt: TestHelpers.createTestDateTime(),
          affectedConnections: ['conn-1'],
        ),
        PerformanceIssue(
          id: 'issue-2',
          description: 'Low throughput',
          severity: IssueSeverity.critical,
          detectedAt: TestHelpers.createTestDateTime(),
          affectedConnections: ['conn-2'],
        ),
      ];

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PerformanceIssuesList(
          issues: issues,
          recommendations: [],
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('Issues (2)'), findsOneWidget);
      expect(find.text('High latency detected'), findsOneWidget);
      expect(find.text('Low throughput'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsWidgets);
      expect(find.byIcon(Icons.error), findsWidgets);
    });

    testWidgets('displays optimization recommendations', (WidgetTester tester) async {
      // Arrange
      final recommendations = [
        OptimizationRecommendation(
          id: 'rec-1',
          recommendation: 'Consider reducing connection pool size',
          priority: 'High',
          estimatedImpact: 'Medium',
        ),
        OptimizationRecommendation(
          id: 'rec-2',
          recommendation: 'Enable connection caching',
          priority: 'Medium',
          estimatedImpact: 'Low',
        ),
      ];

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PerformanceIssuesList(
          issues: [],
          recommendations: recommendations,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('Recommendations (2)'), findsOneWidget);
      expect(find.text('Consider reducing connection pool size'), findsOneWidget);
      expect(find.text('Enable connection caching'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsWidgets);
    });

    testWidgets('displays both issues and recommendations', (WidgetTester tester) async {
      // Arrange
      final issues = [
        PerformanceIssue(
          id: 'issue-1',
          description: 'Test issue',
          severity: IssueSeverity.high,
          detectedAt: TestHelpers.createTestDateTime(),
          affectedConnections: [],
        ),
      ];

      final recommendations = [
        OptimizationRecommendation(
          id: 'rec-1',
          recommendation: 'Test recommendation',
          priority: 'High',
          estimatedImpact: 'Medium',
        ),
      ];

      final widget = WidgetTestHelpers.createTestableWidget(
        child: PerformanceIssuesList(
          issues: issues,
          recommendations: recommendations,
        ),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('Issues (1)'), findsOneWidget);
      expect(find.text('Recommendations (1)'), findsOneWidget);
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/ai2ai/user_connections_display.dart';
import 'package:spots/core/monitoring/connection_monitor.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for UserConnectionsDisplay
/// Tests display of active AI2AI connections
void main() {
  group('UserConnectionsDisplay Widget Tests', () {
    testWidgets('displays empty state when no connections', (WidgetTester tester) async {
      // Arrange
      final overview = ActiveConnectionsOverview.empty();
      final widget = WidgetTestHelpers.createTestableWidget(
        child: UserConnectionsDisplay(overview: overview),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.byType(UserConnectionsDisplay), findsOneWidget);
      expect(find.text('Active Connections'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('No active connections'), findsOneWidget);
      expect(find.text('Your AI will discover nearby personalities automatically'), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsOneWidget);
    });

    testWidgets('displays connection statistics when connections exist', (WidgetTester tester) async {
      // Arrange
      final overview = ActiveConnectionsOverview(
        totalActiveConnections: 3,
        aggregateMetrics: AggregateConnectionMetrics(
          averageCompatibility: 0.75,
          averageLatency: Duration(milliseconds: 100),
          averageThroughput: 1000.0,
          totalMessagesExchanged: 150,
          averageQualityScore: 0.8,
          totalLearningEvents: 25,
        ),
        topPerformingConnections: ['conn-1', 'conn-2', 'conn-3'],
        connectionsNeedingAttention: [],
        learningVelocityDistribution: LearningVelocityDistribution.normal(),
        optimizationOpportunities: [],
        averageConnectionDuration: Duration(minutes: 15),
        totalAlertsGenerated: 0,
        generatedAt: TestHelpers.createTestDateTime(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: UserConnectionsDisplay(overview: overview),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.byType(UserConnectionsDisplay), findsOneWidget);
      expect(find.text('Active Connections'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Avg Compatibility'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Avg Duration'), findsOneWidget);
      expect(find.text('15min'), findsOneWidget);
      expect(find.text('Top Connections'), findsOneWidget);
    });

    testWidgets('displays top performing connections', (WidgetTester tester) async {
      // Arrange
      final overview = ActiveConnectionsOverview(
        totalActiveConnections: 2,
        aggregateMetrics: AggregateConnectionMetrics(
          averageCompatibility: 0.8,
          averageLatency: Duration(milliseconds: 50),
          averageThroughput: 2000.0,
          totalMessagesExchanged: 200,
          averageQualityScore: 0.9,
          totalLearningEvents: 30,
        ),
        topPerformingConnections: ['connection-12345', 'connection-67890'],
        connectionsNeedingAttention: [],
        learningVelocityDistribution: LearningVelocityDistribution.normal(),
        optimizationOpportunities: [],
        averageConnectionDuration: Duration(minutes: 20),
        totalAlertsGenerated: 0,
        generatedAt: TestHelpers.createTestDateTime(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: UserConnectionsDisplay(overview: overview),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('Top Connections'), findsOneWidget);
      expect(find.text('High performance'), findsWidgets);
      expect(find.byIcon(Icons.link), findsWidgets);
    });

    testWidgets('handles zero average duration correctly', (WidgetTester tester) async {
      // Arrange
      final overview = ActiveConnectionsOverview(
        totalActiveConnections: 1,
        aggregateMetrics: AggregateConnectionMetrics(
          averageCompatibility: 0.5,
          averageLatency: Duration.zero,
          averageThroughput: 0.0,
          totalMessagesExchanged: 0,
          averageQualityScore: 0.5,
          totalLearningEvents: 0,
        ),
        topPerformingConnections: ['conn-1'],
        connectionsNeedingAttention: [],
        learningVelocityDistribution: LearningVelocityDistribution.normal(),
        optimizationOpportunities: [],
        averageConnectionDuration: Duration.zero,
        totalAlertsGenerated: 0,
        generatedAt: TestHelpers.createTestDateTime(),
      );

      final widget = WidgetTestHelpers.createTestableWidget(
        child: UserConnectionsDisplay(overview: overview),
      );

      // Act
      await WidgetTestHelpers.pumpAndSettle(tester, widget);

      // Assert
      expect(find.text('0min'), findsOneWidget);
    });
  });
}


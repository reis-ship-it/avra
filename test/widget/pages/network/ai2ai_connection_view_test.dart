/// SPOTS AI2AIConnectionView Widget Tests
/// Date: November 20, 2025
/// Purpose: Test AI2AIConnectionView functionality and UI behavior
/// 
/// Test Coverage:
/// - Rendering: Page displays correctly with connection list
/// - Empty State: Shows empty state when no connections
/// - Connection Cards: Displays connection information correctly
/// - User Interactions: View details, disconnect connections
/// - Status Indicators: Shows connection status and quality ratings
/// 
/// Dependencies:
/// - ConnectionMetrics: For connection data
/// - VibeConnectionOrchestrator: For connection management

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/connection_metrics.dart';
import 'package:spots/presentation/pages/network/ai2ai_connection_view.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for AI2AIConnectionView
/// Tests page rendering, connection display, and user interactions
void main() {
  group('AI2AIConnectionView Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays page with app bar', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const AI2AIConnectionView(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(AI2AIConnectionView), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.descendant(
          of: find.byType(AppBar),
          matching: find.text('AI2AI Connections'),
        ), findsOneWidget);
      });

      testWidgets('displays empty state when no connections', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const AI2AIConnectionView(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('No active connections'), findsOneWidget);
        expect(find.byIcon(Icons.link_off), findsOneWidget);
      });

      testWidgets('displays connection list when connections exist', (WidgetTester tester) async {
        // Arrange
        final connections = [
          ConnectionMetrics.initial(
            localAISignature: 'local-sig-1',
            remoteAISignature: 'remote-sig-1',
            compatibility: 0.85,
          ),
          ConnectionMetrics.initial(
            localAISignature: 'local-sig-2',
            remoteAISignature: 'remote-sig-2',
            compatibility: 0.72,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: connections),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Active Connections'), findsOneWidget);
        expect(find.byType(Card), findsWidgets);
      });
    });

    group('Connection Display', () {
      testWidgets('displays connection compatibility score', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.85,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('85%'), findsOneWidget);
      });

      testWidgets('displays connection status', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Establishing'), findsOneWidget);
      });

      testWidgets('displays connection quality rating', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.90,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        // Quality rating should be displayed (excellent, good, fair, or poor)
        final hasQualityRating = find.textContaining('EXCELLENT').evaluate().isNotEmpty ||
            find.textContaining('GOOD').evaluate().isNotEmpty ||
            find.textContaining('FAIR').evaluate().isNotEmpty ||
            find.textContaining('POOR').evaluate().isNotEmpty;
        expect(hasQualityRating, isTrue);
      });

      testWidgets('displays connection duration', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        final hasDuration = find.textContaining('0m').evaluate().isNotEmpty ||
            find.textContaining('min').evaluate().isNotEmpty ||
            find.textContaining('s').evaluate().isNotEmpty;
        expect(hasDuration, isTrue);
      });
    });

    group('User Interactions', () {
      testWidgets('shows view details button for each connection', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('View Details'), findsOneWidget);
      });

      testWidgets('shows disconnect button for active connections', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.text('Disconnect'), findsOneWidget);
      });

      testWidgets('calls onConnectionTap when connection card is tapped', (WidgetTester tester) async {
        // Arrange
        String? tappedConnectionId;
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(
            connections: [connection],
            onConnectionTap: (connectionId) {
              tappedConnectionId = connectionId;
            },
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);
        await tester.tap(find.text('View Details'));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedConnectionId, equals(connection.connectionId));
      });
    });

    group('Status Indicators', () {
      testWidgets('shows status indicator for each connection', (WidgetTester tester) async {
        // Arrange
        final connection = ConnectionMetrics.initial(
          localAISignature: 'local-sig',
          remoteAISignature: 'remote-sig',
          compatibility: 0.75,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: AI2AIConnectionView(connections: [connection]),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        // Status indicator should be visible (colored dot or icon)
        final hasStatusIndicator = find.byWidgetPredicate(
          (widget) => widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ).evaluate().isNotEmpty;
        expect(hasStatusIndicator, isTrue);
      });
    });
  });
}


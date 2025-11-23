/// SPOTS FederatedLearningStatusWidget Widget Tests
/// Date: November 20, 2025
/// Purpose: Test FederatedLearningStatusWidget functionality and UI behavior
/// 
/// Test Coverage:
/// - Rendering: Active learning rounds display
/// - Participation Status: User participation in rounds
/// - Round Progress: Progress indicators and status
/// - Edge Cases: No active rounds, error states
/// 
/// Dependencies:
/// - FederatedLearningSystem: For round data
/// - RoundStatus: For round status display

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/settings/federated_learning_status_widget.dart';
import 'package:spots/core/p2p/federated_learning.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for FederatedLearningStatusWidget
/// Tests round display, participation status, and progress indicators
void main() {
  group('FederatedLearningStatusWidget Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays widget with title', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningStatusWidget(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(FederatedLearningStatusWidget), findsOneWidget);
        expect(find.textContaining('Learning Round'), findsWidgets);
      });

      testWidgets('displays active rounds when available', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            roundNumber: 1,
            participantNodeIds: List.generate(5, (i) => 'node_$i'),
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Round 1'), findsOneWidget);
        expect(find.textContaining('Training'), findsOneWidget);
        expect(find.textContaining('Learning: Recommendation'), findsOneWidget);
      });

      testWidgets('displays no active rounds message when empty', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningStatusWidget(
            activeRounds: [],
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('No active'), findsOneWidget);
      });

      testWidgets('displays multiple active rounds', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            roundNumber: 1,
          ),
          _createMockRound(
            roundId: 'round_2',
            status: RoundStatus.aggregating,
            roundNumber: 2,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Round 1'), findsOneWidget);
        expect(find.textContaining('Round 2'), findsOneWidget);
      });
    });

    group('Participation Status', () {
      testWidgets('displays participation status when user is participating', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            participantNodeIds: ['node_1', 'node_2', 'current_user_node'],
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
            currentNodeId: 'current_user_node',
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Participating'), findsOneWidget);
      });

      testWidgets('displays not participating when user is not in round', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            participantNodeIds: ['node_1', 'node_2'],
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
            currentNodeId: 'current_user_node',
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Not participating'), findsOneWidget);
      });
    });

    group('Round Progress', () {
      testWidgets('displays round progress indicator', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            roundNumber: 3,
            participantUpdates: {'node_1': _createMockUpdate()},
            participantNodeIds: ['node_1', 'node_2', 'node_3'],
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });

      testWidgets('displays round number correctly', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            roundNumber: 5,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Round 5'), findsOneWidget);
      });

      testWidgets('displays participant count', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            participantNodeIds: List.generate(8, (i) => 'node_$i'),
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('8'), findsOneWidget);
        expect(find.textContaining('participant'), findsOneWidget);
      });

      testWidgets('displays model accuracy when available', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            modelAccuracy: 0.85,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('85'), findsOneWidget);
        expect(find.textContaining('%'), findsOneWidget);
      });
    });

    group('Status Display', () {
      testWidgets('displays training status correctly', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Training'), findsOneWidget);
      });

      testWidgets('displays aggregating status correctly', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.aggregating,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Aggregating'), findsOneWidget);
      });

      testWidgets('displays initializing status correctly', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.initializing,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Initializing'), findsOneWidget);
      });
    });

    group('Learning Objective Display', () {
      testWidgets('displays learning objective name', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            objectiveName: 'Spot Recommendations',
            objectiveDescription: 'Improving recommendation accuracy',
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Learning: Spot Recommendations'), findsOneWidget);
        expect(find.textContaining('Improving recommendation accuracy'), findsOneWidget);
      });

      testWidgets('displays different learning types with appropriate icons', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
            learningType: LearningType.recommendation,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byIcon(Icons.recommend), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles null currentNodeId gracefully', (WidgetTester tester) async {
        // Arrange
        final activeRounds = [
          _createMockRound(
            roundId: 'round_1',
            status: RoundStatus.training,
          ),
        ];

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedLearningStatusWidget(
            activeRounds: activeRounds,
            currentNodeId: null,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(FederatedLearningStatusWidget), findsOneWidget);
      });

      testWidgets('displays info icon for learning round explanation', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedLearningStatusWidget(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        final infoButtons = find.byIcon(Icons.info_outline);
        expect(infoButtons, findsWidgets); // At least one info icon should be present
        expect(find.textContaining('Learning Round Status'), findsOneWidget);
      });
    });
  });
}

/// Helper function to create a mock FederatedLearningRound for testing
FederatedLearningRound _createMockRound({
  required String roundId,
  required RoundStatus status,
  int roundNumber = 1,
  List<String>? participantNodeIds,
  Map<String, LocalModelUpdate>? participantUpdates,
  double? modelAccuracy,
  String? objectiveName,
  String? objectiveDescription,
  LearningType? learningType,
}) {
  final participants = participantNodeIds ?? ['node_1', 'node_2', 'node_3'];
  final updates = participantUpdates ?? {};

  return FederatedLearningRound(
    roundId: roundId,
    organizationId: 'test_org',
    objective: LearningObjective(
      name: objectiveName ?? 'Recommendation',
      description: objectiveDescription ?? 'Test objective',
      type: learningType ?? LearningType.recommendation,
      parameters: {},
    ),
    participantNodeIds: participants,
    status: status,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    roundNumber: roundNumber,
    globalModel: GlobalModel(
      modelId: 'model_1',
      objective: LearningObjective(
        name: 'Recommendation',
        description: 'Test',
        type: LearningType.recommendation,
        parameters: {},
      ),
      version: 1,
      parameters: {},
      loss: 0.5,
      accuracy: modelAccuracy ?? 0.75,
      updatedAt: DateTime.now(),
    ),
    participantUpdates: updates,
    privacyMetrics: PrivacyMetrics.initial(),
  );
}

/// Helper function to create a mock LocalModelUpdate for testing
LocalModelUpdate _createMockUpdate() {
  return LocalModelUpdate(
    nodeId: 'node_1',
    roundId: 'round_1',
    gradients: {},
    trainingMetrics: TrainingMetrics(
      samplesUsed: 100,
      trainingLoss: 0.5,
      accuracy: 0.75,
      privacyBudgetUsed: 0.1,
    ),
    timestamp: DateTime.now(),
    privacyCompliant: true,
  );
}


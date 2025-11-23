/// SPOTS FederatedParticipationHistoryWidget Widget Tests
/// Date: November 20, 2025
/// Purpose: Test FederatedParticipationHistoryWidget functionality and UI behavior
/// 
/// Test Coverage:
/// - Rendering: Participation history display
/// - Contribution Metrics: Rounds participated, contributions made
/// - Benefits Earned: Benefits received from participation
/// - Edge Cases: Empty history, error states
/// 
/// Dependencies:
/// - ParticipationHistory: For participation data
/// - FederatedLearningRound: For round information

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/settings/federated_participation_history_widget.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for FederatedParticipationHistoryWidget
/// Tests participation history, contributions, and benefits display
void main() {
  group('FederatedParticipationHistoryWidget Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays widget with title', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedParticipationHistoryWidget(),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(FederatedParticipationHistoryWidget), findsOneWidget);
        expect(find.textContaining('Participation History'), findsOneWidget);
      });

      testWidgets('displays participation history when available', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 12,
          completedRounds: 10,
          totalContributions: 45,
          benefitsEarned: ['Improved Recommendations', 'Early Access Features'],
          lastParticipationDate: DateTime.now().subtract(const Duration(days: 2)),
          participationStreak: 5,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('12'), findsOneWidget);
        expect(find.textContaining('Total Rounds'), findsOneWidget);
      });

      testWidgets('displays empty state when no history', (WidgetTester tester) async {
        // Arrange
        final widget = WidgetTestHelpers.createTestableWidget(
          child: const FederatedParticipationHistoryWidget(
            participationHistory: null,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('No participation'), findsOneWidget);
      });
    });

    group('Contribution Metrics', () {
      testWidgets('displays total rounds participated', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 25,
          completedRounds: 23,
          totalContributions: 100,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 10,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('25'), findsOneWidget);
        expect(find.textContaining('Total Rounds'), findsOneWidget);
      });

      testWidgets('displays completed rounds count', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 20,
          completedRounds: 18,
          totalContributions: 80,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 8,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('18'), findsOneWidget);
        expect(find.textContaining('Completed'), findsOneWidget);
      });

      testWidgets('displays total contributions', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 15,
          completedRounds: 15,
          totalContributions: 67,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 5,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('67'), findsOneWidget);
        expect(find.textContaining('Contributions'), findsOneWidget);
      });

      testWidgets('displays participation streak', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 10,
          completedRounds: 10,
          totalContributions: 40,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 7,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('7'), findsOneWidget);
        expect(find.textContaining('Streak'), findsOneWidget);
      });
    });

    group('Benefits Earned', () {
      testWidgets('displays benefits earned', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 10,
          completedRounds: 10,
          totalContributions: 40,
          benefitsEarned: [
            'Improved Recommendations',
            'Early Access Features',
            'Priority Support',
          ],
          lastParticipationDate: DateTime.now(),
          participationStreak: 5,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Benefits'), findsOneWidget);
        expect(find.textContaining('Improved Recommendations'), findsOneWidget);
        expect(find.textContaining('Early Access'), findsOneWidget);
      });

      testWidgets('displays no benefits message when empty', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 5,
          completedRounds: 5,
          totalContributions: 20,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 2,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('No benefits'), findsOneWidget);
      });
    });

    group('Visual Indicators', () {
      testWidgets('displays progress indicators', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 10,
          completedRounds: 8,
          totalContributions: 35,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 4,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });

      testWidgets('displays completion rate', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 10,
          completedRounds: 8,
          totalContributions: 35,
          benefitsEarned: [],
          lastParticipationDate: DateTime.now(),
          participationStreak: 4,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('80'), findsOneWidget); // 8/10 = 80%
        expect(find.textContaining('%'), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles zero participation gracefully', (WidgetTester tester) async {
        // Arrange
        final history = ParticipationHistory(
          totalRoundsParticipated: 0,
          completedRounds: 0,
          totalContributions: 0,
          benefitsEarned: [],
          lastParticipationDate: null,
          participationStreak: 0,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(FederatedParticipationHistoryWidget), findsOneWidget);
        expect(find.textContaining('0'), findsWidgets);
      });

      testWidgets('displays last participation date when available', (WidgetTester tester) async {
        // Arrange
        final lastDate = DateTime.now().subtract(const Duration(days: 3));
        final history = ParticipationHistory(
          totalRoundsParticipated: 5,
          completedRounds: 5,
          totalContributions: 20,
          benefitsEarned: [],
          lastParticipationDate: lastDate,
          participationStreak: 2,
        );

        final widget = WidgetTestHelpers.createTestableWidget(
          child: FederatedParticipationHistoryWidget(
            participationHistory: history,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Last participation'), findsOneWidget);
      });
    });
  });
}


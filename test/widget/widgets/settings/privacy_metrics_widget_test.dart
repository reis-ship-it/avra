/// SPOTS PrivacyMetricsWidget Widget Tests
/// Date: November 20, 2025
/// Purpose: Test PrivacyMetricsWidget functionality and UI behavior
/// 
/// Test Coverage:
/// - Rendering: Privacy compliance display
/// - Anonymization Levels: Display of anonymization quality
/// - Data Protection Metrics: Security scores and exposure levels
/// - Edge Cases: Missing data, error states
/// 
/// Dependencies:
/// - PrivacyMetrics: For privacy data
/// - NetworkAnalytics: For privacy metrics

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/settings/privacy_metrics_widget.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import '../../helpers/widget_test_helpers.dart';

/// Widget tests for PrivacyMetricsWidget
/// Tests privacy compliance, anonymization, and data protection display
void main() {
  group('PrivacyMetricsWidget Widget Tests', () {
    group('Rendering', () {
      testWidgets('displays widget with title', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics.secure();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(PrivacyMetricsWidget), findsOneWidget);
        expect(find.textContaining('Privacy'), findsWidgets);
      });

      testWidgets('displays privacy compliance score', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('95'), findsOneWidget);
        expect(find.textContaining('%'), findsWidgets);
      });

      testWidgets('displays anonymization level', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.92,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Anonymization'), findsOneWidget);
        expect(find.textContaining('92'), findsOneWidget);
      });

      testWidgets('displays data protection metrics', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.97,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Data Security'), findsOneWidget);
        expect(find.textContaining('97'), findsOneWidget);
      });
    });

    group('Privacy Compliance', () {
      testWidgets('displays high compliance score with success color', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics.secure();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('98'), findsWidgets); // May appear multiple times
        // High compliance should show success color (green)
      });

      testWidgets('displays overall privacy score', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Privacy Compliance'), findsOneWidget);
      });
    });

    group('Anonymization Levels', () {
      testWidgets('displays anonymization quality metric', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.88,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Anonymization'), findsOneWidget);
        expect(find.textContaining('88'), findsOneWidget);
      });

      testWidgets('displays re-identification risk', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90, // High anonymization = low risk
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Re-identification'), findsOneWidget);
        // Risk should be low (1.0 - 0.90 = 0.10 = 10%)
      });
    });

    group('Data Protection Metrics', () {
      testWidgets('displays data security score', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.96,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('96'), findsOneWidget);
      });

      testWidgets('displays encryption strength', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.97,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Encryption'), findsOneWidget);
        expect(find.textContaining('97'), findsOneWidget);
      });

      testWidgets('displays privacy violations count', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('Violations'), findsOneWidget);
        expect(find.textContaining('0'), findsWidgets);
      });
    });

    group('Visual Indicators', () {
      testWidgets('displays progress indicators for metrics', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics.secure();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });

      testWidgets('displays info icon for privacy explanation', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics.secure();
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        final infoButtons = find.byIcon(Icons.info_outline);
        expect(infoButtons, findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles low privacy scores gracefully', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.70,
          anonymizationLevel: 0.65,
          dataSecurityScore: 0.75,
          privacyViolations: 2,
          encryptionStrength: 0.80,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.byType(PrivacyMetricsWidget), findsOneWidget);
        expect(find.textContaining('70'), findsOneWidget);
      });

      testWidgets('displays zero privacy violations correctly', (WidgetTester tester) async {
        // Arrange
        final privacyMetrics = PrivacyMetrics(
          complianceRate: 0.95,
          anonymizationLevel: 0.90,
          dataSecurityScore: 0.98,
          privacyViolations: 0,
          encryptionStrength: 0.99,
        );
        final widget = WidgetTestHelpers.createTestableWidget(
          child: PrivacyMetricsWidget(
            privacyMetrics: privacyMetrics,
          ),
        );

        // Act
        await WidgetTestHelpers.pumpAndSettle(tester, widget);

        // Assert
        expect(find.textContaining('0'), findsWidgets);
      });
    });
  });
}


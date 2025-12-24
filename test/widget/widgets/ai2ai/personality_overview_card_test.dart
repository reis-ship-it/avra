import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/ai2ai/personality_overview_card.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:spots/core/constants/vibe_constants.dart';
import "../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for PersonalityOverviewCard
/// Tests personality overview display with dimensions, confidence, and archetype
void main() {
  group('PersonalityOverviewCard Widget Tests', () {
    // Removed: Property assignment tests
    // Personality overview card tests focus on business logic (personality overview display, dimension bars, authenticity progress, empty dimensions), not property assignment

    testWidgets(
        'should display personality overview with all dimensions, display dimension bars with correct values, display authenticity progress bar, or handle empty dimensions gracefully',
        (WidgetTester tester) async {
      // Test business logic: Personality overview card display and functionality
      final profile1 = PersonalityProfile(
        userId: 'test-user-id',
        dimensions: {
          'adventure': 0.7,
          'social': 0.8,
          'culture': 0.6,
        },
        dimensionConfidence: {
          'adventure': 0.9,
          'social': 0.85,
          'culture': 0.7,
        },
        archetype: 'explorer',
        authenticity: 0.75,
        createdAt: TestHelpers.createTestDateTime(),
        lastUpdated: TestHelpers.createTestDateTime(),
        evolutionGeneration: 3,
        learningHistory: {},
      );
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: PersonalityOverviewCard(profile: profile1),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(PersonalityOverviewCard), findsOneWidget);
      expect(find.text('Personality Overview'), findsOneWidget);
      expect(find.text('EXPLORER'), findsOneWidget);
      expect(find.text('Authenticity'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Core Dimensions'), findsOneWidget);
      expect(find.text('Evolution Generation'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      final profile2 = PersonalityProfile(
        userId: 'test-user-id',
        dimensions: {
          'adventure': 0.7,
          'social': 0.8,
        },
        dimensionConfidence: {
          'adventure': 0.9,
          'social': 0.85,
        },
        archetype: 'explorer',
        authenticity: 0.75,
        createdAt: TestHelpers.createTestDateTime(),
        lastUpdated: TestHelpers.createTestDateTime(),
        evolutionGeneration: 1,
        learningHistory: {},
      );
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: PersonalityOverviewCard(profile: profile2),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('70%'), findsWidgets);
      expect(find.text('80%'), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsWidgets);

      final profile3 = PersonalityProfile(
        userId: 'test-user-id',
        dimensions: {},
        dimensionConfidence: {},
        archetype: 'developing',
        authenticity: 0.5,
        createdAt: TestHelpers.createTestDateTime(),
        lastUpdated: TestHelpers.createTestDateTime(),
        evolutionGeneration: 1,
        learningHistory: {},
      );
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: PersonalityOverviewCard(profile: profile3),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(find.byType(PersonalityOverviewCard), findsOneWidget);
      expect(find.text('Personality Overview'), findsOneWidget);
    });
  });
}


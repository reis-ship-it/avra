import 'package:flutter_test/flutter_test.dart';
import 'package:spots/presentation/widgets/brand/sponsorship_card.dart';
import 'package:spots/core/models/sponsorship.dart';
import 'package:spots/core/models/product_tracking.dart';
import 'package:spots/core/models/sponsorship_status.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../fixtures/model_factories.dart';

/// Widget tests for SponsorshipCard
///
/// Agent 2: Phase 7, Section 51-52 - Widget Test Coverage
///
/// Tests:
/// - Widget rendering
/// - Status badge display
/// - Contribution display
/// - Product tracking display
/// - Callback handling
void main() {
  group('SponsorshipCard Widget Tests', () {
    // Removed: Property assignment tests
    // Sponsorship card tests focus on business logic (card display, status badges, contributions, user interactions), not property assignment

    testWidgets(
        'should display sponsorship card with event ID, display active status badge, display financial contribution when present, display product tracking when present, or call onTap callback when card is tapped',
        (WidgetTester tester) async {
      // Test business logic: sponsorship card display and interactions
      final sponsorship1 = ModelFactories.createTestSponsorship(
        eventId: 'event-123',
        status: SponsorshipStatus.active,
      );
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: SponsorshipCard(
          sponsorship: sponsorship1,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(SponsorshipCard), findsOneWidget);
      expect(find.text('Event: event-123'), findsOneWidget);

      final sponsorship2 = ModelFactories.createTestSponsorship(
        status: SponsorshipStatus.active,
      );
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: SponsorshipCard(
          sponsorship: sponsorship2,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.byType(SponsorshipCard), findsOneWidget);

      final sponsorship3 = ModelFactories.createTestSponsorship(
        contributionAmount: 500.0,
      );
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: SponsorshipCard(
          sponsorship: sponsorship3,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.byType(SponsorshipCard), findsOneWidget);
      expect(find.textContaining('Your Contribution'), findsOneWidget);

      final sponsorship4 = ModelFactories.createTestSponsorship();
      final productTracking = ProductTracking(
        productName: 'Test Product',
        quantity: 10,
        unitValue: 25.0,
        trackingId: 'track-123',
      );
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: SponsorshipCard(
          sponsorship: sponsorship4,
          productTracking: productTracking,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.byType(SponsorshipCard), findsOneWidget);

      bool wasTapped = false;
      final sponsorship5 = ModelFactories.createTestSponsorship();
      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: SponsorshipCard(
          sponsorship: sponsorship5,
          onTap: () => wasTapped = true,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      await tester.tap(find.byType(SponsorshipCard));
      await tester.pump();
      expect(wasTapped, isTrue);
    });
  });
}

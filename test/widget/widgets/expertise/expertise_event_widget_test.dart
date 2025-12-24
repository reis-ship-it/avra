import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spots/presentation/widgets/expertise/expertise_event_widget.dart';
import 'package:spots/core/models/expertise_event.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../../helpers/test_helpers.dart';

/// Widget tests for ExpertiseEventWidget
/// Tests expertise event display
void main() {
  group('ExpertiseEventWidget Widget Tests', () {
    // Removed: Property assignment tests
    // Expertise event widget tests focus on business logic (event display, registration, user interactions), not property assignment

    testWidgets(
        'should display event information, display register button when user can register, display cancel button when user is registered, display event list widget, or display empty state when no events',
        (WidgetTester tester) async {
      // Test business logic: expertise event widget display and interactions
      final host1 = WidgetTestHelpers.createTestUser();
      final testDate1 = TestHelpers.createTestDateTime();
      final event1 = ExpertiseEvent(
        id: 'event-123',
        title: 'Coffee Tasting Event',
        description: 'Join us for a coffee tasting',
        category: 'Coffee',
        eventType: ExpertiseEventType.workshop,
        host: host1,
        startTime: testDate1.add(const Duration(days: 7)),
        endTime: testDate1.add(const Duration(days: 7, hours: 2)),
        maxAttendees: 20,
        status: EventStatus.upcoming,
        attendeeIds: [],
        spots: [],
        createdAt: testDate1,
        updatedAt: testDate1,
      );
      final widget1 = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseEventWidget(event: event1),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget1);
      expect(find.byType(ExpertiseEventWidget), findsOneWidget);
      expect(find.text('Coffee Tasting Event'), findsOneWidget);
      expect(find.textContaining('Hosted by'), findsOneWidget);

      final host2 = WidgetTestHelpers.createTestUser();
      final currentUser1 = WidgetTestHelpers.createTestUser(id: 'user-456');
      final testDate2 = TestHelpers.createTestDateTime();
      final event2 = ExpertiseEvent(
        id: 'event-123',
        title: 'Coffee Tasting',
        description: 'Join us',
        category: 'Coffee',
        eventType: ExpertiseEventType.workshop,
        host: host2,
        startTime: testDate2.add(const Duration(days: 7)),
        endTime: testDate2.add(const Duration(days: 7, hours: 2)),
        maxAttendees: 20,
        status: EventStatus.upcoming,
        attendeeIds: [],
        spots: [],
        createdAt: testDate2,
        updatedAt: testDate2,
      );
      final widget2 = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseEventWidget(
          event: event2,
          currentUser: currentUser1,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget2);
      expect(find.text('Register'), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);

      final host3 = WidgetTestHelpers.createTestUser();
      final currentUser2 = WidgetTestHelpers.createTestUser(id: 'user-456');
      final testDate3 = TestHelpers.createTestDateTime();
      final event3 = ExpertiseEvent(
        id: 'event-123',
        title: 'Coffee Tasting',
        description: 'Join us',
        category: 'Coffee',
        eventType: ExpertiseEventType.workshop,
        host: host3,
        startTime: testDate3.add(const Duration(days: 7)),
        endTime: testDate3.add(const Duration(days: 7, hours: 2)),
        maxAttendees: 20,
        status: EventStatus.upcoming,
        attendeeIds: ['user-456'],
        spots: [],
        createdAt: testDate3,
        updatedAt: testDate3,
      );
      final widget3 = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseEventWidget(
          event: event3,
          currentUser: currentUser2,
        ),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget3);
      expect(find.text('Cancel Registration'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      final host4 = WidgetTestHelpers.createTestUser();
      final testDate4 = TestHelpers.createTestDateTime();
      final events = [
        ExpertiseEvent(
          id: 'event-1',
          title: 'Event 1',
          description: 'Description 1',
          category: 'Coffee',
          eventType: ExpertiseEventType.workshop,
          host: host4,
          startTime: testDate4.add(const Duration(days: 7)),
          endTime: testDate4.add(const Duration(days: 7, hours: 2)),
          maxAttendees: 20,
          status: EventStatus.upcoming,
          attendeeIds: [],
          spots: [],
          createdAt: testDate4,
          updatedAt: testDate4,
        ),
      ];
      final widget4 = WidgetTestHelpers.createTestableWidget(
        child: ExpertiseEventListWidget(events: events),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget4);
      expect(find.byType(ExpertiseEventListWidget), findsOneWidget);
      expect(find.text('Event 1'), findsOneWidget);

      final widget5 = WidgetTestHelpers.createTestableWidget(
        child: const ExpertiseEventListWidget(events: []),
      );
      await WidgetTestHelpers.pumpAndSettle(tester, widget5);
      expect(find.text('No events found'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });
  });
}

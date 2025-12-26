import 'package:flutter_test/flutter_test.dart';

import 'package:spots/core/controllers/event_attendance_controller.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/data/datasources/local/sembast_database.dart';
import '../../helpers/integration_test_helpers.dart';

/// Event Attendance Controller Integration Tests
/// 
/// Tests the complete event attendance workflow with real service implementations:
/// - Free event registration
/// - Paid event registration (via PaymentProcessingController)
/// - Availability checks
/// - Capacity validation
/// - Error handling
void main() {
  group('EventAttendanceController Integration Tests', () {
    late EventAttendanceController controller;
    late ExpertiseEventService eventService;
    final DateTime now = DateTime.now();

    setUpAll(() async {
      // Initialize Sembast for tests
      SembastDatabase.useInMemoryForTests();
      await SembastDatabase.database;
      
      // Initialize dependency injection
      await di.init();
      
      controller = di.sl<EventAttendanceController>();
      eventService = di.sl<ExpertiseEventService>();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
    });

    group('registerForEvent', () {
      test('should successfully register for free event', () async {
        // Arrange
        final host = IntegrationTestHelpers.createUserWithLocalExpertise(
          id: 'host_${DateTime.now().millisecondsSinceEpoch}',
          category: 'Coffee',
          location: 'Greenpoint, Brooklyn, NY, USA',
        );

        final attendee = IntegrationTestHelpers.createUserWithCityExpertise(
          id: 'attendee_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Create a free event
        final event = await eventService.createEvent(
          host: host,
          title: 'Free Coffee Tour',
          description: 'Free event',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          startTime: now.add(const Duration(days: 7)),
          endTime: now.add(const Duration(days: 7, hours: 2)),
          maxAttendees: 10,
        );

        // Act
        final result = await controller.registerForEvent(
          event: event,
          attendee: attendee,
          quantity: 1,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.event, isNotNull);
        expect(result.event?.attendeeIds, contains(attendee.id));
        expect(result.event?.attendeeCount, equals(1));
        expect(result.payment, isNull); // Free event has no payment
      });

      test('should return failure for event that already started', () async {
        // Arrange
        final host = IntegrationTestHelpers.createUserWithLocalExpertise(
          id: 'host_${DateTime.now().millisecondsSinceEpoch}',
          category: 'Coffee',
        );

        final attendee = IntegrationTestHelpers.createUserWithCityExpertise(
          id: 'attendee_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Create an event in the past
        final pastEvent = await eventService.createEvent(
          host: host,
          title: 'Past Event',
          description: 'Already started',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now.add(const Duration(hours: 1)),
          maxAttendees: 10,
        );

        // Act
        final result = await controller.registerForEvent(
          event: pastEvent,
          attendee: attendee,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('EVENT_STARTED'));
      });

      test('should return failure for insufficient capacity', () async {
        // Arrange
        final host = IntegrationTestHelpers.createUserWithLocalExpertise(
          id: 'host_${DateTime.now().millisecondsSinceEpoch}',
          category: 'Coffee',
        );

        final attendee = IntegrationTestHelpers.createUserWithCityExpertise(
          id: 'attendee_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Create event with capacity 1
        final event = await eventService.createEvent(
          host: host,
          title: 'Limited Capacity Event',
          description: 'Only 1 spot',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          startTime: now.add(const Duration(days: 7)),
          endTime: now.add(const Duration(days: 7, hours: 2)),
          maxAttendees: 1,
        );

        // Register first attendee (fills capacity)
        await eventService.registerForEvent(event, attendee);

        // Create second attendee
        final secondAttendee = IntegrationTestHelpers.createUserWithCityExpertise(
          id: 'attendee2_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Reload event to get updated attendee count
        final updatedEvent = await eventService.getEventById(event.id);
        expect(updatedEvent, isNotNull);

        // Act - Try to register second attendee
        final result = await controller.registerForEvent(
          event: updatedEvent!,
          attendee: secondAttendee,
          quantity: 1,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('INSUFFICIENT_CAPACITY'));
      });

      test('should return failure for already registered user', () async {
        // Arrange
        final host = IntegrationTestHelpers.createUserWithLocalExpertise(
          id: 'host_${DateTime.now().millisecondsSinceEpoch}',
          category: 'Coffee',
        );

        final attendee = IntegrationTestHelpers.createUserWithCityExpertise(
          id: 'attendee_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Create event
        final event = await eventService.createEvent(
          host: host,
          title: 'Test Event',
          description: 'Test',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          startTime: now.add(const Duration(days: 7)),
          endTime: now.add(const Duration(days: 7, hours: 2)),
          maxAttendees: 10,
        );

        // Register user first time
        await eventService.registerForEvent(event, attendee);

        // Reload event to get updated attendee count
        final updatedEvent = await eventService.getEventById(event.id);
        expect(updatedEvent, isNotNull);

        // Act - Try to register again
        final result = await controller.registerForEvent(
          event: updatedEvent!,
          attendee: attendee,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('ALREADY_REGISTERED'));
      });
    });

    group('validate', () {
      test('should validate input correctly', () {
        // Arrange
        final host = IntegrationTestHelpers.createUserWithLocalExpertise(
          id: 'host_${DateTime.now().millisecondsSinceEpoch}',
        );
        final attendee = IntegrationTestHelpers.createUserWithCityExpertise(
          id: 'attendee_${DateTime.now().millisecondsSinceEpoch}',
        );

        final event = ExpertiseEvent(
          id: 'event_123',
          title: 'Test',
          description: 'Test',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: host,
          startTime: now.add(const Duration(days: 7)),
          endTime: now.add(const Duration(days: 7, hours: 2)),
          maxAttendees: 10,
          createdAt: now,
          updatedAt: now,
          attendeeIds: [],
          attendeeCount: 0,
        );

        final data = AttendanceData(
          event: event,
          attendee: attendee,
          quantity: 1,
        );

        // Act
        final result = controller.validate(data);

        // Assert
        expect(result.isValid, isTrue);
      });
    });
  });
}

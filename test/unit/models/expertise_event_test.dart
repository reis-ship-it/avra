import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/spot.dart';
import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for ExpertiseEvent model
/// Tests event creation, JSON serialization, helper methods, and attendee management
void main() {
  group('ExpertiseEvent Model Tests', () {
    late DateTime testDate;
    late DateTime startTime;
    late DateTime endTime;
    late UnifiedUser testHost;
    late List<Spot> testSpots;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
      startTime = testDate.add(Duration(days: 1));
      endTime = startTime.add(Duration(hours: 2));
      testHost = ModelFactories.createTestUser(id: 'host-123', displayName: 'Expert Host');
      testSpots = [
        ModelFactories.createTestSpot(id: 'spot-1', name: 'Coffee Shop 1'),
        ModelFactories.createTestSpot(id: 'spot-2', name: 'Coffee Shop 2'),
      ];
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('Constructor and Properties', () {
      test('should create event with required fields', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour of local coffee shops',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.id, equals('event-123'));
        expect(event.title, equals('Coffee Tour'));
        expect(event.description, equals('A guided tour of local coffee shops'));
        expect(event.category, equals('Coffee'));
        expect(event.eventType, equals(ExpertiseEventType.tour));
        expect(event.host, equals(testHost));
        expect(event.startTime, equals(startTime));
        expect(event.endTime, equals(endTime));
        expect(event.createdAt, equals(testDate));
        expect(event.updatedAt, equals(testDate));
        
        // Test default values
        expect(event.attendeeIds, isEmpty);
        expect(event.attendeeCount, equals(0));
        expect(event.maxAttendees, equals(20));
        expect(event.spots, isEmpty);
        expect(event.location, isNull);
        expect(event.latitude, isNull);
        expect(event.longitude, isNull);
        expect(event.price, isNull);
        expect(event.isPaid, isFalse);
        expect(event.isPublic, isTrue);
        expect(event.status, equals(EventStatus.upcoming));
      });

      test('should create event with all fields', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeIds: ['user-1', 'user-2'],
          attendeeCount: 2,
          maxAttendees: 10,
          startTime: startTime,
          endTime: endTime,
          spots: testSpots,
          location: '123 Main St',
          latitude: 40.7128,
          longitude: -74.0060,
          price: 25.0,
          isPaid: true,
          isPublic: true,
          createdAt: testDate,
          updatedAt: testDate,
          status: EventStatus.upcoming,
        );

        expect(event.attendeeIds, equals(['user-1', 'user-2']));
        expect(event.attendeeCount, equals(2));
        expect(event.maxAttendees, equals(10));
        expect(event.spots, equals(testSpots));
        expect(event.location, equals('123 Main St'));
        expect(event.latitude, equals(40.7128));
        expect(event.longitude, equals(-74.0060));
        expect(event.price, equals(25.0));
        expect(event.isPaid, isTrue);
        expect(event.status, equals(EventStatus.upcoming));
      });
    });

    group('Event Status Checks', () {
      test('isFull should return true when attendeeCount equals maxAttendees', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeCount: 10,
          maxAttendees: 10,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.isFull, isTrue);
      });

      test('isFull should return false when attendeeCount is less than maxAttendees', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeCount: 5,
          maxAttendees: 10,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.isFull, isFalse);
      });

      test('hasStarted should return true when current time is after startTime', () {
        final pastStartTime = DateTime.now().subtract(Duration(hours: 1));
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: pastStartTime,
          endTime: DateTime.now().add(Duration(hours: 1)),
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.hasStarted, isTrue);
      });

      test('hasStarted should return false when current time is before startTime', () {
        final futureStartTime = DateTime.now().add(Duration(hours: 1));
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: futureStartTime,
          endTime: futureStartTime.add(Duration(hours: 2)),
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.hasStarted, isFalse);
      });

      test('hasEnded should return true when current time is after endTime', () {
        final pastEndTime = DateTime.now().subtract(Duration(hours: 1));
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: pastEndTime.subtract(Duration(hours: 2)),
          endTime: pastEndTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.hasEnded, isTrue);
      });

      test('hasEnded should return false when current time is before endTime', () {
        final futureEndTime = DateTime.now().add(Duration(hours: 1));
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: DateTime.now(),
          endTime: futureEndTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.hasEnded, isFalse);
      });
    });

    group('canUserAttend', () {
      test('should return true when user can attend', () {
        final futureEndTime = DateTime.now().add(Duration(hours: 2));
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeCount: 5,
          maxAttendees: 10,
          startTime: DateTime.now().add(Duration(hours: 1)),
          endTime: futureEndTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.canUserAttend('user-new'), isTrue);
      });

      test('should return false when event has ended', () {
        final pastEndTime = DateTime.now().subtract(Duration(hours: 1));
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: pastEndTime.subtract(Duration(hours: 2)),
          endTime: pastEndTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.canUserAttend('user-new'), isFalse);
      });

      test('should return false when event is full', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeCount: 10,
          maxAttendees: 10,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.canUserAttend('user-new'), isFalse);
      });

      test('should return false when user is already attending', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeIds: ['user-1', 'user-2'],
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event.canUserAttend('user-1'), isFalse);
      });
    });

    group('Event Type Display', () {
      test('getEventTypeDisplayName should return correct display names', () {
        expect(
          ExpertiseEvent(
            id: 'event-1',
            title: 'Tour',
            description: 'Test',
            category: 'Coffee',
            eventType: ExpertiseEventType.tour,
            host: testHost,
            startTime: startTime,
            endTime: endTime,
            createdAt: testDate,
            updatedAt: testDate,
          ).getEventTypeDisplayName(),
          equals('Expert Tour'),
        );

        expect(
          ExpertiseEvent(
            id: 'event-2',
            title: 'Workshop',
            description: 'Test',
            category: 'Coffee',
            eventType: ExpertiseEventType.workshop,
            host: testHost,
            startTime: startTime,
            endTime: endTime,
            createdAt: testDate,
            updatedAt: testDate,
          ).getEventTypeDisplayName(),
          equals('Workshop'),
        );

        expect(
          ExpertiseEvent(
            id: 'event-3',
            title: 'Tasting',
            description: 'Test',
            category: 'Coffee',
            eventType: ExpertiseEventType.tasting,
            host: testHost,
            startTime: startTime,
            endTime: endTime,
            createdAt: testDate,
            updatedAt: testDate,
          ).getEventTypeDisplayName(),
          equals('Tasting'),
        );
      });

      test('getEventTypeEmoji should return correct emojis', () {
        expect(
          ExpertiseEvent(
            id: 'event-1',
            title: 'Tour',
            description: 'Test',
            category: 'Coffee',
            eventType: ExpertiseEventType.tour,
            host: testHost,
            startTime: startTime,
            endTime: endTime,
            createdAt: testDate,
            updatedAt: testDate,
          ).getEventTypeEmoji(),
          equals('🚶'),
        );

        expect(
          ExpertiseEvent(
            id: 'event-2',
            title: 'Workshop',
            description: 'Test',
            category: 'Coffee',
            eventType: ExpertiseEventType.workshop,
            host: testHost,
            startTime: startTime,
            endTime: endTime,
            createdAt: testDate,
            updatedAt: testDate,
          ).getEventTypeEmoji(),
          equals('🎓'),
        );
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final event = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          attendeeIds: ['user-1'],
          attendeeCount: 1,
          maxAttendees: 10,
          startTime: startTime,
          endTime: endTime,
          spots: testSpots,
          location: '123 Main St',
          latitude: 40.7128,
          longitude: -74.0060,
          price: 25.0,
          isPaid: true,
          isPublic: true,
          createdAt: testDate,
          updatedAt: testDate,
          status: EventStatus.upcoming,
        );

        final json = event.toJson();

        expect(json['id'], equals('event-123'));
        expect(json['title'], equals('Coffee Tour'));
        expect(json['description'], equals('A guided tour'));
        expect(json['category'], equals('Coffee'));
        expect(json['eventType'], equals('tour'));
        expect(json['hostId'], equals('host-123'));
        expect(json['attendeeIds'], equals(['user-1']));
        expect(json['attendeeCount'], equals(1));
        expect(json['maxAttendees'], equals(10));
        expect(json['startTime'], equals(startTime.toIso8601String()));
        expect(json['endTime'], equals(endTime.toIso8601String()));
        expect(json['spotIds'], equals(['spot-1', 'spot-2']));
        expect(json['location'], equals('123 Main St'));
        expect(json['latitude'], equals(40.7128));
        expect(json['longitude'], equals(-74.0060));
        expect(json['price'], equals(25.0));
        expect(json['isPaid'], isTrue);
        expect(json['isPublic'], isTrue);
        expect(json['createdAt'], equals(testDate.toIso8601String()));
        expect(json['updatedAt'], equals(testDate.toIso8601String()));
        expect(json['status'], equals('upcoming'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'event-123',
          'title': 'Coffee Tour',
          'description': 'A guided tour',
          'category': 'Coffee',
          'eventType': 'tour',
          'hostId': 'host-123',
          'attendeeIds': ['user-1'],
          'attendeeCount': 1,
          'maxAttendees': 10,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'spotIds': ['spot-1', 'spot-2'],
          'location': '123 Main St',
          'latitude': 40.7128,
          'longitude': -74.0060,
          'price': 25.0,
          'isPaid': true,
          'isPublic': true,
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
          'status': 'upcoming',
        };

        final event = ExpertiseEvent.fromJson(json, testHost);

        expect(event.id, equals('event-123'));
        expect(event.title, equals('Coffee Tour'));
        expect(event.description, equals('A guided tour'));
        expect(event.category, equals('Coffee'));
        expect(event.eventType, equals(ExpertiseEventType.tour));
        expect(event.host, equals(testHost));
        expect(event.attendeeIds, equals(['user-1']));
        expect(event.attendeeCount, equals(1));
        expect(event.maxAttendees, equals(10));
        expect(event.startTime, equals(startTime));
        expect(event.endTime, equals(endTime));
        expect(event.location, equals('123 Main St'));
        expect(event.latitude, equals(40.7128));
        expect(event.longitude, equals(-74.0060));
        expect(event.price, equals(25.0));
        expect(event.isPaid, isTrue);
        expect(event.isPublic, isTrue);
        expect(event.status, equals(EventStatus.upcoming));
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'id': 'event-123',
          'title': 'Coffee Tour',
          'description': 'A guided tour',
          'category': 'Coffee',
          'eventType': 'tour',
          'hostId': 'host-123',
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        final event = ExpertiseEvent.fromJson(json, testHost);

        expect(event.attendeeIds, isEmpty);
        expect(event.attendeeCount, equals(0));
        expect(event.maxAttendees, equals(20));
        expect(event.spots, isEmpty);
        expect(event.location, isNull);
        expect(event.latitude, isNull);
        expect(event.longitude, isNull);
        expect(event.price, isNull);
        expect(event.isPaid, isFalse);
        expect(event.isPublic, isTrue);
        expect(event.status, equals(EventStatus.upcoming));
      });
    });

    group('EventStatus Enum', () {
      test('should have all status values', () {
        expect(EventStatus.values, hasLength(4));
        expect(EventStatus.values, contains(EventStatus.upcoming));
        expect(EventStatus.values, contains(EventStatus.ongoing));
        expect(EventStatus.values, contains(EventStatus.completed));
        expect(EventStatus.values, contains(EventStatus.cancelled));
      });
    });

    group('ExpertiseEventType Enum', () {
      test('should have all event type values', () {
        expect(ExpertiseEventType.values, hasLength(6));
        expect(ExpertiseEventType.values, contains(ExpertiseEventType.tour));
        expect(ExpertiseEventType.values, contains(ExpertiseEventType.workshop));
        expect(ExpertiseEventType.values, contains(ExpertiseEventType.tasting));
        expect(ExpertiseEventType.values, contains(ExpertiseEventType.meetup));
        expect(ExpertiseEventType.values, contains(ExpertiseEventType.walk));
        expect(ExpertiseEventType.values, contains(ExpertiseEventType.lecture));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = ExpertiseEvent(
          id: 'event-123',
          title: 'Original Title',
          description: 'Original description',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          attendeeCount: 5,
          status: EventStatus.ongoing,
        );

        expect(updated.id, equals('event-123')); // Unchanged
        expect(updated.title, equals('Updated Title')); // Changed
        expect(updated.attendeeCount, equals(5)); // Changed
        expect(updated.status, equals(EventStatus.ongoing)); // Changed
        expect(updated.category, equals('Coffee')); // Unchanged
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final event1 = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final event2 = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event1, equals(event2));
      });

      test('should not be equal when properties differ', () {
        final event1 = ExpertiseEvent(
          id: 'event-123',
          title: 'Coffee Tour',
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final event2 = ExpertiseEvent(
          id: 'event-123',
          title: 'Different Title', // Different title
          description: 'A guided tour',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: testHost,
          startTime: startTime,
          endTime: endTime,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(event1, isNot(equals(event2)));
      });
    });
  });
}


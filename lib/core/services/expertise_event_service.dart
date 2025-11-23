import 'dart:developer' as developer;
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/services/logger.dart';

/// Expertise Event Service
/// OUR_GUTS.md: "Pins unlock new features, like event hosting"
/// Manages expert-led events (tours, workshops, tastings, etc.)
class ExpertiseEventService {
  static const String _logName = 'ExpertiseEventService';
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);

  /// Create a new expertise event
  /// Requires user to have City level or higher expertise
  Future<ExpertiseEvent> createEvent({
    required UnifiedUser host,
    required String title,
    required String description,
    required String category,
    required ExpertiseEventType eventType,
    required DateTime startTime,
    required DateTime endTime,
    List<Spot>? spots,
    String? location,
    double? latitude,
    double? longitude,
    int maxAttendees = 20,
    double? price,
    bool isPublic = true,
  }) async {
    try {
      _logger.info('Creating expertise event: $title', tag: _logName);

      // Verify host can host events
      if (!host.canHostEvents()) {
        throw Exception('Host must have City level or higher expertise to host events');
      }

      // Verify host has expertise in category
      if (!host.hasExpertiseIn(category)) {
        throw Exception('Host must have expertise in $category');
      }

      final event = ExpertiseEvent(
        id: _generateEventId(),
        title: title,
        description: description,
        category: category,
        eventType: eventType,
        host: host,
        startTime: startTime,
        endTime: endTime,
        spots: spots ?? [],
        location: location,
        latitude: latitude,
        longitude: longitude,
        maxAttendees: maxAttendees,
        price: price,
        isPaid: price != null && price > 0,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: EventStatus.upcoming,
      );

      // In production, save to database
      await _saveEvent(event);

      _logger.info('Created event: ${event.id}', tag: _logName);
      return event;
    } catch (e) {
      _logger.error('Error creating event', error: e, tag: _logName);
      rethrow;
    }
  }

  /// Copy & Repeat: Duplicate an event for easy re-hosting
  /// OUR_GUTS.md: "Make hosting incredibly easy"
  /// Philosophy: One-click to host the same event again
  Future<ExpertiseEvent> duplicateEvent({
    required ExpertiseEvent originalEvent,
    DateTime? newStartTime,
    bool autoSuggestTime = true,
  }) async {
    try {
      _logger.info('Duplicating event: ${originalEvent.id}', tag: _logName);
      
      // Auto-suggest next weekend if no time specified
      DateTime startTime = newStartTime ?? _suggestNextWeekend();
      
      // Calculate end time based on original duration
      final duration = originalEvent.endTime.difference(originalEvent.startTime);
      final endTime = startTime.add(duration);
      
      // Create new event with same settings
      final duplicatedEvent = ExpertiseEvent(
        id: _generateEventId(),
        title: originalEvent.title,
        description: originalEvent.description,
        category: originalEvent.category,
        eventType: originalEvent.eventType,
        host: originalEvent.host,
        startTime: startTime,
        endTime: endTime,
        spots: originalEvent.spots,
        location: originalEvent.location,
        latitude: originalEvent.latitude,
        longitude: originalEvent.longitude,
        maxAttendees: originalEvent.maxAttendees,
        price: originalEvent.price,
        isPaid: originalEvent.isPaid,
        isPublic: originalEvent.isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: EventStatus.upcoming,
        attendeeIds: [], // Reset attendees
        attendeeCount: 0,
      );
      
      await _saveEvent(duplicatedEvent);
      
      _logger.info('Duplicated event: ${duplicatedEvent.id}', tag: _logName);
      return duplicatedEvent;
    } catch (e) {
      _logger.error('Error duplicating event', error: e, tag: _logName);
      rethrow;
    }
  }
  
  /// Suggest next weekend date for events
  DateTime _suggestNextWeekend() {
    final now = DateTime.now();
    var saturday = now.add(Duration(days: (DateTime.saturday - now.weekday) % 7));
    if (saturday.isBefore(now)) {
      saturday = saturday.add(const Duration(days: 7));
    }
    return DateTime(saturday.year, saturday.month, saturday.day, 10, 0);
  }

  /// Register for an event
  Future<void> registerForEvent(ExpertiseEvent event, UnifiedUser user) async {
    try {
      _logger.info('User ${user.id} registering for event ${event.id}', tag: _logName);

      if (!event.canUserAttend(user.id)) {
        throw Exception('User cannot attend this event');
      }

      final updated = event.copyWith(
        attendeeIds: [...event.attendeeIds, user.id],
        attendeeCount: event.attendeeCount + 1,
        updatedAt: DateTime.now(),
      );

      await _saveEvent(updated);
      _logger.info('User registered for event', tag: _logName);
    } catch (e) {
      _logger.error('Error registering for event', error: e, tag: _logName);
      rethrow;
    }
  }

  /// Cancel event registration
  Future<void> cancelRegistration(ExpertiseEvent event, UnifiedUser user) async {
    try {
      if (!event.attendeeIds.contains(user.id)) {
        throw Exception('User is not registered for this event');
      }

      final updated = event.copyWith(
        attendeeIds: event.attendeeIds.where((id) => id != user.id).toList(),
        attendeeCount: event.attendeeCount - 1,
        updatedAt: DateTime.now(),
      );

      await _saveEvent(updated);
      _logger.info('User cancelled registration', tag: _logName);
    } catch (e) {
      _logger.error('Error cancelling registration', error: e, tag: _logName);
      rethrow;
    }
  }

  /// Get events hosted by an expert
  Future<List<ExpertiseEvent>> getEventsByHost(UnifiedUser host) async {
    try {
      final allEvents = await _getAllEvents();
      return allEvents
          .where((event) => event.host.id == host.id)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      _logger.error('Error getting events by host', error: e, tag: _logName);
      return [];
    }
  }

  /// Get events user is attending
  Future<List<ExpertiseEvent>> getEventsByAttendee(UnifiedUser user) async {
    try {
      final allEvents = await _getAllEvents();
      return allEvents
          .where((event) => event.attendeeIds.contains(user.id))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      _logger.error('Error getting events by attendee', error: e, tag: _logName);
      return [];
    }
  }

  /// Search events
  Future<List<ExpertiseEvent>> searchEvents({
    String? category,
    String? location,
    ExpertiseEventType? eventType,
    DateTime? startDate,
    DateTime? endDate,
    int maxResults = 20,
  }) async {
    try {
      final allEvents = await _getAllEvents();
      
      return allEvents.where((event) {
        if (category != null && event.category != category) return false;
        if (location != null && event.location != null) {
          if (!event.location!.toLowerCase().contains(location.toLowerCase())) {
            return false;
          }
        }
        if (eventType != null && event.eventType != eventType) return false;
        if (startDate != null && event.startTime.isBefore(startDate)) return false;
        if (endDate != null && event.endTime.isAfter(endDate)) return false;
        if (event.status != EventStatus.upcoming) return false;
        return true;
      }).take(maxResults).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      _logger.error('Error searching events', error: e, tag: _logName);
      return [];
    }
  }

  /// Get upcoming events in a category
  Future<List<ExpertiseEvent>> getUpcomingEventsInCategory(
    String category, {
    int maxResults = 10,
  }) async {
    return searchEvents(
      category: category,
      maxResults: maxResults,
    );
  }

  /// Update event status
  Future<void> updateEventStatus(
    ExpertiseEvent event,
    EventStatus status,
  ) async {
    try {
      final updated = event.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await _saveEvent(updated);
      _logger.info('Updated event status: ${event.id}', tag: _logName);
    } catch (e) {
      _logger.error('Error updating event status', error: e, tag: _logName);
      rethrow;
    }
  }

  // Private helper methods

  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveEvent(ExpertiseEvent event) async {
    // In production, save to database
  }

  Future<List<ExpertiseEvent>> _getAllEvents() async {
    // In production, query database
    return [];
  }
}


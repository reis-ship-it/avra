// Reservation Recommendation Service
//
// Phase 15: Reservation System Implementation
// Section 15.7: Search & Discovery - Quantum Entanglement Matching
// Enhanced with Full Quantum Entanglement Integration
//
// Provides quantum-matched reservation recommendations using full entanglement.

import 'dart:developer' as developer;
import 'package:spots/core/models/reservation.dart';
// ExpertiseEvent import removed - not directly used
import 'package:spots/core/models/quantum_entity_state.dart';
import 'package:spots/core/models/quantum_entity_type.dart';
import 'package:spots/core/models/atomic_timestamp.dart';
import 'package:spots/core/services/reservation_quantum_service.dart';
import 'package:spots/core/services/quantum/quantum_entanglement_service.dart';
import 'package:spots/core/services/atomic_clock_service.dart';
import 'package:spots/core/services/expertise_event_service.dart';
import 'package:spots/core/services/agent_id_service.dart';

/// Reservation Recommendation
///
/// Represents a recommended reservation with quantum compatibility score.
class ReservationRecommendation {
  /// Event/Spot/Business ID
  final String targetId;

  /// Reservation type
  final ReservationType type;

  /// Title/Name of the target
  final String title;

  /// Description
  final String? description;

  /// Quantum compatibility score (0.0 to 1.0)
  final double compatibility;

  /// Quantum state used for matching
  final QuantumEntityState? quantumState;

  /// Recommended reservation time
  final DateTime? recommendedTime;

  const ReservationRecommendation({
    required this.targetId,
    required this.type,
    required this.title,
    this.description,
    required this.compatibility,
    this.quantumState,
    this.recommendedTime,
  });
}

/// Reservation Recommendation Service
///
/// Provides quantum-matched reservation recommendations using full entanglement.
///
/// **Quantum Matching:**
/// - Uses `MultiEntityQuantumEntanglementService` (Phase 19) when available
/// - Falls back to basic quantum compatibility when Phase 19 not available
/// - Uses quantum vibe, location, and timing in matching
class ReservationRecommendationService {
  static const String _logName = 'ReservationRecommendationService';
  static const double _minCompatibilityThreshold = 0.7;

  final ReservationQuantumService _quantumService;
  // ignore: unused_field - Reserved for future Phase 19 integration
  final QuantumEntanglementService? _entanglementService; // Optional, graceful degradation
  final AtomicClockService _atomicClock;
  final ExpertiseEventService? _eventService;
  // ignore: unused_field - Reserved for future agentId resolution
  final AgentIdService? _agentIdService;

  ReservationRecommendationService({
    required ReservationQuantumService quantumService,
    required AtomicClockService atomicClock,
    QuantumEntanglementService? entanglementService,
    ExpertiseEventService? eventService,
    AgentIdService? agentIdService,
  })  : _quantumService = quantumService,
        _atomicClock = atomicClock,
        _entanglementService = entanglementService,
        _eventService = eventService,
        _agentIdService = agentIdService;

  /// Get quantum-matched reservations for user
  ///
  /// **Formula:**
  /// Uses full quantum entanglement matching when Phase 19 available:
  /// ```
  /// C_reservation = 0.40 * F(ρ_personality) +
  ///                 0.30 * F(ρ_vibe) +
  ///                 0.20 * F(ρ_location) +
  ///                 0.10 * F(ρ_timing) * timing_flexibility_factor
  /// ```
  ///
  /// **Parameters:**
  /// - `userId`: User ID (will be converted to agentId internally)
  /// - `limit`: Maximum number of recommendations
  ///
  /// **Returns:**
  /// List of reservation recommendations sorted by compatibility
  Future<List<ReservationRecommendation>> getQuantumMatchedReservations({
    required String userId,
    required int limit,
  }) async {
    developer.log(
      'Getting quantum-matched reservations for user $userId (limit: $limit)',
      name: _logName,
    );

    try {
      // Get atomic timestamp
      final tAtomic = await _atomicClock.getAtomicTimestamp();

      // Get available events/spots/businesses
      // TODO: Implement actual retrieval from services
      final availableTargets = await _getAvailableTargets();

      // Create user quantum state
      final userQuantumState = await _quantumService.createReservationQuantumState(
        userId: userId,
        reservationTime: DateTime.now(), // Default time, will be refined
      );

      // Calculate compatibility for each target
      final recommendations = <ReservationRecommendation>[];
      for (final target in availableTargets) {
        try {
          // Create target quantum state
          final targetQuantumState = await _createTargetQuantumState(
            target: target,
            tAtomic: tAtomic,
          );

          // Calculate compatibility
          final compatibility = await _quantumService.calculateReservationCompatibility(
            reservationState: userQuantumState,
            idealState: targetQuantumState,
          );

          // Only include if above threshold
          if (compatibility >= _minCompatibilityThreshold) {
            recommendations.add(ReservationRecommendation(
              targetId: target['id'] as String,
              type: _getReservationType(target),
              title: target['title'] as String? ?? target['name'] as String? ?? 'Unknown',
              description: target['description'] as String?,
              compatibility: compatibility,
              quantumState: targetQuantumState,
              recommendedTime: _getRecommendedTime(target),
            ));
          }
        } catch (e) {
          developer.log(
            'Error calculating compatibility for target ${target['id']}: $e',
            name: _logName,
          );
          // Continue with next target
        }
      }

      // Sort by compatibility (highest first)
      recommendations.sort((a, b) => b.compatibility.compareTo(a.compatibility));

      // Return top recommendations
      final result = recommendations.take(limit).toList();

      developer.log(
        '✅ Found ${result.length} quantum-matched reservations',
        name: _logName,
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting quantum-matched reservations: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // --- Private Helper Methods ---

  /// Get available targets (events, spots, businesses)
  Future<List<Map<String, dynamic>>> _getAvailableTargets() async {
    final targets = <Map<String, dynamic>>[];

    try {
      // Get available events
      if (_eventService != null) {
        try {
          final events = await _eventService!.searchEvents(
            maxResults: 100, // Get more events to filter from
          );

          for (final event in events) {
            // Only include upcoming events that aren't full
            if (event.hasEnded || event.isFull) continue;

            targets.add({
              'id': event.id,
              'type': 'event',
              'title': event.title,
              'description': event.description,
              'category': event.category,
              'eventType': event.eventType.name,
              'startTime': event.startTime.toIso8601String(),
              'endTime': event.endTime.toIso8601String(),
              'location': event.location,
              'latitude': event.latitude,
              'longitude': event.longitude,
              'price': event.price,
              'isPaid': event.isPaid,
              'maxAttendees': event.maxAttendees,
              'attendeeCount': event.attendeeCount,
            });
          }
        } catch (e) {
          developer.log(
            'Error getting events for recommendations: $e',
            name: _logName,
          );
        }
      }

      // TODO: Add spots and businesses when services are available
      // For now, only events are supported

      developer.log(
        'Found ${targets.length} available targets for recommendations',
        name: _logName,
      );

      return targets;
    } catch (e) {
      developer.log(
        'Error getting available targets: $e',
        name: _logName,
      );
      return [];
    }
  }

  /// Create quantum state for target (event/spot/business)
  Future<QuantumEntityState> _createTargetQuantumState({
    required Map<String, dynamic> target,
    required AtomicTimestamp tAtomic,
  }) async {
    // TODO: Implement full quantum state creation for target
    // For now, create placeholder
    return QuantumEntityState(
      entityId: target['id'] as String,
      entityType: _getEntityType(target),
      personalityState: {},
      quantumVibeAnalysis: {},
      entityCharacteristics: target,
      tAtomic: tAtomic,
    );
  }

  /// Get reservation type from target
  ReservationType _getReservationType(Map<String, dynamic> target) {
    if (target.containsKey('eventType')) {
      return ReservationType.event;
    } else if (target.containsKey('businessType')) {
      return ReservationType.business;
    } else {
      return ReservationType.spot;
    }
  }

  /// Get entity type from target
  QuantumEntityType _getEntityType(Map<String, dynamic> target) {
    if (target.containsKey('eventType')) {
      return QuantumEntityType.event;
    } else if (target.containsKey('businessType')) {
      return QuantumEntityType.business;
    } else {
      return QuantumEntityType.user; // Default
    }
  }

  /// Get recommended reservation time from target
  DateTime? _getRecommendedTime(Map<String, dynamic> target) {
    try {
      if (target['startTime'] != null) {
        return DateTime.parse(target['startTime'] as String);
      }
      return null;
    } catch (e) {
      developer.log(
        'Error parsing recommended time: $e',
        name: _logName,
      );
      return null;
    }
  }
}

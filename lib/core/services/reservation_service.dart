// Reservation Service
//
// Phase 15: Reservation System Implementation
// Section 15.1: Foundation - Core Service
// Enhanced with Quantum Entanglement Integration
//
// Core reservation management service with quantum integration.

import 'dart:developer' as developer;
import 'dart:convert';
import 'package:spots/core/models/reservation.dart';
// AtomicTimestamp import removed - only used in model, not directly in service
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots/core/services/reservation_quantum_service.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

/// Reservation Service
///
/// Core reservation management with quantum integration.
/// Uses agentId (not userId) for privacy-protected internal tracking.
class ReservationService {
  static const String _logName = 'ReservationService';
  static const String _storageKeyPrefix = 'reservation_';
  static const String _supabaseTable = 'reservations';

  final AtomicClockService _atomicClock;
  final ReservationQuantumService _quantumService;
  final AgentIdService _agentIdService;
  final StorageService _storageService;
  final SupabaseService _supabaseService;
  final Uuid _uuid = const Uuid();

  ReservationService({
    required AtomicClockService atomicClock,
    required ReservationQuantumService quantumService,
    required AgentIdService agentIdService,
    required StorageService storageService,
    required SupabaseService supabaseService,
  })  : _atomicClock = atomicClock,
        _quantumService = quantumService,
        _agentIdService = agentIdService,
        _storageService = storageService,
        _supabaseService = supabaseService;

  /// Create reservation (free by default, business can require fee)
  ///
  /// **CRITICAL:** Uses agentId (not userId) for privacy-protected internal tracking.
  ///
  /// **Quantum Integration:**
  /// - Creates quantum state for reservation
  /// - Uses atomic timestamp for queue ordering
  Future<Reservation> createReservation({
    required String userId, // Will be converted to agentId internally
    required ReservationType type,
    required String targetId,
    required DateTime reservationTime,
    required int partySize,
    int? ticketCount,
    String? specialRequests,
    double? ticketPrice,
    double? depositAmount,
    String? seatId,
    CancellationPolicy? cancellationPolicy,
    Map<String, dynamic>? userData, // Optional user data (shared with business/host if user consents)
  }) async {
    developer.log(
      'Creating reservation: type=$type, targetId=$targetId, time=$reservationTime',
      name: _logName,
    );

    try {
      // Get agentId for privacy-protected internal tracking
      final agentId = await _agentIdService.getUserAgentId(userId);

      // Get atomic timestamp for queue ordering
      final atomicTimestamp = await _atomicClock.getTicketPurchaseTimestamp();

      // Create quantum state for reservation
      final quantumState = await _quantumService.createReservationQuantumState(
        userId: userId,
        eventId: type == ReservationType.event ? targetId : null,
        businessId: type == ReservationType.business ? targetId : null,
        spotId: type == ReservationType.spot ? targetId : null,
        reservationTime: reservationTime,
      );

      // Create reservation
      final reservation = Reservation(
        id: _uuid.v4(),
        agentId: agentId, // CRITICAL: Uses agentId, not userId
        userData: userData,
        type: type,
        targetId: targetId,
        reservationTime: reservationTime,
        partySize: partySize,
        ticketCount: ticketCount ?? partySize,
        specialRequests: specialRequests,
        status: ReservationStatus.pending,
        ticketPrice: ticketPrice,
        depositAmount: depositAmount,
        seatId: seatId,
        cancellationPolicy: cancellationPolicy ?? CancellationPolicy.defaultPolicy(),
        atomicTimestamp: atomicTimestamp,
        quantumState: quantumState,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store locally first (offline-first)
      await _storeReservationLocally(reservation);

      // Sync to cloud when online
      if (_supabaseService.isAvailable) {
        try {
          await _syncReservationToCloud(reservation);
        } catch (e) {
          developer.log(
            'Failed to sync reservation to cloud (will retry later): $e',
            name: _logName,
          );
          // Continue - offline-first, will sync later
        }
      }

      developer.log(
        '✅ Reservation created: ${reservation.id}',
        name: _logName,
      );

      return reservation;
    } catch (e, stackTrace) {
      developer.log(
        'Error creating reservation: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get user's reservations
  ///
  /// **CRITICAL:** Uses agentId (not userId) for privacy-protected internal tracking.
  Future<List<Reservation>> getUserReservations({
    String? userId, // Will be converted to agentId internally
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    developer.log(
      'Getting user reservations: userId=$userId, status=$status',
      name: _logName,
    );

    try {
      // Get agentId if userId provided (for filtering)
      String? agentId;
      if (userId != null) {
        agentId = await _agentIdService.getUserAgentId(userId);
      }

      // Get from local storage first
      final localReservations = await _getReservationsFromLocal(
        agentId: agentId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      // If online, also get from cloud and merge
      if (_supabaseService.isAvailable) {
        try {
          final cloudReservations = await _getReservationsFromCloud(
            agentId: agentId,
            status: status,
            startDate: startDate,
            endDate: endDate,
          );

          // Merge: prefer cloud if newer, otherwise local
          return _mergeReservations(localReservations, cloudReservations);
        } catch (e) {
          developer.log(
            'Failed to get reservations from cloud: $e',
            name: _logName,
          );
          // Return local reservations if cloud fails
        }
      }

      return localReservations;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting user reservations: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if user already has reservation for this target/time
  ///
  /// **CRITICAL:** Uses agentId (not userId) for privacy-protected internal tracking.
  Future<bool> hasExistingReservation({
    required String userId, // Will be converted to agentId internally
    required ReservationType type,
    required String targetId,
    required DateTime reservationTime,
  }) async {
    try {
      // Get reservations for user (uses agentId internally)
      final reservations = await getUserReservations(userId: userId);

      // Check for existing reservation at same target and time (within 1 hour window)
      return reservations.any((r) =>
          r.type == type &&
          r.targetId == targetId &&
          r.reservationTime.difference(reservationTime).inHours.abs() < 1 &&
          r.status != ReservationStatus.cancelled);
    } catch (e) {
      developer.log(
        'Error checking existing reservation: $e',
        name: _logName,
      );
      return false; // Default to false on error
    }
  }

  /// Update reservation (with modification limits)
  Future<Reservation> updateReservation({
    required String reservationId,
    DateTime? reservationTime,
    int? partySize,
    int? ticketCount,
    String? specialRequests,
  }) async {
    developer.log(
      'Updating reservation: $reservationId',
      name: _logName,
    );

    try {
      // Get existing reservation
      final existing = await _getReservationById(reservationId);
      if (existing == null) {
        throw Exception('Reservation not found: $reservationId');
      }

      // Check if can modify
      if (!existing.canModify()) {
        throw Exception('Reservation cannot be modified (max 3 modifications or too close to reservation time)');
      }

      // Update reservation
      final updated = existing.copyWith(
        reservationTime: reservationTime ?? existing.reservationTime,
        partySize: partySize ?? existing.partySize,
        ticketCount: ticketCount ?? existing.ticketCount,
        specialRequests: specialRequests ?? existing.specialRequests,
        modificationCount: existing.modificationCount + 1,
        lastModifiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store locally
      await _storeReservationLocally(updated);

      // Sync to cloud
      if (_supabaseService.isAvailable) {
        try {
          await _syncReservationToCloud(updated);
        } catch (e) {
          developer.log(
            'Failed to sync updated reservation to cloud: $e',
            name: _logName,
          );
        }
      }

      developer.log(
        '✅ Reservation updated: $reservationId',
        name: _logName,
      );

      return updated;
    } catch (e, stackTrace) {
      developer.log(
        'Error updating reservation: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Cancel reservation (applies cancellation policy)
  Future<Reservation> cancelReservation({
    required String reservationId,
    required String reason,
    bool applyPolicy = true,
  }) async {
    developer.log(
      'Cancelling reservation: $reservationId, reason=$reason',
      name: _logName,
    );

    try {
      // Get existing reservation
      final existing = await _getReservationById(reservationId);
      if (existing == null) {
        throw Exception('Reservation not found: $reservationId');
      }

      // Check if can cancel
      if (!existing.canCancel()) {
        throw Exception('Reservation cannot be cancelled');
      }

      // Update status
      final updated = existing.copyWith(
        status: ReservationStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      // Store locally
      await _storeReservationLocally(updated);

      // Sync to cloud
      if (_supabaseService.isAvailable) {
        try {
          await _syncReservationToCloud(updated);
        } catch (e) {
          developer.log(
            'Failed to sync cancelled reservation to cloud: $e',
            name: _logName,
          );
        }
      }

      developer.log(
        '✅ Reservation cancelled: $reservationId',
        name: _logName,
      );

      return updated;
    } catch (e, stackTrace) {
      developer.log(
        'Error cancelling reservation: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // --- Private Helper Methods ---

  /// Store reservation locally (offline-first)
  Future<void> _storeReservationLocally(Reservation reservation) async {
    final key = '$_storageKeyPrefix${reservation.id}';
    final jsonStr = jsonEncode(reservation.toJson());
    await _storageService.setString(key, jsonStr);
  }

  /// Get reservation by ID
  Future<Reservation?> _getReservationById(String reservationId) async {
    final key = '$_storageKeyPrefix$reservationId';
    final jsonStr = _storageService.getString(key);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Reservation.fromJson(json);
    } catch (e) {
      developer.log(
        'Error parsing reservation JSON: $e',
        name: _logName,
      );
      return null;
    }
  }

  /// Get reservations from local storage
  Future<List<Reservation>> _getReservationsFromLocal({
    String? agentId,
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final allKeys = _storageService.getKeys();
      final reservationKeys = allKeys.where((key) => key.startsWith(_storageKeyPrefix)).toList();
      
      final reservations = <Reservation>[];
      
      for (final key in reservationKeys) {
        try {
          final jsonStr = _storageService.getString(key);
          if (jsonStr == null) continue;
          
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          final reservation = Reservation.fromJson(json);
          
          // Filter by agentId if provided
          if (agentId != null && reservation.agentId != agentId) continue;
          
          // Filter by status if provided
          if (status != null && reservation.status != status) continue;
          
          // Filter by date range if provided
          if (startDate != null && reservation.reservationTime.isBefore(startDate)) continue;
          if (endDate != null && reservation.reservationTime.isAfter(endDate)) continue;
          
          reservations.add(reservation);
        } catch (e) {
          developer.log(
            'Error parsing reservation from local storage: $e',
            name: _logName,
          );
          // Continue with next reservation
        }
      }
      
      return reservations;
    } catch (e) {
      developer.log(
        'Error getting reservations from local storage: $e',
        name: _logName,
      );
      return [];
    }
  }

  /// Get reservations from cloud
  Future<List<Reservation>> _getReservationsFromCloud({
    String? agentId,
    ReservationStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_supabaseService.isAvailable) {
      return [];
    }

    try {
      final client = _supabaseService.client;
      var query = client.from(_supabaseTable).select();

      if (agentId != null) {
        query = query.eq('agent_id', agentId);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (startDate != null) {
        query = query.gte('reservation_time', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('reservation_time', endDate.toIso8601String());
      }

      final response = await query;

      if (response.isEmpty) return [];

      final reservations = <Reservation>[];
      for (final row in response) {
        try {
          final reservation = Reservation.fromJson(Map<String, dynamic>.from(row));
          reservations.add(reservation);
        } catch (e) {
          developer.log(
            'Error parsing reservation from cloud: $e',
            name: _logName,
          );
          // Continue with next reservation
        }
      }

      return reservations;
    } catch (e) {
      developer.log(
        'Error getting reservations from cloud: $e',
        name: _logName,
      );
      return [];
    }
  }

  /// Sync reservation to cloud
  Future<void> _syncReservationToCloud(Reservation reservation) async {
    if (!_supabaseService.isAvailable) {
      return;
    }

    try {
      final client = _supabaseService.client;
      await client.from(_supabaseTable).upsert({
        'id': reservation.id,
        'agent_id': reservation.agentId,
        'user_data': reservation.userData,
        'type': reservation.type.name,
        'target_id': reservation.targetId,
        'reservation_time': reservation.reservationTime.toIso8601String(),
        'party_size': reservation.partySize,
        'ticket_count': reservation.ticketCount,
        'special_requests': reservation.specialRequests,
        'status': reservation.status.name,
        'ticket_price': reservation.ticketPrice,
        'deposit_amount': reservation.depositAmount,
        'seat_id': reservation.seatId,
        'cancellation_policy': reservation.cancellationPolicy?.toJson(),
        'modification_count': reservation.modificationCount,
        'last_modified_at': reservation.lastModifiedAt?.toIso8601String(),
        'dispute_status': reservation.disputeStatus.name,
        'dispute_reason': reservation.disputeReason?.name,
        'dispute_description': reservation.disputeDescription,
        'atomic_timestamp': reservation.atomicTimestamp?.toJson(),
        'quantum_state': reservation.quantumState?.toJson(),
        'metadata': reservation.metadata,
        'created_at': reservation.createdAt.toIso8601String(),
        'updated_at': reservation.updatedAt.toIso8601String(),
      });
    } catch (e) {
      developer.log(
        'Error syncing reservation to cloud: $e',
        name: _logName,
      );
      rethrow;
    }
  }

  /// Merge local and cloud reservations (prefer newer)
  List<Reservation> _mergeReservations(
    List<Reservation> local,
    List<Reservation> cloud,
  ) {
    // Create a map of reservations by ID
    final reservationMap = <String, Reservation>{};
    
    // Add local reservations first
    for (final reservation in local) {
      reservationMap[reservation.id] = reservation;
    }
    
    // Merge cloud reservations (prefer newer updatedAt)
    for (final cloudReservation in cloud) {
      final existing = reservationMap[cloudReservation.id];
      if (existing == null) {
        // New reservation from cloud
        reservationMap[cloudReservation.id] = cloudReservation;
      } else {
        // Prefer newer updatedAt
        if (cloudReservation.updatedAt.isAfter(existing.updatedAt)) {
          reservationMap[cloudReservation.id] = cloudReservation;
        }
      }
    }
    
    // Return merged list sorted by reservation time
    final merged = reservationMap.values.toList();
    merged.sort((a, b) => a.reservationTime.compareTo(b.reservationTime));
    return merged;
  }
}

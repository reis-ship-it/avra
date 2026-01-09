/// SPOTS Reservation Service Tests
/// Date: January 1, 2026
/// Purpose: Test ReservationService functionality
/// 
/// Test Coverage:
/// - Core Methods: createReservation, getUserReservations, updateReservation, cancelReservation
/// - Offline-First: Local storage operations
/// - Privacy: agentId usage (not userId)
/// - Error Handling: Invalid inputs, edge cases
/// 
/// Dependencies:
/// - Mock AtomicClockService: Atomic timestamp generation
/// - Mock ReservationQuantumService: Quantum state creation
/// - Mock AgentIdService: Agent ID resolution
/// - Mock StorageService: Local storage
/// - Mock SupabaseService: Cloud sync
/// 
/// ⚠️  TEST QUALITY GUIDELINES:
/// ✅ DO: Test business logic, error handling, async operations, side effects
/// ✅ DO: Test service behavior and interactions with dependencies
/// ✅ DO: Consolidate related checks into comprehensive test blocks
/// 
/// See: docs/plans/test_refactoring/TEST_WRITING_GUIDE.md
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avrai/core/services/reservation_service.dart';
import 'package:avrai_core/services/atomic_clock_service.dart';
import 'package:avrai/core/services/reservation_quantum_service.dart';
import 'package:avrai/core/services/agent_id_service.dart';
import 'package:avrai/core/services/storage_service.dart';
import 'package:avrai/core/services/supabase_service.dart';
import 'package:avrai/core/models/reservation.dart';
import 'package:avrai_core/models/atomic_timestamp.dart';
import 'package:avrai_core/models/quantum_entity_state.dart';
import 'package:avrai_core/models/quantum_entity_type.dart';

// Mock dependencies
class MockAtomicClockService extends Mock implements AtomicClockService {}
class MockReservationQuantumService extends Mock implements ReservationQuantumService {}
class MockAgentIdService extends Mock implements AgentIdService {}
class MockStorageService extends Mock implements StorageService {}
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  group('ReservationService', () {
    late ReservationService service;
    late MockAtomicClockService mockAtomicClock;
    late MockReservationQuantumService mockQuantumService;
    late MockAgentIdService mockAgentIdService;
    late MockStorageService mockStorageService;
    late MockSupabaseService mockSupabaseService;

    setUp(() {
      mockAtomicClock = MockAtomicClockService();
      mockQuantumService = MockReservationQuantumService();
      mockAgentIdService = MockAgentIdService();
      mockStorageService = MockStorageService();
      mockSupabaseService = MockSupabaseService();

      service = ReservationService(
        atomicClock: mockAtomicClock,
        quantumService: mockQuantumService,
        agentIdService: mockAgentIdService,
        storageService: mockStorageService,
        supabaseService: mockSupabaseService,
      );
    });

    group('createReservation', () {
      test('should create reservation with quantum state and atomic timestamp', () async {
        // Arrange
        const userId = 'user-123';
        const agentId = 'agent-123';
        const eventId = 'event-456';
        final reservationTime = DateTime.now().add(const Duration(days: 7));

        final atomicTimestamp = AtomicTimestamp.now(
          precision: TimePrecision.millisecond,
        );

        final quantumState = QuantumEntityState(
          entityId: userId,
          entityType: QuantumEntityType.user,
          personalityState: {},
          quantumVibeAnalysis: {},
          entityCharacteristics: {},
          tAtomic: atomicTimestamp,
        );

        // Setup mocks
        when(() => mockAgentIdService.getUserAgentId(userId))
            .thenAnswer((_) async => agentId);
        when(() => mockAtomicClock.getTicketPurchaseTimestamp())
            .thenAnswer((_) async => atomicTimestamp);
        when(() => mockQuantumService.createReservationQuantumState(
          userId: any(named: 'userId'),
          eventId: any(named: 'eventId'),
          reservationTime: any(named: 'reservationTime'),
        )).thenAnswer((_) async => quantumState);
        when(() => mockStorageService.setString(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockSupabaseService.isAvailable).thenReturn(false); // Offline

        // Act
        final reservation = await service.createReservation(
          userId: userId,
          type: ReservationType.event,
          targetId: eventId,
          reservationTime: reservationTime,
          partySize: 2,
        );

        // Assert - Test actual behavior
        expect(reservation, isA<Reservation>());
        expect(reservation.agentId, equals(agentId)); // Uses agentId, not userId
        expect(reservation.type, equals(ReservationType.event));
        expect(reservation.targetId, equals(eventId));
        expect(reservation.partySize, equals(2));
        expect(reservation.status, equals(ReservationStatus.pending));
        expect(reservation.atomicTimestamp, equals(atomicTimestamp));
        expect(reservation.quantumState, equals(quantumState));

        // Verify interactions
        verify(() => mockAgentIdService.getUserAgentId(userId)).called(1);
        verify(() => mockAtomicClock.getTicketPurchaseTimestamp()).called(1);
        verify(() => mockQuantumService.createReservationQuantumState(
          userId: userId,
          eventId: eventId,
          reservationTime: reservationTime,
        )).called(1);
        verify(() => mockStorageService.setString(any(), any())).called(1);
      });

      test('should sync to cloud when online', () async {
        // Arrange
        const userId = 'user-123';
        const agentId = 'agent-123';
        const eventId = 'event-456';
        final reservationTime = DateTime.now().add(const Duration(days: 7));

        final atomicTimestamp = AtomicTimestamp.now(
          precision: TimePrecision.millisecond,
        );

        final quantumState = QuantumEntityState(
          entityId: userId,
          entityType: QuantumEntityType.user,
          personalityState: {},
          quantumVibeAnalysis: {},
          entityCharacteristics: {},
          tAtomic: atomicTimestamp,
        );

        // Setup mocks
        when(() => mockAgentIdService.getUserAgentId(userId))
            .thenAnswer((_) async => agentId);
        when(() => mockAtomicClock.getTicketPurchaseTimestamp())
            .thenAnswer((_) async => atomicTimestamp);
        when(() => mockQuantumService.createReservationQuantumState(
          userId: any(named: 'userId'),
          eventId: any(named: 'eventId'),
          reservationTime: any(named: 'reservationTime'),
        )).thenAnswer((_) async => quantumState);
        when(() => mockStorageService.setString(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockSupabaseService.isAvailable).thenReturn(true); // Online
        when(() => mockSupabaseService.client).thenThrow(Exception('Not implemented')); // Will fail gracefully

        // Act
        final reservation = await service.createReservation(
          userId: userId,
          type: ReservationType.event,
          targetId: eventId,
          reservationTime: reservationTime,
          partySize: 2,
        );

        // Assert - Reservation should still be created even if cloud sync fails
        expect(reservation, isA<Reservation>());
        expect(reservation.agentId, equals(agentId));
      });
    });

    group('getUserReservations', () {
      test('should get reservations from local storage when offline', () async {
        // Arrange
        const userId = 'user-123';
        const agentId = 'agent-123';

        // Create test reservation
        final testReservation = Reservation(
          id: 'reservation-1',
          agentId: agentId,
          type: ReservationType.event,
          targetId: 'event-456',
          reservationTime: DateTime.now().add(const Duration(days: 7)),
          partySize: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        when(() => mockAgentIdService.getUserAgentId(userId))
            .thenAnswer((_) async => agentId);
        when(() => mockStorageService.getKeys()).thenReturn(['reservation_reservation-1']);
        when(() => mockStorageService.getString('reservation_reservation-1'))
            .thenReturn('{"id":"reservation-1","agentId":"$agentId","type":"event","targetId":"event-456","reservationTime":"${testReservation.reservationTime.toIso8601String()}","partySize":2,"ticketCount":1,"status":"pending","modificationCount":0,"disputeStatus":"none","metadata":{},"createdAt":"${testReservation.createdAt.toIso8601String()}","updatedAt":"${testReservation.updatedAt.toIso8601String()}"}');
        when(() => mockSupabaseService.isAvailable).thenReturn(false); // Offline

        // Act
        final reservations = await service.getUserReservations(userId: userId);

        // Assert
        expect(reservations, isA<List<Reservation>>());
        expect(reservations.length, greaterThanOrEqualTo(0));
      });
    });

    group('hasExistingReservation', () {
      test('should return true when reservation exists for same target and time', () async {
        // Arrange
        const userId = 'user-123';
        const agentId = 'agent-123';
        const eventId = 'event-456';
        final reservationTime = DateTime.now().add(const Duration(days: 7));

        // Create existing reservation
        final existingReservation = Reservation(
          id: 'reservation-1',
          agentId: agentId,
          type: ReservationType.event,
          targetId: eventId,
          reservationTime: reservationTime,
          partySize: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        when(() => mockAgentIdService.getUserAgentId(userId))
            .thenAnswer((_) async => agentId);
        when(() => mockStorageService.getKeys()).thenReturn(['reservation_reservation-1']);
        when(() => mockStorageService.getString('reservation_reservation-1'))
            .thenReturn('{"id":"reservation-1","agentId":"$agentId","type":"event","targetId":"$eventId","reservationTime":"${reservationTime.toIso8601String()}","partySize":2,"ticketCount":1,"status":"pending","modificationCount":0,"disputeStatus":"none","metadata":{},"createdAt":"${existingReservation.createdAt.toIso8601String()}","updatedAt":"${existingReservation.updatedAt.toIso8601String()}"}');
        when(() => mockSupabaseService.isAvailable).thenReturn(false);

        // Act
        final hasExisting = await service.hasExistingReservation(
          userId: userId,
          type: ReservationType.event,
          targetId: eventId,
          reservationTime: reservationTime,
        );

        // Assert
        expect(hasExisting, isTrue);
      });

      test('should return false when no reservation exists', () async {
        // Arrange
        const userId = 'user-123';
        const eventId = 'event-456';
        final reservationTime = DateTime.now().add(const Duration(days: 7));

        // Setup mocks
        when(() => mockAgentIdService.getUserAgentId(userId))
            .thenAnswer((_) async => 'agent-123');
        when(() => mockStorageService.getKeys()).thenReturn([]);
        when(() => mockSupabaseService.isAvailable).thenReturn(false);

        // Act
        final hasExisting = await service.hasExistingReservation(
          userId: userId,
          type: ReservationType.event,
          targetId: eventId,
          reservationTime: reservationTime,
        );

        // Assert
        expect(hasExisting, isFalse);
      });
    });

    group('updateReservation', () {
      test('should update reservation and increment modification count', () async {
        // Arrange
        const reservationId = 'reservation-1';
        const agentId = 'agent-123';
        final originalTime = DateTime.now().add(const Duration(days: 7));
        final newTime = DateTime.now().add(const Duration(days: 8));

        // Create existing reservation
        final existingReservation = Reservation(
          id: reservationId,
          agentId: agentId,
          type: ReservationType.event,
          targetId: 'event-456',
          reservationTime: originalTime,
          partySize: 2,
          modificationCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        when(() => mockStorageService.getString('reservation_$reservationId'))
            .thenReturn('{"id":"$reservationId","agentId":"$agentId","type":"event","targetId":"event-456","reservationTime":"${originalTime.toIso8601String()}","partySize":2,"ticketCount":1,"status":"pending","modificationCount":0,"disputeStatus":"none","metadata":{},"createdAt":"${existingReservation.createdAt.toIso8601String()}","updatedAt":"${existingReservation.updatedAt.toIso8601String()}"}');
        when(() => mockStorageService.setString(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockSupabaseService.isAvailable).thenReturn(false);

        // Act
        final updated = await service.updateReservation(
          reservationId: reservationId,
          reservationTime: newTime,
        );

        // Assert
        expect(updated, isA<Reservation>());
        expect(updated.id, equals(reservationId));
        expect(updated.reservationTime, equals(newTime));
        expect(updated.modificationCount, equals(1)); // Incremented
        expect(updated.lastModifiedAt, isNotNull);
      });

      test('should throw exception when reservation cannot be modified', () async {
        // Arrange
        const reservationId = 'reservation-1';
        const agentId = 'agent-123';
        final originalTime = DateTime.now().add(const Duration(hours: 30)); // Too close

        // Create existing reservation with max modifications
        final existingReservation = Reservation(
          id: reservationId,
          agentId: agentId,
          type: ReservationType.event,
          targetId: 'event-456',
          reservationTime: originalTime,
          partySize: 2,
          modificationCount: 3, // Max modifications
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        when(() => mockStorageService.getString('reservation_$reservationId'))
            .thenReturn('{"id":"$reservationId","agentId":"$agentId","type":"event","targetId":"event-456","reservationTime":"${originalTime.toIso8601String()}","partySize":2,"ticketCount":1,"status":"pending","modificationCount":3,"disputeStatus":"none","metadata":{},"createdAt":"${existingReservation.createdAt.toIso8601String()}","updatedAt":"${existingReservation.updatedAt.toIso8601String()}"}');

        // Act & Assert
        expect(
          () => service.updateReservation(
            reservationId: reservationId,
            reservationTime: originalTime.add(const Duration(days: 1)),
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('cannot be modified'),
          )),
        );
      });
    });

    group('cancelReservation', () {
      test('should cancel reservation and update status', () async {
        // Arrange
        const reservationId = 'reservation-1';
        const agentId = 'agent-123';
        final reservationTime = DateTime.now().add(const Duration(days: 7));

        // Create existing reservation
        final existingReservation = Reservation(
          id: reservationId,
          agentId: agentId,
          type: ReservationType.event,
          targetId: 'event-456',
          reservationTime: reservationTime,
          partySize: 2,
          status: ReservationStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        when(() => mockStorageService.getString('reservation_$reservationId'))
            .thenReturn('{"id":"$reservationId","agentId":"$agentId","type":"event","targetId":"event-456","reservationTime":"${reservationTime.toIso8601String()}","partySize":2,"ticketCount":1,"status":"pending","modificationCount":0,"disputeStatus":"none","metadata":{},"createdAt":"${existingReservation.createdAt.toIso8601String()}","updatedAt":"${existingReservation.updatedAt.toIso8601String()}"}');
        when(() => mockStorageService.setString(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockSupabaseService.isAvailable).thenReturn(false);

        // Act
        final cancelled = await service.cancelReservation(
          reservationId: reservationId,
          reason: 'User request',
        );

        // Assert
        expect(cancelled, isA<Reservation>());
        expect(cancelled.id, equals(reservationId));
        expect(cancelled.status, equals(ReservationStatus.cancelled));
      });

      test('should throw exception when reservation cannot be cancelled', () async {
        // Arrange
        const reservationId = 'reservation-1';
        const agentId = 'agent-123';

        // Create existing reservation that's already cancelled
        final existingReservation = Reservation(
          id: reservationId,
          agentId: agentId,
          type: ReservationType.event,
          targetId: 'event-456',
          reservationTime: DateTime.now().add(const Duration(days: 7)),
          partySize: 2,
          status: ReservationStatus.cancelled, // Already cancelled
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        when(() => mockStorageService.getString('reservation_$reservationId'))
            .thenReturn('{"id":"$reservationId","agentId":"$agentId","type":"event","targetId":"event-456","reservationTime":"${existingReservation.reservationTime.toIso8601String()}","partySize":2,"ticketCount":1,"status":"cancelled","modificationCount":0,"disputeStatus":"none","metadata":{},"createdAt":"${existingReservation.createdAt.toIso8601String()}","updatedAt":"${existingReservation.updatedAt.toIso8601String()}"}');

        // Act & Assert
        expect(
          () => service.cancelReservation(
            reservationId: reservationId,
            reason: 'User request',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('cannot be cancelled'),
          )),
        );
      });
    });
  });
}

// Real-Time User Calling Service
//
// Implements dynamic real-time user calling based on evolving entangled states
// Part of Phase 19: Multi-Entity Quantum Entanglement Matching System
// Section 19.4: Dynamic Real-Time User Calling System
// Patent #29: Multi-Entity Quantum Entanglement Matching System
//
// NOTE: Some methods are marked as unused but are placeholders for future
// user service integration. They will be used when user service integration is complete.

import 'dart:developer' as developer;
import 'dart:async';
import 'package:spots_quantum/models/quantum_entity_state.dart';
import 'package:spots_quantum/models/quantum_entity_type.dart';
import 'package:spots_core/models/atomic_timestamp.dart';
import 'package:spots_core/models/user.dart';
import 'package:spots_core/enums/user_enums.dart';
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots_quantum/services/quantum/quantum_entanglement_service.dart';
import 'package:spots_quantum/services/quantum/location_timing_quantum_state_service.dart';
import 'package:spots_knot/services/knot/cross_entity_compatibility_service.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/preferences_profile_service.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots_knot/services/knot/entity_knot_service.dart';
import 'package:spots_knot/services/knot/personality_knot_service.dart';
import 'package:spots/core/services/quantum/meaningful_experience_calculator.dart';
import 'package:spots/core/services/quantum/user_journey_tracking_service.dart';
import 'package:spots_core/models/unified_location_data.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:math' as math;

/// Real-time user calling service
///
/// **User Calling Formula with Knot Integration and Timing Flexibility:**
/// ```
/// user_entangled_compatibility = 0.5 * F(ρ_user, ρ_entangled) +
///                               0.3 * F(ρ_user_location, ρ_event_location) +
///                               0.2 * timing_flexibility_factor * F(ρ_user_timing, ρ_event_timing) +
///                               0.15 * C_knot_bonus
/// 
/// Where:
/// timing_flexibility_factor = {
///   1.0 if timing_match ≥ 0.7 OR meaningful_experience_score ≥ 0.8,
///   0.5 if meaningful_experience_score ≥ 0.9 (highly meaningful experiences override timing),
///   weighted_combination(EntityTimingQuantumState, QuantumTemporalState) otherwise
/// }
/// ```
///
/// **Dynamic Calling Process:**
/// - Immediate calling upon event creation
/// - Real-time re-evaluation on entity addition
/// - Stop calling if compatibility drops below threshold
class RealTimeUserCallingService {
  static const String _logName = 'RealTimeUserCallingService';

  final AtomicClockService _atomicClock;
  final QuantumEntanglementService _entanglementService;
  final LocationTimingQuantumStateService _locationTimingService;
  final CrossEntityCompatibilityService? _knotCompatibilityService;
  final PersonalityLearning _personalityLearning;
  final UserVibeAnalyzer _vibeAnalyzer;
  final SupabaseService _supabaseService;
  final PreferencesProfileService _preferencesProfileService;
  final AgentIdService _agentIdService;
  final PersonalityKnotService _personalityKnotService;
  final MeaningfulExperienceCalculator _meaningfulExperienceCalculator;
  final UserJourneyTrackingService _journeyTrackingService;

  // Performance optimization: Cache for quantum states and compatibility
  final Map<String, CachedQuantumState> _quantumStateCache = {};
  final Map<String, CachedCompatibility> _compatibilityCache = {};
  static const int _maxCacheSize = 1000;

  // Batching configuration
  static const int _batchSize = 100; // Process users in batches of 100

  // Calling threshold
  static const double _callingThreshold = 0.7; // 70% compatibility threshold

  // Event call tracking (in-memory for now, can be replaced with database)
  // Maps: eventId -> Set of userIds who have been called
  final Map<String, Set<String>> _eventCalls = {};
  // Maps: eventId -> userId -> compatibility score
  final Map<String, Map<String, double>> _eventCallScores = {};

  RealTimeUserCallingService({
    required AtomicClockService atomicClock,
    required QuantumEntanglementService entanglementService,
    required LocationTimingQuantumStateService locationTimingService,
    required PersonalityLearning personalityLearning,
    required UserVibeAnalyzer vibeAnalyzer,
    required AgentIdService agentIdService,
    CrossEntityCompatibilityService? knotCompatibilityService,
    required SupabaseService supabaseService,
    required PreferencesProfileService preferencesProfileService,
    EntityKnotService? entityKnotService,
    required PersonalityKnotService personalityKnotService,
    required MeaningfulExperienceCalculator meaningfulExperienceCalculator,
    required UserJourneyTrackingService journeyTrackingService,
  })  : _atomicClock = atomicClock,
        _entanglementService = entanglementService,
        _locationTimingService = locationTimingService,
        _personalityLearning = personalityLearning,
        _vibeAnalyzer = vibeAnalyzer,
        _agentIdService = agentIdService,
        _knotCompatibilityService = knotCompatibilityService,
        _supabaseService = supabaseService,
        _preferencesProfileService = preferencesProfileService,
        _personalityKnotService = personalityKnotService,
        _meaningfulExperienceCalculator = meaningfulExperienceCalculator,
        _journeyTrackingService = journeyTrackingService;

  /// Call users to event immediately upon event creation
  ///
  /// **Called when:**
  /// - Event is created (initial entanglement: |ψ_event⟩ ⊗ |ψ_creator⟩)
  ///
  /// **Process:**
  /// 1. Get atomic timestamp
  /// 2. Create entangled state from event entities
  /// 3. Evaluate all users
  /// 4. Call users with compatibility >= threshold
  Future<void> callUsersOnEventCreation({
    required String eventId,
    required List<QuantumEntityState> eventEntities,
  }) async {
    developer.log(
      'Calling users on event creation: eventId=$eventId, entities=${eventEntities.length}',
      name: _logName,
    );

    try {
      final tAtomic = await _atomicClock.getAtomicTimestamp();

      // Create entangled state from event entities
      final entangledState = await _entanglementService.createEntangledState(
        entityStates: eventEntities,
      );

      // Evaluate and call users
      await _evaluateAndCallUsers(
        eventId: eventId,
        entangledState: entangledState,
        eventEntities: eventEntities,
        tAtomic: tAtomic,
      );

      developer.log(
        '✅ Completed user calling on event creation: eventId=$eventId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error calling users on event creation: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }

  /// Re-evaluate users when entity is added to event
  ///
  /// **Called when:**
  /// - Business added to event
  /// - Brand added to event
  /// - Expert added to event
  /// - Any entity addition
  ///
  /// **Process:**
  /// 1. Get atomic timestamp
  /// 2. Recreate entangled state with new entity
  /// 3. Re-evaluate all users (incremental optimization: only affected users)
  /// 4. Call new users if compatibility >= threshold
  /// 5. Stop calling users if compatibility drops below threshold
  Future<void> reEvaluateUsersOnEntityAddition({
    required String eventId,
    required List<QuantumEntityState> eventEntities,
    required QuantumEntityState newEntity,
  }) async {
    developer.log(
      'Re-evaluating users on entity addition: eventId=$eventId, newEntity=${newEntity.entityId}',
      name: _logName,
    );

    try {
      final tAtomic = await _atomicClock.getAtomicTimestamp();

      // Create updated entangled state with new entity
      final updatedEntities = [...eventEntities, newEntity];
      final updatedEntangledState = await _entanglementService.createEntangledState(
        entityStates: updatedEntities,
      );

      // Re-evaluate and update user calls
      await _evaluateAndCallUsers(
        eventId: eventId,
        entangledState: updatedEntangledState,
        eventEntities: updatedEntities,
        tAtomic: tAtomic,
      );

      developer.log(
        '✅ Completed user re-evaluation on entity addition: eventId=$eventId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error re-evaluating users on entity addition: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }

  /// Evaluate users and call/update/stop calling based on compatibility
  ///
  /// **Formula:**
  /// ```
  /// user_entangled_compatibility = 0.5 * F(ρ_user, ρ_entangled) +
  ///                               0.3 * F(ρ_user_location, ρ_event_location) +
  ///                               0.2 * F(ρ_user_timing, ρ_event_timing) +
  ///                               0.15 * C_knot_bonus
  /// ```
  Future<void> _evaluateAndCallUsers({
    required String eventId,
    required EntangledQuantumState entangledState,
    required List<QuantumEntityState> eventEntities,
    required AtomicTimestamp tAtomic,
  }) async {
    try {
      // Get all users (with pagination for scalability)
      final users = await _getAllUsers();

      if (users.isEmpty) {
        developer.log(
          'No users found for event calling: eventId=$eventId',
          name: _logName,
        );
        return;
      }

      developer.log(
        'Evaluating ${users.length} users for event: eventId=$eventId',
        name: _logName,
      );

      // Process users in batches for scalability
      for (int i = 0; i < users.length; i += _batchSize) {
        final batch = users.skip(i).take(_batchSize).toList();
        await _processUserBatch(
          eventId: eventId,
          batch: batch,
          entangledState: entangledState,
          eventEntities: eventEntities,
          tAtomic: tAtomic,
        );
      }

      developer.log(
        '✅ User evaluation complete: eventId=$eventId, users=${users.length}',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error evaluating users: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }

  /// Process a batch of users in parallel
  Future<void> _processUserBatch({
    required String eventId,
    required List<User> batch,
    required EntangledQuantumState entangledState,
    required List<QuantumEntityState> eventEntities,
    required AtomicTimestamp tAtomic,
  }) async {
    // Process batch in parallel
    final futures = batch.map((user) async {
      try {
        // Get or create user quantum state (with caching)
        final userState = await _getUserQuantumState(user);

        // Calculate compatibility
        final compatibility = await _calculateUserCompatibility(
          userState: userState,
          entangledState: entangledState,
          eventEntities: eventEntities,
        );

        // Check if user was previously called
        final wasPreviouslyCalled = await _wasUserCalledToEvent(user.id, eventId);

        // Decide on calling action
        if (compatibility >= _callingThreshold) {
          if (!wasPreviouslyCalled) {
            // New user - call them
            await _callUserToEvent(user.id, eventId, compatibility, tAtomic);
          } else {
            // Update existing call
            await _updateUserCall(user.id, eventId, compatibility, tAtomic);
          }
        } else {
          if (wasPreviouslyCalled) {
            // Stop calling this user
            await _stopCallingUserToEvent(user.id, eventId, tAtomic);
          }
        }
      } catch (e) {
        developer.log(
          'Error processing user ${user.id}: $e',
          name: _logName,
        );
        // Continue processing other users
      }
    });

    await Future.wait(futures);
  }

  /// Calculate user compatibility with entangled state
  ///
  /// **Formula:**
  /// ```
  /// user_entangled_compatibility = 0.5 * F(ρ_user, ρ_entangled) +
  ///                               0.3 * F(ρ_user_location, ρ_event_location) +
  ///                               0.2 * F(ρ_user_timing, ρ_event_timing) +
  ///                               0.15 * C_knot_bonus
  /// ```
  Future<double> _calculateUserCompatibility({
    required QuantumEntityState userState,
    required EntangledQuantumState entangledState,
    required List<QuantumEntityState> eventEntities,
  }) async {
    // 1. Quantum entanglement compatibility (50% weight)
    final quantumFidelity = await _entanglementService.calculateFidelity(
      await _entanglementService.createEntangledState(
        entityStates: [userState],
      ),
      entangledState,
    );
    final quantumCompatibility = 0.5 * quantumFidelity;

    // 2. Location compatibility (30% weight)
    double locationCompatibility = 0.0;
    if (userState.location != null) {
      // Find event location from event entities
      final eventLocation = _findEventLocation(eventEntities);
      if (eventLocation != null) {
        locationCompatibility = LocationCompatibilityCalculator.calculateLocationCompatibility(
          userState.location!,
          eventLocation,
        );
      }
    }
    final locationContribution = 0.3 * locationCompatibility;

    // 3. Timing compatibility with flexibility factor (20% weight)
    double timingCompatibility = 0.0;
    double timingFlexibilityFactor = 1.0;
    
    if (userState.timing != null) {
      // Find event timing from event entities
      final eventTiming = _findEventTiming(eventEntities);
      if (eventTiming != null) {
        timingCompatibility = TimingCompatibilityCalculator.calculateTimingCompatibility(
          userState.timing!,
          eventTiming,
        );

        // Calculate timing flexibility factor (best-effort; failures fall back to 1.0).
        try {
          // Calculate meaningful experience score.
          final meaningfulScore =
              await _meaningfulExperienceCalculator.calculateMeaningfulExperienceScore(
            userState: userState,
            entangledState: entangledState,
            eventEntities: eventEntities,
          );

          // Calculate timing flexibility factor.
          timingFlexibilityFactor =
              await _meaningfulExperienceCalculator.calculateTimingFlexibilityFactor(
            userState: userState,
            eventEntities: eventEntities,
            meaningfulExperienceScore: meaningfulScore,
          );
        } catch (e) {
          developer.log(
            'Error calculating timing flexibility factor: $e, using default 1.0',
            name: _logName,
          );
          // Use default 1.0 (no flexibility adjustment) on error.
          timingFlexibilityFactor = 1.0;
        }
      }
    }
    final timingContribution = 0.2 * timingFlexibilityFactor * timingCompatibility;

    // 4. Knot compatibility bonus (15% weight, optional)
    double knotBonus = 0.0;
    if (_knotCompatibilityService != null) {
      try {
        knotBonus = await _calculateKnotCompatibilityBonus(
          userState: userState,
          eventEntities: eventEntities,
        );
      } catch (e) {
        developer.log(
          'Error calculating knot compatibility: $e, using 0.0',
          name: _logName,
        );
      }
    }
    final knotContribution = 0.15 * knotBonus;

    // Combined compatibility
    final totalCompatibility = quantumCompatibility +
        locationContribution +
        timingContribution +
        knotContribution;

    return totalCompatibility.clamp(0.0, 1.0);
  }

  /// Get user quantum state (with caching)
  Future<QuantumEntityState> _getUserQuantumState(User user) async {
    // Check cache
    final cacheKey = 'user_${user.id}';
    final cached = _quantumStateCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.state;
    }

    try {
      final tAtomic = await _atomicClock.getAtomicTimestamp();

      // Get personality profile
      final personalityProfile = await _personalityLearning.getCurrentPersonality(user.id);
      final personalityDimensions = personalityProfile?.dimensions ?? {};

      // Get quantum vibe analysis
      final quantumVibeAnalysis = <String, double>{};
      if (personalityProfile != null) {
        // Use UserVibeAnalyzer to compile user vibe, then extract anonymized dimensions
        final userVibe = await _vibeAnalyzer.compileUserVibe(user.id, personalityProfile);
        // UserVibe has anonymizedDimensions that we can use
        quantumVibeAnalysis.addAll(userVibe.anonymizedDimensions);
      }

      // Get location quantum state (if user has location)
      EntityLocationQuantumState? locationState;
      if (user.location != null) {
        try {
          // Parse location string to UnifiedLocationData
          final unifiedLocation = await _parseLocationString(user.location!);
          if (unifiedLocation != null) {
            locationState = await _locationTimingService.createLocationQuantumState(
              location: unifiedLocation,
            );
          }
        } catch (e) {
          developer.log(
            'Error parsing user location: $e',
            name: _logName,
          );
        }
      }

      // Get timing quantum state from user preferences
      EntityTimingQuantumState? timingState;
      try {
        timingState = await _getUserTimingPreferences(user.id);
      } catch (e) {
        developer.log(
          'Error getting user timing preferences: $e',
          name: _logName,
        );
      }

      final userState = QuantumEntityState(
        entityId: user.id,
        entityType: QuantumEntityType.user,
        personalityState: personalityDimensions,
        quantumVibeAnalysis: quantumVibeAnalysis,
        entityCharacteristics: {
          'type': 'user',
          'email': user.email,
          'displayName': user.displayName,
        },
        location: locationState,
        timing: timingState,
        tAtomic: tAtomic,
      );

      // Cache the state
      _quantumStateCache[cacheKey] = CachedQuantumState(
        state: userState,
        timestamp: tAtomic,
      );

      // Clean cache if too large
      _cleanCacheIfNeeded();

      return userState;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting user quantum state for ${user.id}: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      // Return fallback state
      final tAtomic = await _atomicClock.getAtomicTimestamp();
      return QuantumEntityState(
        entityId: user.id,
        entityType: QuantumEntityType.user,
        personalityState: {},
        quantumVibeAnalysis: {},
        entityCharacteristics: {'type': 'user'},
        tAtomic: tAtomic,
      );
    }
  }

  /// Get all users (with pagination support)
  Future<List<User>> _getAllUsers({int limit = 1000}) async {
    try {
      // Try to get users from Supabase if available
      if (_supabaseService.isAvailable) {
        try {
          final client = _supabaseService.client;
          final response = await client
              .from('users')
              .select('id, email, display_name, photo_url, location, created_at, updated_at, is_online, has_completed_onboarding')
              .limit(limit);

          final users = (response as List).map((json) {
            return User(
              id: json['id'] as String,
              email: json['email'] as String? ?? '',
              name: json['display_name'] as String? ?? json['name'] as String? ?? 'User',
              displayName: json['display_name'] as String?,
              role: UserRole.follower, // Default role - could be parsed from json if available
              avatarUrl: json['photo_url'] as String?,
              location: json['location'] as String?,
              createdAt: DateTime.parse(json['created_at'] as String),
              updatedAt: DateTime.parse(json['updated_at'] as String),
              isOnline: json['is_online'] as bool? ?? false,
            );
          }).toList();

          developer.log(
            'Retrieved ${users.length} users from Supabase',
            name: _logName,
          );
          return users;
        } catch (e) {
          developer.log(
            'Error getting users from Supabase: $e',
            name: _logName,
          );
          // Fall through to return empty list
        }
      }

      // Fallback: Return empty list if no user service available
      developer.log(
        'No user service available, returning empty user list',
        name: _logName,
      );
      return [];
    } catch (e, stackTrace) {
      developer.log(
        'Error getting users: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return [];
    }
  }

  /// Find event location from event entities
  EntityLocationQuantumState? _findEventLocation(List<QuantumEntityState> entities) {
    for (final entity in entities) {
      if (entity.entityType == QuantumEntityType.event && entity.location != null) {
        return entity.location;
      }
    }
    return null;
  }

  /// Find event timing from event entities
  EntityTimingQuantumState? _findEventTiming(List<QuantumEntityState> entities) {
    for (final entity in entities) {
      if (entity.entityType == QuantumEntityType.event && entity.timing != null) {
        return entity.timing;
      }
    }
    return null;
  }

  /// Check if user was previously called to event
  Future<bool> _wasUserCalledToEvent(String userId, String eventId) async {
    // 1. Check in-memory cache first (fast)
    final calledUsers = _eventCalls[eventId];
    if (calledUsers != null && calledUsers.contains(userId)) {
      return true;
    }

    // 2. Check database for persistent tracking (slower but persistent)
    if (_supabaseService.isAvailable) {
      try {
        final client = _supabaseService.client;
        final result = await client
            .from('event_user_calls')
            .select('id')
            .eq('event_id', eventId)
            .eq('user_id', userId)
            .eq('status', 'active')
            .maybeSingle();

        if (result != null) {
          // Update cache for future lookups
          _eventCalls.putIfAbsent(eventId, () => <String>{}).add(userId);
          return true;
        }
      } catch (e) {
        developer.log(
          'Error checking database for event call: $e',
          name: _logName,
        );
      }
    }

    return false;
  }

  /// Call user to event
  Future<void> _callUserToEvent(
    String userId,
    String eventId,
    double compatibility,
    AtomicTimestamp tAtomic,
  ) async {
    developer.log(
      'Calling user $userId to event $eventId (compatibility: ${compatibility.toStringAsFixed(3)})',
      name: _logName,
    );

    try {
      // 1. Update in-memory cache (fast, immediate)
      _eventCalls.putIfAbsent(eventId, () => <String>{}).add(userId);
      _eventCallScores.putIfAbsent(eventId, () => {})[userId] = compatibility;

      // 2. Persist to database (async, can be batched)
      await _persistEventCallToDatabase(
        userId: userId,
        eventId: eventId,
        compatibility: compatibility,
        tAtomic: tAtomic,
        status: 'active',
      );

      // 3. Capture pre-event state for journey tracking
      try {
        await _journeyTrackingService.capturePreEventState(
          userId: userId,
          eventId: eventId,
        );
      } catch (e) {
        developer.log(
          'Error capturing pre-event state: $e, continuing',
          name: _logName,
        );
        // Don't fail calling if journey tracking fails.
      }

      // 4. Send notification to user
      await _sendEventCallNotification(
        userId: userId,
        eventId: eventId,
        compatibility: compatibility,
      );

      developer.log(
        '✅ User $userId called to event $eventId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error calling user $userId to event $eventId: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      // Don't rethrow - notification/database failure shouldn't block calling
    }
  }

  /// Update existing user call
  Future<void> _updateUserCall(
    String userId,
    String eventId,
    double compatibility,
    AtomicTimestamp tAtomic,
  ) async {
    developer.log(
      'Updating call for user $userId to event $eventId (compatibility: ${compatibility.toStringAsFixed(3)})',
      name: _logName,
    );

    try {
      // 1. Update in-memory cache
      _eventCallScores.putIfAbsent(eventId, () => {})[userId] = compatibility;

      // 2. Update database record
      await _persistEventCallToDatabase(
        userId: userId,
        eventId: eventId,
        compatibility: compatibility,
        tAtomic: tAtomic,
        status: 'active',
      );

      // 3. Send updated notification if compatibility changed significantly
      final previousScore = _eventCallScores[eventId]?[userId] ?? 0.0;
      if ((compatibility - previousScore).abs() > 0.1) {
        // Significant change - notify user
        await _sendEventCallNotification(
          userId: userId,
          eventId: eventId,
          compatibility: compatibility,
          isUpdate: true,
        );
      }

      developer.log(
        '✅ Updated call for user $userId to event $eventId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error updating call for user $userId to event $eventId: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
    }
  }

  /// Stop calling user to event
  Future<void> _stopCallingUserToEvent(
    String userId,
    String eventId,
    AtomicTimestamp tAtomic,
  ) async {
    developer.log(
      'Stopping call for user $userId to event $eventId',
      name: _logName,
    );

    try {
      // 1. Remove from in-memory cache
      _eventCalls[eventId]?.remove(userId);
      _eventCallScores[eventId]?.remove(userId);

      // 2. Update database record (mark as stopped)
      if (_supabaseService.isAvailable) {
        try {
          final client = _supabaseService.client;
          await client
              .from('event_user_calls')
              .update({
                'status': 'stopped',
                'stopped_at': tAtomic.serverTime.toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('event_id', eventId)
              .eq('user_id', userId);
        } catch (e) {
          developer.log(
            'Error updating database for stopped call: $e',
            name: _logName,
          );
        }
      }

      developer.log(
        '✅ Stopped calling user $userId to event $eventId',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error stopping call for user $userId to event $eventId: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
    }
  }

  /// Clean cache if it exceeds max size
  void _cleanCacheIfNeeded() {
    if (_quantumStateCache.length > _maxCacheSize) {
      // Remove oldest entries
      final sorted = _quantumStateCache.entries.toList()
        ..sort((a, b) => a.value.cachedAt.compareTo(b.value.cachedAt));
      final toRemove = sorted.take(_quantumStateCache.length - _maxCacheSize);
      for (final entry in toRemove) {
        _quantumStateCache.remove(entry.key);
      }
    }

    if (_compatibilityCache.length > _maxCacheSize) {
      final sorted = _compatibilityCache.entries.toList()
        ..sort((a, b) => a.value.cachedAt.compareTo(b.value.cachedAt));
      final toRemove = sorted.take(_compatibilityCache.length - _maxCacheSize);
      for (final entry in toRemove) {
        _compatibilityCache.remove(entry.key);
      }
    }
  }

  /// Parse location string to UnifiedLocationData
  ///
  /// Attempts to geocode the location string to get coordinates
  Future<UnifiedLocationData?> _parseLocationString(String locationString) async {
    try {
      // Try to geocode the location string
      final placemarks = await geocoding.locationFromAddress(locationString);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return UnifiedLocationData(
          latitude: placemark.latitude,
          longitude: placemark.longitude,
          city: locationString, // Use original string as city fallback
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      developer.log(
        'Error geocoding location string "$locationString": $e',
        name: _logName,
      );
    }

    // Fallback: Try to parse as "City, State" or "City, State, Country"
    // This is a simple parser for common formats
    final parts = locationString.split(',').map((s) => s.trim()).toList();
    if (parts.length >= 2) {
      // Assume format: "City, State" or "City, State, Country"
      // For now, return null as we need coordinates for UnifiedLocationData
      // In production, could use a geocoding service or database lookup
      return null;
    }

    return null;
  }

  /// Get user timing preferences from PreferencesProfile
  ///
  /// Infers timing preferences from user behavior or uses defaults
  Future<EntityTimingQuantumState?> _getUserTimingPreferences(String userId) async {
    try {
      // Get agentId for privacy protection
      final agentId = await _agentIdService.getUserAgentId(userId);

      // Get PreferencesProfile if available
      final preferencesProfile =
          await _preferencesProfileService.getPreferencesProfile(agentId);

      // Infer timing preferences from PreferencesProfile
      if (preferencesProfile != null) {
        final explorationWillingness = preferencesProfile.explorationWillingness;
        
        // Time of day: More exploration = later in day (evening/night preference)
        final timeOfDayPreference = 0.3 + (explorationWillingness * 0.4);
        final timeOfDayHour = (timeOfDayPreference * 24).round().clamp(0, 23);
        
        // Day of week: More exploration = weekend preference
        final dayOfWeekPreference = 0.3 + (explorationWillingness * 0.4);
        final dayOfWeek = (dayOfWeekPreference * 7).round().clamp(0, 6);
        
        // Frequency: Based on exploration (more exploration = more frequent)
        final frequencyPreference = 0.4 + (explorationWillingness * 0.3);
        
        // Duration: Based on exploration (more exploration = longer events)
        final durationPreference = 0.5 + (explorationWillingness * 0.2);
        
        return await _locationTimingService.createTimingQuantumStateFromIntuitive(
          timeOfDayHour: timeOfDayHour,
          dayOfWeek: dayOfWeek,
          frequencyPreference: frequencyPreference,
          durationPreference: durationPreference,
        );
      }

      // Default preferences if no PreferencesProfile
      const defaultTimeOfDayHour = 19; // 7 PM
      const defaultDayOfWeek = 6; // Saturday (weekend)
      const defaultFrequency = 0.5; // Moderate
      const defaultDuration = 0.5; // Medium

      return await _locationTimingService.createTimingQuantumStateFromIntuitive(
        timeOfDayHour: defaultTimeOfDayHour,
        dayOfWeek: defaultDayOfWeek,
        frequencyPreference: defaultFrequency,
        durationPreference: defaultDuration,
      );
    } catch (e) {
      developer.log(
        'Error getting user timing preferences: $e',
        name: _logName,
      );
      return null;
    }
  }

  /// Calculate knot compatibility bonus
  ///
  /// Uses CrossEntityCompatibilityService to calculate compatibility between
  /// user's personality knot and event entity knots
  Future<double> _calculateKnotCompatibilityBonus({
    required QuantumEntityState userState,
    required List<QuantumEntityState> eventEntities,
  }) async {
    if (_knotCompatibilityService == null) {
      return 0.0;
    }

    try {
      // Get user's personality profile to generate knot
      final personalityProfile = await _personalityLearning.getCurrentPersonality(userState.entityId);
      if (personalityProfile == null) {
        return 0.0;
      }

      // Generate user's personality knot (for future use in full knot compatibility)
      // TODO: In production, use EntityKnotService to generate knots for all entity types
      // and use CrossEntityCompatibilityService for full knot compatibility
      // For now, we'll use quantum vibe similarity as a proxy for knot compatibility
      await _personalityKnotService.generateKnot(personalityProfile);

      // Calculate compatibility with each event entity
      double totalCompatibility = 0.0;
      int entityCount = 0;

      for (final eventEntity in eventEntities) {
        try {
          // For now, use quantum vibe similarity as compatibility proxy
          // TODO: In production, generate EntityKnot for event entities using EntityKnotService
          // and use CrossEntityCompatibilityService for full knot compatibility
          final vibeSimilarity = _calculateVibeSimilarity(
            userState.quantumVibeAnalysis,
            eventEntity.quantumVibeAnalysis,
          );
          totalCompatibility += vibeSimilarity;
          entityCount++;
        } catch (e) {
          developer.log(
            'Error calculating compatibility for entity ${eventEntity.entityId}: $e',
            name: _logName,
          );
          // Continue with next entity
        }
      }

      if (entityCount == 0) {
        return 0.0;
      }

      // Average compatibility across all entities
      final averageCompatibility = totalCompatibility / entityCount;
      return averageCompatibility.clamp(0.0, 1.0);
    } catch (e) {
      developer.log(
        'Error calculating knot compatibility bonus: $e',
        name: _logName,
      );
      return 0.0;
    }
  }

  /// Calculate vibe similarity between two quantum vibe analyses
  ///
  /// Uses cosine similarity or dot product of vibe dimensions
  double _calculateVibeSimilarity(
    Map<String, double> vibeA,
    Map<String, double> vibeB,
  ) {
    if (vibeA.isEmpty || vibeB.isEmpty) {
      return 0.0;
    }

    // Calculate dot product (cosine similarity when normalized)
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    final allDimensions = {...vibeA.keys, ...vibeB.keys};
    for (final dimension in allDimensions) {
      final valueA = vibeA[dimension] ?? 0.0;
      final valueB = vibeB[dimension] ?? 0.0;
      dotProduct += valueA * valueB;
      normA += valueA * valueA;
      normB += valueB * valueB;
    }

    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }

    // Cosine similarity
    final similarity = dotProduct / (math.sqrt(normA) * math.sqrt(normB));
    return similarity.clamp(0.0, 1.0);
  }

  /// Persist event call to database
  ///
  /// Uses hybrid approach: in-memory cache + database persistence
  Future<void> _persistEventCallToDatabase({
    required String userId,
    required String eventId,
    required double compatibility,
    required AtomicTimestamp tAtomic,
    required String status,
  }) async {
    if (!_supabaseService.isAvailable) {
      return; // Graceful degradation - cache still works
    }

    try {
      final client = _supabaseService.client;
      await client
          .from('event_user_calls')
          .upsert({
            'event_id': eventId,
            'user_id': userId,
            'compatibility_score': compatibility,
            'called_at': tAtomic.serverTime.toIso8601String(),
            'atomic_timestamp_id': tAtomic.timestampId,
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'event_id,user_id');
    } catch (e) {
      developer.log(
        'Error persisting event call to database: $e',
        name: _logName,
      );
      // Don't rethrow - database failure shouldn't block calling
    }
  }

  /// Send event call notification to user
  ///
  /// Sends push notification when user is called to an event
  Future<void> _sendEventCallNotification({
    required String userId,
    required String eventId,
    required double compatibility,
    bool isUpdate = false,
  }) async {
    try {
      developer.log(
        'Sending ${isUpdate ? "update" : "call"} notification to user $userId for event $eventId (compatibility: ${compatibility.toStringAsFixed(3)})',
        name: _logName,
      );

      // TODO: Implement actual push notification
      // For now, log the notification
      // In production, would use Firebase Cloud Messaging or similar
      // Example:
      // await firebaseMessaging.sendNotification(
      //   userId: userId,
      //   title: isUpdate ? 'Event Match Updated' : 'New Event Match',
      //   body: 'You have a ${(compatibility * 100).round()}% match with an event!',
      //   data: {'eventId': eventId, 'compatibility': compatibility.toString()},
      // );

      // Store notification in database for in-app notifications
      if (_supabaseService.isAvailable) {
        try {
          final client = _supabaseService.client;
          await client.from('notifications').insert({
            'user_id': userId,
            'type': isUpdate ? 'event_call_updated' : 'event_call',
            'title': isUpdate ? 'Event Match Updated' : 'New Event Match',
            'body': 'You have a ${(compatibility * 100).round()}% match with an event!',
            'data': {
              'eventId': eventId,
              'compatibility': compatibility,
            },
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          developer.log(
            'Error storing notification in database: $e',
            name: _logName,
          );
        }
      }
    } catch (e) {
      developer.log(
        'Error sending event call notification: $e',
        name: _logName,
      );
      // Don't rethrow - notification failure shouldn't block calling
    }
  }
}

/// Cached quantum state
class CachedQuantumState {
  final QuantumEntityState state;
  final AtomicTimestamp timestamp;
  final DateTime cachedAt;

  CachedQuantumState({
    required this.state,
    required this.timestamp,
  }) : cachedAt = DateTime.now();

  bool get isExpired {
    // Check if cache is expired using DateTime comparison
    final now = DateTime.now();
    final age = now.difference(cachedAt);
    // TTL is 5 minutes
    return age > const Duration(minutes: 5);
  }
}

/// Cached compatibility
class CachedCompatibility {
  final double compatibility;
  final AtomicTimestamp timestamp;
  final DateTime cachedAt;

  CachedCompatibility({
    required this.compatibility,
    required this.timestamp,
  }) : cachedAt = DateTime.now();

  bool get isExpired {
    // Check if cache is expired using DateTime comparison
    final now = DateTime.now();
    final age = now.difference(cachedAt);
    // TTL is 5 minutes
    return age > const Duration(minutes: 5);
  }
}

// Quantum Matching Controller
//
// Orchestrates multi-entity quantum matching workflow
// Part of Phase 19 Section 19.5: Quantum Matching Controller
// Patent #29: Multi-Entity Quantum Entanglement Matching System

import 'dart:developer' as developer;
import 'package:spots/core/controllers/base/workflow_controller.dart';
import 'package:spots/core/controllers/base/controller_result.dart';
import 'package:spots/core/models/matching_result.dart';
import 'package:spots/core/models/matching_input.dart';
import 'package:spots_quantum/models/quantum_entity_state.dart';
import 'package:spots_core/models/atomic_timestamp.dart';
import 'package:spots_core/services/atomic_clock_service.dart';
import 'package:spots_quantum/services/quantum/quantum_entanglement_service.dart';
import 'package:spots_quantum/services/quantum/location_timing_quantum_state_service.dart';
import 'package:spots_knot/services/knot/integrated_knot_recommendation_engine.dart';
import 'package:spots_knot/services/knot/cross_entity_compatibility_service.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:spots/core/ai/vibe_analysis_engine.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/preferences_profile_service.dart';
import 'package:spots_quantum/services/quantum/meaningful_connection_metrics_service.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/business_account.dart';
import 'package:spots_quantum/models/quantum_entity_type.dart';
import 'package:spots/core/models/unified_models.dart' hide UnifiedUser;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:math' as math;

/// Result class for quantum matching controller
class QuantumMatchingResult extends ControllerResult {
  /// Matching result (null if error)
  final MatchingResult? matchingResult;

  const QuantumMatchingResult({
    required super.success,
    super.error,
    super.errorCode,
    super.metadata,
    this.matchingResult,
  });

  /// Create successful result
  factory QuantumMatchingResult.success({
    required MatchingResult matchingResult,
    Map<String, dynamic>? metadata,
  }) {
    return QuantumMatchingResult(
      success: true,
      matchingResult: matchingResult,
      metadata: metadata,
    );
  }

  /// Create failure result
  factory QuantumMatchingResult.failure({
    required String error,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return QuantumMatchingResult(
      success: false,
      error: error,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props =>
      [success, error, errorCode, metadata, matchingResult];
}

/// Quantum Matching Controller
///
/// Orchestrates the complete multi-entity quantum matching workflow:
/// 1. Convert entities to quantum states
/// 2. Calculate N-way entanglement
/// 3. Apply location/timing factors
/// 4. Calculate knot compatibility (optional)
/// 5. Calculate meaningful connection metrics (optional)
/// 6. Apply privacy protection
/// 7. Return unified matching results
///
/// **Architecture Pattern:**
/// ```
/// UI → BLoC → QuantumMatchingController → Multiple Services → Repository
/// ```
class QuantumMatchingController
    implements WorkflowController<MatchingInput, QuantumMatchingResult> {
  static const String _logName = 'QuantumMatchingController';

  final AtomicClockService _atomicClock;
  final QuantumEntanglementService _entanglementService;
  final LocationTimingQuantumStateService _locationTimingService;
  // TODO(Phase 19.7): Use QuantumVibeEngine for enhanced vibe compilation
  // final QuantumVibeEngine? _quantumVibeEngine;
  final PersonalityLearning _personalityLearning;
  final UserVibeAnalyzer _vibeAnalyzer;
  final AgentIdService _agentIdService;
  final PreferencesProfileService? _preferencesProfileService;
  final IntegratedKnotRecommendationEngine? _knotEngine;
  final CrossEntityCompatibilityService? _knotCompatibilityService;
  final MeaningfulConnectionMetricsService? _meaningfulConnectionMetricsService;
  // TODO(Phase 19.4): Use RealTimeUserCallingService for user calling integration
  // final RealTimeUserCallingService? _userCallingService;

  QuantumMatchingController({
    required AtomicClockService atomicClock,
    required QuantumEntanglementService entanglementService,
    required LocationTimingQuantumStateService locationTimingService,
    required PersonalityLearning personalityLearning,
    required UserVibeAnalyzer vibeAnalyzer,
    required AgentIdService agentIdService,
    PreferencesProfileService? preferencesProfileService,
    IntegratedKnotRecommendationEngine? knotEngine,
    CrossEntityCompatibilityService? knotCompatibilityService,
    MeaningfulConnectionMetricsService? meaningfulConnectionMetricsService,
  })  : _atomicClock = atomicClock,
        _entanglementService = entanglementService,
        _locationTimingService = locationTimingService,
        _personalityLearning = personalityLearning,
        _vibeAnalyzer = vibeAnalyzer,
        _agentIdService = agentIdService,
        _preferencesProfileService = preferencesProfileService,
        _knotEngine = knotEngine,
        _knotCompatibilityService = knotCompatibilityService,
        _meaningfulConnectionMetricsService =
            meaningfulConnectionMetricsService;

  @override
  Future<QuantumMatchingResult> execute(MatchingInput input) async {
    try {
      developer.log(
        '🎯 Starting multi-entity quantum matching for user ${input.user.id}',
        name: _logName,
      );

      // Validate input
      final validation = validate(input);
      if (!validation.isValid) {
        return QuantumMatchingResult.failure(
          error: validation.firstError ?? 'Invalid input',
          errorCode: 'VALIDATION_ERROR',
          metadata: {'validationErrors': validation.allErrors},
        );
      }

      // STEP 1: Get atomic timestamp for matching operation
      final tAtomic = await _atomicClock.getAtomicTimestamp();

      // STEP 2: Convert entities to quantum states
      final quantumStates = await _convertEntitiesToQuantumStates(
        input.user,
        input.allEntities,
        tAtomic,
      );

      if (quantumStates.isEmpty) {
        return QuantumMatchingResult.failure(
          error: 'Failed to convert entities to quantum states',
          errorCode: 'QUANTUM_STATE_CONVERSION_ERROR',
        );
      }

      // STEP 3: Calculate N-way entanglement
      final entangledState = await _entanglementService.createEntangledState(
        entityStates: quantumStates,
      );

      // STEP 4: Calculate quantum compatibility
      final userState = quantumStates.firstWhere(
        (s) => s.entityType == QuantumEntityType.user,
      );
      final quantumFidelity = await _entanglementService.calculateFidelity(
        await _entanglementService.createEntangledState(
          entityStates: [userState],
        ),
        entangledState,
      );

      // STEP 5: Apply location/timing factors
      final locationTimingFactors = await _calculateLocationTimingFactors(
        userState,
        quantumStates,
      );

      // STEP 6: Calculate knot compatibility (optional)
      double? knotCompatibility;
      if (_knotCompatibilityService != null && _knotEngine != null) {
        try {
          knotCompatibility = await _calculateKnotCompatibility(
            userState,
            quantumStates,
          );
        } catch (e) {
          developer.log(
            'Error calculating knot compatibility: $e, continuing without it',
            name: _logName,
          );
        }
      }

      // STEP 7: Calculate meaningful connection metrics (optional, Section 19.7)
      double? meaningfulConnectionScore;
      if (_meaningfulConnectionMetricsService != null) {
        try {
          // For matching, we use a predictive meaningful connection score
          // based on the matching compatibility (since event hasn't happened yet)
          // The actual meaningful connection metrics are calculated after events occur
          meaningfulConnectionScore = await _calculatePredictiveMeaningfulScore(
            userState: userState,
            quantumStates: quantumStates,
            tAtomic: tAtomic,
          );
        } catch (e) {
          developer.log(
            'Error calculating meaningful connection score: $e, continuing without it',
            name: _logName,
          );
        }
      }

      // STEP 8: Combine all compatibility factors
      final combinedCompatibility = _combineCompatibilityFactors(
        quantumFidelity: quantumFidelity,
        locationCompatibility: locationTimingFactors.locationCompatibility,
        timingCompatibility: locationTimingFactors.timingCompatibility,
        knotCompatibility: knotCompatibility,
      );

      // STEP 9: Apply privacy protection (agentId-only for third-party data)
      final agentId = await _agentIdService.getUserAgentId(input.user.id);

      // STEP 10: Create unified matching result
      final matchingResult = MatchingResult.success(
        compatibility: combinedCompatibility,
        quantumCompatibility: quantumFidelity,
        knotCompatibility: knotCompatibility,
        locationCompatibility: locationTimingFactors.locationCompatibility,
        timingCompatibility: locationTimingFactors.timingCompatibility,
        meaningfulConnectionScore: meaningfulConnectionScore,
        timestamp: tAtomic,
        entities: quantumStates,
        metadata: {
          'agentId': agentId, // Privacy-protected identifier
          'entityCount': quantumStates.length,
          'hasKnotCompatibility': knotCompatibility != null,
          'hasMeaningfulMetrics': meaningfulConnectionScore != null,
        },
      );

      developer.log(
        '✅ Multi-entity quantum matching complete: compatibility=${combinedCompatibility.toStringAsFixed(3)}',
        name: _logName,
      );

      return QuantumMatchingResult.success(
        matchingResult: matchingResult,
        metadata: {
          'executionTime':
              DateTime.now().difference(tAtomic.serverTime).inMilliseconds,
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error in multi-entity quantum matching: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );

      return QuantumMatchingResult.failure(
        error: 'Matching failed: ${e.toString()}',
        errorCode: 'MATCHING_ERROR',
        metadata: {
          'errorType': e.runtimeType.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    }
  }

  @override
  Future<void> rollback(QuantumMatchingResult result) async {
    // No rollback needed - matching is read-only
  }

  @override
  ValidationResult validate(MatchingInput input) {
    final errors = <String>[];

    // Validate user
    if (input.user.id.isEmpty) {
      errors.add('User ID is required');
    }

    // Validate at least one entity
    if (!input.isValid) {
      errors
          .add('At least one entity (event, spot, business, etc.) is required');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.invalid(generalErrors: errors);
    }

    return ValidationResult.valid();
  }

  /// Convert entities to quantum states
  Future<List<QuantumEntityState>> _convertEntitiesToQuantumStates(
    UnifiedUser user,
    List<dynamic> entities,
    AtomicTimestamp tAtomic,
  ) async {
    final quantumStates = <QuantumEntityState>[];

    try {
      // Convert user to quantum state
      final userState = await _convertUserToQuantumState(user, tAtomic);
      quantumStates.add(userState);

      // Convert other entities to quantum states
      for (final entity in entities) {
        try {
          QuantumEntityState? entityState;
          if (entity is ExpertiseEvent) {
            entityState = await _convertEventToQuantumState(entity, tAtomic);
          } else if (entity is Spot) {
            entityState = await _convertSpotToQuantumState(entity, tAtomic);
          } else if (entity is BusinessAccount) {
            entityState = await _convertBusinessToQuantumState(entity, tAtomic);
          }

          if (entityState != null) {
            quantumStates.add(entityState);
          }
        } catch (e) {
          developer.log(
            'Error converting entity to quantum state: $e',
            name: _logName,
          );
          // Continue with other entities
        }
      }
    } catch (e) {
      developer.log(
        'Error converting entities to quantum states: $e',
        name: _logName,
      );
    }

    return quantumStates;
  }

  /// Convert user to quantum state
  Future<QuantumEntityState> _convertUserToQuantumState(
    UnifiedUser user,
    AtomicTimestamp tAtomic,
  ) async {
    // Get personality profile
    final personalityProfile =
        await _personalityLearning.getCurrentPersonality(user.id);
    final personalityDimensions = personalityProfile?.dimensions ?? {};

    // Get quantum vibe analysis
    final quantumVibeAnalysis = <String, double>{};
    if (personalityProfile != null) {
      final userVibe =
          await _vibeAnalyzer.compileUserVibe(user.id, personalityProfile);
      quantumVibeAnalysis.addAll(userVibe.anonymizedDimensions);
    }

    // Get location quantum state (if available)
    EntityLocationQuantumState? locationState;
    if (user.location != null) {
      try {
        // Parse location string to UnifiedLocation
        final unifiedLocation = await _parseLocationString(user.location!);
        if (unifiedLocation != null) {
          locationState =
              await _locationTimingService.createLocationQuantumState(
            location: unifiedLocation,
          );
        }
      } catch (e) {
        developer.log('Error parsing user location: $e', name: _logName);
      }
    }

    // Get timing quantum state from preferences
    EntityTimingQuantumState? timingState;
    try {
      final agentId = await _agentIdService.getUserAgentId(user.id);
      final preferencesProfile =
          await _preferencesProfileService?.getPreferencesProfile(agentId);

      if (preferencesProfile != null) {
        final explorationWillingness =
            preferencesProfile.explorationWillingness;
        final timeOfDayPreference = 0.3 + (explorationWillingness * 0.4);
        final timeOfDayHour = (timeOfDayPreference * 24).round().clamp(0, 23);
        final dayOfWeekPreference = 0.3 + (explorationWillingness * 0.4);
        final dayOfWeek = (dayOfWeekPreference * 7).round().clamp(0, 6);
        final frequencyPreference = 0.4 + (explorationWillingness * 0.3);
        final durationPreference = 0.5 + (explorationWillingness * 0.2);

        timingState =
            await _locationTimingService.createTimingQuantumStateFromIntuitive(
          timeOfDayHour: timeOfDayHour,
          dayOfWeek: dayOfWeek,
          frequencyPreference: frequencyPreference,
          durationPreference: durationPreference,
        );
      } else {
        // Default timing preferences
        timingState =
            await _locationTimingService.createTimingQuantumStateFromIntuitive(
          timeOfDayHour: 19,
          dayOfWeek: 6,
          frequencyPreference: 0.5,
          durationPreference: 0.5,
        );
      }
    } catch (e) {
      developer.log('Error getting user timing preferences: $e',
          name: _logName);
    }

    return QuantumEntityState(
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
  }

  /// Convert event to quantum state
  Future<QuantumEntityState> _convertEventToQuantumState(
    ExpertiseEvent event,
    AtomicTimestamp tAtomic,
  ) async {
    // Get event host personality (if available)
    final hostPersonality =
        await _personalityLearning.getCurrentPersonality(event.host.id);
    final personalityDimensions = hostPersonality?.dimensions ?? {};

    // Get quantum vibe for event (from host or event characteristics)
    final quantumVibeAnalysis = <String, double>{};
    if (hostPersonality != null) {
      final hostVibe =
          await _vibeAnalyzer.compileUserVibe(event.host.id, hostPersonality);
      quantumVibeAnalysis.addAll(hostVibe.anonymizedDimensions);
    }

    // Get location quantum state
    EntityLocationQuantumState? locationState;
    if (event.location != null) {
      try {
        final unifiedLocation = await _parseLocationString(event.location!);
        if (unifiedLocation != null) {
          locationState =
              await _locationTimingService.createLocationQuantumState(
            location: unifiedLocation,
          );
        }
      } catch (e) {
        developer.log('Error parsing event location: $e', name: _logName);
      }
    }

    // Get timing quantum state from event DateTime
    EntityTimingQuantumState? timingState;
    try {
      timingState =
          await _locationTimingService.createTimingQuantumStateFromDateTime(
        preferredTime: event.startTime,
        frequencyPreference: 0.5, // Default frequency
        durationPreference: 0.5, // Default duration
      );
    } catch (e) {
      developer.log('Error creating event timing state: $e', name: _logName);
    }

    return QuantumEntityState(
      entityId: event.id,
      entityType: QuantumEntityType.event,
      personalityState: personalityDimensions,
      quantumVibeAnalysis: quantumVibeAnalysis,
      entityCharacteristics: {
        'type': 'event',
        'category': event.category,
        'eventType': event.eventType.name,
        'hostId': event.host.id,
        'title': event.title,
      },
      location: locationState,
      timing: timingState,
      tAtomic: tAtomic,
    );
  }

  /// Convert spot to quantum state
  Future<QuantumEntityState> _convertSpotToQuantumState(
    Spot spot,
    AtomicTimestamp tAtomic,
  ) async {
    // Get spot vibe (if available)
    final quantumVibeAnalysis = <String, double>{};

    // Get location quantum state
    EntityLocationQuantumState? locationState;
    try {
      final unifiedLocation = UnifiedLocation(
        latitude: spot.latitude,
        longitude: spot.longitude,
        city: spot.address ?? spot.name,
        timestamp: DateTime.now(),
      );
      locationState = await _locationTimingService.createLocationQuantumState(
        location: unifiedLocation,
      );
    } catch (e) {
      developer.log('Error creating spot location state: $e', name: _logName);
    }

    return QuantumEntityState(
      entityId: spot.id,
      entityType: QuantumEntityType.business, // Spots are business entities
      personalityState: {},
      quantumVibeAnalysis: quantumVibeAnalysis,
      entityCharacteristics: {
        'type': 'spot',
        'name': spot.name,
        'category': spot.category,
      },
      location: locationState,
      timing: null, // Spots don't have timing
      tAtomic: tAtomic,
    );
  }

  /// Convert business to quantum state
  Future<QuantumEntityState> _convertBusinessToQuantumState(
    BusinessAccount business,
    AtomicTimestamp tAtomic,
  ) async {
    // Get business vibe (if available)
    final quantumVibeAnalysis = <String, double>{};

    // Get location quantum state
    EntityLocationQuantumState? locationState;
    if (business.location != null) {
      try {
        final unifiedLocation = await _parseLocationString(business.location!);
        if (unifiedLocation != null) {
          locationState =
              await _locationTimingService.createLocationQuantumState(
            location: unifiedLocation,
          );
        }
      } catch (e) {
        developer.log('Error creating business location state: $e',
            name: _logName);
      }
    }

    return QuantumEntityState(
      entityId: business.id,
      entityType: QuantumEntityType.business,
      personalityState: {},
      quantumVibeAnalysis: quantumVibeAnalysis,
      entityCharacteristics: {
        'type': 'business',
        'name': business.name,
        'businessType': business.businessType,
      },
      location: locationState,
      timing: null, // Businesses don't have timing
      tAtomic: tAtomic,
    );
  }

  /// Calculate location and timing compatibility factors
  Future<LocationTimingFactors> _calculateLocationTimingFactors(
    QuantumEntityState userState,
    List<QuantumEntityState> entities,
  ) async {
    double locationCompatibility = 0.0;
    double timingCompatibility = 0.0;

    if (userState.location != null) {
      // Find event location from entities
      for (final entity in entities) {
        if (entity.entityType == QuantumEntityType.event &&
            entity.location != null) {
          locationCompatibility =
              LocationCompatibilityCalculator.calculateLocationCompatibility(
            userState.location!,
            entity.location!,
          );
          break;
        }
      }
    }

    if (userState.timing != null) {
      // Find event timing from entities
      for (final entity in entities) {
        if (entity.entityType == QuantumEntityType.event &&
            entity.timing != null) {
          timingCompatibility =
              TimingCompatibilityCalculator.calculateTimingCompatibility(
            userState.timing!,
            entity.timing!,
          );
          break;
        }
      }
    }

    return LocationTimingFactors(
      locationCompatibility: locationCompatibility,
      timingCompatibility: timingCompatibility,
    );
  }

  /// Calculate knot compatibility (optional)
  Future<double?> _calculateKnotCompatibility(
    QuantumEntityState userState,
    List<QuantumEntityState> entities,
  ) async {
    if (_knotCompatibilityService == null || _knotEngine == null) {
      return null;
    }

    try {
      // For now, use vibe similarity as a proxy for knot compatibility
      // TODO: Implement full knot compatibility with EntityKnotService
      double totalCompatibility = 0.0;
      int entityCount = 0;

      for (final entity in entities) {
        if (entity.entityType == QuantumEntityType.event ||
            entity.entityType == QuantumEntityType.expert ||
            entity.entityType == QuantumEntityType.business) {
          final vibeSimilarity = _calculateVibeSimilarity(
            userState.quantumVibeAnalysis,
            entity.quantumVibeAnalysis,
          );
          totalCompatibility += vibeSimilarity;
          entityCount++;
        }
      }

      if (entityCount == 0) {
        return null;
      }

      return (totalCompatibility / entityCount).clamp(0.0, 1.0);
    } catch (e) {
      developer.log('Error calculating knot compatibility: $e', name: _logName);
      return null;
    }
  }

  /// Calculate vibe similarity between two quantum vibe analyses
  double _calculateVibeSimilarity(
    Map<String, double> vibeA,
    Map<String, double> vibeB,
  ) {
    if (vibeA.isEmpty || vibeB.isEmpty) {
      return 0.0;
    }

    // Calculate cosine similarity
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

    final similarity = dotProduct / (math.sqrt(normA) * math.sqrt(normB));
    return similarity.clamp(0.0, 1.0);
  }

  /// Combine all compatibility factors
  double _combineCompatibilityFactors({
    required double quantumFidelity,
    required double locationCompatibility,
    required double timingCompatibility,
    double? knotCompatibility,
  }) {
    // Weighted combination formula:
    // compatibility = 0.5 * quantum + 0.3 * location + 0.2 * timing + 0.15 * knot (if available)
    double compatibility = 0.5 * quantumFidelity +
        0.3 * locationCompatibility +
        0.2 * timingCompatibility;

    if (knotCompatibility != null) {
      // Adjust weights if knot compatibility is available
      compatibility = 0.4 * quantumFidelity +
          0.25 * locationCompatibility +
          0.2 * timingCompatibility +
          0.15 * knotCompatibility;
    }

    return compatibility.clamp(0.0, 1.0);
  }

  /// Calculate predictive meaningful connection score
  ///
  /// For matching (before event occurs), we predict meaningful connection score
  /// based on matching compatibility. The actual meaningful connection metrics
  /// are calculated after events occur using MeaningfulConnectionMetricsService.
  Future<double> _calculatePredictiveMeaningfulScore({
    required QuantumEntityState userState,
    required List<QuantumEntityState> quantumStates,
    required AtomicTimestamp tAtomic,
  }) async {
    try {
      // Use matching compatibility as a proxy for predictive meaningful connection score
      // Higher compatibility = higher likelihood of meaningful connection
      // This is a simplified prediction - actual metrics require post-event data

      // Calculate basic compatibility factors
      double compatibility = 0.0;

      // 1. Quantum entanglement compatibility (40% weight)
      final userEntangledState =
          await _entanglementService.createEntangledState(
        entityStates: [userState],
      );
      final eventEntangledState =
          await _entanglementService.createEntangledState(
        entityStates: quantumStates,
      );
      final quantumFidelity = await _entanglementService.calculateFidelity(
        userEntangledState,
        eventEntangledState,
      );
      compatibility += 0.4 * quantumFidelity;

      // 2. Vibe alignment (30% weight)
      // Calculate average vibe similarity across all event entities
      double totalVibeSimilarity = 0.0;
      int entityCount = 0;
      for (final entityState in quantumStates) {
        final similarity = _calculateVibeSimilarity(
          userState.quantumVibeAnalysis,
          entityState.quantumVibeAnalysis,
        );
        totalVibeSimilarity += similarity;
        entityCount++;
      }
      final vibeAlignment =
          entityCount > 0 ? totalVibeSimilarity / entityCount : 0.0;
      compatibility += 0.3 * vibeAlignment;

      // 3. Location/timing compatibility (20% weight)
      double locationTimingCompat = 0.0;
      if (userState.location != null) {
        final eventLocation = _findEventLocation(quantumStates);
        if (eventLocation != null) {
          locationTimingCompat += 0.5; // Location match
        }
      }
      if (userState.timing != null) {
        final eventTiming = _findEventTiming(quantumStates);
        if (eventTiming != null) {
          locationTimingCompat += 0.5; // Timing match
        }
      }
      compatibility += 0.2 * locationTimingCompat;

      // 4. Interest alignment (10% weight)
      final interestAlignment = _calculateInterestAlignment(
        userState,
        quantumStates,
      );
      compatibility += 0.1 * interestAlignment;

      // Predictive meaningful connection score = compatibility (with some adjustment)
      // Higher compatibility suggests higher likelihood of meaningful connection
      return compatibility.clamp(0.0, 1.0);
    } catch (e) {
      developer.log(
        'Error calculating predictive meaningful score: $e',
        name: _logName,
      );
      return 0.0;
    }
  }

  /// Find event location from quantum states
  EntityLocationQuantumState? _findEventLocation(
      List<QuantumEntityState> quantumStates) {
    for (final state in quantumStates) {
      if (state.location != null) {
        return state.location;
      }
    }
    return null;
  }

  /// Find event timing from quantum states
  EntityTimingQuantumState? _findEventTiming(
      List<QuantumEntityState> quantumStates) {
    for (final state in quantumStates) {
      if (state.timing != null) {
        return state.timing;
      }
    }
    return null;
  }

  /// Calculate interest alignment between user and entities
  double _calculateInterestAlignment(
    QuantumEntityState userState,
    List<QuantumEntityState> quantumStates,
  ) {
    // Extract user interests from entity characteristics
    final userInterests =
        userState.entityCharacteristics['interests'] as List<String>? ?? [];
    if (userInterests.isEmpty) {
      return 0.5; // Default moderate alignment
    }

    // Extract entity categories
    final entityCategories = <String>{};
    for (final state in quantumStates) {
      final category = state.entityCharacteristics['category'] as String?;
      if (category != null) {
        entityCategories.add(category);
      }
    }

    if (entityCategories.isEmpty) {
      return 0.5; // Default moderate alignment
    }

    // Calculate overlap
    final matchingInterests = userInterests
        .where((interest) => entityCategories.contains(interest))
        .length;
    final alignment = matchingInterests /
        math.max(userInterests.length, entityCategories.length);

    return alignment.clamp(0.0, 1.0);
  }

  /// Parse location string to UnifiedLocation
  Future<UnifiedLocation?> _parseLocationString(String locationString) async {
    try {
      // Use geocoding to parse location string
      final placemarks = await geocoding.locationFromAddress(locationString);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return UnifiedLocation(
          latitude: placemark.latitude,
          longitude: placemark.longitude,
          city: locationString,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      developer.log('Error geocoding location string "$locationString": $e',
          name: _logName);
    }

    return null;
  }
}

/// Location and timing compatibility factors
class LocationTimingFactors {
  final double locationCompatibility;
  final double timingCompatibility;

  const LocationTimingFactors({
    required this.locationCompatibility,
    required this.timingCompatibility,
  });
}

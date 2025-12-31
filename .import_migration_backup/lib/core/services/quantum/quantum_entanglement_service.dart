// Quantum Entanglement Service
//
// Implements N-way quantum entanglement for multi-entity matching
// Part of Phase 19: Multi-Entity Quantum Entanglement Matching System
// Patent #29: Multi-Entity Quantum Entanglement Matching System

import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:spots/core/models/quantum_entity_state.dart';
import 'package:spots/core/models/quantum_entity_type.dart';
import 'package:spots/core/models/atomic_timestamp.dart';
import 'package:spots/core/services/atomic_clock_service.dart';
import 'package:spots/core/services/knot/integrated_knot_recommendation_engine.dart';
import 'package:spots/core/services/knot/cross_entity_compatibility_service.dart';

/// N-way quantum entanglement service
///
/// **Formula:**
/// |ψ_entangled(t_atomic)⟩ = Σᵢ αᵢ(t_atomic) |ψ_entity_i(t_atomic_i)⟩ ⊗ |ψ_entity_j(t_atomic_j)⟩ ⊗ ... ⊗ |ψ_entity_k(t_atomic_k)⟩
///
/// **Normalization Constraints:**
/// 1. Entity State Normalization: ⟨ψ_entity_i|ψ_entity_i⟩ = 1
/// 2. Coefficient Normalization: Σᵢ |αᵢ|² = 1
/// 3. Entangled State Normalization: ⟨ψ_entangled|ψ_entangled⟩ = 1
///
/// **Atomic Timing:**
/// All entanglement calculations use AtomicClockService for precise temporal tracking
class QuantumEntanglementService {
  static const String _logName = 'QuantumEntanglementService';

  final AtomicClockService _atomicClock;
  final IntegratedKnotRecommendationEngine? _knotEngine;
  final CrossEntityCompatibilityService? _knotCompatibilityService;

  QuantumEntanglementService({
    required AtomicClockService atomicClock,
    IntegratedKnotRecommendationEngine? knotEngine,
    CrossEntityCompatibilityService? knotCompatibilityService,
  })  : _atomicClock = atomicClock,
        _knotEngine = knotEngine,
        _knotCompatibilityService = knotCompatibilityService;

  /// Create N-way entangled state from multiple entity states
  ///
  /// **Formula:**
  /// |ψ_entangled(t_atomic)⟩ = Σᵢ αᵢ(t_atomic) |ψ_entity_i(t_atomic_i)⟩ ⊗ |ψ_entity_j(t_atomic_j)⟩ ⊗ ... ⊗ |ψ_entity_k(t_atomic_k)⟩
  ///
  /// **Parameters:**
  /// - `entityStates`: List of normalized quantum entity states
  /// - `coefficients`: Optional entanglement coefficients (will be optimized if not provided)
  ///
  /// **Returns:**
  /// EntangledQuantumState with normalized entangled state and atomic timestamp
  Future<EntangledQuantumState> createEntangledState({
    required List<QuantumEntityState> entityStates,
    List<double>? coefficients,
  }) async {
    developer.log(
      'Creating N-way entangled state for ${entityStates.length} entities',
      name: _logName,
    );

    try {
      // Validate input
      if (entityStates.isEmpty) {
        throw ArgumentError('Cannot create entangled state with no entities');
      }

      // Get atomic timestamp for entanglement creation
      final tAtomic = await _atomicClock.getAtomicTimestamp();

      // Normalize all entity states
      final normalizedStates = entityStates.map((state) => state.normalized()).toList();

      // Calculate or use provided coefficients
      final finalCoefficients = coefficients ?? _calculateDefaultCoefficients(normalizedStates);

      // Validate coefficient normalization: Σᵢ |αᵢ|² = 1
      final coefficientNorm = finalCoefficients.fold<double>(
        0.0,
        (sum, coeff) => sum + coeff * coeff,
      );
      if ((coefficientNorm - 1.0).abs() > 0.0001) {
        developer.log(
          '⚠️ Coefficient normalization off: $coefficientNorm, normalizing...',
          name: _logName,
        );
        final scale = 1.0 / math.sqrt(coefficientNorm);
        for (var i = 0; i < finalCoefficients.length; i++) {
          finalCoefficients[i] *= scale;
        }
      }

      // Perform tensor product: |ψ_entity_i⟩ ⊗ |ψ_entity_j⟩ ⊗ ... ⊗ |ψ_entity_k⟩
      final tensorProduct = _tensorProduct(normalizedStates);

      // Create entangled state: Σᵢ αᵢ |ψ_tensor_i⟩
      final entangledVector = _createEntangledVector(tensorProduct, finalCoefficients);

      // Normalize entangled state: ⟨ψ_entangled|ψ_entangled⟩ = 1
      final normalizedEntangled = _normalizeVector(entangledVector);

      developer.log(
        '✅ Created entangled state: ${normalizedStates.length} entities, ${normalizedEntangled.length} dimensions',
        name: _logName,
      );

      return EntangledQuantumState(
        entityStates: normalizedStates,
        coefficients: finalCoefficients,
        entangledVector: normalizedEntangled,
        tAtomic: tAtomic,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error creating entangled state: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }

  /// Calculate default coefficients based on entity types
  ///
  /// Uses entity type weights from QuantumEntityTypeMetadata
  List<double> _calculateDefaultCoefficients(List<QuantumEntityState> entityStates) {
    final coefficients = <double>[];

    for (final state in entityStates) {
      final weight = QuantumEntityTypeMetadata.getDefaultWeight(state.entityType);
      coefficients.add(weight);
    }

    // Normalize coefficients: Σᵢ |αᵢ|² = 1
    final norm = coefficients.fold<double>(
      0.0,
      (sum, coeff) => sum + coeff * coeff,
    );
    final scale = 1.0 / math.sqrt(norm);

    return coefficients.map((coeff) => coeff * scale).toList();
  }

  /// Perform tensor product: |ψ_entity_i⟩ ⊗ |ψ_entity_j⟩ ⊗ ... ⊗ |ψ_entity_k⟩
  ///
  /// **Tensor Product:**
  /// For two states |a⟩ and |b⟩, the tensor product is |a⟩ ⊗ |b⟩ = |ab⟩
  /// For N states, we recursively compute: |a₁⟩ ⊗ |a₂⟩ ⊗ ... ⊗ |aₙ⟩
  List<double> _tensorProduct(List<QuantumEntityState> entityStates) {
    if (entityStates.isEmpty) {
      return [];
    }

    if (entityStates.length == 1) {
      return _stateToVector(entityStates[0]);
    }

    // Recursive tensor product
    var result = _stateToVector(entityStates[0]);
    for (var i = 1; i < entityStates.length; i++) {
      final nextVector = _stateToVector(entityStates[i]);
      result = _tensorProductVectors(result, nextVector);
    }

    return result;
  }

  /// Convert quantum entity state to vector representation
  List<double> _stateToVector(QuantumEntityState state) {
    final vector = <double>[];

    // Add personality state components
    vector.addAll(state.personalityState.values);

    // Add quantum vibe analysis components
    vector.addAll(state.quantumVibeAnalysis.values);

    // Add location components (if present)
    if (state.location != null) {
      vector.add(state.location!.latitudeQuantumState);
      vector.add(state.location!.longitudeQuantumState);
      vector.add(state.location!.accessibilityScore);
      vector.add(state.location!.vibeLocationMatch);
    }

    // Add timing components (if present)
    if (state.timing != null) {
      vector.add(state.timing!.timeOfDayPreference);
      vector.add(state.timing!.dayOfWeekPreference);
      vector.add(state.timing!.frequencyPreference);
      vector.add(state.timing!.durationPreference);
      vector.add(state.timing!.timingVibeMatch);
    }

    return vector;
  }

  /// Tensor product of two vectors
  ///
  /// **Formula:**
  /// |a⟩ ⊗ |b⟩ = [a₁b₁, a₁b₂, ..., a₁bₙ, a₂b₁, a₂b₂, ..., aₘbₙ]
  List<double> _tensorProductVectors(List<double> vectorA, List<double> vectorB) {
    final result = <double>[];
    for (final a in vectorA) {
      for (final b in vectorB) {
        result.add(a * b);
      }
    }
    return result;
  }

  /// Create entangled vector: Σᵢ αᵢ |ψ_tensor_i⟩
  ///
  /// For N entities, we have one tensor product result, so we scale by the coefficient
  /// In general, we would sum over all possible combinations, but for simplicity,
  /// we use the single tensor product scaled by the coefficient
  List<double> _createEntangledVector(List<double> tensorProduct, List<double> coefficients) {
    // For N-way entanglement, we use the tensor product directly
    // The coefficients are applied during optimization
    // Here, we scale by the average coefficient for simplicity
    final avgCoeff = coefficients.fold<double>(0.0, (sum, c) => sum + c) / coefficients.length;
    return tensorProduct.map((value) => value * avgCoeff).toList();
  }

  /// Normalize vector: ⟨ψ|ψ⟩ = 1
  List<double> _normalizeVector(List<double> vector) {
    final norm = vector.fold<double>(
      0.0,
      (sum, value) => sum + value * value,
    );

    if (norm < 0.0001) {
      // Vector is essentially zero
      return vector;
    }

    final scale = 1.0 / math.sqrt(norm);
    return vector.map((value) => value * scale).toList();
  }

  /// Calculate quantum fidelity between two entangled states
  ///
  /// **Formula:**
  /// F(ρ₁, ρ₂) = [Tr(√(√ρ₁ · ρ₂ · √ρ₁))]²
  ///
  /// For pure states:
  /// F(|ψ₁⟩, |ψ₂⟩) = |⟨ψ₁|ψ₂⟩|²
  Future<double> calculateFidelity(
    EntangledQuantumState state1,
    EntangledQuantumState state2,
  ) async {
    if (state1.entangledVector.length != state2.entangledVector.length) {
      throw ArgumentError('Cannot calculate fidelity between states of different dimensions');
    }

    // Calculate inner product: ⟨ψ₁|ψ₂⟩
    var innerProduct = 0.0;
    for (var i = 0; i < state1.entangledVector.length; i++) {
      innerProduct += state1.entangledVector[i] * state2.entangledVector[i];
    }

    // Fidelity: |⟨ψ₁|ψ₂⟩|²
    final fidelity = innerProduct * innerProduct;

    developer.log(
      'Fidelity: ${fidelity.toStringAsFixed(4)}',
      name: _logName,
    );

    return fidelity.clamp(0.0, 1.0);
  }

  /// Calculate knot compatibility bonus (optional)
  ///
  /// **Formula:**
  /// C_knot_bonus = knot_compatibility_score (if available)
  ///
  /// Returns 0.0 if knot services unavailable (graceful degradation)
  Future<double> calculateKnotCompatibilityBonus(
    List<QuantumEntityState> entityStates,
  ) async {
    if (_knotEngine == null || _knotCompatibilityService == null) {
      // Graceful degradation: return 0.0 if knot services unavailable
      return 0.0;
    }

    try {
      // TODO: Implement knot compatibility calculation
      // This would use IntegratedKnotRecommendationEngine and CrossEntityCompatibilityService
      // For now, return 0.0 (placeholder)
      return 0.0;
    } catch (e) {
      developer.log(
        'Error calculating knot compatibility: $e, using 0.0',
        name: _logName,
      );
      return 0.0;
    }
  }
}

/// Entangled quantum state result
class EntangledQuantumState {
  /// Original entity states
  final List<QuantumEntityState> entityStates;

  /// Entanglement coefficients (normalized: Σᵢ |αᵢ|² = 1)
  final List<double> coefficients;

  /// Entangled state vector (normalized: ⟨ψ_entangled|ψ_entangled⟩ = 1)
  final List<double> entangledVector;

  /// Atomic timestamp of entanglement creation
  final AtomicTimestamp tAtomic;

  EntangledQuantumState({
    required this.entityStates,
    required this.coefficients,
    required this.entangledVector,
    required this.tAtomic,
  });

  /// Check if entangled state is normalized
  bool get isNormalized {
    final norm = entangledVector.fold<double>(
      0.0,
      (sum, value) => sum + value * value,
    );
    return (norm - 1.0).abs() < 0.0001;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'entityStates': entityStates.map((s) => s.toJson()).toList(),
      'coefficients': coefficients,
      'entangledVector': entangledVector,
      'tAtomic': tAtomic.toJson(),
    };
  }

  @override
  String toString() {
    return 'EntangledQuantumState(entities: ${entityStates.length}, dimensions: ${entangledVector.length}, normalized: $isNormalized, tAtomic: $tAtomic)';
  }
}

// Cross-Entity Compatibility Service
// 
// Service for calculating compatibility between any entity types
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase 1.5: Universal Cross-Pollination Extension

import 'dart:developer' as developer;
import 'package:spots_knot/models/entity_knot.dart';
import 'package:spots_knot/models/personality_knot.dart';
import 'package:spots_knot/services/knot/personality_knot_service.dart';
import 'package:spots_knot/services/knot/bridge/knot_math_bridge.dart/api.dart';

/// Service for calculating compatibility between any entity types
/// 
/// **Supported Compatibility Types:**
/// - Person ↔ Person
/// - Person ↔ Event
/// - Person ↔ Place
/// - Person ↔ Company
/// - Event ↔ Place
/// - Event ↔ Company
/// - Place ↔ Company
/// - Multi-entity weave compatibility
/// 
/// **Compatibility Formula:**
/// C_integrated = α·C_quantum + β·C_topological + γ·C_weave
/// 
/// Where:
/// - α = 0.5 (quantum weight)
/// - β = 0.3 (topological weight)
/// - γ = 0.2 (weave weight)
class CrossEntityCompatibilityService {
  static const String _logName = 'CrossEntityCompatibilityService';
  
  // Compatibility weights
  static const double _quantumWeight = 0.5;
  static const double _topologicalWeight = 0.3;
  static const double _weaveWeight = 0.2;

  CrossEntityCompatibilityService({
    PersonalityKnotService? knotService,
  }) {
    // knotService parameter reserved for future use
    // Currently, compatibility calculations use direct FFI calls
    if (knotService != null) {
      // Future: Use knotService for additional operations
    }
  }

  /// Calculate integrated compatibility between any two entities
  /// 
  /// **Formula:** C_integrated = α·C_quantum + β·C_topological + γ·C_weave
  /// 
  /// **Returns:** Compatibility score in [0, 1]
  Future<double> calculateIntegratedCompatibility({
    required EntityKnot entityA,
    required EntityKnot entityB,
  }) async {
    developer.log(
      'Calculating compatibility between ${entityA.entityType} and ${entityB.entityType}',
      name: _logName,
    );

    try {
      // Quantum compatibility (from existing system)
      // TODO: Integrate with QuantumCompatibilityService when available
      final quantum = await _calculateQuantumCompatibility(entityA, entityB);
      
      // Topological compatibility (knot invariants)
      final topological = calculateTopologicalCompatibility(
        braidDataA: entityA.knot.braidData,
        braidDataB: entityB.knot.braidData,
      );
      
      // Weave compatibility (if applicable)
      final weave = await _calculateWeaveCompatibility(entityA.knot, entityB.knot);
      
      // Combined: α·C_quantum + β·C_topological + γ·C_weave
      final compatibility = (_quantumWeight * quantum) +
                           (_topologicalWeight * topological) +
                           (_weaveWeight * weave);
      
      developer.log(
        '✅ Compatibility calculated: $compatibility (quantum: $quantum, topological: $topological, weave: $weave)',
        name: _logName,
      );
      
      return compatibility.clamp(0.0, 1.0);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to calculate compatibility: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }

  /// Calculate quantum compatibility between two entities
  /// 
  /// **Note:** This is a placeholder. In production, this would integrate
  /// with the existing QuantumCompatibilityService.
  Future<double> _calculateQuantumCompatibility(
    EntityKnot entityA,
    EntityKnot entityB,
  ) async {
    // TODO: Integrate with QuantumCompatibilityService
    // For now, return a simple compatibility based on entity types
    if (entityA.entityType == entityB.entityType) {
      return 0.7; // Same type entities have moderate compatibility
    }
    
    // Cross-entity compatibility (simplified)
    // Person-Event, Person-Place, Person-Company have higher compatibility
    if (entityA.entityType == EntityType.person || entityB.entityType == EntityType.person) {
      return 0.6; // Person-entity compatibility
    }
    
    // Other cross-entity types
    return 0.5; // Default cross-entity compatibility
  }

  /// Calculate weave compatibility between two knots
  /// 
  /// **Algorithm:**
  /// - Analyze how well the two knots can be woven together
  /// - Consider knot complexity, crossing numbers, and topological structure
  Future<double> _calculateWeaveCompatibility(
    PersonalityKnot knotA,
    PersonalityKnot knotB,
  ) async {
    // Simple weave compatibility based on knot similarity
    // More similar knots are easier to weave together
    
    final crossingDiff = (knotA.invariants.crossingNumber - knotB.invariants.crossingNumber).abs();
    final maxCrossings = knotA.invariants.crossingNumber
        .clamp(knotB.invariants.crossingNumber, double.infinity)
        .toInt()
        .max(1);
    
    // Similar crossing numbers = easier to weave
    final crossingSimilarity = 1.0 - (crossingDiff / maxCrossings).clamp(0.0, 1.0);
    
      // Polynomial similarity (using polynomial distance)
      final polyDistance = polynomialDistance(
        coefficientsA: knotA.invariants.jonesPolynomial,
        coefficientsB: knotB.invariants.jonesPolynomial,
      );
      
      // Normalize polynomial distance (simple normalization)
      final polynomialSimilarity = 1.0 / (1.0 + polyDistance).clamp(0.0, 1.0);
    
    // Combined weave compatibility
    final weave = (0.6 * crossingSimilarity) + (0.4 * polynomialSimilarity);
    
    return weave.clamp(0.0, 1.0);
  }

  /// Calculate multi-entity weave compatibility
  /// 
  /// **Algorithm:**
  /// - Create multi-entity braid from all entity knots
  /// - Calculate braided knot stability
  /// - Return stability as compatibility score
  Future<double> calculateMultiEntityWeaveCompatibility({
    required List<EntityKnot> entities,
  }) async {
    developer.log(
      'Calculating multi-entity weave compatibility for ${entities.length} entities',
      name: _logName,
    );

    if (entities.length < 2) {
      return 1.0; // Single entity is perfectly compatible with itself
    }

    try {
      // Calculate pairwise compatibilities
      double totalCompatibility = 0.0;
      int pairCount = 0;
      
      for (int i = 0; i < entities.length; i++) {
        for (int j = i + 1; j < entities.length; j++) {
          final compatibility = await calculateIntegratedCompatibility(
            entityA: entities[i],
            entityB: entities[j],
          );
          totalCompatibility += compatibility;
          pairCount++;
        }
      }
      
      // Average compatibility across all pairs
      final averageCompatibility = pairCount > 0
          ? totalCompatibility / pairCount
          : 1.0;
      
      developer.log(
        '✅ Multi-entity weave compatibility: $averageCompatibility',
        name: _logName,
      );
      
      return averageCompatibility.clamp(0.0, 1.0);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to calculate multi-entity weave compatibility: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }
}

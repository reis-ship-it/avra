// Knot Worldsheet Model
// 
// Represents a 2D plane/worldsheet for group evolution
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase: Knot Orchestration & Worldsheet Generation
//
// Mathematical representation: Σ(σ, τ, t) = F(t)
// Where:
// - σ = spatial parameter (position along each individual string/user)
// - τ = group parameter (which user/strand in the fabric)
// - t = time parameter
// - Σ(σ, τ, t) = fabric configuration at time t
// - F(t) = the KnotFabric at time t

import 'package:avrai_core/models/personality_knot.dart';
import 'package:avrai_knot/models/knot/knot_fabric.dart';
import 'package:avrai_knot/models/knot/fabric_snapshot.dart';
import 'package:avrai_knot/services/knot/knot_evolution_string_service.dart';

/// Worldsheet representation of group evolution
/// 
/// Represents continuous evolution of a group fabric: Σ(σ, τ, t) = F(t)
/// This is a 2D surface where:
/// - One dimension (σ) represents individual user evolution (strings)
/// - One dimension (τ) represents group composition (which users)
/// - Time (t) represents temporal evolution
class KnotWorldsheet {
  /// Group identifier
  final String groupId;
  
  /// Initial fabric (at t=0 or earliest snapshot)
  final KnotFabric initialFabric;
  
  /// Evolution snapshots (discrete points in time)
  final List<FabricSnapshot> snapshots;
  
  /// Individual user strings (map from agentId to KnotString)
  /// These represent the σ dimension (individual evolution)
  final Map<String, KnotString> userStrings;
  
  /// Created timestamp
  final DateTime createdAt;
  
  /// Last updated timestamp
  final DateTime lastUpdated;
  
  KnotWorldsheet({
    required this.groupId,
    required this.initialFabric,
    required this.snapshots,
    required this.userStrings,
    required this.createdAt,
    required this.lastUpdated,
  });
  
  /// Get fabric at any time t (interpolated between snapshots)
  /// 
  /// Uses linear interpolation between nearest snapshots
  /// If t is before first snapshot, returns initial fabric
  /// If t is after last snapshot, extrapolates using evolution dynamics
  KnotFabric? getFabricAtTime(DateTime t) {
    if (snapshots.isEmpty) {
      return initialFabric;
    }
    
    // Sort snapshots by timestamp
    final sortedSnapshots = List<FabricSnapshot>.from(snapshots)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Check if before first snapshot
    if (t.isBefore(sortedSnapshots.first.timestamp)) {
      return initialFabric;
    }
    
    // Check if after last snapshot (extrapolate)
    if (t.isAfter(sortedSnapshots.last.timestamp)) {
      // TODO: Implement extrapolation
      return sortedSnapshots.last.fabric;
    }
    
    // Find surrounding snapshots
    FabricSnapshot? before;
    FabricSnapshot? after;
    
    for (int i = 0; i < sortedSnapshots.length; i++) {
      if (sortedSnapshots[i].timestamp.isAfter(t)) {
        after = sortedSnapshots[i];
        if (i > 0) {
          before = sortedSnapshots[i - 1];
        } else {
          before = null;
        }
        break;
      }
    }
    
    // If exactly on a snapshot
    if (before != null && before.timestamp == t) {
      return before.fabric;
    }
    if (after != null && after.timestamp == t) {
      return after.fabric;
    }
    
    // Interpolate between snapshots (TODO: implement interpolation)
    if (before != null && after != null) {
      // For now, return the closer snapshot
      final beforeDiff = t.difference(before.timestamp).abs();
      final afterDiff = t.difference(after.timestamp).abs();
      return beforeDiff < afterDiff ? before.fabric : after.fabric;
    }
    
    return null;
  }
  
  /// Get individual user's string within the worldsheet
  /// 
  /// Returns the KnotString for a specific user (σ dimension)
  KnotString? getUserString(String agentId) {
    return userStrings[agentId];
  }
  
  /// Get cross-section at time t (all users at that moment)
  /// 
  /// Returns list of PersonalityKnots for all users at time t
  /// This is a "slice" through the worldsheet at a specific time
  List<PersonalityKnot> getCrossSectionAtTime(DateTime t) {
    final knots = <PersonalityKnot>[];
    
    for (final entry in userStrings.entries) {
      final knot = entry.value.getKnotAtTime(t);
      if (knot != null) {
        knots.add(knot);
      }
    }
    
    return knots;
  }
  
  /// Get all user IDs in the worldsheet
  List<String> get userIds => userStrings.keys.toList();
  
  /// Get time span of worldsheet
  Duration get timeSpan {
    if (snapshots.isEmpty) {
      return Duration.zero;
    }
    
    final sortedSnapshots = List<FabricSnapshot>.from(snapshots)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return sortedSnapshots.last.timestamp
        .difference(sortedSnapshots.first.timestamp);
  }
  
  /// Create from JSON
  factory KnotWorldsheet.fromJson(Map<String, dynamic> json) {
    return KnotWorldsheet(
      groupId: json['groupId'] ?? '',
      initialFabric: KnotFabric.fromJson(
        json['initialFabric'] as Map<String, dynamic>,
      ),
      snapshots: (json['snapshots'] as List<dynamic>?)
              ?.map((s) => FabricSnapshot.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      userStrings: {}, // TODO: Implement KnotString serialization
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'initialFabric': initialFabric.toJson(),
      'snapshots': snapshots.map((s) => s.toJson()).toList(),
      'userStrings': {}, // TODO: Implement KnotString serialization
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

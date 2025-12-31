// Personality Knot Model
// 
// Represents a personality profile as a topological knot
// Part of Patent #31: Topological Knot Theory for Personality Representation

/// Represents knot invariants (Jones polynomial, Alexander polynomial, etc.)
class KnotInvariants {
  /// Jones polynomial coefficients (lowest degree first)
  final List<double> jonesPolynomial;
  
  /// Alexander polynomial coefficients (lowest degree first)
  final List<double> alexanderPolynomial;
  
  /// Crossing number (minimum crossings in any diagram)
  final int crossingNumber;
  
  /// Writhe (signed sum of crossing signs)
  final int writhe;
  
  KnotInvariants({
    required this.jonesPolynomial,
    required this.alexanderPolynomial,
    required this.crossingNumber,
    required this.writhe,
  });
  
  /// Create from JSON
  factory KnotInvariants.fromJson(Map<String, dynamic> json) {
    return KnotInvariants(
      jonesPolynomial: List<double>.from(json['jonesPolynomial'] ?? []),
      alexanderPolynomial: List<double>.from(json['alexanderPolynomial'] ?? []),
      crossingNumber: json['crossingNumber'] ?? 0,
      writhe: json['writhe'] ?? 0,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'jonesPolynomial': jonesPolynomial,
      'alexanderPolynomial': alexanderPolynomial,
      'crossingNumber': crossingNumber,
      'writhe': writhe,
    };
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnotInvariants &&
          runtimeType == other.runtimeType &&
          jonesPolynomial == other.jonesPolynomial &&
          alexanderPolynomial == other.alexanderPolynomial &&
          crossingNumber == other.crossingNumber &&
          writhe == other.writhe;
  
  @override
  int get hashCode =>
      jonesPolynomial.hashCode ^
      alexanderPolynomial.hashCode ^
      crossingNumber.hashCode ^
      writhe.hashCode;
}

/// Represents physics-based knot properties
class KnotPhysics {
  /// Knot energy: E_K = ∫_K |κ(s)|² ds
  final double energy;
  
  /// Knot stability: -d²E_K/dK²
  final double stability;
  
  /// Knot length
  final double length;
  
  KnotPhysics({
    required this.energy,
    required this.stability,
    required this.length,
  });
  
  /// Create from JSON
  factory KnotPhysics.fromJson(Map<String, dynamic> json) {
    return KnotPhysics(
      energy: (json['energy'] ?? 0.0).toDouble(),
      stability: (json['stability'] ?? 0.0).toDouble(),
      length: (json['length'] ?? 0.0).toDouble(),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'stability': stability,
      'length': length,
    };
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnotPhysics &&
          runtimeType == other.runtimeType &&
          energy == other.energy &&
          stability == other.stability &&
          length == other.length;
  
  @override
  int get hashCode => energy.hashCode ^ stability.hashCode ^ length.hashCode;
}

/// Represents a personality knot
class PersonalityKnot {
  /// Associated agent ID (matches PersonalityProfile.agentId)
  final String agentId;
  
  /// Knot invariants (topological properties)
  final KnotInvariants invariants;
  
  /// Physics-based properties
  final KnotPhysics? physics;
  
  /// Braid data used to generate knot
  /// Format: [strands, crossing1_strand, crossing1_over, ...]
  final List<double> braidData;
  
  /// Timestamp when knot was generated
  final DateTime createdAt;
  
  /// Timestamp when knot was last updated
  final DateTime lastUpdated;
  
  PersonalityKnot({
    required this.agentId,
    required this.invariants,
    this.physics,
    required this.braidData,
    required this.createdAt,
    required this.lastUpdated,
  });
  
  /// Create from JSON
  factory PersonalityKnot.fromJson(Map<String, dynamic> json) {
    return PersonalityKnot(
      agentId: json['agentId'] ?? '',
      invariants: KnotInvariants.fromJson(json['invariants'] as Map<String, dynamic>? ?? {}),
      physics: json['physics'] != null
          ? KnotPhysics.fromJson(json['physics'] as Map<String, dynamic>)
          : null,
      braidData: List<double>.from(json['braidData'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'invariants': invariants.toJson(),
      'physics': physics?.toJson(),
      'braidData': braidData,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  /// Create copy with updated fields
  PersonalityKnot copyWith({
    String? agentId,
    KnotInvariants? invariants,
    KnotPhysics? physics,
    List<double>? braidData,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return PersonalityKnot(
      agentId: agentId ?? this.agentId,
      invariants: invariants ?? this.invariants,
      physics: physics ?? this.physics,
      braidData: braidData ?? this.braidData,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  @override
  String toString() {
    return 'PersonalityKnot(agentId: ${agentId.substring(0, 10)}..., '
        'crossings: ${invariants.crossingNumber}, writhe: ${invariants.writhe})';
  }
}

/// Represents a snapshot of knot at a point in time (for evolution tracking)
class KnotSnapshot {
  /// Timestamp of snapshot
  final DateTime timestamp;
  
  /// Knot at this time
  final PersonalityKnot knot;
  
  /// Reason for snapshot (milestone, evolution, etc.)
  final String? reason;
  
  KnotSnapshot({
    required this.timestamp,
    required this.knot,
    this.reason,
  });
  
  /// Create from JSON
  factory KnotSnapshot.fromJson(Map<String, dynamic> json) {
    return KnotSnapshot(
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      knot: PersonalityKnot.fromJson(json['knot'] ?? {}),
      reason: json['reason'],
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'knot': knot.toJson(),
      'reason': reason,
    };
  }
}

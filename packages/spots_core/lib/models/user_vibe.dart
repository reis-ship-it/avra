import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_vibe.g.dart';

/// OUR_GUTS.md: "Anonymous vibe signatures that preserve privacy while enabling AI2AI connections"
/// Represents an anonymized user vibe that can be safely shared for AI2AI personality matching
@JsonSerializable()
class UserVibe extends Equatable {
  final String hashedSignature;
  final Map<String, double> anonymizedDimensions;
  final double overallEnergy;
  final double socialPreference;
  final double explorationTendency;
  final DateTime createdAt;
  final DateTime expiresAt;
  final double privacyLevel;
  final String temporalContext;
  
  const UserVibe({
    required this.hashedSignature,
    required this.anonymizedDimensions,
    required this.overallEnergy,
    required this.socialPreference,
    required this.explorationTendency,
    required this.createdAt,
    required this.expiresAt,
    required this.privacyLevel,
    required this.temporalContext,
  });
  
  /// Create anonymized vibe signature from personality profile
  factory UserVibe.fromPersonalityProfile(
    String userId,
    Map<String, double> personalityDimensions, {
    String? contextualSalt,
  }) {
    final now = DateTime.now();
    
    // Generate contextual salt if not provided
    final salt = contextualSalt ?? _generateTemporalSalt(now);
    
    // Create anonymized hash signature
    final hashedSignature = _createAnonymizedHash(userId, personalityDimensions, salt);
    
    // Anonymize personality dimensions
    final anonymizedDimensions = _anonymizeDimensions(personalityDimensions);
    
    // Calculate derived metrics
    final overallEnergy = _calculateOverallEnergy(personalityDimensions);
    final socialPreference = _calculateSocialPreference(personalityDimensions);
    final explorationTendency = _calculateExplorationTendency(personalityDimensions);
    
    return UserVibe(
      hashedSignature: hashedSignature,
      anonymizedDimensions: anonymizedDimensions,
      overallEnergy: overallEnergy,
      socialPreference: socialPreference,
      explorationTendency: explorationTendency,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)), // Vibe expires after 24 hours
      privacyLevel: 0.8, // High privacy by default
      temporalContext: _generateTemporalContext(now),
    );
  }
  
  /// Check if vibe is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);
  
  /// Check if vibe is expired
  bool get isExpired => !isValid;
  
  /// Calculate compatibility with another vibe (0.0 to 1.0)
  double compatibilityWith(UserVibe other) {
    if (!isValid || !other.isValid) return 0.0;
    
    // Compare anonymized dimensions
    double dimensionCompatibility = _compareDimensions(
      anonymizedDimensions, 
      other.anonymizedDimensions,
    );
    
    // Compare energy levels
    double energyCompatibility = 1.0 - (overallEnergy - other.overallEnergy).abs();
    
    // Compare social preferences
    double socialCompatibility = 1.0 - (socialPreference - other.socialPreference).abs();
    
    // Compare exploration tendencies
    double explorationCompatibility = 1.0 - (explorationTendency - other.explorationTendency).abs();
    
    // Weighted average
    return (dimensionCompatibility * 0.4) + 
           (energyCompatibility * 0.2) + 
           (socialCompatibility * 0.2) + 
           (explorationCompatibility * 0.2);
  }
  
  /// Generate refreshed vibe (to maintain privacy over time)
  UserVibe refresh(String userId, Map<String, double> personalityDimensions) {
    return UserVibe.fromPersonalityProfile(userId, personalityDimensions);
  }
  
  // Private helper methods
  static String _generateTemporalSalt(DateTime timestamp) {
    // Generate salt based on hour of day for temporal anonymity
    final hour = timestamp.hour;
    return 'temporal_${hour}_salt';
  }
  
  static String _createAnonymizedHash(
    String userId, 
    Map<String, double> dimensions, 
    String salt,
  ) {
    // Simplified hash - in real implementation would use crypto package
    final combined = '$userId$dimensions$salt';
    return combined.hashCode.toString();
  }
  
  static Map<String, double> _anonymizeDimensions(Map<String, double> original) {
    // Add noise and normalize to preserve privacy
    final anonymized = <String, double>{};
    for (final entry in original.entries) {
      // Add small amount of noise while preserving general pattern
      final noise = (0.5 - (entry.key.hashCode % 100) / 100.0) * 0.1;
      anonymized[entry.key] = (entry.value + noise).clamp(0.0, 1.0);
    }
    return anonymized;
  }
  
  static double _calculateOverallEnergy(Map<String, double> dimensions) {
    final energyFactors = ['extroversion', 'openness', 'excitement'];
    double total = 0.0;
    int count = 0;
    
    for (final factor in energyFactors) {
      if (dimensions.containsKey(factor)) {
        total += dimensions[factor]!;
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.5;
  }
  
  static double _calculateSocialPreference(Map<String, double> dimensions) {
    final socialFactors = ['extroversion', 'agreeableness'];
    double total = 0.0;
    int count = 0;
    
    for (final factor in socialFactors) {
      if (dimensions.containsKey(factor)) {
        total += dimensions[factor]!;
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.5;
  }
  
  static double _calculateExplorationTendency(Map<String, double> dimensions) {
    final explorationFactors = ['openness', 'curiosity', 'adventure'];
    double total = 0.0;
    int count = 0;
    
    for (final factor in explorationFactors) {
      if (dimensions.containsKey(factor)) {
        total += dimensions[factor]!;
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.5;
  }
  
  static double _compareDimensions(
    Map<String, double> dims1, 
    Map<String, double> dims2,
  ) {
    final commonKeys = dims1.keys.toSet().intersection(dims2.keys.toSet());
    if (commonKeys.isEmpty) return 0.0;
    
    double totalSimilarity = 0.0;
    for (final key in commonKeys) {
      final similarity = 1.0 - (dims1[key]! - dims2[key]!).abs();
      totalSimilarity += similarity;
    }
    
    return totalSimilarity / commonKeys.length;
  }
  
  static String _generateTemporalContext(DateTime timestamp) {
    final hour = timestamp.hour;
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
  
  factory UserVibe.fromJson(Map<String, dynamic> json) => _$UserVibeFromJson(json);
  Map<String, dynamic> toJson() => _$UserVibeToJson(this);
  
  @override
  List<Object?> get props => [
    hashedSignature,
    anonymizedDimensions,
    overallEnergy,
    socialPreference,
    explorationTendency,
    createdAt,
    expiresAt,
    privacyLevel,
    temporalContext,
  ];
}

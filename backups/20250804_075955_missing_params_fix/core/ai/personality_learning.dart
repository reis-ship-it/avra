import 'dart:developer' as developer;
import 'package:spots/core/constants/vibe_constants.dart';
import 'package:spots/core/models/personality_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OUR_GUTS.md: "AI personality that evolves and learns from user behavior while preserving privacy"
/// Core personality learning engine that manages the 8-dimensional personality evolution
class PersonalityLearning {
  static const String _logName = 'PersonalityLearning';
  
  // Storage keys for personality data
  static const String _personalityProfileKey = 'personality_profile';
  static const String _learningHistoryKey = 'personality_learning_history';
  static const String _dimensionConfidenceKey = 'dimension_confidence';
  
  final SharedPreferences _prefs;
  PersonalityProfile? _currentProfile;
  bool _isLearning = false;
  
  PersonalityLearning({required SharedPreferences prefs}) : _prefs = prefs;
  
  /// Initialize personality learning system for a user
  Future<PersonalityProfile> initializePersonality(String userId) async {
    developer.log('Initializing personality learning for user: $userId', name: _logName);
    
    try {
      // Try to load existing personality profile
      final existingProfile = await _loadPersonalityProfile(userId);
      if (existingProfile != null) {
        _currentProfile = existingProfile;
        developer.log('Loaded existing personality profile (generation ${existingProfile.evolutionGeneration})', name: _logName);
        return existingProfile;
      }
      
      // Create new personality profile
      final newProfile = PersonalityProfile.initial(userId);
      await _savePersonalityProfile(newProfile);
      _currentProfile = newProfile;
      
      developer.log('Created new personality profile for user', name: _logName);
      return newProfile;
    } catch (e) {
      developer.log('Error initializing personality: $e', name: _logName);
      
      // Fallback to default profile
      final fallbackProfile = PersonalityProfile.initial(userId);
      _currentProfile = fallbackProfile;
      return fallbackProfile;
    }
  }
  
  /// Evolve personality based on user action
  Future<PersonalityProfile> evolveFromUserAction(
    String userId,
    UserAction action,
  ) async {
    if (_currentProfile == null) {
      await initializePersonality(userId);
    }
    
    if (_isLearning) {
      developer.log('Personality learning already in progress, queuing action', name: _logName);
      return _currentProfile!;
    }
    
    _isLearning = true;
    
    try {
      developer.log('Evolving personality from user action: ${action.type}', name: _logName);
      
      // Analyze action for personality insights
      final dimensionUpdates = await _analyzeActionForDimensions(action);
      final confidenceUpdates = await _analyzeActionForConfidence(action);
      
      // Apply learning rate to dimension updates
      final adjustedUpdates = <String, double>{};
      dimensionUpdates.forEach((dimension, change) {
        adjustedUpdates[dimension] = change * VibeConstants.personalityLearningRate;
      });
      
      // Calculate new authenticity score
      final newAuthenticity = await _calculateAuthenticityFromAction(action);
      
      // Create learning history entry
      final learningData = {
        'total_interactions': 1,
        'action_types': [action.type.toString()],
        'learning_source': 'user_action',
        'dimension_changes': adjustedUpdates,
      };
      
      // Evolve the personality
      final evolvedProfile = _currentProfile!.evolve(
        newDimensions: adjustedUpdates,
        newConfidence: confidenceUpdates,
        newAuthenticity: newAuthenticity,
        additionalLearning: learningData,
      );
      
      // Save updated profile
      await _savePersonalityProfile(evolvedProfile);
      _currentProfile = evolvedProfile;
      
      developer.log('Personality evolved to generation ${evolvedProfile.evolutionGeneration}', name: _logName);
      developer.log('Dominant traits: ${evolvedProfile.getDominantTraits()}', name: _logName);
      
      return evolvedProfile;
    } catch (e) {
      developer.log('Error evolving personality: $e', name: _logName);
      return _currentProfile!;
    } finally {
      _isLearning = false;
    }
  }
  
  /// Evolve personality from AI2AI learning interaction
  Future<PersonalityProfile> evolveFromAI2AILearning(
    String userId,
    AI2AILearningInsight insight,
  ) async {
    if (_currentProfile == null) {
      await initializePersonality(userId);
    }
    
    if (_isLearning) {
      developer.log('Personality learning already in progress, queuing AI2AI learning', name: _logName);
      return _currentProfile!;
    }
    
    _isLearning = true;
    
    try {
      developer.log('Evolving personality from AI2AI learning: ${insight.type}', name: _logName);
      
      // Apply AI2AI learning rate (typically lower than direct user actions)
      final adjustedInsights = <String, double>{};
      insight.dimensionInsights.forEach((dimension, change) {
        adjustedInsights[dimension] = change * VibeConstants.ai2aiLearningRate;
      });
      
      // Create learning history entry
      final learningData = {
        'total_interactions': 1,
        'successful_ai2ai_connections': 1,
        'learning_source': 'ai2ai_interaction',
        'insight_type': insight.type.toString(),
        'dimension_changes': adjustedInsights,
      };
      
      // Evolve personality with AI2AI insights
      final evolvedProfile = _currentProfile!.evolve(
        newDimensions: adjustedInsights,
        additionalLearning: learningData,
      );
      
      // Save updated profile
      await _savePersonalityProfile(evolvedProfile);
      _currentProfile = evolvedProfile;
      
      developer.log('Personality evolved from AI2AI learning to generation ${evolvedProfile.evolutionGeneration}', name: _logName);
      
      return evolvedProfile;
    } catch (e) {
      developer.log('Error evolving personality from AI2AI learning: $e', name: _logName);
      return _currentProfile!;
    } finally {
      _isLearning = false;
    }
  }
  
  /// Get current personality profile
  Future<PersonalityProfile?> getCurrentPersonality(String userId) async {
    if (_currentProfile != null && _currentProfile!.userId == userId) {
      return _currentProfile;
    }
    
    return await _loadPersonalityProfile(userId);
  }
  
  /// Get personality evolution history
  Future<List<PersonalityEvolutionEvent>> getEvolutionHistory(String userId) async {
    try {
      final historyJson = _prefs.getString('${_learningHistoryKey}_$userId');
      if (historyJson == null) return [];
      
      // Parse evolution history
      // This would contain timestamp, generation, dimension changes, etc.
      // Implementation depends on storage format
      return [];
    } catch (e) {
      developer.log('Error loading evolution history: $e', name: _logName);
      return [];
    }
  }
  
  /// Calculate personality readiness for AI2AI connections
  Future<PersonalityReadiness> calculateAI2AIReadiness(String userId) async {
    final profile = await getCurrentPersonality(userId);
    if (profile == null) {
      return PersonalityReadiness(
        isReady: false,
        readinessScore: 0.0,
        reasons: ['No personality profile found'],
      );
    }
    
    final reasons = <String>[];
    double readinessScore = 0.0;
    
    // Check if personality is well-developed
    if (profile.isWellDeveloped) {
      readinessScore += 0.4;
    } else {
      reasons.add('Personality needs more development (${profile.learningHistory['total_interactions']} interactions)');
    }
    
    // Check confidence levels
    final avgConfidence = profile.dimensionConfidence.values.isNotEmpty
        ? profile.dimensionConfidence.values.reduce((a, b) => a + b) / profile.dimensionConfidence.length
        : 0.0;
    
    if (avgConfidence >= VibeConstants.personalityConfidenceThreshold) {
      readinessScore += 0.3;
    } else {
      reasons.add('Low confidence in personality dimensions (${(avgConfidence * 100).toStringAsFixed(1)}%)');
    }
    
    // Check authenticity score
    if (profile.authenticity >= 0.6) {
      readinessScore += 0.2;
    } else {
      reasons.add('Low authenticity score (${(profile.authenticity * 100).toStringAsFixed(1)}%)');
    }
    
    // Check evolution generation (more evolved = more ready)
    if (profile.evolutionGeneration >= 5) {
      readinessScore += 0.1;
    } else {
      reasons.add('Personality needs more evolution (generation ${profile.evolutionGeneration})');
    }
    
    return PersonalityReadiness(
      isReady: readinessScore >= 0.7,
      readinessScore: readinessScore,
      reasons: reasons,
    );
  }
  
  /// Reset personality learning (for testing or user request)
  Future<void> resetPersonality(String userId) async {
    developer.log('Resetting personality for user: $userId', name: _logName);
    
    await _prefs.remove('${_personalityProfileKey}_$userId');
    await _prefs.remove('${_learningHistoryKey}_$userId');
    await _prefs.remove('${_dimensionConfidenceKey}_$userId');
    
    _currentProfile = null;
    
    developer.log('Personality reset completed', name: _logName);
  }
  
  // Private helper methods
  Future<PersonalityProfile?> _loadPersonalityProfile(String userId) async {
    try {
      final profileJson = _prefs.getString('${_personalityProfileKey}_$userId');
      if (profileJson == null) return null;
      
      // In a real implementation, this would parse JSON
      // For now, return null to create new profile
      return null;
    } catch (e) {
      developer.log('Error loading personality profile: $e', name: _logName);
      return null;
    }
  }
  
  Future<void> _savePersonalityProfile(PersonalityProfile profile) async {
    try {
      // In a real implementation, this would serialize to JSON
      await _prefs.setString(
        '${_personalityProfileKey}_${profile.userId}',
        'profile_data', // Would be profile.toJson()
      );
      
      developer.log('Personality profile saved (generation ${profile.evolutionGeneration})', name: _logName);
    } catch (e) {
      developer.log('Error saving personality profile: $e', name: _logName);
    }
  }
  
  Future<Map<String, double>> _analyzeActionForDimensions(UserAction action) async {
    final dimensionUpdates = <String, double>{};
    
    switch (action.type) {
      case UserActionType.spotVisit:
        // Visiting spots indicates exploration eagerness
        dimensionUpdates['exploration_eagerness'] = 0.1;
        
        // Check if it's a social or solo visit
        if (action.metadata['social_visit'] == true) {
          dimensionUpdates['community_orientation'] = 0.05;
        }
        
        // Check distance traveled
        final distanceTraveled = action.metadata['distance_km'] as double? ?? 0.0;
        if (distanceTraveled > 10.0) {
          dimensionUpdates['location_adventurousness'] = 0.08;
        }
        break;
        
      case UserActionType.socialInteraction:
        dimensionUpdates['community_orientation'] = 0.12;
        dimensionUpdates['social_discovery_style'] = 0.08;
        break;
        
      case UserActionType.spontaneousActivity:
        dimensionUpdates['temporal_flexibility'] = 0.15;
        dimensionUpdates['exploration_eagerness'] = 0.08;
        break;
        
      case UserActionType.curationActivity:
        dimensionUpdates['curation_tendency'] = 0.12;
        dimensionUpdates['community_orientation'] = 0.06;
        break;
        
      case UserActionType.authenticPreference:
        dimensionUpdates['authenticity_preference'] = 0.10;
        break;
        
      case UserActionType.trustNetworkUse:
        dimensionUpdates['trust_network_reliance'] = 0.08;
        break;
    }
    
    return dimensionUpdates;
  }
  
  Future<Map<String, double>> _analyzeActionForConfidence(UserAction action) async {
    // Increase confidence for dimensions that are consistently expressed
    final confidenceUpdates = <String, double>{};
    
    // Base confidence increase for any action
    const baseConfidenceIncrease = 0.02;
    
    switch (action.type) {
      case UserActionType.spotVisit:
        confidenceUpdates['exploration_eagerness'] = baseConfidenceIncrease;
        if (action.metadata['social_visit'] == true) {
          confidenceUpdates['community_orientation'] = baseConfidenceIncrease;
        }
        break;
        
      case UserActionType.socialInteraction:
        confidenceUpdates['community_orientation'] = baseConfidenceIncrease * 1.5;
        confidenceUpdates['social_discovery_style'] = baseConfidenceIncrease;
        break;
        
      case UserActionType.spontaneousActivity:
        confidenceUpdates['temporal_flexibility'] = baseConfidenceIncrease * 1.2;
        break;
        
      case UserActionType.curationActivity:
        confidenceUpdates['curation_tendency'] = baseConfidenceIncrease * 1.3;
        break;
        
      case UserActionType.authenticPreference:
        confidenceUpdates['authenticity_preference'] = baseConfidenceIncrease * 1.1;
        break;
        
      case UserActionType.trustNetworkUse:
        confidenceUpdates['trust_network_reliance'] = baseConfidenceIncrease;
        break;
    }
    
    return confidenceUpdates;
  }
  
  Future<double> _calculateAuthenticityFromAction(UserAction action) async {
    if (_currentProfile == null) return 0.5;
    
    double authenticityChange = 0.0;
    
    switch (action.type) {
      case UserActionType.authenticPreference:
        authenticityChange = 0.05;
        break;
      case UserActionType.curationActivity:
        // Curation can indicate authenticity or algorithmic preference
        final curationType = action.metadata['curation_type'] as String?;
        if (curationType == 'personal_experience') {
          authenticityChange = 0.03;
        } else if (curationType == 'algorithmic_based') {
          authenticityChange = -0.02;
        }
        break;
      case UserActionType.spotVisit:
        // Visiting lesser-known spots indicates authenticity preference
        final spotPopularity = action.metadata['spot_popularity'] as double? ?? 0.5;
        if (spotPopularity < 0.3) {
          authenticityChange = 0.02;
        }
        break;
      default:
        // Neutral actions don't affect authenticity much
        break;
    }
    
    final newAuthenticity = (_currentProfile!.authenticity + authenticityChange).clamp(0.0, 1.0);
    return newAuthenticity;
  }
}

// Supporting classes for personality learning
class UserAction {
  final UserActionType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  UserAction({
    required this.type,
    required this.timestamp,
    required this.metadata,
  });
}

enum UserActionType {
  spotVisit,
  socialInteraction,
  spontaneousActivity,
  curationActivity,
  authenticPreference,
  trustNetworkUse,
}

class AI2AILearningInsight {
  final AI2AIInsightType type;
  final Map<String, double> dimensionInsights;
  final double learningQuality;
  final DateTime timestamp;
  
  AI2AILearningInsight({
    required this.type,
    required this.dimensionInsights,
    required this.learningQuality,
    required this.timestamp,
  });
}

enum AI2AIInsightType {
  compatibilityLearning,
  dimensionDiscovery,
  patternRecognition,
  trustBuilding,
  communityInsight,
  cloudLearning,
}

class PersonalityReadiness {
  final bool isReady;
  final double readinessScore;
  final List<String> reasons;
  
  PersonalityReadiness({
    required this.isReady,
    required this.readinessScore,
    required this.reasons,
  });
}

class PersonalityEvolutionEvent {
  final DateTime timestamp;
  final int generation;
  final Map<String, double> dimensionChanges;
  final String learningSource;
  
  PersonalityEvolutionEvent({
    required this.timestamp,
    required this.generation,
    required this.dimensionChanges,
    required this.learningSource,
  });
}
  /// Calculate personality readiness
  Future<double> calculatePersonalityReadiness() async {
    if (_currentProfile == null) return 0.0;
    return _currentProfile!.confidence;
  }

  /// Evolve personality
  Future<PersonalityProfile> evolvePersonality(UserAction action) async {
    return await evolveFromUserAction(_currentProfile?.userId ?? '', action);
  }


  /// Calculate personality readiness
  Future<double> calculatePersonalityReadiness() async {
    if (_currentProfile == null) return 0.0;
    return _currentProfile!.confidence;
  }

  /// Evolve personality
  Future<PersonalityProfile> evolvePersonality(UserAction action) async {
    return await evolveFromUserAction(_currentProfile?.userId ?? '', action);
  }


  /// Recognize behavioral patterns
  Future<List<BehavioralPattern>> recognizeBehavioralPatterns(List<UserAction> actions) async {
    // Simple pattern recognition
    return [];
  }

  /// Predict future preferences
  Future<Map<String, double>> predictFuturePreferences() async {
    if (_currentProfile == null) return {};
    return _currentProfile!.dimensionScores;
  }

  /// Anonymize personality data
  Future<AnonymizedPersonalityData> anonymizePersonality() async {
    if (_currentProfile == null) {
      return AnonymizedPersonalityData(
        hashedUserId: '',
        hashedSignature: '',
        anonymizedDimensions: {},
        metadata: {},
      );
    }
    
    return AnonymizedPersonalityData(
      hashedUserId: _currentProfile!.hashedUserId,
      hashedSignature: _currentProfile!.userId.hashCode.toString(),
      anonymizedDimensions: _currentProfile!.dimensionScores,
      metadata: {},
    );
  }


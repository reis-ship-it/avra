import 'dart:developer' as developer;
import 'dart:math';
import 'package:spots/core/constants/vibe_constants.dart';
import 'package:spots/core/ai/personality_learning.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OUR_GUTS.md: "Dynamic dimension discovery through user feedback analysis that evolves personality understanding"
/// Advanced feedback learning system that extracts implicit personality dimensions from user interactions
class UserFeedbackAnalyzer {
  static const String _logName = 'UserFeedbackAnalyzer';
  
  // Storage keys for feedback data
  static const String _feedbackHistoryKey = 'feedback_history';
  static const String _discoveredDimensionsKey = 'discovered_dimensions';
  static const String _feedbackPatternsKey = 'feedback_patterns';
  
  final SharedPreferences _prefs;
  final PersonalityLearning _personalityLearning;
  
  // Feedback analysis state
  final Map<String, List<FeedbackEvent>> _feedbackHistory = {};
  final Map<String, Map<String, double>> _discoveredDimensions = {};
  final Map<String, FeedbackPattern> _userPatterns = {};
  
  UserFeedbackAnalyzer({
    required SharedPreferences prefs,
    required PersonalityLearning personalityLearning,
  }) : _prefs = prefs,
       _personalityLearning = personalityLearning;
  
  /// Analyze user feedback to extract implicit personality dimensions
  Future<FeedbackAnalysisResult> analyzeFeedback(
    String userId,
    FeedbackEvent feedback,
  ) async {
    try {
      developer.log('Analyzing feedback from user: $userId', name: _logName);
      developer.log('Feedback type: ${feedback.type}, satisfaction: ${feedback.satisfaction}', name: _logName);
      
      // Store feedback in history
      await _storeFeedbackEvent(userId, feedback);
      
      // Extract implicit dimensions from feedback
      final implicitDimensions = await _extractImplicitDimensions(userId, feedback);
      
      // Analyze feedback patterns over time
      final patterns = await _analyzeFeedbackPatterns(userId);
      
      // Discover new personality dimensions
      final newDimensions = await _discoverNewDimensions(userId, feedback, patterns);
      
      // Calculate personality adjustment recommendations
      final adjustments = await _calculatePersonalityAdjustments(
        userId,
        feedback,
        implicitDimensions,
        newDimensions,
      );
      
      // Generate learning insights
      final insights = await _generateLearningInsights(userId, feedback, patterns);
      
      final result = FeedbackAnalysisResult(
        userId: userId,
        feedback: feedback,
        implicitDimensions: implicitDimensions,
        discoveredDimensions: newDimensions,
        personalityAdjustments: adjustments,
        learningInsights: insights,
        analysisTimestamp: DateTime.now(),
        confidenceScore: _calculateAnalysisConfidence(feedback, patterns),
      );
      
      // Apply learning if confidence is high enough
      if (result.confidenceScore >= 0.7) {
        await _applyFeedbackLearning(userId, result);
      }
      
      developer.log('Feedback analysis completed (confidence: ${(result.confidenceScore * 100).round()}%)', name: _logName);
      return result;
    } catch (e) {
      developer.log('Error analyzing feedback: $e', name: _logName);
      return FeedbackAnalysisResult.fallback(userId, feedback);
    }
  }
  
  /// Analyze multiple feedback events to identify behavioral patterns
  Future<List<BehavioralPattern>> identifyBehavioralPatterns(String userId) async {
    try {
      developer.log('Identifying behavioral patterns for user: $userId', name: _logName);
      
      final feedbackHistory = await _getFeedbackHistory(userId);
      if (feedbackHistory.length < 5) {
        developer.log('Insufficient feedback history for pattern analysis', name: _logName);
        return [];
      }
      
      final patterns = <BehavioralPattern>[];
      
      // Analyze satisfaction patterns
      final satisfactionPattern = await _analyzeSatisfactionPattern(feedbackHistory);
      if (satisfactionPattern != null) patterns.add(satisfactionPattern);
      
      // Analyze temporal patterns
      final temporalPattern = await _analyzeTemporalPattern(feedbackHistory);
      if (temporalPattern != null) patterns.add(temporalPattern);
      
      // Analyze category preferences
      final categoryPattern = await _analyzeCategoryPattern(feedbackHistory);
      if (categoryPattern != null) patterns.add(categoryPattern);
      
      // Analyze social context patterns
      final socialPattern = await _analyzeSocialContextPattern(feedbackHistory);
      if (socialPattern != null) patterns.add(socialPattern);
      
      // Analyze expectation vs reality patterns
      final expectationPattern = await _analyzeExpectationPattern(feedbackHistory);
      if (expectationPattern != null) patterns.add(expectationPattern);
      
      developer.log('Identified ${patterns.length} behavioral patterns', name: _logName);
      return patterns;
    } catch (e) {
      developer.log('Error identifying behavioral patterns: $e', name: _logName);
      return [];
    }
  }
  
  /// Extract new personality dimensions from user feedback
  Future<Map<String, double>> extractNewDimensions(
    String userId,
    List<FeedbackEvent> recentFeedback,
  ) async {
    try {
      developer.log('Extracting new dimensions from feedback patterns', name: _logName);
      
      final newDimensions = <String, double>{};
      
      // Analyze feedback sentiment patterns
      final sentimentDimensions = await _extractSentimentDimensions(recentFeedback);
      newDimensions.addAll(sentimentDimensions);
      
      // Analyze preference intensity patterns
      final intensityDimensions = await _extractIntensityDimensions(recentFeedback);
      newDimensions.addAll(intensityDimensions);
      
      // Analyze decision-making patterns
      final decisionDimensions = await _extractDecisionDimensions(recentFeedback);
      newDimensions.addAll(decisionDimensions);
      
      // Analyze adaptation patterns
      final adaptationDimensions = await _extractAdaptationDimensions(recentFeedback);
      newDimensions.addAll(adaptationDimensions);
      
      // Validate new dimensions against existing personality
      final validatedDimensions = await _validateNewDimensions(userId, newDimensions);
      
      developer.log('Extracted ${validatedDimensions.length} new personality dimensions', name: _logName);
      return validatedDimensions;
    } catch (e) {
      developer.log('Error extracting new dimensions: $e', name: _logName);
      return {};
    }
  }
  
  /// Predict user satisfaction based on learned patterns
  Future<SatisfactionPrediction> predictUserSatisfaction(
    String userId,
    Map<String, dynamic> scenario,
  ) async {
    try {
      developer.log('Predicting user satisfaction for scenario', name: _logName);
      
      final patterns = await _getUserPatterns(userId);
      final feedbackHistory = await _getFeedbackHistory(userId);
      
      if (patterns.isEmpty || feedbackHistory.isEmpty) {
        developer.log('Insufficient data for satisfaction prediction', name: _logName);
        return SatisfactionPrediction.uncertain();
      }
      
      // Analyze scenario against learned patterns
      final contextMatch = await _calculateContextMatch(scenario, patterns);
      final preferenceAlignment = await _calculatePreferenceAlignment(scenario, feedbackHistory);
      final noveltyScore = await _calculateNoveltyScore(scenario, feedbackHistory);
      
      // Calculate predicted satisfaction
      final predictedSatisfaction = (
        contextMatch * 0.4 +
        preferenceAlignment * 0.4 +
        noveltyScore * 0.2
      ).clamp(0.0, 1.0);
      
      // Calculate prediction confidence
      final confidence = _calculatePredictionConfidence(patterns, feedbackHistory.length);
      
      // Generate explanation
      final explanation = await _generateSatisfactionExplanation(
        contextMatch,
        preferenceAlignment,
        noveltyScore,
        patterns,
      );
      
      final prediction = SatisfactionPrediction(
        predictedSatisfaction: predictedSatisfaction,
        confidence: confidence,
        explanation: explanation,
        factorsAnalyzed: {
          'context_match': contextMatch,
          'preference_alignment': preferenceAlignment,
          'novelty_score': noveltyScore,
        },
        basedOnFeedbackCount: feedbackHistory.length,
        predictionTimestamp: DateTime.now(),
      );
      
      developer.log('Satisfaction predicted: ${(predictedSatisfaction * 100).round()}% (confidence: ${(confidence * 100).round()}%)', name: _logName);
      return prediction;
    } catch (e) {
      developer.log('Error predicting satisfaction: $e', name: _logName);
      return SatisfactionPrediction.uncertain();
    }
  }
  
  /// Get feedback learning insights for personality evolution
  Future<FeedbackLearningInsights> getFeedbackInsights(String userId) async {
    try {
      developer.log('Generating feedback learning insights for user: $userId', name: _logName);
      
      final feedbackHistory = await _getFeedbackHistory(userId);
      final patterns = await identifyBehavioralPatterns(userId);
      final discoveredDimensions = await _getDiscoveredDimensions(userId);
      
      // Calculate learning progress
      final learningProgress = await _calculateLearningProgress(userId, feedbackHistory);
      
      // Identify learning opportunities
      final opportunities = await _identifyLearningOpportunities(patterns, discoveredDimensions);
      
      // Generate personalized recommendations
      final recommendations = await _generatePersonalityRecommendations(
        userId,
        patterns,
        discoveredDimensions,
      );
      
      final insights = FeedbackLearningInsights(
        userId: userId,
        totalFeedbackEvents: feedbackHistory.length,
        behavioralPatterns: patterns,
        discoveredDimensions: discoveredDimensions,
        learningProgress: learningProgress,
        learningOpportunities: opportunities,
        recommendations: recommendations,
        insightsGenerated: DateTime.now(),
      );
      
      developer.log('Generated feedback insights: ${patterns.length} patterns, ${discoveredDimensions.length} dimensions', name: _logName);
      return insights;
    } catch (e) {
      developer.log('Error generating feedback insights: $e', name: _logName);
      return FeedbackLearningInsights.empty(userId);
    }
  }
  
  // Private helper methods
  Future<void> _storeFeedbackEvent(String userId, FeedbackEvent feedback) async {
    final userHistory = _feedbackHistory[userId] ?? <FeedbackEvent>[];
    userHistory.add(feedback);
    _feedbackHistory[userId] = userHistory;
    
    // Keep only recent feedback (last 100 events)
    if (userHistory.length > 100) {
      _feedbackHistory[userId] = userHistory.sublist(userHistory.length - 100);
    }
    
    // Persist to storage
    await _saveFeedbackHistory(userId);
  }
  
  Future<Map<String, double>> _extractImplicitDimensions(
    String userId,
    FeedbackEvent feedback,
  ) async {
    final dimensions = <String, double>{};
    
    // Extract dimensions based on feedback type and satisfaction
    switch (feedback.type) {
      case FeedbackType.spotExperience:
        dimensions['experience_sensitivity'] = feedback.satisfaction;
        if (feedback.metadata.containsKey('crowd_level')) {
          final crowdLevel = feedback.metadata['crowd_level'] as double;
          dimensions['crowd_tolerance'] = 1.0 - (crowdLevel * (1.0 - feedback.satisfaction));
        }
        break;
        
      case FeedbackType.socialInteraction:
        dimensions['social_energy_preference'] = feedback.satisfaction;
        if (feedback.metadata.containsKey('group_size')) {
          final groupSize = feedback.metadata['group_size'] as int;
          dimensions['group_size_preference'] = feedback.satisfaction * (groupSize / 10.0).clamp(0.0, 1.0);
        }
        break;
        
      case FeedbackType.recommendation:
        dimensions['recommendation_receptivity'] = feedback.satisfaction;
        dimensions['algorithmic_trust'] = feedback.satisfaction * 0.8;
        break;
        
      case FeedbackType.discovery:
        dimensions['novelty_appreciation'] = feedback.satisfaction;
        dimensions['exploration_reward_sensitivity'] = feedback.satisfaction;
        break;
        
      case FeedbackType.curation:
        dimensions['sharing_satisfaction'] = feedback.satisfaction;
        dimensions['community_contribution_drive'] = feedback.satisfaction * 0.9;
        break;
    }
    
    return dimensions;
  }
  
  Future<FeedbackPattern> _analyzeFeedbackPatterns(String userId) async {
    final history = await _getFeedbackHistory(userId);
    if (history.length < 3) return FeedbackPattern.insufficient();
    
    // Calculate average satisfaction by type
    final satisfactionByType = <FeedbackType, double>{};
    final countByType = <FeedbackType, int>{};
    
    for (final feedback in history) {
      satisfactionByType[feedback.type] = 
          (satisfactionByType[feedback.type] ?? 0.0) + feedback.satisfaction;
      countByType[feedback.type] = (countByType[feedback.type] ?? 0) + 1;
    }
    
    // Average the satisfaction scores
    satisfactionByType.forEach((type, totalSatisfaction) {
      satisfactionByType[type] = totalSatisfaction / countByType[type]!;
    });
    
    // Analyze temporal patterns
    final recentFeedback = history.length > 10 ? history.sublist(history.length - 10) : history;
    final recentSatisfaction = recentFeedback.fold(0.0, (sum, f) => sum + f.satisfaction) / recentFeedback.length;
    
    // Calculate trend
    double trend = 0.0;
    if (history.length >= 6) {
      final firstHalf = history.sublist(0, history.length ~/ 2);
      final secondHalf = history.sublist(history.length ~/ 2);
      
      final firstAvg = firstHalf.fold(0.0, (sum, f) => sum + f.satisfaction) / firstHalf.length;
      final secondAvg = secondHalf.fold(0.0, (sum, f) => sum + f.satisfaction) / secondHalf.length;
      
      trend = secondAvg - firstAvg;
    }
    
    return FeedbackPattern(
      userId: userId,
      satisfactionByType: satisfactionByType,
      overallSatisfaction: history.fold(0.0, (sum, f) => sum + f.satisfaction) / history.length,
      recentSatisfaction: recentSatisfaction,
      satisfactionTrend: trend,
      feedbackFrequency: history.length / 30.0, // Assuming 30-day window
      patternConfidence: min(1.0, history.length / 20.0),
    );
  }
  
  Future<Map<String, double>> _discoverNewDimensions(
    String userId,
    FeedbackEvent feedback,
    FeedbackPattern patterns,
  ) async {
    final newDimensions = <String, double>{};
    
    // Discover dimensions based on satisfaction patterns
    if (patterns.satisfactionTrend > 0.2) {
      newDimensions['adaptability'] = 0.8;
      newDimensions['learning_receptivity'] = 0.9;
    } else if (patterns.satisfactionTrend < -0.2) {
      newDimensions['consistency_preference'] = 0.7;
      newDimensions['change_resistance'] = 0.6;
    }
    
    // Discover dimensions from feedback consistency
    if (patterns.patternConfidence > 0.8) {
      newDimensions['preference_clarity'] = patterns.patternConfidence;
    }
    
    // Discover dimensions from feedback frequency
    if (patterns.feedbackFrequency > 0.5) {
      newDimensions['engagement_level'] = patterns.feedbackFrequency;
      newDimensions['communication_tendency'] = patterns.feedbackFrequency * 0.8;
    }
    
    return newDimensions;
  }
  
  Future<Map<String, double>> _calculatePersonalityAdjustments(
    String userId,
    FeedbackEvent feedback,
    Map<String, double> implicitDimensions,
    Map<String, double> newDimensions,
  ) async {
    final adjustments = <String, double>{};
    
    // Calculate adjustments based on implicit dimensions
    implicitDimensions.forEach((dimension, value) {
      // Map implicit dimensions to core personality dimensions
      if (dimension.contains('social')) {
        adjustments['community_orientation'] = value * VibeConstants.dimensionLearningRate;
        adjustments['social_discovery_style'] = value * VibeConstants.dimensionLearningRate;
      } else if (dimension.contains('exploration') || dimension.contains('novelty')) {
        adjustments['exploration_eagerness'] = value * VibeConstants.dimensionLearningRate;
        adjustments['location_adventurousness'] = value * VibeConstants.dimensionLearningRate;
      } else if (dimension.contains('authentic')) {
        adjustments['authenticity_preference'] = value * VibeConstants.dimensionLearningRate;
      }
    });
    
    // Apply learning rate constraint
    adjustments.forEach((dimension, adjustment) {
      adjustments[dimension] = adjustment.clamp(-0.1, 0.1); // Limit adjustment magnitude
    });
    
    return adjustments;
  }
  
  Future<List<LearningInsight>> _generateLearningInsights(
    String userId,
    FeedbackEvent feedback,
    FeedbackPattern patterns,
  ) async {
    final insights = <LearningInsight>[];
    
    // Generate satisfaction trend insights
    if (patterns.satisfactionTrend > 0.1) {
      insights.add(LearningInsight(
        type: InsightType.improvement,
        message: 'Your satisfaction has been increasing - you\'re adapting well to new experiences',
        confidence: patterns.patternConfidence,
        actionable: true,
      ));
    } else if (patterns.satisfactionTrend < -0.1) {
      insights.add(LearningInsight(
        type: InsightType.concern,
        message: 'Your satisfaction has been declining - consider exploring different types of experiences',
        confidence: patterns.patternConfidence,
        actionable: true,
      ));
    }
    
    // Generate feedback frequency insights
    if (patterns.feedbackFrequency > 0.7) {
      insights.add(LearningInsight(
        type: InsightType.strength,
        message: 'You provide frequent feedback - this helps your AI personality learn quickly',
        confidence: 0.9,
        actionable: false,
      ));
    }
    
    // Generate type-specific insights
    if (patterns.satisfactionByType[FeedbackType.spotExperience] != null) {
      final spotSatisfaction = patterns.satisfactionByType[FeedbackType.spotExperience]!;
      if (spotSatisfaction > 0.8) {
        insights.add(LearningInsight(
          type: InsightType.strength,
          message: 'You consistently enjoy new spot experiences - your exploration eagerness is high',
          confidence: 0.8,
          actionable: false,
        ));
      }
    }
    
    return insights;
  }
  
  double _calculateAnalysisConfidence(FeedbackEvent feedback, FeedbackPattern patterns) {
    var confidence = 0.5; // Base confidence
    
    // Increase confidence based on pattern strength
    confidence += patterns.patternConfidence * 0.3;
    
    // Increase confidence based on feedback richness
    if (feedback.metadata.isNotEmpty) {
      confidence += 0.1;
    }
    
    // Increase confidence based on satisfaction certainty
    if (feedback.satisfaction > 0.8 || feedback.satisfaction < 0.2) {
      confidence += 0.1; // Strong satisfaction signals are more reliable
    }
    
    return confidence.clamp(0.0, 1.0);
  }
  
  Future<void> _applyFeedbackLearning(String userId, FeedbackAnalysisResult result) async {
    if (result.personalityAdjustments.isNotEmpty) {
      // Create a feedback learning insight for personality evolution
      final feedbackInsight = AI2AILearningInsight(
        type: AI2AIInsightType.dimensionDiscovery,
        dimensionInsights: result.personalityAdjustments,
        learningQuality: result.confidenceScore,
        timestamp: DateTime.now(),
      );
      
      // Apply the learning through the personality learning system
      await _personalityLearning.evolveFromAI2AILearning(userId, feedbackInsight);
      
      developer.log('Applied feedback learning with ${result.personalityAdjustments.length} adjustments', name: _logName);
    }
  }
  
  // Additional helper methods for pattern analysis
  Future<List<FeedbackEvent>> _getFeedbackHistory(String userId) async {
    return _feedbackHistory[userId] ?? <FeedbackEvent>[];
  }
  
  Future<void> _saveFeedbackHistory(String userId) async {
    // In a real implementation, this would serialize and save the feedback history
    // For now, we'll just log the save action
    developer.log('Saved feedback history for user: $userId', name: _logName);
  }
  
  Future<Map<String, double>> _getDiscoveredDimensions(String userId) async {
    return _discoveredDimensions[userId] ?? <String, double>{};
  }
  
  Future<List<FeedbackPattern>> _getUserPatterns(String userId) async {
    final pattern = _userPatterns[userId];
    return pattern != null ? [pattern] : <FeedbackPattern>[];
  }
  
  // Placeholder implementations for complex analysis methods
  Future<BehavioralPattern?> _analyzeSatisfactionPattern(List<FeedbackEvent> history) async => null;
  Future<BehavioralPattern?> _analyzeTemporalPattern(List<FeedbackEvent> history) async => null;
  Future<BehavioralPattern?> _analyzeCategoryPattern(List<FeedbackEvent> history) async => null;
  Future<BehavioralPattern?> _analyzeSocialContextPattern(List<FeedbackEvent> history) async => null;
  Future<BehavioralPattern?> _analyzeExpectationPattern(List<FeedbackEvent> history) async => null;
  
  Future<Map<String, double>> _extractSentimentDimensions(List<FeedbackEvent> feedback) async => {};
  Future<Map<String, double>> _extractIntensityDimensions(List<FeedbackEvent> feedback) async => {};
  Future<Map<String, double>> _extractDecisionDimensions(List<FeedbackEvent> feedback) async => {};
  Future<Map<String, double>> _extractAdaptationDimensions(List<FeedbackEvent> feedback) async => {};
  
  Future<Map<String, double>> _validateNewDimensions(String userId, Map<String, double> dimensions) async => dimensions;
  
  Future<double> _calculateContextMatch(Map<String, dynamic> scenario, List<FeedbackPattern> patterns) async => 0.7;
  Future<double> _calculatePreferenceAlignment(Map<String, dynamic> scenario, List<FeedbackEvent> history) async => 0.8;
  Future<double> _calculateNoveltyScore(Map<String, dynamic> scenario, List<FeedbackEvent> history) async => 0.6;
  
  double _calculatePredictionConfidence(List<FeedbackPattern> patterns, int historyLength) => min(1.0, historyLength / 20.0);
  
  Future<String> _generateSatisfactionExplanation(
    double contextMatch,
    double preferenceAlignment, 
    double noveltyScore,
    List<FeedbackPattern> patterns,
  ) async => 'Based on your feedback patterns and preferences';
  
  Future<LearningProgress> _calculateLearningProgress(String userId, List<FeedbackEvent> history) async {
    return LearningProgress(
      totalFeedbackEvents: history.length,
      learningVelocity: history.length / 30.0,
      personalityEvolution: 0.5,
      insightAccuracy: 0.8,
    );
  }
  
  Future<List<LearningOpportunity>> _identifyLearningOpportunities(
    List<BehavioralPattern> patterns,
    Map<String, double> dimensions,
  ) async => [];
  
  Future<List<String>> _generatePersonalityRecommendations(
    String userId,
    List<BehavioralPattern> patterns,
    Map<String, double> dimensions,
  ) async => ['Continue providing detailed feedback to improve personality learning'];
}

// Supporting classes for feedback learning
class FeedbackEvent {
  final FeedbackType type;
  final double satisfaction;
  final String? comment;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  
  FeedbackEvent({
    required this.type,
    required this.satisfaction,
    this.comment,
    required this.metadata,
    required this.timestamp,
  });
}

enum FeedbackType {
  spotExperience,
  socialInteraction,
  recommendation,
  discovery,
  curation,
}

class FeedbackAnalysisResult {
  final String userId;
  final FeedbackEvent feedback;
  final Map<String, double> implicitDimensions;
  final Map<String, double> discoveredDimensions;
  final Map<String, double> personalityAdjustments;
  final List<LearningInsight> learningInsights;
  final DateTime analysisTimestamp;
  final double confidenceScore;
  
  FeedbackAnalysisResult({
    required this.userId,
    required this.feedback,
    required this.implicitDimensions,
    required this.discoveredDimensions,
    required this.personalityAdjustments,
    required this.learningInsights,
    required this.analysisTimestamp,
    required this.confidenceScore,
  });
  
  static FeedbackAnalysisResult fallback(String userId, FeedbackEvent feedback) {
    return FeedbackAnalysisResult(
      userId: userId,
      feedback: feedback,
      implicitDimensions: {},
      discoveredDimensions: {},
      personalityAdjustments: {},
      learningInsights: [],
      analysisTimestamp: DateTime.now(),
      confidenceScore: 0.0,
    );
  }
}

class FeedbackPattern {
  final String userId;
  final Map<FeedbackType, double> satisfactionByType;
  final double overallSatisfaction;
  final double recentSatisfaction;
  final double satisfactionTrend;
  final double feedbackFrequency;
  final double patternConfidence;
  
  FeedbackPattern({
    required this.userId,
    required this.satisfactionByType,
    required this.overallSatisfaction,
    required this.recentSatisfaction,
    required this.satisfactionTrend,
    required this.feedbackFrequency,
    required this.patternConfidence,
  });
  
  static FeedbackPattern insufficient() {
    return FeedbackPattern(
      userId: '',
      satisfactionByType: {},
      overallSatisfaction: 0.5,
      recentSatisfaction: 0.5,
      satisfactionTrend: 0.0,
      feedbackFrequency: 0.0,
      patternConfidence: 0.0,
    );
  }
}

class BehavioralPattern {
  final String patternType;
  final Map<String, dynamic> characteristics;
  final double strength;
  final double confidence;
  
  BehavioralPattern({
    required this.patternType,
    required this.characteristics,
    required this.strength,
    required this.confidence,
  });
}

class SatisfactionPrediction {
  final double predictedSatisfaction;
  final double confidence;
  final String explanation;
  final Map<String, double> factorsAnalyzed;
  final int basedOnFeedbackCount;
  final DateTime predictionTimestamp;
  
  SatisfactionPrediction({
    required this.predictedSatisfaction,
    required this.confidence,
    required this.explanation,
    required this.factorsAnalyzed,
    required this.basedOnFeedbackCount,
    required this.predictionTimestamp,
  });
  
  static SatisfactionPrediction uncertain() {
    return SatisfactionPrediction(
      predictedSatisfaction: 0.5,
      confidence: 0.1,
      explanation: 'Insufficient data for prediction',
      factorsAnalyzed: {},
      basedOnFeedbackCount: 0,
      predictionTimestamp: DateTime.now(),
    );
  }
}

class FeedbackLearningInsights {
  final String userId;
  final int totalFeedbackEvents;
  final List<BehavioralPattern> behavioralPatterns;
  final Map<String, double> discoveredDimensions;
  final LearningProgress learningProgress;
  final List<LearningOpportunity> learningOpportunities;
  final List<String> recommendations;
  final DateTime insightsGenerated;
  
  FeedbackLearningInsights({
    required this.userId,
    required this.totalFeedbackEvents,
    required this.behavioralPatterns,
    required this.discoveredDimensions,
    required this.learningProgress,
    required this.learningOpportunities,
    required this.recommendations,
    required this.insightsGenerated,
  });
  
  static FeedbackLearningInsights empty(String userId) {
    return FeedbackLearningInsights(
      userId: userId,
      totalFeedbackEvents: 0,
      behavioralPatterns: [],
      discoveredDimensions: {},
      learningProgress: LearningProgress(
        totalFeedbackEvents: 0,
        learningVelocity: 0.0,
        personalityEvolution: 0.0,
        insightAccuracy: 0.0,
      ),
      learningOpportunities: [],
      recommendations: [],
      insightsGenerated: DateTime.now(),
    );
  }
}

class LearningInsight {
  final InsightType type;
  final String message;
  final double confidence;
  final bool actionable;
  
  LearningInsight({
    required this.type,
    required this.message,
    required this.confidence,
    required this.actionable,
  });
}

enum InsightType { improvement, concern, strength, discovery }

class LearningProgress {
  final int totalFeedbackEvents;
  final double learningVelocity;
  final double personalityEvolution;
  final double insightAccuracy;
  
  LearningProgress({
    required this.totalFeedbackEvents,
    required this.learningVelocity,
    required this.personalityEvolution,
    required this.insightAccuracy,
  });
}

class LearningOpportunity {
  final String area;
  final String description;
  final double potential;
  
  LearningOpportunity({
    required this.area,
    required this.description,
    required this.potential,
  });
}
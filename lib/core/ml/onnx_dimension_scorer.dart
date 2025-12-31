// ONNX Dimension Scorer for Phase 11: User-AI Interaction Update
// Provides fast, privacy-sensitive dimension scoring using ONNX models

import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:spots/core/ai2ai/embedding_delta_collector.dart';

/// Scores personality dimensions from onboarding inputs
/// Uses ONNX model for fast, privacy-sensitive scoring
class OnnxDimensionScorer {
  static const String _logName = 'OnnxDimensionScorer';
  
  // TODO: Add ONNX runtime instance when ONNX backend is fully integrated
  // For now, this is a placeholder that provides rule-based scoring
  bool _isInitialized = false;
  
  /// Initialize the ONNX scorer
  Future<void> initialize() async {
    // TODO: Load ONNX model when ONNX backend is available
    // For now, mark as initialized with rule-based fallback
    _isInitialized = true;
    developer.log(
      'ONNX Dimension Scorer initialized (using rule-based fallback)',
      name: _logName,
    );
  }
  
  /// Scores personality dimensions from input data
  /// 
  /// **Parameters:**
  /// - `input`: Map containing onboarding data, places, social graph, etc.
  /// 
  /// **Returns:**
  /// Map of dimension names to scores (0.0-1.0)
  Future<Map<String, double>> scoreDimensions(Map<String, dynamic> input) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // TODO: Use ONNX model for scoring when available
      // For now, use rule-based scoring as placeholder
      return _ruleBasedScoring(input);
    } catch (e) {
      developer.log(
        'Error scoring dimensions: $e',
        name: _logName,
        error: e,
      );
      // Return default scores on error
      return _getDefaultScores();
    }
  }
  
  /// Rule-based scoring (fallback when ONNX model not available)
  Map<String, double> _ruleBasedScoring(Map<String, dynamic> input) {
    final scores = <String, double>{};
    
    // Extract input data
    final onboardingData = input['onboarding_data'] as Map<String, dynamic>? ?? {};
    final places = input['places'] as List? ?? [];
    final socialGraph = input['social_graph'] as List? ?? [];
    final homebase = onboardingData['homebase'] as String?;
    final preferences = onboardingData['preferences'] as Map<String, dynamic>? ?? {};
    
    // Exploration eagerness: based on number of places, preferences
    if (places.length > 5) {
      scores['exploration_eagerness'] = 0.8;
    } else if (places.isNotEmpty) {
      scores['exploration_eagerness'] = 0.6;
    } else {
      scores['exploration_eagerness'] = 0.5;
    }
    
    // Community orientation: based on social graph size
    if (socialGraph.length > 10) {
      scores['community_orientation'] = 0.8;
    } else if (socialGraph.isNotEmpty) {
      scores['community_orientation'] = 0.6;
    } else {
      scores['community_orientation'] = 0.5;
    }
    
    // Location adventurousness: based on homebase and places
    if (homebase != null && places.length > 3) {
      scores['location_adventurousness'] = 0.7;
    } else {
      scores['location_adventurousness'] = 0.5;
    }
    
    // Authenticity preference: based on preferences
    if (preferences.containsKey('authentic') && preferences['authentic'] == true) {
      scores['authenticity_preference'] = 0.8;
    } else {
      scores['authenticity_preference'] = 0.5;
    }
    
    // Trust network reliance: based on social graph
    if (socialGraph.length > 5) {
      scores['trust_network_reliance'] = 0.7;
    } else {
      scores['trust_network_reliance'] = 0.5;
    }
    
    // Temporal flexibility: default
    scores['temporal_flexibility'] = 0.5;
    
    return scores;
  }
  
  /// Get default dimension scores
  Map<String, double> _getDefaultScores() {
    return {
      'exploration_eagerness': 0.5,
      'community_orientation': 0.5,
      'location_adventurousness': 0.5,
      'authenticity_preference': 0.5,
      'trust_network_reliance': 0.5,
      'temporal_flexibility': 0.5,
    };
  }
  
  /// Validate dimension scores for safety
  /// 
  /// **Parameters:**
  /// - `scores`: Map of dimension names to scores
  /// 
  /// **Returns:**
  /// true if scores are safe (within valid ranges), false otherwise
  bool validateScores(Map<String, double> scores) {
    // Check for extreme values
    for (final entry in scores.entries) {
      final score = entry.value;
      if (score < 0.0 || score > 1.0) {
        developer.log(
          'Invalid score for ${entry.key}: $score (must be 0.0-1.0)',
          name: _logName,
        );
        return false;
      }
    }
    
    // Check for all-zero or all-one scores (suspicious)
    final allZero = scores.values.every((s) => s == 0.0);
    final allOne = scores.values.every((s) => s == 1.0);
    
    if (allZero || allOne) {
      developer.log(
        'Suspicious scores detected: all ${allZero ? "zero" : "one"}',
        name: _logName,
      );
      return false;
    }
    
    return true;
  }
  
  /// Update ONNX model with federated deltas
  /// 
  /// Phase 11 Section 7: Federated Learning Hooks
  /// Applies anonymized embedding deltas from AI2AI connections to the
  /// on-device model for continuous learning.
  /// 
  /// [deltas] - List of anonymized embedding deltas from AI2AI connections
  /// 
  /// Note: This is a lightweight update (not full retraining).
  /// The deltas are applied incrementally to keep personalization fresh.
  Future<void> updateWithDeltas(List<EmbeddingDelta> deltas) async {
    try {
      developer.log(
        'Updating ONNX model with ${deltas.length} federated deltas',
        name: _logName,
      );
      
      if (deltas.isEmpty) {
        developer.log('No deltas to apply', name: _logName);
        return;
      }
      
      // TODO: Apply deltas to actual ONNX model when ONNX backend is available
      // For now, this is a placeholder that logs the deltas
      
      // Aggregate deltas by category
      final deltasByCategory = <String, List<EmbeddingDelta>>{};
      for (final delta in deltas) {
        final category = delta.category ?? 'general';
        deltasByCategory.putIfAbsent(category, () => []).add(delta);
      }
      
      developer.log(
        'Deltas by category: ${deltasByCategory.keys.join(", ")}',
        name: _logName,
      );
      
      // Calculate average delta per category
      for (final entry in deltasByCategory.entries) {
        final category = entry.key;
        final categoryDeltas = entry.value;
        
        if (categoryDeltas.isEmpty) continue;
        
        // Calculate average delta vector
        final avgDelta = _calculateAverageDelta(categoryDeltas);
        final avgMagnitude = _calculateDeltaMagnitude(avgDelta);
        
        developer.log(
          'Category: $category, avg magnitude: ${avgMagnitude.toStringAsFixed(3)}, deltas: ${categoryDeltas.length}',
          name: _logName,
        );
        
        // TODO: Apply avgDelta to ONNX model weights
        // This would update the model's internal weights based on the aggregated deltas
        // For now, we just log the information
      }
      
      developer.log(
        'Federated delta update complete (placeholder - ONNX backend not yet available)',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error updating model with deltas: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - delta update failure shouldn't break the app
    }
  }
  
  /// Calculate average delta vector from multiple deltas
  List<double> _calculateAverageDelta(List<EmbeddingDelta> deltas) {
    if (deltas.isEmpty) return [];
    
    // Find the maximum length delta
    int maxLength = 0;
    for (final delta in deltas) {
      if (delta.delta.length > maxLength) {
        maxLength = delta.delta.length;
      }
    }
    
    // Calculate average for each dimension
    final avgDelta = List<double>.filled(maxLength, 0.0);
    for (final delta in deltas) {
      for (int i = 0; i < delta.delta.length && i < maxLength; i++) {
        avgDelta[i] += delta.delta[i];
      }
    }
    
    // Divide by count to get average
    for (int i = 0; i < avgDelta.length; i++) {
      avgDelta[i] /= deltas.length;
    }
    
    return avgDelta;
  }
  
  /// Calculate magnitude of delta vector
  double _calculateDeltaMagnitude(List<double> delta) {
    if (delta.isEmpty) return 0.0;
    
    double sum = 0.0;
    for (final value in delta) {
      sum += value * value;
    }
    return math.sqrt(sum / delta.length);
  }
}

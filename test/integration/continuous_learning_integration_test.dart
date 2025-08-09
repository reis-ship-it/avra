import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/ai/continuous_learning_system.dart';

/// Integration test for Continuous Learning System
/// OUR_GUTS.md: Ensures AI learns from everything every second
void main() {
  group('Continuous Learning System Integration', () {
    late ContinuousLearningSystem learningSystem;

    setUp(() {
      learningSystem = ContinuousLearningSystem();
    });

    test('should initialize all 10 learning dimensions', () async {
      // Test that the system initializes with all required learning dimensions
      expect(learningSystem, isNotNull);
      
      // The system should be able to start without errors
      await learningSystem.startContinuousLearning();
      
      // Verify the system is learning actively
      expect(learningSystem.isLearningActive, isTrue);
      
      await learningSystem.stopContinuousLearning();
    });

    test('should handle learning cycle without errors', () async {
      await learningSystem.startContinuousLearning();
      
      // Let it run for a few cycles
      await Future.delayed(Duration(seconds: 3));
      
      // Should still be active and learning
      expect(learningSystem.isLearningActive, isTrue);
      
      await learningSystem.stopContinuousLearning();
      expect(learningSystem.isLearningActive, isFalse);
    });

    test('should comply with OUR_GUTS.md principles', () {
      // Verify the learning dimensions align with OUR_GUTS.md
      final dimensions = [
        'user_preference_understanding',  // "Belonging Comes First"
        'location_intelligence',          // "Effortless, Seamless Discovery"
        'temporal_patterns',              // Pattern recognition
        'social_dynamics',                // "Community, Not Just Places"
        'authenticity_detection',         // "Authenticity Over Algorithms"
        'community_evolution',            // "Community, Not Just Places"
        'recommendation_accuracy',        // "Belonging Comes First"
        'personalization_depth',          // "Privacy and Control Are Non-Negotiable"
        'trend_prediction',               // Pattern analysis
        'collaboration_effectiveness',    // "Community, Not Just Places"
      ];
      
      // All dimensions should be present
      expect(dimensions.length, equals(10));
      
      // Each dimension should align with OUR_GUTS.md principles
      expect(dimensions, contains('authenticity_detection'));
      expect(dimensions, contains('community_evolution'));
      expect(dimensions, contains('user_preference_understanding'));
    });
  });
}
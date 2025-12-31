import 'dart:developer' as developer;
import 'dart:math';
import 'package:spots_ai/models/personality_profile.dart';
import 'package:spots/core/ai/ai2ai_learning.dart';

/// Generates AI2AI learning recommendations
class LearningRecommendationsGenerator {
  static const String _logName = 'LearningRecommendationsGenerator';

  /// Identify optimal personality types for learning
  Future<List<OptimalPartner>> identifyOptimalLearningPartners(
    PersonalityProfile currentPersonality,
    List<CrossPersonalityLearningPattern> learningPatterns,
  ) async {
    try {
      developer.log(
          'Identifying optimal learning partners from ${learningPatterns.length} patterns',
          name: _logName);

      final partners = <OptimalPartner>[];

      // Analyze patterns to find compatible personality types
      // This is simplified - in production would analyze actual personality compatibility
      for (final pattern in learningPatterns.where((p) =>
          p.patternType == 'trust_building' || p.patternType == 'knowledge_sharing')) {
        // Extract participant information from pattern characteristics
        final participantCount = pattern.characteristics['unique_participants'] as int? ?? 0;
        final trustScore = pattern.strength;

        if (participantCount > 0 && trustScore >= 0.5) {
          // Create partner recommendation (simplified - would use actual personality data)
          partners.add(OptimalPartner(
            pattern.patternType,
            trustScore,
          ));
        }
      }

      // Sort by compatibility
      partners.sort((a, b) => b.compatibility.compareTo(a.compatibility));

      developer.log('Identified ${partners.length} optimal learning partners',
          name: _logName);
      return partners.take(5).toList(); // Return top 5
    } catch (e) {
      developer.log('Error identifying optimal partners: $e', name: _logName);
      return [];
    }
  }

  /// Generate conversation topics for maximum learning
  Future<List<LearningTopic>> generateLearningTopics(
    PersonalityProfile currentPersonality,
    List<CrossPersonalityLearningPattern> learningPatterns,
  ) async {
    try {
      developer.log('Generating learning topics from patterns',
          name: _logName);

      final topics = <LearningTopic>[];

      // Extract topics from patterns
      for (final pattern in learningPatterns) {
        if (pattern.patternType == 'knowledge_sharing') {
          final sharingScore = pattern.strength;
          final insightCount =
              pattern.characteristics['total_insights'] as int? ?? 0;

          if (sharingScore >= 0.3 && insightCount > 0) {
            topics.add(LearningTopic(
              pattern.patternType.replaceAll('_', ' '),
              sharingScore,
            ));
          }
        }
      }

      // Sort by potential
      topics.sort((a, b) => b.potential.compareTo(a.potential));

      developer.log('Generated ${topics.length} learning topics',
          name: _logName);
      return topics.take(10).toList(); // Return top 10
    } catch (e) {
      developer.log('Error generating learning topics: $e', name: _logName);
      return [];
    }
  }

  /// Recommend personality development areas
  Future<List<DevelopmentArea>> recommendDevelopmentAreas(
    PersonalityProfile currentPersonality,
    List<CrossPersonalityLearningPattern> learningPatterns,
  ) async {
    try {
      developer.log('Recommending development areas from patterns',
          name: _logName);

      final areas = <DevelopmentArea>[];

      // Analyze patterns for development opportunities
      for (final pattern in learningPatterns) {
        if (pattern.patternType == 'compatibility_evolution' ||
            pattern.patternType == 'learning_acceleration') {
          final evolutionRate =
              pattern.characteristics['evolution_rate'] as double? ??
                  pattern.strength;

          if (evolutionRate >= 0.2) {
            areas.add(DevelopmentArea(
              pattern.patternType.replaceAll('_', ' '),
              evolutionRate,
            ));
          }
        }
      }

      // Sort by priority (highest first) and return top 5
      areas.sort((a, b) => b.priority.compareTo(a.priority));
      developer.log('Recommended ${areas.length} development areas',
          name: _logName);
      return areas.take(5).toList();
    } catch (e) {
      developer.log('Error recommending development areas: $e',
          name: _logName);
      return [];
    }
  }

  /// Suggest optimal interaction timing and frequency
  Future<InteractionStrategy> suggestInteractionStrategy(
    String userId,
    List<CrossPersonalityLearningPattern> patterns,
  ) async {
    // Simplified - returns balanced strategy
    // In production, would analyze patterns to suggest optimal timing
    return InteractionStrategy.balanced();
  }

  /// Calculate expected outcomes from learning recommendations
  Future<List<ExpectedOutcome>> calculateExpectedOutcomes(
    PersonalityProfile personality,
    List<OptimalPartner> partners,
    List<LearningTopic> topics,
  ) async {
    try {
      final outcomes = <ExpectedOutcome>[];

      // Calculate expected outcomes based on partners and topics
      if (partners.isNotEmpty && topics.isNotEmpty) {
        final avgCompatibility = partners
                .map((p) => p.compatibility)
                .reduce((a, b) => a + b) /
            partners.length;

        final avgTopicPotential = topics
                .map((t) => t.potential)
                .reduce((a, b) => a + b) /
            topics.length;

        // Expected personality evolution
        final evolutionProbability =
            (avgCompatibility * 0.6 + avgTopicPotential * 0.4).clamp(0.0, 1.0);
        outcomes.add(ExpectedOutcome(
          id: 'personality_evolution',
          description: 'Personality evolution through AI2AI learning',
          probability: evolutionProbability,
        ));

        // Expected dimension development
        outcomes.add(ExpectedOutcome(
          id: 'dimension_development',
          description: 'Development of personality dimensions',
          probability: avgTopicPotential,
        ));

        // Expected trust building
        outcomes.add(ExpectedOutcome(
          id: 'trust_building',
          description: 'Building trust with AI2AI partners',
          probability: avgCompatibility * 0.8,
        ));
      }

      return outcomes;
    } catch (e) {
      developer.log('Error calculating expected outcomes: $e', name: _logName);
      return [];
    }
  }

  /// Calculate recommendation confidence score
  double calculateRecommendationConfidence(
      List<CrossPersonalityLearningPattern> patterns) =>
      min(1.0, patterns.length / 5.0);
}

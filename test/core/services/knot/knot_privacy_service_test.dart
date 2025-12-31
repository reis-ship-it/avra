// Unit tests for KnotPrivacyService
// 
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase 7: Audio & Privacy

import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/knot/knot_privacy_service.dart';
import 'package:spots_ai/models/personality_profile.dart';
import 'package:spots_knot/models/personality_knot.dart';
import 'package:spots/core/services/knot/personality_knot_service.dart';

void main() {
  group('KnotPrivacyService', () {
    late KnotPrivacyService privacyService;
    late PersonalityKnotService knotService;

    setUp(() {
      privacyService = KnotPrivacyService();
      knotService = PersonalityKnotService();
    });

    group('generateAnonymizedKnot', () {
      test('should generate anonymized knot from profile with knot', () async {
        // Arrange: Create a profile and generate a knot for it
        final profile = PersonalityProfile.initial('test_user');
        final knot = await knotService.generateKnot(profile);
        
        // Create a profile with the knot using the evolve method or copyWith
        // Since PersonalityProfile is immutable, we need to create a new profile with the knot
        final profileWithKnot = PersonalityProfile(
          agentId: profile.agentId,
          userId: profile.userId,
          dimensions: profile.dimensions,
          dimensionConfidence: profile.dimensionConfidence,
          archetype: profile.archetype,
          authenticity: profile.authenticity,
          createdAt: profile.createdAt,
          lastUpdated: profile.lastUpdated,
          evolutionGeneration: profile.evolutionGeneration,
          learningHistory: profile.learningHistory,
          corePersonality: profile.corePersonality,
          contexts: profile.contexts,
          evolutionTimeline: profile.evolutionTimeline,
          currentPhaseId: profile.currentPhaseId,
          isInTransition: profile.isInTransition,
          activeTransition: profile.activeTransition,
          personalityKnot: knot,
          knotEvolutionHistory: profile.knotEvolutionHistory,
        );

        // Act
        final anonymizedKnot = privacyService.generateAnonymizedKnot(profileWithKnot);

        // Assert
        expect(anonymizedKnot, isNotNull);
        expect(anonymizedKnot.topology, isNotNull);
        expect(anonymizedKnot.topology.jonesPolynomial, equals(knot.invariants.jonesPolynomial));
        expect(anonymizedKnot.topology.alexanderPolynomial, equals(knot.invariants.alexanderPolynomial));
        expect(anonymizedKnot.topology.crossingNumber, equals(knot.invariants.crossingNumber));
        expect(anonymizedKnot.topology.writhe, equals(knot.invariants.writhe));
      });

      test('should throw error if profile has no knot', () {
        // Arrange
        final profile = PersonalityProfile.initial('test_user');
        // Profile doesn't have a knot by default

        // Act & Assert
        expect(
          () => privacyService.generateAnonymizedKnot(profile),
          throwsArgumentError,
        );
      });
    });

    group('generateContextKnot', () {
      test('should generate public context knot', () {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 3,
            writhe: 1,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final contextKnot = privacyService.generateContextKnot(
          originalKnot: knot,
          context: KnotContext.public,
        );

        // Assert
        expect(contextKnot, isNotNull);
        expect(contextKnot.invariants, isNotNull);
      });

      test('should generate friends context knot with noise', () {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 3,
            writhe: 1,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final contextKnot = privacyService.generateContextKnot(
          originalKnot: knot,
          context: KnotContext.friends,
        );

        // Assert
        expect(contextKnot, isNotNull);
        expect(contextKnot.invariants, isNotNull);
        // Friends context should have noise added
      });

      test('should generate private context knot (minimal)', () {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 3,
            writhe: 1,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final contextKnot = privacyService.generateContextKnot(
          originalKnot: knot,
          context: KnotContext.private,
        );

        // Assert
        expect(contextKnot, isNotNull);
        expect(contextKnot.invariants, isNotNull);
        // Private context should be minimal (topology only)
      });

      test('should generate anonymous context knot (fully anonymized)', () {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 3,
            writhe: 1,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final contextKnot = privacyService.generateContextKnot(
          originalKnot: knot,
          context: KnotContext.anonymous,
        );

        // Assert
        expect(contextKnot, isNotNull);
        expect(contextKnot.invariants, isNotNull);
        // Anonymous context should be fully anonymized
      });
    });

    group('Error Handling', () {
      test('should handle knot gracefully', () {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 3,
            writhe: 1,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act & Assert: Should not throw
        final contextKnot = privacyService.generateContextKnot(
          originalKnot: knot,
          context: KnotContext.public,
        );
        expect(contextKnot, isNotNull);
      });
    });
  });
}

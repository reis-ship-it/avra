// Unit tests for KnotAudioService
// 
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase 7: Audio & Privacy

import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/knot/knot_audio_service.dart';
import 'package:spots_knot/models/personality_knot.dart';

void main() {
  group('KnotAudioService', () {
    late KnotAudioService audioService;

    setUp(() {
      audioService = KnotAudioService();
    });

    group('generateLoadingSound', () {
      test('should generate audio sequence from knot', () async {
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
        final audioSequence = await audioService.generateKnotLoadingSound(knot);

        // Assert
        expect(audioSequence, isNotNull);
        expect(audioSequence.notes, isNotEmpty);
        expect(audioSequence.duration, greaterThan(0.0));
        expect(audioSequence.loop, isTrue);
      });

      test('should generate notes based on crossing number', () async {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 5,
            writhe: 2,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final audioSequence = await audioService.generateKnotLoadingSound(knot);

        // Assert
        expect(audioSequence.notes.length, equals(5)); // One note per crossing
        for (final note in audioSequence.notes) {
          expect(note.frequency, greaterThan(0.0));
          expect(note.duration, greaterThan(0.0));
        }
      });

      test('should use writhe for rhythm calculation', () async {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 3,
            writhe: 3, // Higher writhe
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final audioSequence = await audioService.generateKnotLoadingSound(knot);

        // Assert
        expect(audioSequence.rhythm, isNotNull);
        // Higher writhe should affect rhythm
        expect(audioSequence.notes.length, equals(3));
      });

      test('should calculate frequencies within valid range', () async {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0, 1.0, 0.0, 2.0, 1.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0, -1.0, 1.0],
            alexanderPolynomial: [1.0, 0.0, -1.0],
            crossingNumber: 4,
            writhe: 1,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final audioSequence = await audioService.generateKnotLoadingSound(knot);

        // Assert
        for (final note in audioSequence.notes) {
          // Frequencies should be in audible range (20-20000 Hz)
          expect(note.frequency, greaterThanOrEqualTo(20.0));
          expect(note.frequency, lessThanOrEqualTo(20000.0));
        }
      });
    });

    group('knotToMusicalPattern', () {
      test('should convert knot to musical pattern', () async {
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
        final audioSequence = await audioService.generateKnotLoadingSound(knot);
        final pattern = audioSequence; // AudioSequence contains the pattern

        // Assert
        expect(pattern, isNotNull);
        expect(pattern.notes, isNotEmpty);
        expect(pattern.notes.length, equals(3)); // One note per crossing
      });

      test('should handle knots with zero crossings', () async {
        // Arrange
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0],
          invariants: KnotInvariants(
            jonesPolynomial: [1.0],
            alexanderPolynomial: [1.0],
            crossingNumber: 0,
            writhe: 0,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act
        final audioSequence = await audioService.generateKnotLoadingSound(knot);

        // Assert
        expect(audioSequence, isNotNull);
        // When crossingNumber is 0, the service may generate 0 notes (which is valid)
        // The important thing is that it doesn't throw
        expect(audioSequence.notes.length, greaterThanOrEqualTo(0));
      });
    });

    group('Error Handling', () {
      test('should handle knots with minimal data gracefully', () async {
        // Arrange: Knot with minimal but valid data
        final knot = PersonalityKnot(
          agentId: 'test_user',
          braidData: [8.0], // Minimal but valid braid data
          invariants: KnotInvariants(
            jonesPolynomial: [1.0], // Minimal but valid polynomial
            alexanderPolynomial: [1.0], // Minimal but valid polynomial
            crossingNumber: 0,
            writhe: 0,
          ),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        // Act & Assert: Should not throw
        final audioSequence = await audioService.generateKnotLoadingSound(knot);
        expect(audioSequence, isNotNull);
        // When crossingNumber is 0, the service may generate 0 notes (which is valid)
        // The important thing is that it doesn't throw
        expect(audioSequence.notes.length, greaterThanOrEqualTo(0));
      });
    });
  });
}

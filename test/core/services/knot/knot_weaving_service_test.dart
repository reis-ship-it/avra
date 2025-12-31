// Knot Weaving Service Tests
// 
// Tests for KnotWeavingService
// Part of Patent #31: Topological Knot Theory for Personality Representation
// Phase 2: Knot Weaving

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spots_knot/models/personality_knot.dart';
import 'package:spots_knot/models/knot/braided_knot.dart';
import 'package:spots/core/services/knot/knot_weaving_service.dart';
import 'package:spots/core/services/knot/personality_knot_service.dart';
import 'package:spots/core/services/knot/bridge/knot_math_bridge.dart/frb_generated.dart';

class MockPersonalityKnotService extends Mock implements PersonalityKnotService {}

void main() {
  group('KnotWeavingService Tests', () {
    late KnotWeavingService service;
    late MockPersonalityKnotService mockPersonalityKnotService;
    late PersonalityKnot knotA;
    late PersonalityKnot knotB;
    bool rustLibInitialized = false;

    setUpAll(() async {
      // Initialize Rust library for tests
      if (!rustLibInitialized) {
        try {
          await RustLib.init();
          rustLibInitialized = true;
        } catch (e) {
          // If already initialized, that's fine
          if (!e.toString().contains('Should not initialize')) {
            rethrow;
          }
          rustLibInitialized = true;
        }
      }
    });

    setUp(() {
      mockPersonalityKnotService = MockPersonalityKnotService();
      service = KnotWeavingService(
        personalityKnotService: mockPersonalityKnotService,
      );

      knotA = PersonalityKnot(
        agentId: 'agent-a',
        invariants: KnotInvariants(
          jonesPolynomial: [1.0, 2.0, 3.0],
          alexanderPolynomial: [1.0, 1.0],
          crossingNumber: 5,
          writhe: 2,
        ),
        braidData: [8.0, 0.0, 1.0, 1.0, 1.0],
        createdAt: DateTime(2025, 1, 1),
        lastUpdated: DateTime(2025, 1, 1),
      );

      knotB = PersonalityKnot(
        agentId: 'agent-b',
        invariants: KnotInvariants(
          jonesPolynomial: [2.0, 3.0, 4.0],
          alexanderPolynomial: [2.0, 2.0],
          crossingNumber: 6,
          writhe: 3,
        ),
        braidData: [8.0, 1.0, 1.0, 2.0, 1.0],
        createdAt: DateTime(2025, 1, 1),
        lastUpdated: DateTime(2025, 1, 1),
      );
    });

    test('should weave knots for friendship relationship type', () async {
      final braidedKnot = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      expect(braidedKnot, isNotNull);
      expect(braidedKnot.knotA, equals(knotA));
      expect(braidedKnot.knotB, equals(knotB));
      expect(braidedKnot.relationshipType, equals(RelationshipType.friendship));
      expect(braidedKnot.braidSequence, isNotEmpty);
      expect(braidedKnot.complexity, greaterThanOrEqualTo(0.0));
      expect(braidedKnot.complexity, lessThanOrEqualTo(1.0));
      expect(braidedKnot.stability, greaterThanOrEqualTo(0.0));
      expect(braidedKnot.stability, lessThanOrEqualTo(1.0));
      expect(braidedKnot.harmonyScore, greaterThanOrEqualTo(0.0));
      expect(braidedKnot.harmonyScore, lessThanOrEqualTo(1.0));
    });

    test('should weave knots for all relationship types', () async {
      final relationshipTypes = [
        RelationshipType.friendship,
        RelationshipType.mentorship,
        RelationshipType.romantic,
        RelationshipType.collaborative,
        RelationshipType.professional,
      ];

      for (final relationshipType in relationshipTypes) {
        final braidedKnot = await service.weaveKnots(
          knotA: knotA,
          knotB: knotB,
          relationshipType: relationshipType,
        );

        expect(braidedKnot.relationshipType, equals(relationshipType));
        expect(braidedKnot.braidSequence, isNotEmpty);
      }
    });

    test('should calculate weaving compatibility', () async {
      final compatibility = await service.calculateWeavingCompatibility(
        knotA: knotA,
        knotB: knotB,
      );

      expect(compatibility, greaterThanOrEqualTo(0.0));
      expect(compatibility, lessThanOrEqualTo(1.0));
    });

    test('should create braiding preview', () async {
      final preview = await service.previewBraiding(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      expect(preview, isNotNull);
      expect(preview.braidedKnot, isNotNull);
      expect(preview.complexity, greaterThanOrEqualTo(0.0));
      expect(preview.stability, greaterThanOrEqualTo(0.0));
      expect(preview.harmony, greaterThanOrEqualTo(0.0));
      expect(preview.compatibility, greaterThanOrEqualTo(0.0));
      expect(preview.relationshipType, equals('Friendship'));
    });

    test('should generate different braid sequences for different relationship types', () async {
      final friendshipBraid = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      final romanticBraid = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.romantic,
      );

      // Different relationship types should produce different braid sequences
      expect(friendshipBraid.braidSequence, isNot(equals(romanticBraid.braidSequence)));
    });

    test('should handle empty braid sequences gracefully', () async {
      final emptyKnotA = PersonalityKnot(
        agentId: 'agent-a',
        invariants: KnotInvariants(
          jonesPolynomial: [],
          alexanderPolynomial: [],
          crossingNumber: 0,
          writhe: 0,
        ),
        braidData: [8.0], // Only strand count
        createdAt: DateTime(2025, 1, 1),
        lastUpdated: DateTime(2025, 1, 1),
      );

      final emptyKnotB = PersonalityKnot(
        agentId: 'agent-b',
        invariants: KnotInvariants(
          jonesPolynomial: [],
          alexanderPolynomial: [],
          crossingNumber: 0,
          writhe: 0,
        ),
        braidData: [8.0], // Only strand count
        createdAt: DateTime(2025, 1, 1),
        lastUpdated: DateTime(2025, 1, 1),
      );

      final braidedKnot = await service.weaveKnots(
        knotA: emptyKnotA,
        knotB: emptyKnotB,
        relationshipType: RelationshipType.friendship,
      );

      expect(braidedKnot, isNotNull);
      expect(braidedKnot.braidSequence, isNotEmpty);
    });

    test('should produce consistent results for same inputs', () async {
      final braid1 = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      final braid2 = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      // Same inputs should produce same braid sequence
      expect(braid1.braidSequence, equals(braid2.braidSequence));
      expect(braid1.complexity, equals(braid2.complexity));
      expect(braid1.stability, equals(braid2.stability));
      expect(braid1.harmonyScore, equals(braid2.harmonyScore));
    });

    test('should calculate complexity based on crossing count', () async {
      final braidedKnot = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      // Complexity should be normalized to [0, 1]
      expect(braidedKnot.complexity, greaterThanOrEqualTo(0.0));
      expect(braidedKnot.complexity, lessThanOrEqualTo(1.0));
    });

    test('should calculate stability based on topological compatibility', () async {
      final braidedKnot = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      // Stability should be normalized to [0, 1]
      expect(braidedKnot.stability, greaterThanOrEqualTo(0.0));
      expect(braidedKnot.stability, lessThanOrEqualTo(1.0));
    });

    test('should calculate harmony based on relationship type', () async {
      final friendshipBraid = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.friendship,
      );

      final romanticBraid = await service.weaveKnots(
        knotA: knotA,
        knotB: knotB,
        relationshipType: RelationshipType.romantic,
      );

      // Different relationship types may have different harmony scores
      expect(friendshipBraid.harmonyScore, greaterThanOrEqualTo(0.0));
      expect(romanticBraid.harmonyScore, greaterThanOrEqualTo(0.0));
    });
  });
}

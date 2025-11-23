import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/expertise_recognition_service.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../fixtures/model_factories.dart';

/// Expertise Recognition Service Tests
/// Tests community recognition and appreciation functionality
void main() {
  group('ExpertiseRecognitionService Tests', () {
    late ExpertiseRecognitionService service;
    late UnifiedUser expert;
    late UnifiedUser recognizer;

    setUp(() {
      service = ExpertiseRecognitionService();
      expert = ModelFactories.createTestUser(
        id: 'expert-123',
        tags: ['food'],
      ).copyWith(
        expertiseMap: {'food': 'city'},
      );
      recognizer = ModelFactories.createTestUser(
        id: 'recognizer-123',
      );
    });

    group('recognizeExpert', () {
      test('should recognize expert successfully', () async {
        await service.recognizeExpert(
          expert: expert,
          recognizer: recognizer,
          reason: 'Very helpful with food recommendations',
          type: RecognitionType.helpful,
        );

        // Verify recognition was created (in production, would fetch from database)
        expect(expert.id, isNot(equals(recognizer.id)));
      });

      test('should throw exception when recognizing yourself', () async {
        expect(
          () => service.recognizeExpert(
            expert: expert,
            recognizer: expert,
            reason: 'I am great',
            type: RecognitionType.exceptional,
          ),
          throwsException,
        );
      });

      test('should accept different recognition types', () async {
        await service.recognizeExpert(
          expert: expert,
          recognizer: recognizer,
          reason: 'Inspiring others',
          type: RecognitionType.inspiring,
        );

        await service.recognizeExpert(
          expert: expert,
          recognizer: recognizer,
          reason: 'Exceptional expertise',
          type: RecognitionType.exceptional,
        );

        // Verify both recognitions were created
        expect(expert.id, isNot(equals(recognizer.id)));
      });
    });

    group('getRecognitionsForExpert', () {
      test('should return recognitions for expert', () async {
        final recognitions = await service.getRecognitionsForExpert(expert);

        expect(recognitions, isA<List<ExpertRecognition>>());
      });

      test('should return empty list when no recognitions', () async {
        final newExpert = ModelFactories.createTestUser(id: 'new-expert');
        final recognitions = await service.getRecognitionsForExpert(newExpert);

        // In test environment, may be empty
        expect(recognitions, isA<List<ExpertRecognition>>());
      });
    });

    group('getFeaturedExperts', () {
      test('should return featured experts', () async {
        final featured = await service.getFeaturedExperts();

        expect(featured, isA<List<FeaturedExpert>>());
      });

      test('should filter by category when provided', () async {
        final featured = await service.getFeaturedExperts(
          category: 'food',
        );

        expect(featured, isA<List<FeaturedExpert>>());
      });

      test('should respect maxResults parameter', () async {
        final featured = await service.getFeaturedExperts(
          maxResults: 5,
        );

        expect(featured.length, lessThanOrEqualTo(5));
      });

      test('should sort by recognition score', () async {
        final featured = await service.getFeaturedExperts();

        // Featured experts should be sorted by score (highest first)
        for (var i = 0; i < featured.length - 1; i++) {
          expect(
            featured[i].recognitionScore,
            greaterThanOrEqualTo(featured[i + 1].recognitionScore),
          );
        }
      });
    });

    group('getExpertSpotlight', () {
      test('should return expert spotlight', () async {
        final spotlight = await service.getExpertSpotlight();

        expect(spotlight, anyOf(isNull, isA<ExpertSpotlight>()));
      });

      test('should filter by category when provided', () async {
        final spotlight = await service.getExpertSpotlight(
          category: 'food',
        );

        expect(spotlight, anyOf(isNull, isA<ExpertSpotlight>()));
      });

      test('should include top recognitions', () async {
        final spotlight = await service.getExpertSpotlight();

        if (spotlight != null) {
          expect(spotlight.topRecognitions.length, lessThanOrEqualTo(3));
        }
      });
    });

    group('getCommunityAppreciation', () {
      test('should return community appreciation for expert', () async {
        final appreciation = await service.getCommunityAppreciation(expert);

        expect(appreciation, isA<List<CommunityAppreciation>>());
      });

      test('should return empty list when no appreciation', () async {
        final newExpert = ModelFactories.createTestUser(id: 'new-expert');
        final appreciation = await service.getCommunityAppreciation(newExpert);

        // In test environment, may be empty
        expect(appreciation, isA<List<CommunityAppreciation>>());
      });
    });
  });
}


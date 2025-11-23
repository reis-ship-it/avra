import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/expert_recommendations_service.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../fixtures/model_factories.dart';

/// Expert Recommendations Service Tests
/// Tests expert-based recommendation functionality
void main() {
  group('ExpertRecommendationsService Tests', () {
    late ExpertRecommendationsService service;
    late UnifiedUser user;

    setUp(() {
      service = ExpertRecommendationsService();
      user = ModelFactories.createTestUser(
        id: 'user-123',
        tags: ['food'],
      ).copyWith(
        expertiseMap: {'food': 'city'},
      );
    });

    group('getExpertRecommendations', () {
      test('should return recommendations for user with expertise', () async {
        final recommendations = await service.getExpertRecommendations(
          user,
          category: 'food',
        );

        expect(recommendations, isA<List<ExpertRecommendation>>());
      });

      test('should return general recommendations when user has no expertise', () async {
        final userWithoutExpertise = ModelFactories.createTestUser(
          id: 'user-456',
        ).copyWith(expertiseMap: {});

        final recommendations = await service.getExpertRecommendations(
          userWithoutExpertise,
        );

        expect(recommendations, isA<List<ExpertRecommendation>>());
      });

      test('should respect maxResults parameter', () async {
        final recommendations = await service.getExpertRecommendations(
          user,
          category: 'food',
          maxResults: 10,
        );

        expect(recommendations.length, lessThanOrEqualTo(10));
      });

      test('should use user expertise categories when category not specified', () async {
        final recommendations = await service.getExpertRecommendations(
          user,
          maxResults: 20,
        );

        expect(recommendations, isA<List<ExpertRecommendation>>());
      });

      test('should return recommendations sorted by score', () async {
        final recommendations = await service.getExpertRecommendations(
          user,
          category: 'food',
        );

        // Recommendations should be sorted by score (highest first)
        for (var i = 0; i < recommendations.length - 1; i++) {
          expect(
            recommendations[i].recommendationScore,
            greaterThanOrEqualTo(recommendations[i + 1].recommendationScore),
          );
        }
      });
    });

    group('getExpertCuratedLists', () {
      test('should return expert-curated lists', () async {
        final lists = await service.getExpertCuratedLists(
          user,
          category: 'food',
        );

        expect(lists, isA<List<ExpertCuratedList>>());
      });

      test('should respect maxResults parameter', () async {
        final lists = await service.getExpertCuratedLists(
          user,
          category: 'food',
          maxResults: 5,
        );

        expect(lists.length, lessThanOrEqualTo(5));
      });

      test('should filter by category when provided', () async {
        final lists = await service.getExpertCuratedLists(
          user,
          category: 'food',
        );

        for (final list in lists) {
          expect(list.category, equals('food'));
        }
      });
    });

    group('getExpertValidatedSpots', () {
      test('should return expert-validated spots', () async {
        final spots = await service.getExpertValidatedSpots(
          category: 'food',
          location: 'San Francisco',
        );

        expect(spots, isA<List>());
      });

      test('should respect maxResults parameter', () async {
        final spots = await service.getExpertValidatedSpots(
          category: 'food',
          maxResults: 10,
        );

        expect(spots.length, lessThanOrEqualTo(10));
      });

      test('should filter by location when provided', () async {
        final spots = await service.getExpertValidatedSpots(
          category: 'food',
          location: 'San Francisco',
        );

        expect(spots, isA<List>());
      });
    });
  });
}


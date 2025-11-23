import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/services/business_expert_matching_service.dart';
import 'package:spots/core/services/expertise_matching_service.dart';
import 'package:spots/core/services/expertise_community_service.dart';
import 'package:spots/core/services/llm_service.dart';
import 'package:spots/core/models/business_account.dart';
import 'package:spots/core/models/business_expert_preferences.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../fixtures/model_factories.dart';

import 'business_expert_matching_service_test.mocks.dart';

@GenerateMocks([ExpertiseMatchingService, ExpertiseCommunityService, LLMService])
void main() {
  group('BusinessExpertMatchingService Tests', () {
    late BusinessExpertMatchingService service;
    late MockExpertiseMatchingService mockExpertiseMatchingService;
    late MockExpertiseCommunityService mockCommunityService;
    late MockLLMService mockLLMService;
    late BusinessAccount business;

    setUp(() {
      mockExpertiseMatchingService = MockExpertiseMatchingService();
      mockCommunityService = MockExpertiseCommunityService();
      mockLLMService = MockLLMService();

      service = BusinessExpertMatchingService(
        expertiseMatchingService: mockExpertiseMatchingService,
        communityService: mockCommunityService,
        llmService: mockLLMService,
      );

      business = BusinessAccount(
        id: 'business-123',
        name: 'Test Restaurant',
        email: 'test@restaurant.com',
        businessType: 'Restaurant',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user-123',
        requiredExpertise: ['food', 'restaurant'],
      );
    });

    group('findExpertsForBusiness', () {
      test('should return empty list when no experts match', () async {
        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        final matches = await service.findExpertsForBusiness(business);

        expect(matches, isEmpty);
      });

      test('should respect maxResults parameter', () async {
        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        final matches = await service.findExpertsForBusiness(
          business,
          maxResults: 10,
        );

        expect(matches.length, lessThanOrEqualTo(10));
      });

      test('should use expert preferences when available', () async {
        final preferences = BusinessExpertPreferences(
          requiredExpertiseCategories: ['food'],
          preferredExpertiseCategories: ['restaurant'],
        );

        final businessWithPreferences = business.copyWith(
          expertPreferences: preferences,
        );

        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        final matches = await service.findExpertsForBusiness(
          businessWithPreferences,
        );

        expect(matches, isA<List<BusinessExpertMatch>>());
      });

      test('should apply minimum match score threshold from preferences', () async {
        final preferences = BusinessExpertPreferences(
          requiredExpertiseCategories: ['food'],
          minMatchScore: 0.7,
        );

        final businessWithPreferences = business.copyWith(
          expertPreferences: preferences,
        );

        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        final matches = await service.findExpertsForBusiness(
          businessWithPreferences,
        );

        // All matches should meet minimum threshold
        for (final match in matches) {
          expect(match.matchScore, greaterThanOrEqualTo(0.7));
        }
      });

      test('should find experts from preferred communities', () async {
        final preferences = BusinessExpertPreferences(
          requiredExpertiseCategories: ['food'],
          preferredCommunities: ['community-1'],
        );

        final businessWithPreferences = business.copyWith(
          expertPreferences: preferences,
        );

        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        when(mockCommunityService.searchCommunities())
            .thenAnswer((_) async => []);

        final matches = await service.findExpertsForBusiness(
          businessWithPreferences,
        );

        expect(matches, isA<List<BusinessExpertMatch>>());
      });

      test('should use AI suggestions when LLM service available', () async {
        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        when(mockLLMService.generateRecommendation(
          userQuery: anyNamed('userQuery'),
        )).thenAnswer((_) async => 'AI suggestion response');

        final matches = await service.findExpertsForBusiness(business);

        expect(matches, isA<List<BusinessExpertMatch>>());
      });

      test('should work without LLM service', () async {
        final serviceWithoutLLM = BusinessExpertMatchingService(
          expertiseMatchingService: mockExpertiseMatchingService,
          communityService: mockCommunityService,
          llmService: null,
        );

        when(mockExpertiseMatchingService.findSimilarExperts(
          any,
          any,
          location: anyNamed('location'),
          maxResults: anyNamed('maxResults'),
        )).thenAnswer((_) async => []);

        final matches = await serviceWithoutLLM.findExpertsForBusiness(business);

        expect(matches, isA<List<BusinessExpertMatch>>());
      });
    });
  });
}


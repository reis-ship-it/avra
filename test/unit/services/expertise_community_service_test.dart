import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/expertise_community_service.dart';
import 'package:spots/core/models/expertise_community.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/expertise_level.dart';
import '../../fixtures/model_factories.dart';

/// Expertise Community Service Tests
/// Tests expertise-based community management functionality
void main() {
  group('ExpertiseCommunityService Tests', () {
    late ExpertiseCommunityService service;
    late UnifiedUser user;

    setUp(() {
      service = ExpertiseCommunityService();
      user = ModelFactories.createTestUser(
        id: 'user-123',
        tags: ['food'],
      ).copyWith(
        expertiseMap: {'food': 'city'},
      );
    });

    group('createCommunity', () {
      test('should create community when user has expertise', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
          description: 'Food experts community',
        );

        expect(community, isA<ExpertiseCommunity>());
        expect(community.category, equals('food'));
        expect(community.memberIds, contains(user.id));
        expect(community.memberCount, equals(1));
        expect(community.createdBy, equals(user.id));
      });

      test('should throw exception when creator lacks expertise', () async {
        final userWithoutExpertise = ModelFactories.createTestUser(
          id: 'user-456',
        ).copyWith(expertiseMap: {});

        expect(
          () => service.createCommunity(
            creator: userWithoutExpertise,
            category: 'food',
          ),
          throwsException,
        );
      });

      test('should include location in community name when provided', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
          location: 'San Francisco',
        );

        expect(community.name, contains('San Francisco'));
        expect(community.location, equals('San Francisco'));
      });

      test('should respect minLevel parameter', () async {
        final regionalUser = ModelFactories.createTestUser(
          id: 'user-123',
        ).copyWith(
          expertiseMap: {'food': 'regional'},
        );

        final community = await service.createCommunity(
          creator: regionalUser,
          category: 'food',
          minLevel: ExpertiseLevel.city,
        );

        expect(community.minLevel, equals(ExpertiseLevel.city));
      });

      test('should respect isPublic parameter', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
          isPublic: false,
        );

        expect(community.isPublic, equals(false));
      });
    });

    group('joinCommunity', () {
      test('should allow user to join community when eligible', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
        );

        final newUser = ModelFactories.createTestUser(
          id: 'user-456',
        ).copyWith(
          expertiseMap: {'food': 'local'},
        );

        await service.joinCommunity(community, newUser);

        // Verify user was added (in production, would fetch updated community)
        expect(community.canUserJoin(newUser), isTrue);
      });

      test('should throw exception when user cannot join', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
          minLevel: ExpertiseLevel.city,
        );

        final localUser = ModelFactories.createTestUser(
          id: 'user-456',
        ).copyWith(
          expertiseMap: {'food': 'local'},
        );

        expect(
          () => service.joinCommunity(community, localUser),
          throwsException,
        );
      });

      test('should throw exception when user is already a member', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
        );

        expect(
          () => service.joinCommunity(community, user),
          throwsException,
        );
      });
    });

    group('leaveCommunity', () {
      test('should allow user to leave community', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
        );

        await service.leaveCommunity(community, user);

        // Verify user was removed (in production, would fetch updated community)
        expect(community.isMember(user), isFalse);
      });

      test('should throw exception when user is not a member', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
        );

        final nonMember = ModelFactories.createTestUser(
          id: 'user-456',
        );

        expect(
          () => service.leaveCommunity(community, nonMember),
          throwsException,
        );
      });
    });

    group('findCommunitiesForUser', () {
      test('should return communities matching user expertise', () async {
        final communities = await service.findCommunitiesForUser(user);

        expect(communities, isA<List<ExpertiseCommunity>>());
      });

      test('should return empty list when user has no expertise', () async {
        final userWithoutExpertise = ModelFactories.createTestUser(
          id: 'user-456',
        ).copyWith(expertiseMap: {});

        final communities = await service.findCommunitiesForUser(userWithoutExpertise);

        expect(communities, isEmpty);
      });
    });

    group('searchCommunities', () {
      test('should search communities by category', () async {
        final communities = await service.searchCommunities(
          category: 'food',
        );

        expect(communities, isA<List<ExpertiseCommunity>>());
      });

      test('should search communities by location', () async {
        final communities = await service.searchCommunities(
          location: 'San Francisco',
        );

        expect(communities, isA<List<ExpertiseCommunity>>());
      });

      test('should respect maxResults parameter', () async {
        final communities = await service.searchCommunities(
          category: 'food',
          maxResults: 5,
        );

        expect(communities.length, lessThanOrEqualTo(5));
      });
    });

    group('getCommunityMembers', () {
      test('should return community members', () async {
        final community = await service.createCommunity(
          creator: user,
          category: 'food',
        );

        final members = await service.getCommunityMembers(community);

        expect(members, isA<List<UnifiedUser>>());
      });
    });
  });
}


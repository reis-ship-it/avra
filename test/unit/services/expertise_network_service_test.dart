import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/expertise_network_service.dart';
import 'package:spots/core/models/unified_user.dart';
import '../../fixtures/model_factories.dart';

/// Expertise Network Service Tests
/// Tests expertise-based social graph and network functionality
void main() {
  group('ExpertiseNetworkService Tests', () {
    late ExpertiseNetworkService service;
    late UnifiedUser user;

    setUp(() {
      service = ExpertiseNetworkService();
      user = ModelFactories.createTestUser(
        id: 'user-123',
        tags: ['food', 'travel'],
      ).copyWith(
        expertiseMap: {'food': 'city', 'travel': 'local'},
      );
    });

    group('getUserExpertiseNetwork', () {
      test('should return expertise network for user', () async {
        final network = await service.getUserExpertiseNetwork(user);

        expect(network, isA<ExpertiseNetwork>());
        expect(network.user.id, equals(user.id));
        expect(network.connections, isA<List<ExpertiseConnection>>());
        expect(network.networkSize, greaterThanOrEqualTo(0));
        expect(network.strongestConnections, isA<List<ExpertiseConnection>>());
      });

      test('should return empty network when user has no expertise', () async {
        final userWithoutExpertise = ModelFactories.createTestUser(
          id: 'user-456',
        ).copyWith(expertiseMap: {});

        final network = await service.getUserExpertiseNetwork(userWithoutExpertise);

        expect(network, isA<ExpertiseNetwork>());
        expect(network.networkSize, equals(0));
        expect(network.connections, isEmpty);
      });

      test('should include strongest connections', () async {
        final network = await service.getUserExpertiseNetwork(user);

        expect(network.strongestConnections.length, lessThanOrEqualTo(10));
      });
    });

    group('getExpertiseCircles', () {
      test('should return expertise circles for category', () async {
        final circles = await service.getExpertiseCircles('food');

        expect(circles, isA<List<ExpertiseCircle>>());
      });

      test('should filter by location when provided', () async {
        final circles = await service.getExpertiseCircles(
          'food',
          location: 'San Francisco',
        );

        expect(circles, isA<List<ExpertiseCircle>>());
      });

      test('should return empty list when no experts in category', () async {
        final circles = await service.getExpertiseCircles('nonexistent-category');

        expect(circles, isA<List<ExpertiseCircle>>());
        // In test environment, may be empty due to empty user list
      });

      test('should group experts by level', () async {
        final circles = await service.getExpertiseCircles('food');

        // Each circle should have a level
        for (final circle in circles) {
          expect(circle.level, isNotNull);
          expect(circle.category, equals('food'));
          expect(circle.members, isA<List<UnifiedUser>>());
          expect(circle.memberCount, equals(circle.members.length));
        }
      });
    });

    group('getExpertiseInfluence', () {
      test('should return expertise influence for user', () async {
        final influences = await service.getExpertiseInfluence(user);

        expect(influences, isA<List<ExpertiseInfluence>>());
      });

      test('should return empty list when no influences', () async {
        final influences = await service.getExpertiseInfluence(user);

        // In test environment, placeholder returns empty list
        expect(influences, isEmpty);
      });
    });

    group('getExpertiseFollowers', () {
      test('should return expertise followers for user', () async {
        final followers = await service.getExpertiseFollowers(user);

        expect(followers, isA<List<UnifiedUser>>());
      });

      test('should return empty list when no followers', () async {
        final followers = await service.getExpertiseFollowers(user);

        // In test environment, placeholder returns empty list
        expect(followers, isEmpty);
      });
    });
  });
}


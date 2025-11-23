import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/domain/repositories/spots_repository.dart';
import 'package:spots/domain/usecases/spots/get_spots_from_respected_lists_usecase.dart';

import 'get_spots_from_respected_lists_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([SpotsRepository])
void main() {
  group('GetSpotsFromRespectedListsUseCase', () {
    late GetSpotsFromRespectedListsUseCase usecase;
    late MockSpotsRepository mockRepository;
    late List<Spot> respectedSpots;

    setUp(() {
      mockRepository = MockSpotsRepository();
      usecase = GetSpotsFromRespectedListsUseCase(mockRepository);
      
      // OUR_GUTS.md: "Community, Not Just Places" - Test respected community spots
      respectedSpots = [
        Spot(
          id: 'respected_spot_1',
          name: 'Community Garden',
          description: 'Beloved local community garden maintained by neighbors',
          latitude: 40.7589,
          longitude: -73.9851,
          category: 'park',
          rating: 4.9,
          createdBy: 'community_leader_1',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 15),
          address: '456 Community Ave, New York, NY',
          tags: ['community', 'organic', 'educational'],
          metadata: {
            'verified': true,
            'community_endorsed': true,
            'respect_count': 127,
            'curator_verified': true,
            'local_favorite': true,
          },
        ),
        Spot(
          id: 'respected_spot_2',
          name: 'Local Bookstore Café',
          description: 'Independent bookstore with amazing coffee, supported by the community',
          latitude: 40.7505,
          longitude: -73.9934,
          category: 'cafe',
          rating: 4.8,
          createdBy: 'local_curator_2',
          createdAt: DateTime(2024, 1, 5),
          updatedAt: DateTime(2024, 1, 20),
          address: '789 Literature Lane, New York, NY',
          tags: ['books', 'coffee', 'local_business', 'cozy'],
          metadata: {
            'verified': true,
            'community_endorsed': true,
            'respect_count': 89,
            'support_local': true,
            'quiet_work_space': true,
          },
        ),
        Spot(
          id: 'respected_spot_3',
          name: 'Neighborhood Art Wall',
          description: 'Street art wall where local artists showcase their work legally',
          latitude: 40.7282,
          longitude: -73.9942,
          category: 'art',
          rating: 4.6,
          createdBy: 'art_enthusiast_3',
          createdAt: DateTime(2024, 1, 10),
          updatedAt: DateTime(2024, 1, 25),
          address: 'Art Alley, Brooklyn, NY',
          tags: ['street_art', 'local_artists', 'photography'],
          metadata: {
            'verified': true,
            'community_endorsed': true,
            'respect_count': 156,
            'rotating_exhibits': true,
            'artist_supported': true,
          },
        ),
      ];
    });

    group('Successful retrieval of respected spots', () {
      test('should return spots from respected lists successfully', () async {
        // Arrange
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => respectedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, equals(respectedSpots));
        expect(result, hasLength(3));
        expect(result[0].name, equals('Community Garden'));
        expect(result[1].name, equals('Local Bookstore Café'));
        expect(result[2].name, equals('Neighborhood Art Wall'));
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no respected spots exist', () async {
        // Arrange
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => <Spot>[]);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Spot>>());
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should return single respected spot in list', () async {
        // Arrange
        final singleRespectedSpot = [respectedSpots.first];
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => singleRespectedSpot);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(1));
        expect(result.first, equals(respectedSpots.first));
        expect(result.first.metadata['community_endorsed'], isTrue);
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should preserve all respected spot properties', () async {
        // Arrange
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => respectedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        final firstSpot = result.first;
        expect(firstSpot.id, equals('respected_spot_1'));
        expect(firstSpot.name, equals('Community Garden'));
        expect(firstSpot.description, contains('community'));
        expect(firstSpot.latitude, equals(40.7589));
        expect(firstSpot.longitude, equals(-73.9851));
        expect(firstSpot.category, equals('park'));
        expect(firstSpot.rating, equals(4.9));
        expect(firstSpot.createdBy, equals('community_leader_1'));
        expect(firstSpot.tags, contains('community'));
        expect(firstSpot.metadata['verified'], isTrue);
        expect(firstSpot.metadata['community_endorsed'], isTrue);
        expect(firstSpot.metadata['respect_count'], equals(127));
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should return spots with high community engagement', () async {
        // Arrange
        final highEngagementSpots = respectedSpots.map((spot) {
          final currentRespectCount = spot.metadata['respect_count'] as int;
          final updatedMetadata = Map<String, dynamic>.from(spot.metadata);
          updatedMetadata.addAll({
            'respect_count': currentRespectCount + 50,
            'community_comments': (currentRespectCount * 0.3).round(),
            'local_recommendations': (currentRespectCount * 0.5).round(),
          });
          return spot.copyWith(metadata: updatedMetadata);
        }).toList();

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => highEngagementSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        for (final spot in result) {
          expect(spot.metadata['respect_count'], greaterThan(130));
          expect(spot.metadata['community_comments'], isA<int>());
          expect(spot.metadata['local_recommendations'], isA<int>());
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });
    });

    group('Community-focused edge cases', () {
      test('should handle spots with different levels of community respect', () async {
        // Arrange
        final varyingRespectSpots = [
          respectedSpots[0].copyWith(
            metadata: Map.from(respectedSpots[0].metadata)..['respect_count'] = 10,
          ),
          respectedSpots[1].copyWith(
            metadata: Map.from(respectedSpots[1].metadata)..['respect_count'] = 500,
          ),
          respectedSpots[2].copyWith(
            metadata: Map.from(respectedSpots[2].metadata)..['respect_count'] = 1000,
          ),
        ];

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => varyingRespectSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].metadata['respect_count'], equals(10));
        expect(result[1].metadata['respect_count'], equals(500));
        expect(result[2].metadata['respect_count'], equals(1000));
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle spots from different community types', () async {
        // Arrange
        final diverseCommunitySpots = [
          respectedSpots[0].copyWith(
            tags: ['residential_community', 'family_friendly'],
            metadata: Map.from(respectedSpots[0].metadata)..addAll({
              'community_type': 'residential',
              'age_groups': ['families', 'seniors'],
            }),
          ),
          respectedSpots[1].copyWith(
            tags: ['student_community', 'study_space'],
            metadata: Map.from(respectedSpots[1].metadata)..addAll({
              'community_type': 'academic',
              'age_groups': ['students', 'young_professionals'],
            }),
          ),
          respectedSpots[2].copyWith(
            tags: ['artist_community', 'creative_space'],
            metadata: Map.from(respectedSpots[2].metadata)..addAll({
              'community_type': 'creative',
              'age_groups': ['artists', 'creatives', 'all_ages'],
            }),
          ),
        ];

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => diverseCommunitySpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].metadata['community_type'], equals('residential'));
        expect(result[1].metadata['community_type'], equals('academic'));
        expect(result[2].metadata['community_type'], equals('creative'));
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle spots with community validation metadata', () async {
        // Arrange
        final validatedSpots = respectedSpots.map((spot) => spot.copyWith(
          metadata: Map.from(spot.metadata)..addAll({
            'curator_verified': true,
            'community_validated': true,
            'validation_date': '2024-01-15T10:30:00Z',
            'validator_count': 5,
            'validation_score': 0.95,
            'authenticity_rating': 'high',
          }),
        )).toList();

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => validatedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        for (final spot in result) {
          expect(spot.metadata['curator_verified'], isTrue);
          expect(spot.metadata['community_validated'], isTrue);
          expect(spot.metadata['validation_score'], equals(0.95));
          expect(spot.metadata['authenticity_rating'], equals('high'));
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle spots with temporal community data', () async {
        // Arrange
        final temporalSpots = respectedSpots.map((spot) => spot.copyWith(
          metadata: Map.from(spot.metadata)..addAll({
            'trending_since': '2024-01-01',
            'peak_respect_period': '2024-01-15_to_2024-01-25',
            'seasonal_popularity': {
              'spring': 0.8,
              'summer': 0.9,
              'fall': 0.7,
              'winter': 0.6,
            },
            'recent_activity_score': 0.85,
          }),
        )).toList();

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => temporalSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        for (final spot in result) {
          expect(spot.metadata['trending_since'], isNotNull);
          expect(spot.metadata['seasonal_popularity'], isA<Map>());
          expect(spot.metadata['recent_activity_score'], equals(0.85));
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });
    });

    group('Large dataset handling', () {
      test('should handle large list of respected spots', () async {
        // Arrange
        final largeRespectedList = List.generate(500, (index) => Spot(
          id: 'respected_spot_$index',
          name: 'Community Spot $index',
          description: 'Well-respected community spot number $index',
          latitude: 40.0 + (index * 0.001),
          longitude: -74.0 + (index * 0.001),
          category: ['park', 'cafe', 'art', 'community'][index % 4],
          rating: 4.0 + (index % 10) * 0.1,
          createdBy: 'community_member_$index',
          createdAt: DateTime(2024, 1, (index % 30) + 1),
          updatedAt: DateTime(2024, 1, (index % 30) + 1),
          tags: ['community', 'respected', 'category_${index % 4}'],
          metadata: {
            'verified': true,
            'community_endorsed': true,
            'respect_count': 50 + (index * 2),
            'curator_verified': index % 3 == 0,
          },
        ));

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => largeRespectedList);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(500));
        expect(result.first.id, equals('respected_spot_0'));
        expect(result.last.id, equals('respected_spot_499'));
        for (final spot in result) {
          expect(spot.metadata['community_endorsed'], isTrue);
          expect(spot.metadata['respect_count'], greaterThan(49));
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should preserve complex metadata in large datasets', () async {
        // Arrange
        final complexMetadataSpots = List.generate(100, (index) => Spot(
          id: 'complex_spot_$index',
          name: 'Complex Spot $index',
          description: 'Spot with complex metadata $index',
          latitude: 40.7128,
          longitude: -74.0060,
          category: 'test',
          rating: 4.5,
          createdBy: 'user_$index',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {
            'respect_count': index * 10,
            'community_data': {
              'engagement_metrics': {
                'daily_visits': index * 2,
                'weekly_visits': index * 14,
                'monthly_visits': index * 60,
              },
              'user_demographics': {
                'age_ranges': ['18-25', '26-35', '36-45'],
                'interests': ['food', 'art', 'nature'],
              },
              'feedback_scores': {
                'cleanliness': 0.8 + (index % 10) * 0.02,
                'accessibility': 0.7 + (index % 15) * 0.02,
                'atmosphere': 0.9 + (index % 5) * 0.02,
              },
            },
            'verification_data': {
              'verifiers': List.generate(index % 5 + 1, (i) => 'verifier_$i'),
              'verification_timestamps': List.generate(
                index % 3 + 1, 
                (i) => DateTime.now().subtract(Duration(days: i)).toIso8601String(),
              ),
            },
          },
        ));

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => complexMetadataSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(100));
        for (int i = 0; i < result.length; i++) {
          final spot = result[i];
          expect(spot.metadata['respect_count'], equals(i * 10));
          expect(spot.metadata['community_data'], isA<Map>());
          expect(spot.metadata['verification_data'], isA<Map>());
          expect(spot.metadata['community_data']['engagement_metrics'], isA<Map>());
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });
    });

    group('Error handling', () {
      test('should throw exception when repository throws exception', () async {
        // Arrange
        final exception = Exception('Failed to load respected lists');
        when(mockRepository.getSpotsFromRespectedLists())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(exception),
        );
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle network timeout for respected lists', () async {
        // Arrange
        final timeoutError = Exception('Network timeout while loading respected spots');
        when(mockRepository.getSpotsFromRespectedLists())
            .thenThrow(timeoutError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(timeoutError),
        );
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle permission denied for respected lists access', () async {
        // Arrange
        final permissionError = Exception('Insufficient permissions to access respected lists');
        when(mockRepository.getSpotsFromRespectedLists())
            .thenThrow(permissionError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(permissionError),
        );
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle data corruption in respected lists', () async {
        // Arrange
        final corruptionError = FormatException('Corrupted data in respected lists');
        when(mockRepository.getSpotsFromRespectedLists())
            .thenThrow(corruptionError);

        // Act & Assert
        expect(
          () async => await usecase.call(),
          throwsA(corruptionError),
        );
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });
    });

    group('Business logic validation', () {
      test('should not apply additional filtering to respected spots', () async {
        // Arrange
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => respectedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, equals(respectedSpots));
        expect(identical(result, respectedSpots), isTrue); // Same reference
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should preserve community ranking order from repository', () async {
        // Arrange
        final reorderedSpots = [respectedSpots[2], respectedSpots[0], respectedSpots[1]];
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => reorderedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result[0].id, equals('respected_spot_3'));
        expect(result[1].id, equals('respected_spot_1'));
        expect(result[2].id, equals('respected_spot_2'));
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should handle duplicate respected spots from different lists', () async {
        // Arrange - Simulate spot appearing in multiple respected lists
        final duplicateRespectedSpots = [
          respectedSpots[0],
          respectedSpots[0], // Same spot from different list
          respectedSpots[1],
        ];

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => duplicateRespectedSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].id, equals(result[1].id)); // Duplicates preserved
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should be idempotent - multiple calls return consistent data', () async {
        // Arrange
        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => respectedSpots);

        // Act
        final result1 = await usecase.call();
        final result2 = await usecase.call();
        final result3 = await usecase.call();

        // Assert
        expect(result1, equals(result2));
        expect(result2, equals(result3));
        verify(mockRepository.getSpotsFromRespectedLists()).called(3);
      });

      test('should maintain community trust signals in metadata', () async {
        // Arrange
        final trustSignalSpots = respectedSpots.map((spot) => spot.copyWith(
          metadata: Map.from(spot.metadata)..addAll({
            'trust_score': 0.95,
            'community_trust_level': 'high',
            'curator_endorsements': 12,
            'peer_validations': 45,
            'abuse_reports': 0,
            'false_positive_rate': 0.02,
          }),
        )).toList();

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => trustSignalSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        for (final spot in result) {
          expect(spot.metadata['trust_score'], equals(0.95));
          expect(spot.metadata['community_trust_level'], equals('high'));
          expect(spot.metadata['curator_endorsements'], equals(12));
          expect(spot.metadata['abuse_reports'], equals(0));
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });
    });

    group('Privacy and OUR_GUTS.md compliance', () {
      test('should preserve privacy-respecting metadata only', () async {
        // Arrange - Spots with privacy-conscious metadata
        final privacyRespectingSpots = respectedSpots.map((spot) => spot.copyWith(
          metadata: {
            'community_endorsed': true,
            'respect_count': spot.metadata['respect_count'],
            'category_popularity': 0.8,
            'general_satisfaction': 4.5,
            // Note: No personal data, user IDs, or tracking info
            'privacy_compliant': true,
            'anonymized_feedback': true,
          },
        )).toList();

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => privacyRespectingSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        for (final spot in result) {
          expect(spot.metadata['privacy_compliant'], isTrue);
          expect(spot.metadata['anonymized_feedback'], isTrue);
          expect(spot.metadata.keys, everyElement(isNot(contains('user_id'))));
          expect(spot.metadata.keys, everyElement(isNot(contains('personal'))));
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });

      test('should maintain authenticity signals over algorithmic ranking', () async {
        // Arrange - OUR_GUTS.md: "Authenticity Over Algorithms"
        final authenticSpots = respectedSpots.map((spot) => spot.copyWith(
          metadata: Map.from(spot.metadata)..addAll({
            'authentic_community_choice': true,
            'organic_discovery': true,
            'human_curated': true,
            'algorithm_free_ranking': true,
            'community_driven_selection': true,
          }),
        )).toList();

        when(mockRepository.getSpotsFromRespectedLists())
            .thenAnswer((_) async => authenticSpots);

        // Act
        final result = await usecase.call();

        // Assert
        expect(result, hasLength(3));
        for (final spot in result) {
          expect(spot.metadata['authentic_community_choice'], isTrue);
          expect(spot.metadata['human_curated'], isTrue);
          expect(spot.metadata['algorithm_free_ranking'], isTrue);
          expect(spot.metadata['community_driven_selection'], isTrue);
        }
        verify(mockRepository.getSpotsFromRespectedLists()).called(1);
      });
    });
  });
}

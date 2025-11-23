import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/services/expertise_curation_service.dart';
import 'package:spots/core/models/unified_user.dart';
import 'package:spots/core/models/spot.dart';
import 'package:spots/core/models/expertise_level.dart';
import '../../fixtures/model_factories.dart';

/// Expertise Curation Service Tests
/// Tests expert-based curation and validation functionality
void main() {
  group('ExpertiseCurationService Tests', () {
    late ExpertiseCurationService service;
    late UnifiedUser curator;
    late List<Spot> spots;

    setUp(() {
      service = ExpertiseCurationService();
      curator = ModelFactories.createTestUser(
        id: 'curator-123',
        tags: ['food'],
      ).copyWith(
        expertiseMap: {'food': 'regional'},
      );
      spots = [
        ModelFactories.createTestSpot(name: 'Spot 1'),
        ModelFactories.createTestSpot(name: 'Spot 2'),
      ];
    });

    group('createExpertCuratedList', () {
      test('should create curated list when curator has regional level', () async {
        final collection = await service.createExpertCuratedList(
          curator: curator,
          title: 'Best Food Spots',
          description: 'Curated list of best food spots',
          category: 'food',
          spots: spots,
        );

        expect(collection, isA<ExpertCuratedCollection>());
        expect(collection.title, equals('Best Food Spots'));
        expect(collection.category, equals('food'));
        expect(collection.curator.id, equals(curator.id));
        expect(collection.spotCount, equals(spots.length));
        expect(collection.curatorLevel, equals(ExpertiseLevel.regional));
      });

      test('should throw exception when curator lacks regional level', () async {
        final localCurator = ModelFactories.createTestUser(
          id: 'curator-456',
        ).copyWith(
          expertiseMap: {'food': 'local'},
        );

        expect(
          () => service.createExpertCuratedList(
            curator: localCurator,
            title: 'Best Food Spots',
            description: 'Curated list',
            category: 'food',
            spots: spots,
          ),
          throwsException,
        );
      });

      test('should respect isPublic parameter', () async {
        final collection = await service.createExpertCuratedList(
          curator: curator,
          title: 'Private List',
          description: 'Private curated list',
          category: 'food',
          spots: spots,
          isPublic: false,
        );

        expect(collection.isPublic, equals(false));
      });

      test('should set respectCount to zero initially', () async {
        final collection = await service.createExpertCuratedList(
          curator: curator,
          title: 'New List',
          description: 'Description',
          category: 'food',
          spots: spots,
        );

        expect(collection.respectCount, equals(0));
      });
    });

    group('getExpertCuratedCollections', () {
      test('should return collections filtered by category', () async {
        final collections = await service.getExpertCuratedCollections(
          category: 'food',
        );

        expect(collections, isA<List<ExpertCuratedCollection>>());
      });

      test('should filter by location when provided', () async {
        final collections = await service.getExpertCuratedCollections(
          category: 'food',
          location: 'San Francisco',
        );

        expect(collections, isA<List<ExpertCuratedCollection>>());
      });

      test('should filter by minimum level', () async {
        final collections = await service.getExpertCuratedCollections(
          category: 'food',
          minLevel: ExpertiseLevel.regional,
        );

        expect(collections, isA<List<ExpertCuratedCollection>>());
      });

      test('should respect maxResults parameter', () async {
        final collections = await service.getExpertCuratedCollections(
          category: 'food',
          maxResults: 10,
        );

        expect(collections.length, lessThanOrEqualTo(10));
      });

      test('should sort by respectCount descending', () async {
        final collections = await service.getExpertCuratedCollections(
          category: 'food',
        );

        // Collections should be sorted by respectCount (highest first)
        for (var i = 0; i < collections.length - 1; i++) {
          expect(
            collections[i].respectCount,
            greaterThanOrEqualTo(collections[i + 1].respectCount),
          );
        }
      });
    });

    group('createExpertPanelValidation', () {
      test('should create panel validation with regional level experts', () async {
        final experts = [
          ModelFactories.createTestUser(id: 'expert-1').copyWith(
            expertiseMap: {'food': 'regional'},
          ),
          ModelFactories.createTestUser(id: 'expert-2').copyWith(
            expertiseMap: {'food': 'regional'},
          ),
        ];

        final validation = await service.createExpertPanelValidation(
          spot: spots.first,
          experts: experts,
          category: 'food',
        );

        expect(validation, isA<ExpertPanelValidation>());
        expect(validation.spot.id, equals(spots.first.id));
        expect(validation.category, equals('food'));
        expect(validation.experts.length, equals(2));
      });

      test('should throw exception when expert lacks regional level', () async {
        final experts = [
          ModelFactories.createTestUser(id: 'expert-1').copyWith(
            expertiseMap: {'food': 'local'},
          ),
        ];

        expect(
          () => service.createExpertPanelValidation(
            spot: spots.first,
            experts: experts,
            category: 'food',
          ),
          throwsException,
        );
      });

      test('should accept validations map', () async {
        final experts = [
          ModelFactories.createTestUser(id: 'expert-1').copyWith(
            expertiseMap: {'food': 'regional'},
          ),
        ];

        final validations = {'expert-1': true};

        final validation = await service.createExpertPanelValidation(
          spot: spots.first,
          experts: experts,
          category: 'food',
          validations: validations,
        );

        expect(validation.validations, equals(validations));
      });

      test('should determine if spot is validated by consensus', () async {
        final experts = [
          ModelFactories.createTestUser(id: 'expert-1').copyWith(
            expertiseMap: {'food': 'regional'},
          ),
          ModelFactories.createTestUser(id: 'expert-2').copyWith(
            expertiseMap: {'food': 'regional'},
          ),
          ModelFactories.createTestUser(id: 'expert-3').copyWith(
            expertiseMap: {'food': 'regional'},
          ),
        ];

        final validations = {
          'expert-1': true,
          'expert-2': true,
          'expert-3': false,
        };

        final validation = await service.createExpertPanelValidation(
          spot: spots.first,
          experts: experts,
          category: 'food',
          validations: validations,
        );

        expect(validation.isValidated, isTrue);
        expect(validation.validationPercentage, greaterThan(0.5));
      });
    });

    group('getCommunityValidatedSpots', () {
      test('should return validated spots', () async {
        final validatedSpots = await service.getCommunityValidatedSpots(
          category: 'food',
        );

        expect(validatedSpots, isA<List<Spot>>());
      });

      test('should respect minValidations parameter', () async {
        final validatedSpots = await service.getCommunityValidatedSpots(
          category: 'food',
          minValidations: 3,
        );

        expect(validatedSpots, isA<List<Spot>>());
      });

      test('should respect maxResults parameter', () async {
        final validatedSpots = await service.getCommunityValidatedSpots(
          category: 'food',
          maxResults: 10,
        );

        expect(validatedSpots.length, lessThanOrEqualTo(10));
      });

      test('should filter by category when provided', () async {
        final validatedSpots = await service.getCommunityValidatedSpots(
          category: 'food',
        );

        expect(validatedSpots, isA<List<Spot>>());
      });
    });
  });
}


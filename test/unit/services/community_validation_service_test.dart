import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spots/core/services/community_validation_service.dart';
import 'package:spots/core/models/unified_models.dart';
import 'package:spots/core/models/community_validation.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mock_dependencies.dart.mocks.dart';
import '../../fixtures/model_factories.dart';

void main() {
  group('CommunityValidationService Tests', () {
    late CommunityValidationService service;
    late MockStorageService mockStorageService;
    late SharedPreferences prefs;

    setUp(() async {
      mockStorageService = MockStorageService();
      prefs = await SharedPreferences.getInstance();
      
      service = CommunityValidationService(
        storageService: mockStorageService,
        prefs: prefs,
      );
    });

    tearDown(() async {
      await prefs.clear();
    });

    group('validateSpot', () {
      test('validates spot successfully', () async {
        // Arrange
        final spot = ModelFactories.createTestSpot();
        when(mockStorageService.getObject<List<dynamic>>(
          any,
          box: anyNamed('box'),
        )).thenReturn([]);
        when(mockStorageService.setObject(
          any,
          any,
          box: anyNamed('box'),
        )).thenAnswer((_) async {});

        // Act
        final validation = await service.validateSpot(
          spot: spot,
          validatorId: 'validator_id',
          status: ValidationStatus.validated,
          criteria: [ValidationCriteria.locationAccuracy],
        );

        // Assert
        expect(validation, isNotNull);
        expect(validation.spotId, equals(spot.id));
        expect(validation.status, equals(ValidationStatus.validated));
        expect(validation.isActive, isTrue);
      });
    });

    group('validateList', () {
      test('validates list with valid spots', () async {
        // Arrange
        final list = ModelFactories.createTestList();
        when(mockStorageService.getObject<List<dynamic>>(
          any,
          box: anyNamed('box'),
        )).thenReturn([]);
        when(mockStorageService.getObject<Map<String, dynamic>>(
          any,
          box: anyNamed('box'),
        )).thenReturn({});

        // Act
        final result = await service.validateList(
          list: list,
          validatorId: 'validator_id',
          criteria: [ValidationCriteria.locationAccuracy],
        );

        // Assert
        expect(result, isNotNull);
        expect(result.totalSpots, equals(list.spots.length));
      });

      test('returns invalid for empty list', () async {
        // Arrange
        final emptyList = ModelFactories.createTestList();
        emptyList.spots.clear();

        // Act
        final result = await service.validateList(
          list: emptyList,
          validatorId: 'validator_id',
          criteria: [ValidationCriteria.locationAccuracy],
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.issues, contains('List has no spots'));
      });
    });

    group('getSpotValidationSummary', () {
      test('returns summary for validated spot', () async {
        // Arrange
        final spot = ModelFactories.createTestSpot();
        when(mockStorageService.getObject<List<dynamic>>(
          any,
          box: anyNamed('box'),
        )).thenReturn([]);

        // Act
        final summary = await service.getSpotValidationSummary(spot.id);

        // Assert
        expect(summary, isNotNull);
        expect(summary.spotId, equals(spot.id));
      });
    });
  });
}


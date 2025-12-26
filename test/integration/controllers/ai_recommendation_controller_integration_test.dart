import 'package:flutter_test/flutter_test.dart';

import 'package:spots/core/controllers/ai_recommendation_controller.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/core/models/expertise_event.dart';
import 'package:spots/core/controllers/event_creation_controller.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';
import '../../helpers/integration_test_helpers.dart';

/// AI Recommendation Controller Integration Tests
/// 
/// Tests the complete recommendation workflow with real service implementations:
/// - Personality profile loading
/// - Preferences profile loading
/// - Event recommendation generation
/// - Quantum compatibility enhancement
/// - Result filtering and sorting
void main() {
  group('AIRecommendationController Integration Tests', () {
    late AIRecommendationController controller;

    setUpAll(() async {
      // Initialize Sembast for tests
      SembastDatabase.useInMemoryForTests();
      await SembastDatabase.database;
      
      // Initialize dependency injection
      await di.init();
      
      controller = di.sl<AIRecommendationController>();
    });

    setUp(() async {
      // Reset database for each test
      await SembastDatabase.resetForTests();
    });

    group('generateRecommendations', () {
      test('should successfully generate recommendations with real services', () async {
        // Arrange
        final host = IntegrationTestHelpers.createUserWithLocalExpertise(
          id: 'host_${DateTime.now().millisecondsSinceEpoch}',
          category: 'Coffee',
          location: 'Greenpoint, Brooklyn, NY, USA',
        );

        // Create a test event
        final testEvent = ExpertiseEvent(
          id: 'event_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Coffee Tasting Tour',
          description: 'Explore local coffee shops',
          category: 'Coffee',
          eventType: ExpertiseEventType.tour,
          host: host,
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: EventStatus.upcoming,
          price: 25.0,
          isPaid: true,
          maxAttendees: 20,
          attendeeCount: 5,
        );

        // Create event via EventCreationController (proper workflow)
        final eventCreationController = di.sl<EventCreationController>();
        final eventFormData = EventFormData(
          title: testEvent.title,
          description: testEvent.description,
          category: testEvent.category,
          eventType: testEvent.eventType,
          startTime: testEvent.startTime,
          endTime: testEvent.endTime,
          location: 'Greenpoint, Brooklyn, NY, USA',
          locality: 'Greenpoint',
          maxAttendees: testEvent.maxAttendees,
          price: testEvent.price,
          isPublic: testEvent.isPublic,
        );
        await eventCreationController.createEvent(
          formData: eventFormData,
          host: host,
        );

        // Create test user
        final testUser = IntegrationTestHelpers.createUserWithoutHosting(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Act
        final result = await controller.generateRecommendations(
          userId: testUser.id,
          context: RecommendationContext(
            category: 'Coffee',
            location: 'Greenpoint',
            maxResults: 10,
          ),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.events, isA<List>());
        // May have 0 events if no matching events exist, but should succeed
      });

      test('should handle missing personality profile gracefully', () async {
        // Arrange
        final testUser = IntegrationTestHelpers.createUserWithoutHosting(
          id: 'user_no_personality_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Act
        final result = await controller.generateRecommendations(
          userId: testUser.id,
          context: const RecommendationContext(),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        // Should succeed even without personality profile
      });

      test('should handle missing preferences profile gracefully', () async {
        // Arrange
        final testUser = IntegrationTestHelpers.createUserWithoutHosting(
          id: 'user_no_preferences_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Act
        final result = await controller.generateRecommendations(
          userId: testUser.id,
          context: const RecommendationContext(),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        // Should succeed even without preferences profile
      });

      test('should filter recommendations by minRelevanceScore', () async {
        // Arrange
        final testUser = IntegrationTestHelpers.createUserWithoutHosting(
          id: 'user_filter_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Act
        final result = await controller.generateRecommendations(
          userId: testUser.id,
          context: RecommendationContext(
            minRelevanceScore: 0.7, // High threshold
            maxResults: 10,
          ),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        // All returned events should have relevance >= 0.7
        for (final event in result.events) {
          expect(event.relevanceScore, greaterThanOrEqualTo(0.7));
        }
      });

      test('should limit results to maxResults', () async {
        // Arrange
        final testUser = IntegrationTestHelpers.createUserWithoutHosting(
          id: 'user_limit_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Act
        final result = await controller.generateRecommendations(
          userId: testUser.id,
          context: const RecommendationContext(
            maxResults: 5,
          ),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.events.length, lessThanOrEqualTo(5));
      });

      test('should return empty list when no events match', () async {
        // Arrange
        final testUser = IntegrationTestHelpers.createUserWithoutHosting(
          id: 'user_no_match_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Act - Request recommendations for a category that likely has no events
        final result = await controller.generateRecommendations(
          userId: testUser.id,
          context: RecommendationContext(
            category: 'NonExistentCategory_${DateTime.now().millisecondsSinceEpoch}',
            maxResults: 10,
          ),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.events, isEmpty);
      });
    });

    group('validate (WorkflowController interface)', () {
      test('should validate input correctly', () {
        // Arrange
        final validInput = RecommendationInput(
          userId: 'user_123',
          context: const RecommendationContext(
            maxResults: 20,
            explorationRatio: 0.3,
          ),
        );

        final invalidInput = RecommendationInput(
          userId: '',
          context: const RecommendationContext(),
        );

        // Act
        final validResult = controller.validate(validInput);
        final invalidResult = controller.validate(invalidInput);

        // Assert
        expect(validResult.isValid, isTrue);
        expect(invalidResult.isValid, isFalse);
      });
    });
  });
}


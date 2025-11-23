import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/models/unified_models.dart';
import '../../fixtures/model_factories.dart';
import '../../helpers/test_helpers.dart';

/// Comprehensive tests for Unified Models
/// Tests UnifiedUserAction, UnifiedAIModel, and OrchestrationEvent
void main() {
  group('Unified Models Tests', () {
    late DateTime testDate;

    setUp(() {
      TestHelpers.setupTestEnvironment();
      testDate = TestHelpers.createTestDateTime();
    });

    tearDown(() {
      TestHelpers.teardownTestEnvironment();
    });

    group('UserAction Enum Tests', () {
      test('should have all expected action types', () {
        final expectedActions = [
          UserAction.spotVisit,
          UserAction.listCreate,
          UserAction.feedbackGiven,
          UserAction.spotRespect,
          UserAction.listRespect,
          UserAction.profileUpdate,
          UserAction.locationChange,
          UserAction.searchQuery,
          UserAction.filterApplied,
          UserAction.mapInteraction,
          UserAction.onboardingComplete,
          UserAction.aiInteraction,
          UserAction.communityJoin,
          UserAction.eventAttend,
          UserAction.recommendationAccept,
          UserAction.recommendationReject,
        ];

        expect(UserAction.values.length, equals(expectedActions.length));
        
        for (final action in expectedActions) {
          expect(UserAction.values.contains(action), isTrue);
        }
      });

      test('should have correct string representation', () {
        expect(UserAction.spotVisit.name, equals('spotVisit'));
        expect(UserAction.listCreate.name, equals('listCreate'));
        expect(UserAction.aiInteraction.name, equals('aiInteraction'));
        expect(UserAction.recommendationAccept.name, equals('recommendationAccept'));
      });
    });

    group('UnifiedUserAction Model Tests', () {
      test('should create action with required fields', () {
        final action = UnifiedUserAction(
          type: 'test_action',
          timestamp: testDate,
          metadata: {'key': 'value'},
          socialContext: UnifiedSocialContext(
            nearbyUsers: [],
            friends: [],
            communityMembers: ['test_community'],
            socialMetrics: {'engagement': 0.8},
            timestamp: testDate,
          ),
        );

        expect(action.type, equals('test_action'));
        expect(action.timestamp, equals(testDate));
        expect(action.metadata['key'], equals('value'));
        expect(action.socialContext.communityMembers, contains('test_community'));
        expect(action.location, isNull);
      });

      test('should create action with all fields', () {
        final location = UnifiedLocation(
          latitude: 40.7128,
          longitude: -74.0060,
          address: 'New York, NY',
        );
        
        final action = UnifiedUserAction(
          type: 'spot_visit',
          timestamp: testDate,
          metadata: {'spot_id': 'spot-123', 'duration': 30},
          location: location,
          socialContext: UnifiedSocialContext(
            nearbyUsers: [],
            friends: [],
            communityMembers: ['local_community'],
            socialMetrics: {'influence': 0.9, 'trust': 0.8},
            timestamp: testDate,
          ),
        );

        expect(action.type, equals('spot_visit'));
        expect(action.timestamp, equals(testDate));
        expect(action.metadata['spot_id'], equals('spot-123'));
        expect(action.metadata['duration'], equals(30));
        expect(action.location, isNotNull);
        expect(action.location!.latitude, equals(40.7128));
        expect(action.location!.longitude, equals(-74.0060));
        expect(action.socialContext.socialMetrics['influence'], equals(0.9));
      });

      test('should serialize to JSON correctly', () {
        final action = ModelFactories.createTestUserAction(
          type: 'list_create',
          metadata: {'list_id': 'list-123', 'category': 'restaurants'},
        );

        final json = action.toJson();

        expect(json['type'], equals('list_create'));
        expect(json['timestamp'], equals(action.timestamp.toIso8601String()));
        expect(json['metadata']['list_id'], equals('list-123'));
        expect(json['metadata']['category'], equals('restaurants'));
        expect(json['socialContext'], isA<Map<String, dynamic>>());
        expect(json['location'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'type': 'profile_update',
          'timestamp': testDate.toIso8601String(),
          'metadata': {'field': 'display_name', 'old_value': 'Old Name', 'new_value': 'New Name'},
          'socialContext': {
            'nearbyUsers': [],
            'friends': [],
            'communityMembers': ['global'],
            'socialMetrics': {'activity': 0.7},
            'timestamp': testDate.toIso8601String(),
          },
        };

        final action = UnifiedUserAction.fromJson(json);

        expect(action.type, equals('profile_update'));
        expect(action.timestamp, equals(testDate));
        expect(action.metadata['field'], equals('display_name'));
        expect(action.metadata['old_value'], equals('Old Name'));
        expect(action.metadata['new_value'], equals('New Name'));
        expect(action.socialContext.communityMembers, contains('global'));
        expect(action.socialContext.socialMetrics['activity'], equals(0.7));
      });

      test('should handle JSON roundtrip correctly', () {
        final originalAction = ModelFactories.createTestUserAction(
          type: 'search_query',
          metadata: {'query': 'italian restaurants', 'filters': ['rating>4', 'price<3']},
        );
        
        final json = originalAction.toJson();
        final reconstructed = UnifiedUserAction.fromJson(json);
        
        // Compare properties individually since UnifiedUserAction doesn't implement Equatable
        expect(reconstructed.type, equals(originalAction.type));
        expect(reconstructed.timestamp, equals(originalAction.timestamp));
        expect(reconstructed.metadata, equals(originalAction.metadata));
      });

      test('should handle missing optional fields in JSON', () {
        final minimalJson = {
          'type': 'map_interaction',
          'timestamp': testDate.toIso8601String(),
          'socialContext': {
            'nearbyUsers': [],
            'friends': [],
            'communityMembers': ['local'],
            'socialMetrics': {},
            'timestamp': testDate.toIso8601String(),
          },
        };

        final action = UnifiedUserAction.fromJson(minimalJson);

        expect(action.type, equals('map_interaction'));
        expect(action.timestamp, equals(testDate));
        expect(action.metadata, isEmpty);
        expect(action.location, isNull);
        expect(action.socialContext.communityMembers, contains('local'));
      });
    });

    group('UnifiedAIModel Tests', () {
      test('should create AI model with required fields', () {
        final model = UnifiedAIModel(
          id: 'model-123',
          name: 'Personality Learner v2.1',
          version: '2.1.0',
          parameters: {'learning_rate': 0.01, 'batch_size': 32},
          lastUpdated: testDate,
          accuracy: 0.92,
          status: 'active',
        );

        expect(model.id, equals('model-123'));
        expect(model.name, equals('Personality Learner v2.1'));
        expect(model.version, equals('2.1.0'));
        expect(model.parameters['learning_rate'], equals(0.01));
        expect(model.parameters['batch_size'], equals(32));
        expect(model.lastUpdated, equals(testDate));
        expect(model.accuracy, equals(0.92));
        expect(model.status, equals('active'));
      });

      test('should create AI model with complex parameters', () {
        final complexParams = {
          'architecture': {
            'layers': [128, 64, 32, 8],
            'activation': 'relu',
            'dropout': 0.2,
          },
          'training': {
            'epochs': 100,
            'early_stopping': true,
            'validation_split': 0.2,
          },
          'optimization': {
            'optimizer': 'adam',
            'learning_rate': 0.001,
            'decay': 0.95,
          },
        };

        final model = UnifiedAIModel(
          id: 'complex-model',
          name: 'Deep Personality Network',
          version: '3.0.0-beta',
          parameters: complexParams,
          lastUpdated: testDate,
          accuracy: 0.95,
          status: 'training',
        );

        expect(model.parameters['architecture']['layers'], equals([128, 64, 32, 8]));
        expect(model.parameters['training']['epochs'], equals(100));
        expect(model.parameters['optimization']['optimizer'], equals('adam'));
      });

      test('should serialize to JSON correctly', () {
        final model = UnifiedAIModel(
          id: 'test-model',
          name: 'Test AI Model',
          version: '1.0.0',
          parameters: {'param1': 'value1', 'param2': 42},
          lastUpdated: testDate,
          accuracy: 0.88,
          status: 'deployed',
        );

        final json = model.toJson();

        expect(json['id'], equals('test-model'));
        expect(json['name'], equals('Test AI Model'));
        expect(json['version'], equals('1.0.0'));
        expect(json['parameters']['param1'], equals('value1'));
        expect(json['parameters']['param2'], equals(42));
        expect(json['lastUpdated'], equals(testDate.toIso8601String()));
        expect(json['accuracy'], equals(0.88));
        expect(json['status'], equals('deployed'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'deserialized-model',
          'name': 'Deserialized Model',
          'version': '2.0.0',
          'parameters': {
            'feature_size': 256,
            'learning_enabled': true,
          },
          'lastUpdated': testDate.toIso8601String(),
          'accuracy': 0.91,
          'status': 'active',
        };

        final model = UnifiedAIModel.fromJson(json);

        expect(model.id, equals('deserialized-model'));
        expect(model.name, equals('Deserialized Model'));
        expect(model.version, equals('2.0.0'));
        expect(model.parameters['feature_size'], equals(256));
        expect(model.parameters['learning_enabled'], equals(true));
        expect(model.lastUpdated, equals(testDate));
        expect(model.accuracy, equals(0.91));
        expect(model.status, equals('active'));
      });

      test('should handle missing optional fields with defaults', () {
        final json = {
          'id': 'minimal-model',
          'name': 'Minimal Model',
          'version': '1.0.0',
          'lastUpdated': testDate.toIso8601String(),
        };

        final model = UnifiedAIModel.fromJson(json);

        expect(model.id, equals('minimal-model'));
        expect(model.name, equals('Minimal Model'));
        expect(model.version, equals('1.0.0'));
        expect(model.parameters, isEmpty);
        expect(model.accuracy, equals(0.0));
        expect(model.status, equals('inactive'));
      });

      test('should handle JSON roundtrip correctly', () {
        final originalModel = UnifiedAIModel(
          id: 'roundtrip-model',
          name: 'Roundtrip Test Model',
          version: '1.5.2',
          parameters: {
            'nested': {'deep': {'value': 'test'}},
            'array': [1, 2, 3],
            'boolean': true,
          },
          lastUpdated: testDate,
          accuracy: 0.89,
          status: 'testing',
        );
        
        final json = originalModel.toJson();
        final reconstructed = UnifiedAIModel.fromJson(json);
        
        // Compare properties individually since UnifiedAIModel doesn't implement Equatable
        expect(reconstructed.id, equals(originalModel.id));
        expect(reconstructed.name, equals(originalModel.name));
        expect(reconstructed.version, equals(originalModel.version));
        expect(reconstructed.parameters, equals(originalModel.parameters));
      });
    });

    group('OrchestrationEvent Tests', () {
      test('should create event with required fields', () {
        final event = OrchestrationEvent(
          eventType: 'personality_update',
          value: 0.75,
          timestamp: testDate,
        );

        expect(event.eventType, equals('personality_update'));
        expect(event.value, equals(0.75));
        expect(event.timestamp, equals(testDate));
      });

      test('should handle different event types', () {
        final events = [
          OrchestrationEvent(
            eventType: 'ai2ai_connection_established',
            value: 1.0,
            timestamp: testDate,
          ),
          OrchestrationEvent(
            eventType: 'learning_milestone_reached',
            value: 0.85,
            timestamp: testDate,
          ),
          OrchestrationEvent(
            eventType: 'network_optimization_complete',
            value: 0.92,
            timestamp: testDate,
          ),
        ];

        expect(events[0].eventType, equals('ai2ai_connection_established'));
        expect(events[1].eventType, equals('learning_milestone_reached'));
        expect(events[2].eventType, equals('network_optimization_complete'));
      });

      test('should handle various value ranges', () {
        final events = [
          OrchestrationEvent(eventType: 'minimum', value: 0.0, timestamp: testDate),
          OrchestrationEvent(eventType: 'maximum', value: 1.0, timestamp: testDate),
          OrchestrationEvent(eventType: 'negative', value: -0.5, timestamp: testDate),
          OrchestrationEvent(eventType: 'large', value: 100.0, timestamp: testDate),
          OrchestrationEvent(eventType: 'precise', value: 0.123456, timestamp: testDate),
        ];

        expect(events[0].value, equals(0.0));
        expect(events[1].value, equals(1.0));
        expect(events[2].value, equals(-0.5));
        expect(events[3].value, equals(100.0));
        expect(events[4].value, equals(0.123456));
      });

      test('should serialize to JSON correctly', () {
        final event = OrchestrationEvent(
          eventType: 'compatibility_calculated',
          value: 0.87,
          timestamp: testDate,
        );

        final json = event.toJson();

        expect(json['eventType'], equals('compatibility_calculated'));
        expect(json['value'], equals(0.87));
        expect(json['timestamp'], equals(testDate.toIso8601String()));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'eventType': 'trust_score_updated',
          'value': 0.93,
          'timestamp': testDate.toIso8601String(),
        };

        final event = OrchestrationEvent.fromJson(json);

        expect(event.eventType, equals('trust_score_updated'));
        expect(event.value, equals(0.93));
        expect(event.timestamp, equals(testDate));
      });

      test('should handle JSON roundtrip correctly', () {
        final originalEvent = OrchestrationEvent(
          eventType: 'ai_model_performance_metric',
          value: 0.9456,
          timestamp: testDate,
        );
        
        final json = originalEvent.toJson();
        final reconstructed = OrchestrationEvent.fromJson(json);
        
        // Compare properties individually since OrchestrationEvent doesn't implement Equatable
        expect(reconstructed.eventType, equals(originalEvent.eventType));
        expect(reconstructed.value, equals(originalEvent.value));
        expect(reconstructed.timestamp, equals(originalEvent.timestamp));
      });

      test('should handle edge case timestamps', () {
        final events = [
          OrchestrationEvent(
            eventType: 'past_event',
            value: 0.5,
            timestamp: DateTime(2020, 1, 1),
          ),
          OrchestrationEvent(
            eventType: 'future_event',
            value: 0.7,
            timestamp: DateTime(2030, 12, 31),
          ),
          OrchestrationEvent(
            eventType: 'precise_time',
            value: 0.8,
            timestamp: DateTime(2025, 6, 15, 14, 30, 45, 123, 456),
          ),
        ];

        expect(events[0].timestamp.year, equals(2020));
        expect(events[1].timestamp.year, equals(2030));
        expect(events[2].timestamp.microsecond, equals(456));
      });
    });

    group('Integration Tests', () {
      test('should handle complex user action with AI model reference', () {
        final aiModelUpdate = UnifiedUserAction(
          type: 'ai_model_retrained',
          timestamp: testDate,
          metadata: {
            'model_id': 'personality-learner-v3',
            'previous_accuracy': 0.89,
            'new_accuracy': 0.93,
            'training_duration_ms': 45000,
            'events_processed': 1500,
          },
          socialContext: UnifiedSocialContext(
            nearbyUsers: [],
            friends: [],
            communityMembers: ['ai2ai_network'],
            socialMetrics: {
              'learning_effectiveness': 0.92,
              'network_impact': 0.85,
            },
            timestamp: testDate,
          ),
        );

        expect(aiModelUpdate.type, equals('ai_model_retrained'));
        expect(aiModelUpdate.metadata['model_id'], equals('personality-learner-v3'));
        expect(aiModelUpdate.metadata['new_accuracy'], equals(0.93));
        expect(aiModelUpdate.socialContext.socialMetrics['learning_effectiveness'], equals(0.92));
      });

      test('should create orchestration event sequence', () {
        final events = [
          OrchestrationEvent(
            eventType: 'ai2ai_connection_initiated',
            value: 0.0,
            timestamp: testDate,
          ),
          OrchestrationEvent(
            eventType: 'compatibility_assessment_complete',
            value: 0.87,
            timestamp: testDate.add(const Duration(seconds: 1)),
          ),
          OrchestrationEvent(
            eventType: 'learning_session_started',
            value: 1.0,
            timestamp: testDate.add(const Duration(seconds: 2)),
          ),
          OrchestrationEvent(
            eventType: 'personality_evolution_triggered',
            value: 0.92,
            timestamp: testDate.add(const Duration(seconds: 30)),
          ),
        ];

        expect(events.length, equals(4));
        expect(events[0].eventType, contains('initiated'));
        expect(events[1].value, equals(0.87));
        expect(events[2].timestamp.isAfter(events[1].timestamp), isTrue);
        expect(events[3].value, greaterThan(events[1].value));
      });

      test('should validate event chronology', () {
        final events = [
          OrchestrationEvent(
            eventType: 'start',
            value: 0.0,
            timestamp: testDate,
          ),
          OrchestrationEvent(
            eventType: 'middle',
            value: 0.5,
            timestamp: testDate.add(const Duration(minutes: 5)),
          ),
          OrchestrationEvent(
            eventType: 'end',
            value: 1.0,
            timestamp: testDate.add(const Duration(minutes: 10)),
          ),
        ];

        // Verify chronological order
        for (int i = 1; i < events.length; i++) {
          expect(events[i].timestamp.isAfter(events[i-1].timestamp), isTrue);
        }
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty metadata in user actions', () {
        final action = UnifiedUserAction(
          type: 'empty_metadata_action',
          timestamp: testDate,
          metadata: {},
          socialContext: UnifiedSocialContext(
            nearbyUsers: [],
            friends: [],
            communityMembers: ['test'],
            socialMetrics: {},
            timestamp: testDate,
          ),
        );

        expect(action.metadata, isEmpty);
        expect(action.socialContext.socialMetrics, isEmpty);
      });

      test('should handle empty parameters in AI model', () {
        final model = UnifiedAIModel(
          id: 'empty-params',
          name: 'Empty Parameters Model',
          version: '1.0.0',
          parameters: {},
          lastUpdated: testDate,
          accuracy: 0.0,
          status: 'inactive',
        );

        expect(model.parameters, isEmpty);
        expect(model.accuracy, equals(0.0));
      });

      test('should handle extreme values', () {
        final event = OrchestrationEvent(
          eventType: 'extreme_value',
          value: double.maxFinite,
          timestamp: testDate,
        );

        expect(event.value, equals(double.maxFinite));
      });

      test('should handle special characters in strings', () {
        final action = UnifiedUserAction(
          type: 'special_chars_test_🚀',
          timestamp: testDate,
          metadata: {
            'unicode_text': 'Hello 世界 🌍',
            'special_chars': r'@#$%^&*()_+-=[]{}|;:,.<>?',
          },
          socialContext: UnifiedSocialContext(
            nearbyUsers: [],
            friends: [],
            communityMembers: ['unicode_test_ñáéíóú'],
            socialMetrics: {'test': 0.5},
            timestamp: testDate,
          ),
        );

        expect(action.type, contains('🚀'));
        expect(action.metadata['unicode_text'], contains('世界'));
        expect(action.socialContext.communityMembers.first, contains('ñáéíóú'));
      });
    });
  });
}

// Note: Using UnifiedLocation from unified_models.dart
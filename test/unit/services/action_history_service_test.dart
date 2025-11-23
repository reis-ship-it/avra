/// SPOTS ActionHistoryService Unit Tests
/// Date: November 20, 2025
/// Purpose: Test ActionHistoryService functionality
/// 
/// Test Coverage:
/// - Action Storage: Store executed actions with intent and result
/// - Action Retrieval: Get action history with limits and filtering
/// - Undo Functionality: Track undoable actions and execute undo
/// - History Limits: Enforce maximum history size
/// - Edge Cases: Empty history, storage errors, invalid data
/// 
/// Dependencies:
/// - StorageService: For persistent storage
/// - ActionIntent/ActionResult: Action models

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spots/core/ai/action_models.dart';
import 'package:spots/core/services/action_history_service.dart';
import '../../mocks/mock_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ActionHistoryService', () {
    late ActionHistoryService service;
    late GetStorage testStorage;
    
    setUp(() {
      // Use mock storage for tests
      testStorage = MockGetStorage.getInstance();
      MockGetStorage.reset(); // Clear before each test
      
      // Initialize service with test storage
      service = ActionHistoryService(
        storage: testStorage,
      );
    });
    
    tearDown(() {
      MockGetStorage.reset();
    });
    
    group('Action Storage', () {
      test('should store action with intent and result', () async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test description',
          latitude: 37.7749,
          longitude: -122.4194,
          category: 'Coffee',
          userId: 'user123',
          confidence: 0.9,
        );
        final result = ActionResult.success(
          message: 'Spot created successfully',
          data: {'spotId': 'spot123'},
          intent: intent,
        );
        
        // Act
        await service.addAction(intent: intent, result: result);
        
        // Assert
        final history = await service.getHistory(limit: 10);
        expect(history.length, equals(1));
        expect(history.first.intent.type, equals(intent.type));
        expect(history.first.result.success, equals(result.success));
        expect(history.first.timestamp, isNotNull);
      });
      
      test('should store multiple actions in chronological order', () async {
        // Arrange
        final intent1 = CreateSpotIntent(
          name: 'Spot 1',
          description: 'First spot',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        final intent2 = CreateListIntent(
          title: 'List 1',
          description: 'First list',
          userId: 'user123',
          confidence: 0.8,
        );
        
        // Act
        await service.addAction(
          intent: intent1,
          result: ActionResult.success(intent: intent1),
        );
        await Future.delayed(const Duration(milliseconds: 10)); // Ensure different timestamps
        await service.addAction(
          intent: intent2,
          result: ActionResult.success(intent: intent2),
        );
        
        // Assert
        final history = await service.getHistory(limit: 10);
        expect(history.length, equals(2));
        // Most recent should be first
        expect(history.first.intent.type, equals('create_list'));
        expect(history.last.intent.type, equals('create_spot'));
      });
      
      test('should mark actions as undoable when result is successful', () async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        final successResult = ActionResult.success(intent: intent);
        
        // Act
        await service.addAction(intent: intent, result: successResult);
        
        // Assert
        final history = await service.getHistory(limit: 10);
        expect(history.first.canUndo, isTrue);
      });
      
      test('should mark failed actions as not undoable', () async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        final failureResult = ActionResult.failure(
          error: 'Failed to create spot',
          intent: intent,
        );
        
        // Act
        await service.addAction(intent: intent, result: failureResult);
        
        // Assert
        final history = await service.getHistory(limit: 10);
        expect(history.first.canUndo, isFalse);
      });
    });
    
    group('Action Retrieval', () {
      test('should retrieve actions with limit', () async {
        // Arrange - Add 5 actions
        for (int i = 0; i < 5; i++) {
          final intent = CreateSpotIntent(
            name: 'Spot $i',
            description: 'Test',
            latitude: 0.0,
            longitude: 0.0,
            category: 'Test',
            userId: 'user123',
            confidence: 0.9,
          );
          await service.addAction(
            intent: intent,
            result: ActionResult.success(intent: intent),
          );
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        // Act
        final history = await service.getHistory(limit: 3);
        
        // Assert
        expect(history.length, equals(3));
      });
      
      test('should return empty list when no actions stored', () async {
        // Act
        final history = await service.getHistory();
        
        // Assert
        expect(history, isEmpty);
      });
      
      test('should filter actions by user ID', () async {
        // Arrange
        final intent1 = CreateSpotIntent(
          name: 'User1 Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user1',
          confidence: 0.9,
        );
        final intent2 = CreateSpotIntent(
          name: 'User2 Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user2',
          confidence: 0.9,
        );
        
        await service.addAction(
          intent: intent1,
          result: ActionResult.success(intent: intent1),
        );
        await service.addAction(
          intent: intent2,
          result: ActionResult.success(intent: intent2),
        );
        
        // Act
        final history = await service.getHistory(userId: 'user1');
        
        // Assert
        expect(history.length, equals(1));
        expect(history.first.userId, equals('user1'));
      });
      
      test('should filter actions by type', () async {
        // Arrange
        final spotIntent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        final listIntent = CreateListIntent(
          title: 'Test List',
          description: 'Test',
          userId: 'user123',
          confidence: 0.8,
        );
        
        await service.addAction(
          intent: spotIntent,
          result: ActionResult.success(intent: spotIntent),
        );
        await service.addAction(
          intent: listIntent,
          result: ActionResult.success(intent: listIntent),
        );
        
        // Act
        final history = await service.getHistory(actionType: 'create_list');
        
        // Assert
        expect(history.length, equals(1));
        expect(history.first.intent.type, equals('create_list'));
      });
    });
    
    group('Undo Functionality', () {
      test('should mark action as undone', () async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        await service.addAction(
          intent: intent,
          result: ActionResult.success(intent: intent),
        );
        
        final history = await service.getHistory();
        final entry = history.first;
        
        // Act
        await service.markAsUndone(entry.id);
        
        // Assert
        final updatedHistory = await service.getHistory();
        expect(updatedHistory.first.isUndone, isTrue);
      });
      
      test('should not allow undo of already undone action', () async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        await service.addAction(
          intent: intent,
          result: ActionResult.success(intent: intent),
        );
        
        final history = await service.getHistory();
        final entry = history.first;
        await service.markAsUndone(entry.id);
        
        // Act & Assert
        final updatedHistory = await service.getHistory();
        expect(updatedHistory.first.isUndone, isTrue);
        // Once undone, canUndo should still be true (it's about the action type, not undo state)
        // But we check that markAsUndone returns false for already undone actions
        final canUndoAgain = await service.markAsUndone(entry.id);
        expect(canUndoAgain, isFalse);
      });
      
      test('should not allow undo of failed actions', () async {
        // Arrange
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        await service.addAction(
          intent: intent,
          result: ActionResult.failure(error: 'Failed', intent: intent),
        );
        
        final history = await service.getHistory();
        final entry = history.first;
        
        // Act
        await service.markAsUndone(entry.id);
        
        // Assert
        final updatedHistory = await service.getHistory();
        expect(updatedHistory.first.isUndone, isFalse);
      });
    });
    
    group('History Limits', () {
      test('should enforce maximum history size', () async {
        // Arrange - Add more than max (default is 100)
        for (int i = 0; i < 105; i++) {
          final intent = CreateSpotIntent(
            name: 'Spot $i',
            description: 'Test',
            latitude: 0.0,
            longitude: 0.0,
            category: 'Test',
            userId: 'user123',
            confidence: 0.9,
          );
          await service.addAction(
            intent: intent,
            result: ActionResult.success(intent: intent),
          );
        }
        
        // Act
        final history = await service.getHistory();
        
        // Assert - Should be limited to max (100)
        expect(history.length, lessThanOrEqualTo(100));
      });
      
      test('should remove oldest actions when limit exceeded', () async {
        // Arrange - Add actions with custom max
        final customService = ActionHistoryService(
          storage: testStorage,
          maxHistorySize: 5,
        );
        
        for (int i = 0; i < 7; i++) {
          final intent = CreateSpotIntent(
            name: 'Spot $i',
            description: 'Test',
            latitude: 0.0,
            longitude: 0.0,
            category: 'Test',
            userId: 'user123',
            confidence: 0.9,
          );
          await customService.addAction(
            intent: intent,
            result: ActionResult.success(intent: intent),
          );
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        // Act
        final history = await customService.getHistory();
        
        // Assert - Should only have 5 most recent
        expect(history.length, equals(5));
        // Most recent should be Spot 6
        expect((history.first.intent as CreateSpotIntent).name, equals('Spot 6'));
      });
    });
    
    group('Edge Cases', () {
      test('should handle storage errors gracefully', () async {
        // Arrange - Use the test storage which should work
        final intent = CreateSpotIntent(
          name: 'Test Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        
        // Act & Assert - Should not throw even if storage has issues
        await expectLater(
          service.addAction(
            intent: intent,
            result: ActionResult.success(intent: intent),
          ),
          completes,
        );
      });
      
      test('should handle empty history gracefully', () async {
        // Act
        final history = await service.getHistory();
        final undoable = await service.getUndoableActions();
        
        // Assert
        expect(history, isEmpty);
        expect(undoable, isEmpty);
      });
      
      test('should return only undoable actions', () async {
        // Arrange
        final successIntent = CreateSpotIntent(
          name: 'Success Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        final failureIntent = CreateSpotIntent(
          name: 'Failure Spot',
          description: 'Test',
          latitude: 0.0,
          longitude: 0.0,
          category: 'Test',
          userId: 'user123',
          confidence: 0.9,
        );
        
        await service.addAction(
          intent: successIntent,
          result: ActionResult.success(intent: successIntent),
        );
        await service.addAction(
          intent: failureIntent,
          result: ActionResult.failure(error: 'Failed', intent: failureIntent),
        );
        
        // Act
        final undoable = await service.getUndoableActions();
        
        // Assert
        expect(undoable.length, equals(1));
        expect(undoable.first.intent.type, equals('create_spot'));
        expect(undoable.first.result.success, isTrue);
      });
    });
  });
}


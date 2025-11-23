import 'dart:developer' as developer;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:spots/core/ai/action_models.dart';

/// Service for managing action history and undo functionality
/// 
/// Phase 1.1 Enhancement: Provides undo capability for AI-executed actions
/// Stores action history in local storage and provides methods to undo actions
class ActionHistoryService {
  static const String _logName = 'ActionHistoryService';
  static const String _storageKey = 'action_history';
  static const int _maxHistorySize = 50; // Keep last 50 actions
  
  final GetStorage _storage;
  
  ActionHistoryService({GetStorage? storage})
      : _storage = storage ?? GetStorage();
  
  /// Record an action in history
  Future<void> recordAction(ActionResult result) async {
    try {
      if (!result.success) {
        developer.log('Not recording failed action', name: _logName);
        return;
      }
      
      final history = await getHistory();
      
      // Create history entry
      final entry = ActionHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        intent: result.intent,
        result: result,
        timestamp: DateTime.now(),
        isUndone: false,
      );
      
      // Add to history (newest first)
      history.insert(0, entry);
      
      // Limit history size
      if (history.length > _maxHistorySize) {
        history.removeRange(_maxHistorySize, history.length);
      }
      
      // Save to storage
      await _saveHistory(history);
      
      developer.log('Recorded action: ${result.intent.runtimeType}', name: _logName);
    } catch (e) {
      developer.log('Error recording action: $e', name: _logName);
    }
  }
  
  /// Get action history
  Future<List<ActionHistoryEntry>> getHistory() async {
    try {
      final data = _storage.read(_storageKey);
      if (data == null) return [];
      
      final list = jsonDecode(data as String) as List;
      return list.map((e) => ActionHistoryEntry.fromJson(e)).toList();
    } catch (e) {
      developer.log('Error reading history: $e', name: _logName);
      return [];
    }
  }
  
  /// Save history to storage
  Future<void> _saveHistory(List<ActionHistoryEntry> history) async {
    try {
      final data = jsonEncode(history.map((e) => e.toJson()).toList());
      await _storage.write(_storageKey, data);
    } catch (e) {
      developer.log('Error saving history: $e', name: _logName);
    }
  }
  
  /// Undo an action by ID
  Future<UndoResult> undoAction(String actionId) async {
    try {
      final history = await getHistory();
      final entry = history.firstWhere(
        (e) => e.id == actionId,
        orElse: () => throw Exception('Action not found in history'),
      );
      
      if (entry.isUndone) {
        return UndoResult(
          success: false,
          message: 'Action already undone',
        );
      }
      
      // Perform undo based on action type
      final undoResult = await _performUndo(entry.intent, entry.result);
      
      if (undoResult.success) {
        // Mark as undone
        entry.isUndone = true;
        entry.undoneAt = DateTime.now();
        await _saveHistory(history);
      }
      
      return undoResult;
    } catch (e) {
      developer.log('Error undoing action: $e', name: _logName);
      return UndoResult(
        success: false,
        message: 'Failed to undo: $e',
      );
    }
  }
  
  /// Undo the most recent action
  Future<UndoResult> undoLastAction() async {
    try {
      final history = await getHistory();
      
      // Find most recent non-undone action
      final entry = history.firstWhere(
        (e) => !e.isUndone,
        orElse: () => throw Exception('No actions to undo'),
      );
      
      return await undoAction(entry.id);
    } catch (e) {
      developer.log('Error undoing last action: $e', name: _logName);
      return UndoResult(
        success: false,
        message: 'No actions to undo',
      );
    }
  }
  
  /// Perform the actual undo operation
  Future<UndoResult> _performUndo(ActionIntent intent, ActionResult result) async {
    try {
      // Note: These use cases would need to be imported and called
      // For now, this is a placeholder showing the structure
      
      if (intent is CreateSpotIntent) {
        return await _undoCreateSpot(intent, result);
      } else if (intent is CreateListIntent) {
        return await _undoCreateList(intent, result);
      } else if (intent is AddSpotToListIntent) {
        return await _undoAddSpotToList(intent, result);
      } else {
        return UndoResult(
          success: false,
          message: 'Undo not supported for this action type',
        );
      }
    } catch (e) {
      return UndoResult(
        success: false,
        message: 'Undo failed: $e',
      );
    }
  }
  
  /// Undo spot creation
  Future<UndoResult> _undoCreateSpot(CreateSpotIntent intent, ActionResult result) async {
    // TODO: Wire to DeleteSpotUseCase when available
    // For now, return a placeholder
    developer.log('Undo create spot: ${intent.spotName}', name: _logName);
    
    return UndoResult(
      success: false,
      message: 'Spot deletion not yet implemented. Please delete manually.',
    );
  }
  
  /// Undo list creation
  Future<UndoResult> _undoCreateList(CreateListIntent intent, ActionResult result) async {
    // TODO: Wire to DeleteListUseCase when available
    // For now, return a placeholder
    developer.log('Undo create list: ${intent.listName}', name: _logName);
    
    return UndoResult(
      success: false,
      message: 'List deletion not yet implemented. Please delete manually.',
    );
  }
  
  /// Undo adding spot to list
  Future<UndoResult> _undoAddSpotToList(AddSpotToListIntent intent, ActionResult result) async {
    // TODO: Wire to RemoveSpotFromListUseCase when available
    // For now, return a placeholder
    developer.log('Undo add spot to list', name: _logName);
    
    return UndoResult(
      success: false,
      message: 'Spot removal not yet implemented. Please remove manually.',
    );
  }
  
  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await _storage.remove(_storageKey);
      developer.log('Cleared action history', name: _logName);
    } catch (e) {
      developer.log('Error clearing history: $e', name: _logName);
    }
  }
  
  /// Get undoable actions (non-undone actions from last 24 hours)
  Future<List<ActionHistoryEntry>> getUndoableActions() async {
    final history = await getHistory();
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    
    return history
        .where((e) => !e.isUndone && e.timestamp.isAfter(cutoff))
        .toList();
  }
}

/// Entry in action history
class ActionHistoryEntry {
  final String id;
  final ActionIntent intent;
  final ActionResult result;
  final DateTime timestamp;
  bool isUndone;
  DateTime? undoneAt;
  
  ActionHistoryEntry({
    required this.id,
    required this.intent,
    required this.result,
    required this.timestamp,
    this.isUndone = false,
    this.undoneAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'intent': _intentToJson(intent),
    'result': _resultToJson(result),
    'timestamp': timestamp.toIso8601String(),
    'isUndone': isUndone,
    'undoneAt': undoneAt?.toIso8601String(),
  };
  
  factory ActionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ActionHistoryEntry(
      id: json['id'] as String,
      intent: _intentFromJson(json['intent']),
      result: _resultFromJson(json['result']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isUndone: json['isUndone'] as bool? ?? false,
      undoneAt: json['undoneAt'] != null 
          ? DateTime.parse(json['undoneAt'] as String)
          : null,
    );
  }
  
  /// Serialize intent to JSON
  static Map<String, dynamic> _intentToJson(ActionIntent intent) {
    if (intent is CreateSpotIntent) {
      return {
        'type': 'CreateSpot',
        'spotName': intent.spotName,
        'lat': intent.lat,
        'lng': intent.lng,
      };
    } else if (intent is CreateListIntent) {
      return {
        'type': 'CreateList',
        'listName': intent.listName,
      };
    } else if (intent is AddSpotToListIntent) {
      return {
        'type': 'AddSpotToList',
        'spotId': intent.spotId,
        'listId': intent.listId,
      };
    }
    return {'type': 'Unknown'};
  }
  
  /// Deserialize intent from JSON
  static ActionIntent _intentFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'CreateSpot':
        return CreateSpotIntent(
          spotName: json['spotName'] as String,
          lat: json['lat'] as double?,
          lng: json['lng'] as double?,
        );
      case 'CreateList':
        return CreateListIntent(
          listName: json['listName'] as String,
        );
      case 'AddSpotToList':
        return AddSpotToListIntent(
          spotId: json['spotId'] as String,
          listId: json['listId'] as String,
        );
      default:
        throw Exception('Unknown intent type: $type');
    }
  }
  
  /// Serialize result to JSON
  static Map<String, dynamic> _resultToJson(ActionResult result) {
    return {
      'success': result.success,
      'message': result.message,
      'data': result.data,
    };
  }
  
  /// Deserialize result from JSON
  static ActionResult _resultFromJson(Map<String, dynamic> json) {
    // Need to reconstruct intent - stored separately
    // This is a simplified version
    return ActionResult(
      success: json['success'] as bool,
      intent: CreateListIntent(listName: 'Unknown'), // Placeholder
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Result of undo operation
class UndoResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  
  UndoResult({
    required this.success,
    required this.message,
    this.data,
  });
}

// Knot Storage Service
// 
// Service for storing and retrieving personality knots
// Integrates with PersonalityProfile storage system

import 'dart:developer' as developer;
import 'package:spots_knot/models/personality_knot.dart';
import 'package:spots_knot/models/knot/braided_knot.dart';
import 'package:spots/core/services/storage_service.dart';

/// Service for storing and retrieving personality knots and braided knots
class KnotStorageService {
  static const String _logName = 'KnotStorageService';
  static const String _knotPrefix = 'personality_knot:';
  static const String _evolutionPrefix = 'knot_evolution:';
  static const String _braidedKnotPrefix = 'braided_knot:';
  
  final StorageService _storageService;
  
  KnotStorageService({
    required StorageService storageService,
  }) : _storageService = storageService;
  
  /// Save knot for an agent
  /// 
  /// **Storage Key:** `personality_knot:{agentId}`
  Future<void> saveKnot(String agentId, PersonalityKnot knot) async {
    developer.log(
      'Saving knot for agentId: ${agentId.length > 10 ? agentId.substring(0, 10) : agentId}...',
      name: _logName,
    );
    
    try {
      final key = '$_knotPrefix$agentId';
      final json = knot.toJson();
      
      await _storageService.setObject(key, json);
      
      developer.log('✅ Knot saved successfully', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to save knot: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }
  
  /// Load knot for an agent
  /// 
  /// Returns null if knot doesn't exist
  Future<PersonalityKnot?> loadKnot(String agentId) async {
    developer.log(
      'Loading knot for agentId: ${agentId.substring(0, 10)}...',
      name: _logName,
    );
    
    try {
      final key = '$_knotPrefix$agentId';
      final json = _storageService.getObject<Map<String, dynamic>>(key);
      
      if (json == null) {
        developer.log('No knot found for agentId', name: _logName);
        return null;
      }
      
      final knot = PersonalityKnot.fromJson(json);
      
      developer.log('✅ Knot loaded successfully', name: _logName);
      return knot;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to load knot: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return null;
    }
  }
  
  /// Save knot evolution history
  /// 
  /// **Storage Key:** `knot_evolution:{agentId}`
  Future<void> saveEvolutionHistory(
    String agentId,
    List<KnotSnapshot> history,
  ) async {
    developer.log(
      'Saving evolution history for agentId: ${agentId.substring(0, 10)}...',
      name: _logName,
    );
    
    try {
      final key = '$_evolutionPrefix$agentId';
      final jsonList = history.map((snapshot) => snapshot.toJson()).toList();
      
      await _storageService.setObject(key, jsonList);
      
      developer.log(
        '✅ Evolution history saved: ${history.length} snapshots',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to save evolution history: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }
  
  /// Load knot evolution history
  /// 
  /// Returns empty list if history doesn't exist
  Future<List<KnotSnapshot>> loadEvolutionHistory(String agentId) async {
    developer.log(
      'Loading evolution history for agentId: ${agentId.substring(0, 10)}...',
      name: _logName,
    );
    
    try {
      final key = '$_evolutionPrefix$agentId';
      final jsonList = _storageService.getObject<List<dynamic>>(key);
      
      if (jsonList == null) {
        developer.log('No evolution history found', name: _logName);
        return [];
      }
      
      final history = jsonList
          .map((json) => KnotSnapshot.fromJson(json as Map<String, dynamic>))
          .toList();
      
      developer.log(
        '✅ Evolution history loaded: ${history.length} snapshots',
        name: _logName,
      );
      return history;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to load evolution history: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return [];
    }
  }
  
  /// Add snapshot to evolution history
  /// 
  /// Loads existing history, adds new snapshot, saves back
  Future<void> addSnapshot(String agentId, KnotSnapshot snapshot) async {
    final history = await loadEvolutionHistory(agentId);
    history.add(snapshot);
    await saveEvolutionHistory(agentId, history);
  }
  
  /// Delete knot and evolution history for an agent
  Future<void> deleteKnot(String agentId) async {
    developer.log(
      'Deleting knot for agentId: ${agentId.substring(0, 10)}...',
      name: _logName,
    );
    
    try {
      final knotKey = '$_knotPrefix$agentId';
      final evolutionKey = '$_evolutionPrefix$agentId';
      
      await _storageService.remove(knotKey);
      await _storageService.remove(evolutionKey);
      
      developer.log('✅ Knot deleted successfully', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to delete knot: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }
  
  /// Check if knot exists for an agent
  Future<bool> knotExists(String agentId) async {
    final key = '$_knotPrefix$agentId';
    final json = _storageService.getObject<Map<String, dynamic>>(key);
    return json != null;
  }

  /// Get all stored knots
  /// 
  /// **Returns:** List of all personality knots in storage
  /// **Note:** This loads all knots, use with caution for large datasets
  Future<List<PersonalityKnot>> getAllKnots() async {
    developer.log(
      'Loading all knots from storage',
      name: _logName,
    );

    try {
      // Get all keys
      final allKeys = _storageService.getKeys();
      
      // Filter for knot keys
      final knotKeys = allKeys.where((key) => key.startsWith(_knotPrefix)).toList();
      
      developer.log(
        'Found ${knotKeys.length} knot keys',
        name: _logName,
      );

      // Load all knots
      final knots = <PersonalityKnot>[];
      for (final key in knotKeys) {
        try {
          final json = _storageService.getObject<Map<String, dynamic>>(key);
          if (json != null) {
            final knot = PersonalityKnot.fromJson(json);
            knots.add(knot);
          }
        } catch (e) {
          developer.log(
            '⚠️ Failed to load knot from key $key: $e',
            name: _logName,
          );
          // Continue loading other knots
        }
      }

      developer.log(
        '✅ Loaded ${knots.length} knots successfully',
        name: _logName,
      );

      return knots;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to load all knots: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return [];
    }
  }

  // ========================================================================
  // Phase 2: Braided Knot Storage
  // ========================================================================

  /// Save braided knot for connection
  /// 
  /// **Storage Key:** `braided_knot:{connectionId}`
  /// 
  /// **Parameters:**
  /// - `connectionId`: Unique identifier for the connection
  /// - `braidedKnot`: The braided knot to store
  Future<void> saveBraidedKnot({
    required String connectionId,
    required BraidedKnot braidedKnot,
  }) async {
    developer.log(
      'Saving braided knot for connection: ${connectionId.substring(0, 10)}...',
      name: _logName,
    );

    try {
      final key = '$_braidedKnotPrefix$connectionId';
      final json = braidedKnot.toJson();

      await _storageService.setObject(key, json);

      developer.log('✅ Braided knot saved successfully', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to save braided knot: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }

  /// Get braided knot for connection
  /// 
  /// **Storage Key:** `braided_knot:{connectionId}`
  /// 
  /// **Parameters:**
  /// - `connectionId`: Unique identifier for the connection
  /// 
  /// **Returns:**
  /// BraidedKnot if found, null otherwise
  Future<BraidedKnot?> getBraidedKnot(String connectionId) async {
    developer.log(
      'Loading braided knot for connection: ${connectionId.substring(0, 10)}...',
      name: _logName,
    );

    try {
      final key = '$_braidedKnotPrefix$connectionId';
      final json = _storageService.getObject<Map<String, dynamic>>(key);

      if (json == null) {
        developer.log('No braided knot found for connectionId', name: _logName);
        return null;
      }

      final braidedKnot = BraidedKnot.fromJson(json);

      developer.log('✅ Braided knot loaded successfully', name: _logName);
      return braidedKnot;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to load braided knot: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return null;
    }
  }

  /// Get all braided knots
  /// 
  /// **Returns:** List of all braided knots in storage
  Future<List<BraidedKnot>> getAllBraidedKnots() async {
    developer.log(
      'Loading all braided knots from storage',
      name: _logName,
    );

    try {
      // Get all keys
      final allKeys = _storageService.getKeys();
      
      // Filter for braided knot keys
      final braidedKnotKeys = allKeys.where((key) => key.startsWith(_braidedKnotPrefix)).toList();
      
      developer.log(
        'Found ${braidedKnotKeys.length} braided knot keys',
        name: _logName,
      );

      // Load all braided knots
      final braidedKnots = <BraidedKnot>[];
      for (final key in braidedKnotKeys) {
        try {
          final json = _storageService.getObject<Map<String, dynamic>>(key);
          if (json != null) {
            final braidedKnot = BraidedKnot.fromJson(json);
            braidedKnots.add(braidedKnot);
          }
        } catch (e) {
          developer.log(
            '⚠️ Failed to load braided knot from key $key: $e',
            name: _logName,
          );
          // Continue loading other knots
        }
      }

      developer.log(
        '✅ Loaded ${braidedKnots.length} braided knots successfully',
        name: _logName,
      );

      return braidedKnots;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to load all braided knots: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return [];
    }
  }

  /// Get all braided knots for an agent
  /// 
  /// Searches all braided knots where the agent is part of the connection
  /// 
  /// **Parameters:**
  /// - `agentId`: Agent identifier
  /// 
  /// **Returns:**
  /// List of braided knots involving this agent
  Future<List<BraidedKnot>> getBraidedKnotsForAgent(String agentId) async {
    developer.log(
      'Loading braided knots for agent: ${agentId.length > 10 ? '${agentId.substring(0, 10)}...' : agentId}',
      name: _logName,
    );

    try {
      // Get all braided knots
      final allBraidedKnots = await getAllBraidedKnots();
      
      // Filter for knots involving this agent
      final agentBraidedKnots = allBraidedKnots.where((braidedKnot) {
        return braidedKnot.knotA.agentId == agentId || 
               braidedKnot.knotB.agentId == agentId;
      }).toList();

      developer.log(
        '✅ Loaded ${agentBraidedKnots.length} braided knots for agent',
        name: _logName,
      );
      return agentBraidedKnots;
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to load braided knots for agent: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return [];
    }
  }

  /// Delete braided knot (when connection deleted)
  /// 
  /// **Storage Key:** `braided_knot:{connectionId}`
  /// 
  /// **Parameters:**
  /// - `connectionId`: Unique identifier for the connection
  Future<void> deleteBraidedKnot(String connectionId) async {
    developer.log(
      'Deleting braided knot for connection: ${connectionId.substring(0, 10)}...',
      name: _logName,
    );

    try {
      final key = '$_braidedKnotPrefix$connectionId';
      await _storageService.remove(key);

      developer.log('✅ Braided knot deleted successfully', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to delete braided knot: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      rethrow;
    }
  }
}

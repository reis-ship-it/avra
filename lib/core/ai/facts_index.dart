import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spots/core/ai/structured_facts.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/injection_container.dart' as di;

/// Facts Index
/// 
/// Indexes and retrieves structured facts from Supabase database.
/// Provides methods to store and retrieve facts for LLM context preparation.
/// Phase 11 Section 5: Retrieval + LLM Fusion
class FactsIndex {
  static const String _logName = 'FactsIndex';
  
  final SupabaseClient supabase;
  final AgentIdService _agentIdService;
  
  FactsIndex({
    required this.supabase,
    AgentIdService? agentIdService,
  }) : _agentIdService = agentIdService ?? di.sl<AgentIdService>();
  
  /// Index structured facts for a user (by userId, converts to agentId internally)
  /// 
  /// [userId] - Authenticated user ID
  /// [facts] - StructuredFacts to index
  /// Merges with existing facts if they exist
  Future<void> indexFacts({
    required String userId,
    required StructuredFacts facts,
  }) async {
    try {
      developer.log('Indexing facts for user: $userId', name: _logName);
      
      // Convert userId → agentId
      final agentId = await _agentIdService.getUserAgentId(userId);
      
      // Get existing facts (if any)
      final existingFacts = await _getExistingFacts(agentId);
      
      // Merge with existing facts
      final mergedFacts = existingFacts != null
          ? existingFacts.merge(facts)
          : facts;
      
      // Upsert merged facts
      await supabase
          .from('structured_facts')
          .upsert({
            'agent_id': agentId,
            'traits': mergedFacts.traits,
            'places': mergedFacts.places,
            'social_graph': mergedFacts.socialGraph,
            'timestamp': mergedFacts.timestamp.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'agent_id');
      
      developer.log(
        '✅ Facts indexed: ${mergedFacts.traits.length} traits, ${mergedFacts.places.length} places, ${mergedFacts.socialGraph.length} social connections',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error indexing facts: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Retrieve indexed facts for LLM context (by userId, converts to agentId internally)
  /// 
  /// [userId] - Authenticated user ID
  /// Returns StructuredFacts if found, empty facts otherwise
  Future<StructuredFacts> retrieveFacts({required String userId}) async {
    try {
      developer.log('Retrieving facts for user: $userId', name: _logName);
      
      // Convert userId → agentId
      final agentId = await _agentIdService.getUserAgentId(userId);
      
      final result = await supabase
          .from('structured_facts')
          .select('*')
          .eq('agent_id', agentId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (result == null) {
        developer.log('No facts found for user: $userId', name: _logName);
        return StructuredFacts.empty();
      }
      
      final facts = StructuredFacts(
        traits: List<String>.from(result['traits'] ?? []),
        places: List<String>.from(result['places'] ?? []),
        socialGraph: List<String>.from(result['social_graph'] ?? []),
        timestamp: DateTime.parse(result['timestamp'] as String),
      );
      
      developer.log(
        '✅ Facts retrieved: ${facts.traits.length} traits, ${facts.places.length} places, ${facts.socialGraph.length} social connections',
        name: _logName,
      );
      
      return facts;
    } catch (e, stackTrace) {
      developer.log(
        'Error retrieving facts: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Return empty facts on error
      return StructuredFacts.empty();
    }
  }
  
  /// Get existing facts from database (internal helper)
  Future<StructuredFacts?> _getExistingFacts(String agentId) async {
    try {
      final result = await supabase
          .from('structured_facts')
          .select('*')
          .eq('agent_id', agentId)
          .maybeSingle();
      
      if (result == null) {
        return null;
      }
      
      return StructuredFacts(
        traits: List<String>.from(result['traits'] ?? []),
        places: List<String>.from(result['places'] ?? []),
        socialGraph: List<String>.from(result['social_graph'] ?? []),
        timestamp: DateTime.parse(result['timestamp'] as String),
      );
    } catch (e) {
      developer.log('Error getting existing facts: $e', name: _logName);
      return null;
    }
  }
  
  /// Clear facts for a user (by userId, converts to agentId internally)
  /// 
  /// [userId] - Authenticated user ID
  Future<void> clearFacts({required String userId}) async {
    try {
      developer.log('Clearing facts for user: $userId', name: _logName);
      
      // Convert userId → agentId
      final agentId = await _agentIdService.getUserAgentId(userId);
      
      await supabase
          .from('structured_facts')
          .delete()
          .eq('agent_id', agentId);
      
      developer.log('✅ Facts cleared for user: $userId', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error clearing facts: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

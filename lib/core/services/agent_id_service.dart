import 'dart:developer' as developer;
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/business_account_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math' as math;

/// Agent ID Service
/// 
/// Manages agent ID lookup and generation for users and businesses.
/// Agent IDs are used for ai2ai network routing.
class AgentIdService {
  static const String _logName = 'AgentIdService';
  final SupabaseService _supabaseService;

  AgentIdService({
    SupabaseService? supabaseService,
    BusinessAccountService? businessService, // Reserved for future use
  })  : _supabaseService = supabaseService ?? SupabaseService();

  /// Get agent ID for a user
  /// 
  /// First checks database for existing mapping, then generates if needed.
  Future<String> getUserAgentId(String userId) async {
    try {
      if (!_supabaseService.isAvailable) {
        // Fallback: Generate deterministic agent ID from user ID
        return _generateDeterministicAgentId('user_$userId');
      }

      final client = _supabaseService.client;

      // Check for existing mapping
      try {
        final response = await client
            .from('user_agent_mappings')
            .select('agent_id')
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null && response['agent_id'] != null) {
          return response['agent_id'] as String;
        }
      } catch (e) {
        developer.log('Error checking user agent mapping: $e', name: _logName);
      }

      // Generate new agent ID
      final agentId = _generateSecureAgentId();
      
      // Store mapping (if Supabase available)
      try {
        await client.from('user_agent_mappings').insert({
          'user_id': userId,
          'agent_id': agentId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        developer.log('Error storing user agent mapping: $e', name: _logName);
        // Continue with generated ID even if storage fails
      }

      return agentId;
    } catch (e) {
      developer.log('Error getting user agent ID: $e', name: _logName);
      // Fallback: Generate deterministic agent ID
      return _generateDeterministicAgentId('user_$userId');
    }
  }

  /// Get agent ID for a business
  /// 
  /// Uses business ID to generate/get agent ID.
  /// Businesses can have their own agent IDs for ai2ai routing.
  Future<String> getBusinessAgentId(String businessId) async {
    try {
      if (!_supabaseService.isAvailable) {
        // Fallback: Generate deterministic agent ID from business ID
        return _generateDeterministicAgentId('business_$businessId');
      }

      // Check for existing mapping in business_agent_mappings (if table exists)
      // For now, use deterministic generation based on business ID
      // TODO: Create business_agent_mappings table if needed
      
      // Generate deterministic agent ID for business
      // This ensures same business always gets same agent ID
      return _generateDeterministicAgentId('business_$businessId');
    } catch (e) {
      developer.log('Error getting business agent ID: $e', name: _logName);
      return _generateDeterministicAgentId('business_$businessId');
    }
  }

  /// Generate cryptographically secure agent ID
  /// 
  /// Format: agent_[32+ character base64url string]
  String _generateSecureAgentId() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final hash = sha256.convert(bytes);
    final base64 = base64Encode(hash.bytes);
    // Convert to base64url (replace + with -, / with _)
    final base64url = base64.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
    return 'agent_${base64url.substring(0, 32)}';
  }

  /// Generate deterministic agent ID from identifier
  /// 
  /// Same identifier always produces same agent ID.
  /// Used for businesses and fallback scenarios.
  String _generateDeterministicAgentId(String identifier) {
    final bytes = utf8.encode(identifier);
    final hash = sha256.convert(bytes);
    final base64 = base64Encode(hash.bytes);
    final base64url = base64.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
    return 'agent_${base64url.substring(0, 32)}';
  }

  /// Get agent ID for expert (user)
  /// 
  /// Alias for getUserAgentId for clarity.
  Future<String> getExpertAgentId(String expertId) async {
    return getUserAgentId(expertId);
  }
}


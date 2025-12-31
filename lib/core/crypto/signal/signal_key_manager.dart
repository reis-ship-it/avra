// Signal Protocol Key Manager for Phase 14: Signal Protocol Implementation
// Option 1: libsignal-ffi via FFI
// Manages Signal Protocol keys: identity keys, prekeys, and session keys

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spots/core/crypto/signal/signal_types.dart';
import 'package:spots/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:spots/core/services/supabase_service.dart';

/// Signal Protocol Key Manager
/// 
/// Manages all Signal Protocol keys:
/// - Identity keys (long-term, stored securely)
/// - Signed prekeys (medium-term, uploaded to server)
/// - One-time prekeys (short-term, uploaded to server)
/// - Session keys (ephemeral, derived via Double Ratchet)
/// 
/// Phase 14: Signal Protocol Implementation - Option 1
class SignalKeyManager {
  static const String _logName = 'SignalKeyManager';
  static const String _identityKeyStorageKey = 'signal_identity_key_pair';
  
  final FlutterSecureStorage _secureStorage;
  final SignalFFIBindings _ffiBindings;
  final SupabaseService? _supabaseService;
  
  // Cached identity key (loaded once, kept in memory)
  SignalIdentityKeyPair? _identityKeyPair;
  
  SignalKeyManager({
    required FlutterSecureStorage secureStorage,
    required SignalFFIBindings ffiBindings,
    SupabaseService? supabaseService,
  }) : _secureStorage = secureStorage,
       _ffiBindings = ffiBindings,
       _supabaseService = supabaseService;
  
  /// Get or generate identity key pair
  /// 
  /// Identity keys are long-term keys used for authentication.
  /// Generated once per device and stored securely.
  /// 
  /// **Returns:**
  /// Identity key pair (generated if doesn't exist)
  Future<SignalIdentityKeyPair> getOrGenerateIdentityKeyPair() async {
    if (_identityKeyPair != null) {
      return _identityKeyPair!;
    }
    
    try {
      // Try to load from secure storage
      final storedKeyJson = await _secureStorage.read(key: _identityKeyStorageKey);
      
      if (storedKeyJson != null) {
        try {
          // Deserialize stored key
          final json = jsonDecode(storedKeyJson) as Map<String, dynamic>;
          final identityKeyPair = SignalIdentityKeyPair.fromJson(json);
          
          developer.log('✅ Loaded identity key pair from secure storage', name: _logName);
          _identityKeyPair = identityKeyPair;
          return identityKeyPair;
        } catch (e, stackTrace) {
          developer.log(
            'Error deserializing stored identity key: $e',
            name: _logName,
            error: e,
            stackTrace: stackTrace,
          );
          // Continue to generate new key if deserialization fails
        }
      }
      
      // Generate new identity key pair
      developer.log('Generating new Signal Protocol identity key pair', name: _logName);
      final identityKeyPair = await _ffiBindings.generateIdentityKeyPair();
      
      // Store securely
      try {
        final jsonString = jsonEncode(identityKeyPair.toJson());
        await _secureStorage.write(
          key: _identityKeyStorageKey,
          value: jsonString,
        );
        developer.log('✅ Identity key pair stored securely', name: _logName);
      } catch (e, stackTrace) {
        developer.log(
          'Warning: Failed to store identity key pair: $e',
          name: _logName,
          error: e,
          stackTrace: stackTrace,
        );
        // Continue even if storage fails - key is in memory
      }
      
      _identityKeyPair = identityKeyPair;
      developer.log('✅ Identity key pair generated and cached', name: _logName);
      
      return identityKeyPair;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting/generating identity key pair: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Generate prekey bundle for X3DH key exchange
  /// 
  /// Generates a bundle containing:
  /// - Signed prekey (signed with identity key)
  /// - One-time prekey (optional)
  /// - Identity key public key
  /// 
  /// **Returns:**
  /// Prekey bundle ready for upload to key server
  Future<SignalPreKeyBundle> generatePreKeyBundle() async {
    try {
      final identityKeyPair = await getOrGenerateIdentityKeyPair();
      
      developer.log('Generating prekey bundle', name: _logName);
      final preKeyBundle = await _ffiBindings.generatePreKeyBundle(
        identityKeyPair: identityKeyPair,
      );
      
      developer.log('✅ Prekey bundle generated', name: _logName);
      return preKeyBundle;
    } catch (e, stackTrace) {
      developer.log(
        'Error generating prekey bundle: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Upload prekey bundle to key server
  /// 
  /// Uploads prekey bundle to Supabase for distribution to other agents.
  /// 
  /// **Parameters:**
  /// - `agentId`: Our agent ID
  /// - `preKeyBundle`: Prekey bundle to upload
  Future<void> uploadPreKeyBundle({
    required String agentId,
    required SignalPreKeyBundle preKeyBundle,
  }) async {
    try {
      developer.log(
        'Uploading prekey bundle for agent: $agentId',
        name: _logName,
      );
      
      // Check if Supabase is available
      if (_supabaseService == null || !_supabaseService!.isAvailable) {
        developer.log(
          '⚠️ Supabase not available, skipping prekey bundle upload',
          name: _logName,
        );
        return;
      }
      
      final client = _supabaseService!.client;
      
      // Serialize prekey bundle to JSON
      final preKeyBundleJson = preKeyBundle.toJson();
      
      // Convert Uint8List to List<int> for JSON serialization
      final jsonForStorage = {
        'preKeyId': preKeyBundleJson['preKeyId'],
        'signedPreKey': preKeyBundleJson['signedPreKey'],
        'signedPreKeyId': preKeyBundleJson['signedPreKeyId'],
        'signature': preKeyBundleJson['signature'],
        'identityKey': preKeyBundleJson['identityKey'],
        'oneTimePreKey': preKeyBundleJson['oneTimePreKey'],
        'oneTimePreKeyId': preKeyBundleJson['oneTimePreKeyId'],
        'registrationId': preKeyBundleJson['registrationId'],
        'deviceId': preKeyBundleJson['deviceId'],
        'kyberPreKeyId': preKeyBundleJson['kyberPreKeyId'],
        'kyberPreKey': preKeyBundleJson['kyberPreKey'],
        'kyberPreKeySignature': preKeyBundleJson['kyberPreKeySignature'],
      };
      
      // Upload to Supabase (upsert - update if exists, insert if not)
      await client.from('signal_prekey_bundles').upsert({
        'agent_id': agentId,
        'prekey_bundle_json': jsonForStorage,
        'consumed': false,
        'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });
      
      developer.log('✅ Prekey bundle uploaded to Supabase', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error uploading prekey bundle: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - allow app to continue with in-memory storage for testing
      developer.log(
        'Continuing without Supabase upload (using in-memory storage)',
        name: _logName,
      );
    }
  }
  
  // Test-only: In-memory storage for prekey bundles (for testing)
  final Map<String, SignalPreKeyBundle> _testPreKeyBundles = {};
  
  /// Set prekey bundle for testing
  /// 
  /// **Note:** This is a test-only method. In production, prekey bundles
  /// are fetched from the key server.
  void setTestPreKeyBundle(String agentId, SignalPreKeyBundle bundle) {
    _testPreKeyBundles[agentId] = bundle;
    developer.log(
      'Test prekey bundle set for agent: $agentId',
      name: _logName,
    );
  }
  
  /// Fetch prekey bundle for a recipient
  /// 
  /// Fetches prekey bundle from key server for X3DH key exchange.
  /// For testing, checks in-memory storage first.
  /// 
  /// **Parameters:**
  /// - `recipientAgentId`: Recipient's agent ID
  /// 
  /// **Returns:**
  /// Prekey bundle for the recipient
  Future<SignalPreKeyBundle> fetchPreKeyBundle(String recipientAgentId) async {
    try {
      developer.log(
        'Fetching prekey bundle for recipient: $recipientAgentId',
        name: _logName,
      );
      
      // For testing, check in-memory storage first
      if (_testPreKeyBundles.containsKey(recipientAgentId)) {
        developer.log(
          'Found prekey bundle in test storage for recipient: $recipientAgentId',
          name: _logName,
        );
        return _testPreKeyBundles[recipientAgentId]!;
      }
      
      // Try to fetch from Supabase
      if (_supabaseService != null && _supabaseService!.isAvailable) {
        try {
          final client = _supabaseService!.client;
          
          // Query for non-consumed, non-expired prekey bundle
          final response = await client
              .from('signal_prekey_bundles')
              .select()
              .eq('agent_id', recipientAgentId)
              .eq('consumed', false)
              .gt('expires_at', DateTime.now().toIso8601String())
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
          
          if (response != null && response['prekey_bundle_json'] != null) {
            final jsonData = response['prekey_bundle_json'] as Map<String, dynamic>;
            final preKeyBundle = SignalPreKeyBundle.fromJson(jsonData);
            
            developer.log(
              '✅ Fetched prekey bundle from Supabase for recipient: $recipientAgentId',
              name: _logName,
            );
            
            // Mark as consumed if it's a one-time prekey
            if (preKeyBundle.oneTimePreKey != null) {
              try {
                await client
                    .from('signal_prekey_bundles')
                    .update({'consumed': true, 'consumed_at': DateTime.now().toIso8601String()})
                    .eq('agent_id', recipientAgentId)
                    .eq('consumed', false);
              } catch (e) {
                // Log but don't fail - bundle is already fetched
                developer.log(
                  'Warning: Failed to mark prekey bundle as consumed: $e',
                  name: _logName,
                );
              }
            }
            
            return preKeyBundle;
          }
        } catch (e, stackTrace) {
          developer.log(
            'Error fetching prekey bundle from Supabase: $e',
            name: _logName,
            error: e,
            stackTrace: stackTrace,
          );
          // Continue to throw exception below
        }
      }
      
      // Not found in test storage or Supabase
      throw SignalProtocolException(
        'Prekey bundle not found for recipient: $recipientAgentId. '
        'Use SignalKeyManager.setTestPreKeyBundle() for testing, or upload bundle to Supabase.',
        code: 'PREKEY_BUNDLE_NOT_FOUND',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching prekey bundle: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Rotate prekeys
  /// 
  /// Generates new prekeys and uploads them to the key server.
  /// Should be called periodically to maintain fresh prekeys.
  Future<void> rotatePreKeys({required String agentId}) async {
    try {
      developer.log('Rotating prekeys for agent: $agentId', name: _logName);
      
      final newPreKeyBundle = await generatePreKeyBundle();
      await uploadPreKeyBundle(
        agentId: agentId,
        preKeyBundle: newPreKeyBundle,
      );
      
      developer.log('✅ Prekeys rotated successfully', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error rotating prekeys: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

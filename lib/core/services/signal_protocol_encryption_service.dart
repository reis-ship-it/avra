// Signal Protocol Encryption Service for Phase 14: Signal Protocol Implementation
// Option 1: libsignal-ffi via FFI
// Implements MessageEncryptionService interface using Signal Protocol

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:convert';
import 'package:spots/core/services/message_encryption_service.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/crypto/signal/signal_protocol_service.dart';
import 'package:spots/core/crypto/signal/signal_types.dart';

/// Signal Protocol Encryption Service
/// 
/// Implements MessageEncryptionService using Signal Protocol.
/// Provides perfect forward secrecy, X3DH key exchange, and Double Ratchet.
/// 
/// Phase 14: Signal Protocol Implementation - Option 1
class SignalProtocolEncryptionService implements MessageEncryptionService {
  static const String _logName = 'SignalProtocolEncryptionService';
  
  final SignalProtocolService _signalProtocol;
  final AgentIdService _agentIdService;
  final SupabaseService _supabaseService;
  
  // Cached agent ID (resolved lazily from current user)
  String? _cachedAgentId;
  
  SignalProtocolEncryptionService({
    required SignalProtocolService signalProtocol,
    required AgentIdService agentIdService,
    required SupabaseService supabaseService,
  }) : _signalProtocol = signalProtocol,
       _agentIdService = agentIdService,
       _supabaseService = supabaseService;
  
  /// Check if Signal Protocol is initialized and ready
  bool get isInitialized => _signalProtocol.isInitialized;
  
  @override
  EncryptionType get encryptionType => EncryptionType.signalProtocol;
  
  /// Encrypt a message for a recipient
  /// 
  /// Uses Signal Protocol (Double Ratchet) for encryption.
  /// Automatically establishes session if needed via X3DH.
  /// 
  /// **Parameters:**
  /// - `plaintext`: Message to encrypt
  /// - `recipientId`: Recipient's agent ID
  /// 
  /// **Returns:**
  /// Encrypted message with Signal Protocol metadata
  @override
  Future<EncryptedMessage> encrypt(String plaintext, String recipientId) async {
    try {
      // Ensure Signal Protocol is initialized
      if (!_signalProtocol.isInitialized) {
        await _signalProtocol.initialize();
      }
      
      // Convert plaintext to bytes
      final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
      
      // Encrypt using Signal Protocol
      final encrypted = await _signalProtocol.encryptMessage(
        plaintext: plaintextBytes,
        recipientId: recipientId,
      );
      
      // Convert to EncryptedMessage format
      final encryptedBytes = encrypted.toBytes();
      
      developer.log(
        'Message encrypted using Signal Protocol for recipient: $recipientId',
        name: _logName,
      );
      
      return EncryptedMessage(
        encryptedContent: encryptedBytes,
        encryptionType: EncryptionType.signalProtocol,
        metadata: {
          'recipientId': recipientId,
          'timestamp': DateTime.now().toIso8601String(),
          'messageHeaderLength': encrypted.messageHeader?.length ?? 0,
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error encrypting message with Signal Protocol: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Signal Protocol encryption failed: $e');
    }
  }
  
  /// Decrypt a message from a sender
  /// 
  /// Uses Signal Protocol (Double Ratchet) for decryption.
  /// Automatically establishes session if needed via X3DH.
  /// 
  /// **Parameters:**
  /// - `encrypted`: Encrypted message
  /// - `senderId`: Sender's agent ID
  /// 
  /// **Returns:**
  /// Decrypted plaintext
  @override
  Future<String> decrypt(EncryptedMessage encrypted, String senderId) async {
    try {
      // Ensure Signal Protocol is initialized
      if (!_signalProtocol.isInitialized) {
        await _signalProtocol.initialize();
      }
      
      // Validate encryption type
      if (encrypted.encryptionType != EncryptionType.signalProtocol) {
        throw Exception(
          'Invalid encryption type: expected SignalProtocol, got ${encrypted.encryptionType}',
        );
      }
      
      // Get encrypted content
      final encryptedBytes = encrypted.encryptedContent;
      
      // Parse SignalEncryptedMessage
      final signalEncrypted = SignalEncryptedMessage.fromBytes(encryptedBytes);
      
      // Decrypt using Signal Protocol
      final plaintextBytes = await _signalProtocol.decryptMessage(
        encrypted: signalEncrypted,
        senderId: senderId,
      );
      
      // Convert bytes to string
      final plaintext = utf8.decode(plaintextBytes);
      
      developer.log(
        'Message decrypted using Signal Protocol from sender: $senderId',
        name: _logName,
      );
      
      return plaintext;
    } catch (e, stackTrace) {
      developer.log(
        'Error decrypting message with Signal Protocol: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Signal Protocol decryption failed: $e');
    }
  }
  
  /// Get the current user's agent ID (resolved lazily)
  /// 
  /// Resolves agent ID from the current authenticated user.
  /// Caches the result for subsequent calls.
  Future<String> _getCurrentAgentId() async {
    if (_cachedAgentId != null) {
      return _cachedAgentId!;
    }
    
    try {
      // Get current user ID from Supabase
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null || currentUser.id.isEmpty) {
        throw Exception('No authenticated user found. Cannot resolve agent ID.');
      }
      
      // Resolve agent ID for current user
      _cachedAgentId = await _agentIdService.getUserAgentId(currentUser.id);
      
      developer.log(
        'Resolved agent ID for user ${currentUser.id}: $_cachedAgentId',
        name: _logName,
      );
      
      return _cachedAgentId!;
    } catch (e, stackTrace) {
      developer.log(
        'Error resolving agent ID: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Initialize Signal Protocol service
  /// 
  /// Should be called during app initialization.
  /// Resolves agent ID from current user and uploads prekey bundle.
  Future<void> initialize() async {
    try {
      await _signalProtocol.initialize();
      
      // Resolve agent ID from current user
      final agentId = await _getCurrentAgentId();
      
      // Upload prekey bundle to key server
      await _signalProtocol.uploadPreKeyBundle(agentId);
      
      developer.log('Signal Protocol encryption service initialized', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Signal Protocol encryption service: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - allow fallback to AES-256-GCM
      developer.log(
        'Signal Protocol initialization failed, will use fallback encryption',
        name: _logName,
      );
    }
  }
  
  /// Clear cached agent ID (useful when user changes)
  void clearAgentIdCache() {
    _cachedAgentId = null;
    developer.log('Cleared agent ID cache', name: _logName);
  }
}

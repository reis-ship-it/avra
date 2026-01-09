// Signal Protocol Service for Phase 14: Signal Protocol Implementation
// Option 1: libsignal-ffi via FFI
// High-level service for Signal Protocol encryption/decryption

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:avrai/core/crypto/signal/signal_types.dart';
import 'package:avrai/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:avrai/core/crypto/signal/signal_ffi_store_callbacks.dart';
import 'package:avrai/core/crypto/signal/signal_key_manager.dart';
import 'package:avrai/core/crypto/signal/signal_session_manager.dart';
import 'package:avrai_core/services/atomic_clock_service.dart';

/// Signal Protocol Service
/// 
/// High-level service for Signal Protocol encryption and decryption.
/// Provides a simple API for encrypting/decrypting messages using Signal Protocol.
/// 
/// **Features:**
/// - Perfect forward secrecy (Double Ratchet)
/// - X3DH key exchange
/// - Automatic session management
/// - Post-quantum security (PQXDH) support
/// 
/// Phase 14: Signal Protocol Implementation - Option 1
class SignalProtocolService {
  static const String _logName = 'SignalProtocolService';
  
  final SignalFFIBindings _ffiBindings;
  final SignalFFIStoreCallbacks _storeCallbacks;
  final SignalKeyManager _keyManager;
  final SignalSessionManager _sessionManager;
  
  SignalProtocolService({
    required SignalFFIBindings ffiBindings,
    required SignalFFIStoreCallbacks storeCallbacks,
    required SignalKeyManager keyManager,
    required SignalSessionManager sessionManager,
    AtomicClockService? atomicClock, // Reserved for future use (atomic timestamps)
  }) : _ffiBindings = ffiBindings,
       _storeCallbacks = storeCallbacks,
       _keyManager = keyManager,
       _sessionManager = sessionManager;
  
  /// Initialize Signal Protocol service
  /// 
  /// Initializes FFI bindings and ensures identity key exists.
  Future<void> initialize() async {
    try {
      developer.log('Initializing Signal Protocol service...', name: _logName);
      
      // Initialize FFI bindings
      await _ffiBindings.initialize();

      // Initialize store callbacks (required for any session/identity store access
      // inside libsignal-ffi operations).
      if (!_storeCallbacks.isInitialized) {
        await _storeCallbacks.initialize();
      }
      
      // Ensure identity key exists
      await _keyManager.getOrGenerateIdentityKeyPair();
      
      developer.log('✅ Signal Protocol service initialized', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Signal Protocol service: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Encrypt a message for a recipient
  /// 
  /// Encrypts a message using Signal Protocol (Double Ratchet).
  /// Automatically establishes session if needed via X3DH.
  /// 
  /// **Parameters:**
  /// - `plaintext`: Message to encrypt
  /// - `recipientId`: Recipient's agent ID
  /// 
  /// **Returns:**
  /// Encrypted message ready for transmission
  Future<SignalEncryptedMessage> encryptMessage({
    required Uint8List plaintext,
    required String recipientId,
  }) async {
    try {
      // Check if session exists
      var session = await _sessionManager.getSession(recipientId);
      
      // If no session, perform X3DH key exchange to establish one
      if (session == null) {
        developer.log(
          'No session found for recipient: $recipientId. Performing X3DH key exchange...',
          name: _logName,
        );
        
        // Fetch recipient's prekey bundle
        final preKeyBundle = await _keyManager.fetchPreKeyBundle(recipientId);
        
        // Get our identity key
        final identityKeyPair = await _keyManager.getOrGenerateIdentityKeyPair();
        
        // Perform X3DH key exchange
        session = await _ffiBindings.performX3DHKeyExchange(
          recipientId: recipientId,
          preKeyBundle: preKeyBundle,
          identityKeyPair: identityKeyPair,
          storeCallbacks: _storeCallbacks,
        );
        
        // Save session
        await _sessionManager.updateSession(session);
        
        developer.log(
          '✅ X3DH key exchange completed. Session established for recipient: $recipientId',
          name: _logName,
        );
      }
      
      // Encrypt using Signal Protocol
      final encrypted = await _ffiBindings.encryptMessage(
        plaintext: plaintext,
        recipientId: recipientId,
        storeCallbacks: _storeCallbacks,
      );
      
      // Update session state (Double Ratchet advances)
      // TODO: Update session with new state from encryption
      // await _sessionManager.updateSession(updatedSession);
      
      developer.log(
        'Message encrypted for recipient: $recipientId (${plaintext.length} bytes → ${encrypted.ciphertext.length} bytes)',
        name: _logName,
      );
      
      return encrypted;
    } catch (e, stackTrace) {
      developer.log(
        'Error encrypting message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Decrypt a message from a sender
  /// 
  /// Decrypts a message using Signal Protocol (Double Ratchet).
  /// Automatically establishes session if needed via X3DH.
  /// 
  /// **Parameters:**
  /// - `encrypted`: Encrypted message
  /// - `senderId`: Sender's agent ID
  /// 
  /// **Returns:**
  /// Decrypted plaintext
  Future<Uint8List> decryptMessage({
    required SignalEncryptedMessage encrypted,
    required String senderId,
  }) async {
    try {
      // Try to decrypt - libsignal-ffi will handle PreKey messages automatically
      // If it's a PreKey message, the session will be established during decryption
      final plaintext = await _ffiBindings.decryptMessage(
        encrypted: encrypted,
        senderId: senderId,
        storeCallbacks: _storeCallbacks,
      );
      
      // After decryption, check if a new session was created
      // (This happens automatically via store callbacks for PreKey messages)
      final session = await _sessionManager.getSession(senderId);
      if (session != null) {
        // Update session state (Double Ratchet advances)
        // TODO: Update session with new state from decryption
        // await _sessionManager.updateSession(updatedSession);
      }
      
      developer.log(
        'Message decrypted from sender: $senderId (${encrypted.ciphertext.length} bytes → ${plaintext.length} bytes)',
        name: _logName,
      );
      
      return plaintext;
    } catch (e, stackTrace) {
      developer.log(
        'Error decrypting message: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Upload prekey bundle to key server
  /// 
  /// Should be called periodically to maintain fresh prekeys.
  /// 
  /// **Parameters:**
  /// - `userId`: Our Supabase auth user id (used as Signal address for user-to-user messaging)
  Future<void> uploadPreKeyBundle(String userId) async {
    try {
      await _keyManager.rotatePreKeys(userId: userId);
      developer.log('Prekey bundle uploaded for user: $userId', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error uploading prekey bundle: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Check if service is initialized
  bool get isInitialized => _ffiBindings.isInitialized;
}

// Signal Protocol Session Manager for Phase 14: Signal Protocol Implementation
// Option 1: libsignal-ffi via FFI
// Manages Signal Protocol session states for Double Ratchet

import 'dart:developer' as developer;
import 'package:sembast/sembast.dart';
import 'package:spots/core/crypto/signal/signal_types.dart';
import 'package:spots/core/crypto/signal/signal_ffi_bindings.dart';
import 'package:spots/core/crypto/signal/signal_key_manager.dart';

/// Signal Protocol Session Manager
/// 
/// Manages Signal Protocol session states for Double Ratchet algorithm.
/// Sessions are stored locally and used for encrypting/decrypting messages.
/// 
/// Phase 14: Signal Protocol Implementation - Option 1
class SignalSessionManager {
  static const String _logName = 'SignalSessionManager';
  static const String _sessionsStoreName = 'signal_sessions';
  
  final Database _database;
  // Note: _ffiBindings kept for potential future use (e.g., session serialization)
  // ignore: unused_field
  final SignalFFIBindings _ffiBindings;
  final SignalKeyManager _keyManager;
  
  // In-memory cache of active sessions
  final Map<String, SignalSessionState> _sessionCache = {};
  
  // Store for session states
  late final StoreRef<String, Map<String, Object?>> _sessionsStore;
  
  SignalSessionManager({
    required Database database,
    required SignalFFIBindings ffiBindings,
    required SignalKeyManager keyManager,
  }) : _database = database,
       _ffiBindings = ffiBindings,
       _keyManager = keyManager {
    _sessionsStore = stringMapStoreFactory.store(_sessionsStoreName);
  }
  
  /// Get or create session for a recipient
  /// 
  /// If session doesn't exist, performs X3DH key exchange to establish one.
  /// 
  /// **Parameters:**
  /// - `recipientId`: Recipient's agent ID
  /// 
  /// **Returns:**
  /// Session state for the recipient
  Future<SignalSessionState> getOrCreateSession(String recipientId) async {
    try {
      // Check cache first
      if (_sessionCache.containsKey(recipientId)) {
        return _sessionCache[recipientId]!;
      }
      
      // Try to load from database
      final storedSession = await _loadSession(recipientId);
      if (storedSession != null) {
        _sessionCache[recipientId] = storedSession;
        return storedSession;
      }
      
      // Create new session via X3DH key exchange
      developer.log(
        'Creating new Signal Protocol session for recipient: $recipientId',
        name: _logName,
      );
      
      // Fetch recipient's prekey bundle
      // ignore: unused_local_variable - Fetched but not used because method throws exception
      final preKeyBundle = await _keyManager.fetchPreKeyBundle(recipientId);
      
      // Get our identity key
      // ignore: unused_local_variable - Fetched but not used because method throws exception
      final identityKeyPair = await _keyManager.getOrGenerateIdentityKeyPair();
      
      // Perform X3DH key exchange
      // NOTE: This requires storeCallbacks, which creates a circular dependency
      // SignalProtocolService handles X3DH directly, so this method should not be called
      // for session creation. Use SignalProtocolService.encryptMessage() instead.
      throw SignalProtocolException(
        'X3DH key exchange requires storeCallbacks. '
        'Use SignalProtocolService.encryptMessage() which handles this automatically.',
        code: 'STORE_CALLBACKS_REQUIRED',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error getting/creating session: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get session for a recipient (returns null if doesn't exist)
  Future<SignalSessionState?> getSession(String recipientId) async {
    // Check cache first
    if (_sessionCache.containsKey(recipientId)) {
      return _sessionCache[recipientId];
    }
    
    // Load from database
    final session = await _loadSession(recipientId);
    if (session != null) {
      _sessionCache[recipientId] = session;
    }
    
    return session;
  }
  
  /// Save session state
  Future<void> _saveSession(SignalSessionState session) async {
    try {
      final key = _getSessionKey(session.recipientId);
      final json = session.toJson();
      
      await _sessionsStore.record(key).put(_database, json);
      
      developer.log(
        'Session saved for recipient: ${session.recipientId}',
        name: _logName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error saving session: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Load session state from database
  Future<SignalSessionState?> _loadSession(String recipientId) async {
    try {
      final key = _getSessionKey(recipientId);
      final json = await _sessionsStore.record(key).get(_database);
      
      if (json == null) {
        return null;
      }
      
      return SignalSessionState.fromJson(json.cast<String, dynamic>());
    } catch (e, stackTrace) {
      developer.log(
        'Error loading session: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
  
  /// Update session state (after encryption/decryption)
  Future<void> updateSession(SignalSessionState session) async {
    try {
      _sessionCache[session.recipientId] = session;
      await _saveSession(session);
    } catch (e, stackTrace) {
      developer.log(
        'Error updating session: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Delete session for a recipient
  Future<void> deleteSession(String recipientId) async {
    try {
      _sessionCache.remove(recipientId);
      
      final key = _getSessionKey(recipientId);
      await _sessionsStore.record(key).delete(_database);
      
      developer.log('Session deleted for recipient: $recipientId', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting session: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get session key for database storage
  String _getSessionKey(String recipientId) {
    return 'session_$recipientId';
  }
  
  /// Clear all sessions (for testing/debugging)
  Future<void> clearAllSessions() async {
    try {
      _sessionCache.clear();
      await _sessionsStore.delete(_database);
      developer.log('All sessions cleared', name: _logName);
    } catch (e, stackTrace) {
      developer.log(
        'Error clearing sessions: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

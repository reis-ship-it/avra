// Signal Protocol Integration for AI2AIProtocol
// Phase 14: Signal Protocol Implementation - Option 1
// 
// This file contains integration helpers for adding Signal Protocol to AI2AIProtocol.
// The actual integration will be done once FFI bindings are complete.

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:spots/core/crypto/signal/signal_protocol_service.dart';
import 'package:spots/core/crypto/signal/signal_types.dart';

/// Signal Protocol Integration Helper for AI2AIProtocol
/// 
/// Provides helper methods for integrating Signal Protocol into AI2AIProtocol.
/// 
/// **Note:** This is a preparation file. Actual integration will happen once
/// FFI bindings are complete and Signal Protocol is fully functional.
class AI2AIProtocolSignalIntegration {
  static const String _logName = 'AI2AIProtocolSignalIntegration';
  
  final SignalProtocolService? _signalProtocol;
  
  AI2AIProtocolSignalIntegration({
    SignalProtocolService? signalProtocol,
  }) : _signalProtocol = signalProtocol;
  
  /// Check if Signal Protocol is available and ready
  bool get isAvailable => _signalProtocol != null && _signalProtocol!.isInitialized;
  
  /// Encrypt data using Signal Protocol (if available)
  /// 
  /// Falls back to returning null if Signal Protocol is not available,
  /// allowing caller to use AES-256-GCM fallback.
  /// 
  /// **Parameters:**
  /// - `data`: Data to encrypt
  /// - `recipientId`: Recipient's agent ID (required for Signal Protocol)
  /// 
  /// **Returns:**
  /// Encrypted data if Signal Protocol is available, null otherwise
  Future<Uint8List?> encryptWithSignalProtocol({
    required Uint8List data,
    required String recipientId,
  }) async {
    if (!isAvailable) {
      developer.log(
        'Signal Protocol not available, returning null for fallback',
        name: _logName,
      );
      return null;
    }
    
    try {
      // Encrypt using Signal Protocol
      final encrypted = await _signalProtocol!.encryptMessage(
        plaintext: data,
        recipientId: recipientId,
      );
      
      // Convert to bytes
      final encryptedBytes = encrypted.toBytes();
      
      developer.log(
        'Data encrypted using Signal Protocol for recipient: $recipientId',
        name: _logName,
      );
      
      return encryptedBytes;
    } catch (e, stackTrace) {
      developer.log(
        'Error encrypting with Signal Protocol, falling back to AES-256-GCM: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return null; // Fallback to AES-256-GCM
    }
  }
  
  /// Decrypt data using Signal Protocol (if available)
  /// 
  /// Falls back to returning null if Signal Protocol is not available,
  /// allowing caller to use AES-256-GCM fallback.
  /// 
  /// **Parameters:**
  /// - `encrypted`: Encrypted data
  /// - `senderId`: Sender's agent ID (required for Signal Protocol)
  /// 
  /// **Returns:**
  /// Decrypted data if Signal Protocol is available, null otherwise
  Future<Uint8List?> decryptWithSignalProtocol({
    required Uint8List encrypted,
    required String senderId,
  }) async {
    if (!isAvailable) {
      developer.log(
        'Signal Protocol not available, returning null for fallback',
        name: _logName,
      );
      return null;
    }
    
    try {
      // Parse SignalEncryptedMessage from bytes
      final signalEncrypted = SignalEncryptedMessage.fromBytes(encrypted);
      
      // Decrypt using Signal Protocol
      final decrypted = await _signalProtocol!.decryptMessage(
        encrypted: signalEncrypted,
        senderId: senderId,
      );
      
      developer.log(
        'Data decrypted using Signal Protocol from sender: $senderId',
        name: _logName,
      );
      
      return decrypted;
    } catch (e, stackTrace) {
      developer.log(
        'Error decrypting with Signal Protocol, falling back to AES-256-GCM: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );
      return null; // Fallback to AES-256-GCM
    }
  }
  
  /// Initialize Signal Protocol (if available)
  /// 
  /// Should be called during AI2AIProtocol initialization.
  Future<void> initialize() async {
    if (_signalProtocol != null && !_signalProtocol!.isInitialized) {
      try {
        await _signalProtocol!.initialize();
        developer.log('Signal Protocol initialized for AI2AIProtocol', name: _logName);
      } catch (e, stackTrace) {
        developer.log(
          'Error initializing Signal Protocol: $e',
          name: _logName,
          error: e,
          stackTrace: stackTrace,
        );
        // Continue without Signal Protocol (fallback to AES-256-GCM)
      }
    }
  }
}

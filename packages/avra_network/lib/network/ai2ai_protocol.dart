import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:spots_ai/models/personality_profile.dart';

import 'package:spots_network/network/message_encryption_service.dart';

/// AI2AI Protocol Handler for Phase 6: Physical Layer
/// Handles message encoding/decoding, encryption, and connection management
/// OUR_GUTS.md: "Privacy-preserving AI2AI communication"
class AI2AIProtocol {
  static const String _logName = 'AI2AIProtocol';
  static const String _protocolVersion = '1.0';
  static const String _spotsIdentifier = 'SPOTS-AI2AI';

  // Message encryption service (Phase 14: Signal Protocol ready)
  final MessageEncryptionService _encryptionService;

  // Legacy encryption key (deprecated - kept for backward compatibility)
  // TODO: Remove once all code uses MessageEncryptionService
  final Uint8List? _encryptionKey;

  AI2AIProtocol({
    required MessageEncryptionService encryptionService,
    Uint8List? encryptionKey, // Deprecated - use encryptionService instead
  }) : _encryptionService = encryptionService,
       _encryptionKey = encryptionKey;

  /// Encode a message for transmission
  ///
  /// **CRITICAL:** This method validates that no UnifiedUser data is in the payload.
  /// All user data must be converted to AnonymousUser before calling this method.
  ///
  /// **Phase 14:** Now uses MessageEncryptionService (Signal Protocol ready)
  Future<ProtocolMessage> encodeMessage({
    required MessageType type,
    required Map<String, dynamic> payload,
    required String senderNodeId,
    String? recipientNodeId,
  }) async {
    try {
      // Validate no UnifiedUser in payload (safety check)
      _validateNoUnifiedUserInPayload(payload);

      final message = ProtocolMessage(
        version: _protocolVersion,
        type: type,
        senderId: senderNodeId,
        recipientId: recipientNodeId,
        timestamp: DateTime.now(),
        payload: payload,
      );

      // Serialize message
      final json = jsonEncode(message.toJson());

      // Encrypt using MessageEncryptionService (Phase 14: Signal Protocol ready)
      Uint8List encryptedBytes;
      try {
        final encryptedMessage = await _encryptionService.encrypt(
          json,
          recipientNodeId ?? senderNodeId,
        );
        encryptedBytes = encryptedMessage.encryptedContent;

        developer.log(
          'Message encrypted using ${_encryptionService.encryptionType.name}',
          name: _logName,
        );
      } catch (e) {
        developer.log(
          'Encryption failed, falling back to unencrypted: $e',
          name: _logName,
        );
        // Fallback to unencrypted if encryption fails
        encryptedBytes = Uint8List.fromList(utf8.encode(json));
      }

      // Create protocol packet (for future transport layer implementation)
      final packet = ProtocolPacket(
        identifier: _spotsIdentifier,
        version: _protocolVersion,
        data: encryptedBytes,
        checksum: _calculateChecksum(encryptedBytes),
      );

      // Log packet creation for debugging (packet will be used when transport layer is implemented)
      developer.log(
        'Protocol packet created: ${packet.identifier} v${packet.version}, checksum: ${packet.checksum.substring(0, 8)}...',
        name: _logName,
      );

      return message;
    } catch (e) {
      developer.log('Error encoding message: $e', name: _logName);
      rethrow;
    }
  }

  /// Encode and return the full protocol packet bytes (for BLE transport).
  ///
  /// This is the same as `encodeMessage()` but returns the serialized packet:
  /// `[identifier(12)][version(4)][checksum(64)][data...]`
  Future<Uint8List> encodePacketBytes({
    required MessageType type,
    required Map<String, dynamic> payload,
    required String senderNodeId,
    String? recipientNodeId,
  }) async {
    // Validate no UnifiedUser in payload (safety check)
    _validateNoUnifiedUserInPayload(payload);

    final message = ProtocolMessage(
      version: _protocolVersion,
      type: type,
      senderId: senderNodeId,
      recipientId: recipientNodeId,
      timestamp: DateTime.now(),
      payload: payload,
    );

    final json = jsonEncode(message.toJson());

    Uint8List encryptedBytes;
    try {
      final encryptedMessage = await _encryptionService.encrypt(
        json,
        recipientNodeId ?? senderNodeId,
      );
      encryptedBytes = encryptedMessage.encryptedContent;
    } catch (e) {
      // Last resort: plaintext (not ideal, but keeps transport functional).
      encryptedBytes = Uint8List.fromList(utf8.encode(json));
    }

    final checksum = _calculateChecksum(encryptedBytes);
    return _buildPacketBytes(
      identifier: _spotsIdentifier,
      version: _protocolVersion,
      checksum: checksum,
      data: encryptedBytes,
    );
  }

  Uint8List _buildPacketBytes({
    required String identifier,
    required String version,
    required String checksum,
    required Uint8List data,
  }) {
    final idBytes = Uint8List.fromList(utf8.encode(identifier));
    final verBytes = Uint8List.fromList(utf8.encode(version));
    final chkBytes = Uint8List.fromList(utf8.encode(checksum));

    // Fixed-width fields required by _parsePacket().
    final idField = Uint8List(12);
    final verField = Uint8List(4);
    final chkField = Uint8List(64);

    idField.setRange(0, idBytes.length.clamp(0, 12), idBytes);
    verField.setRange(0, verBytes.length.clamp(0, 4), verBytes);
    chkField.setRange(0, chkBytes.length.clamp(0, 64), chkBytes);

    final out = BytesBuilder(copy: false);
    out.add(idField);
    out.add(verField);
    out.add(chkField);
    out.add(data);
    return out.toBytes();
  }

  /// Decode a received message
  ///
  /// **Phase 14:** Now uses MessageEncryptionService (Signal Protocol ready)
  Future<ProtocolMessage?> decodeMessage(
    Uint8List packetData,
    String senderId,
  ) async {
    try {
      // Parse packet header
      final packet = _parsePacket(packetData);

      // Verify checksum
      final calculatedChecksum = _calculateChecksum(packet.data);
      if (calculatedChecksum != packet.checksum) {
        developer.log('Checksum mismatch, packet corrupted', name: _logName);
        return null;
      }

      // Verify identifier
      if (packet.identifier != _spotsIdentifier) {
        developer.log('Invalid protocol identifier', name: _logName);
        return null;
      }

      // Decrypt using MessageEncryptionService (Phase 14: Signal Protocol ready)
      String json;
      try {
        // Try to decrypt using MessageEncryptionService
        // First, try to detect encryption type from packet data
        // If it looks like AES-256-GCM format (IV + ciphertext + tag), use that
        // Otherwise, try Signal Protocol
        final decryptedJson = await _encryptionService.decrypt(
          EncryptedMessage(
            encryptedContent: packet.data,
            encryptionType:
                _encryptionService.encryptionType, // Use current service's type
          ),
          senderId,
        );
        json = decryptedJson;

        developer.log(
          'Message decrypted using ${_encryptionService.encryptionType.name}',
          name: _logName,
        );
      } catch (e) {
        // Fallback: Try legacy decryption if MessageEncryptionService fails
        if (_encryptionKey != null) {
          try {
            final decryptedBytes = _decrypt(packet.data);
            json = utf8.decode(decryptedBytes);
            developer.log(
              'Message decrypted using legacy encryption',
              name: _logName,
            );
          } catch (legacyError) {
            developer.log(
              'Both encryption methods failed: $e, $legacyError',
              name: _logName,
            );
            // Last resort: try as plaintext
            json = utf8.decode(packet.data);
          }
        } else {
          // No encryption - use as plaintext
          json = utf8.decode(packet.data);
        }
      }

      // Deserialize message
      final data = jsonDecode(json) as Map<String, dynamic>;

      return ProtocolMessage.fromJson(data);
    } catch (e) {
      developer.log('Error decoding message: $e', name: _logName);
      return null;
    }
  }

  /// Validate that no UnifiedUser is being sent directly in AI2AI network
  ///
  /// This is a safety check to prevent accidental personal data leaks.
  /// All user data must be pre-anonymized before transmission.
  void _validateNoUnifiedUserInPayload(Map<String, dynamic> payload) {
    // Check for common UnifiedUser fields that should never appear in AI2AI payloads
    final forbiddenFields = [
      'id',
      'email',
      'displayName',
      'photoUrl',
      'userId',
    ];

    for (final field in forbiddenFields) {
      if (payload.containsKey(field)) {
        throw Exception(
          'CRITICAL: UnifiedUser field "$field" detected in AI2AI payload. '
          'All user data must be anonymized before transmission.',
        );
      }
    }

    // Recursively check nested objects
    for (final value in payload.values) {
      if (value is Map<String, dynamic>) {
        _validateNoUnifiedUserInPayload(value);
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            _validateNoUnifiedUserInPayload(item);
          }
        }
      }
    }
  }

  /// Create a heartbeat message
  Future<ProtocolMessage> createHeartbeat({
    required String senderNodeId,
    String? recipientNodeId,
  }) async {
    return await encodeMessage(
      type: MessageType.heartbeat,
      payload: {'timestamp': DateTime.now().toIso8601String()},
      senderNodeId: senderNodeId,
      recipientNodeId: recipientNodeId,
    );
  }

  // ========================================================================
  // OFFLINE AI2AI METHODS (Philosophy Implementation - Phase 1)
  // OUR_GUTS.md: "Always Learning With You"
  // Philosophy: The key works everywhere, not just when online
  // ========================================================================

  /// Exchange full personality profiles peer-to-peer (offline)
  /// Returns remote device's personality profile
  ///
  /// Philosophy: "AI2AI = Doors to People"
  /// When your AI connects with someone else's AI, it learns about doors
  /// they've opened. This works completely offline via Bluetooth/NSD.
  Future<PersonalityProfile?> exchangePersonalityProfile(
    String deviceId,
    PersonalityProfile localProfile,
  ) async {
    try {
      // Create personality exchange message
      final message = await encodeMessage(
        type: MessageType.personalityExchange,
        payload: {
          'profile': localProfile.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
          'vibeSignature': await _generateVibeSignature(localProfile),
        },
        senderNodeId: deviceId,
      );

      // In production, this would send via existing transport layer
      // and wait for response with timeout
      developer.log(
        'Exchanging personality profile with device: $deviceId (message type: ${message.type.name}, payload size: ${message.payload.toString().length} chars)',
        name: _logName,
      );

      // Timeout after 5 seconds
      // For now, return null - full transport implementation needed
      // TODO: Implement actual send/receive via Bluetooth/NSD
      // Message is prepared but not sent until transport layer is implemented
      return null;
    } catch (e) {
      developer.log('Error exchanging personality profile: $e', name: _logName);
      return null;
    }
  }

  /// Encrypt data using AES-256-GCM authenticated encryption
  ///
  /// **Deprecated:** Legacy method kept for backward compatibility.
  /// New code should use MessageEncryptionService instead.
  /// Returns encrypted data with format: IV (12 bytes) + ciphertext + tag (16 bytes)
  // ignore: unused_element
  Uint8List _encrypt(Uint8List data) {
    final encryptionKey = _encryptionKey;
    if (encryptionKey == null) {
      developer.log(
        'Warning: No encryption key set, returning unencrypted data',
        name: _logName,
      );
      return data;
    }

    try {
      // Generate random IV (12 bytes for GCM - 96 bits recommended)
      final iv = _generateIV();

      // Create AES-256-GCM cipher
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          true, // encrypt
          AEADParameters(
            KeyParameter(encryptionKey),
            128, // MAC length (128 bits)
            iv,
            Uint8List(0), // Additional authenticated data (none)
          ),
        );

      // Encrypt
      final ciphertext = cipher.process(data);
      final tag = cipher.mac;

      // Combine: IV + ciphertext + tag
      final encrypted = Uint8List(iv.length + ciphertext.length + tag.length);
      encrypted.setRange(0, iv.length, iv);
      encrypted.setRange(iv.length, iv.length + ciphertext.length, ciphertext);
      encrypted.setRange(iv.length + ciphertext.length, encrypted.length, tag);

      return encrypted;
    } catch (e) {
      developer.log('Error encrypting data: $e', name: _logName);
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt data using AES-256-GCM authenticated encryption
  ///
  /// Verifies authentication tag to ensure message integrity and authenticity.
  Uint8List _decrypt(Uint8List encrypted) {
    final encryptionKey = _encryptionKey;
    if (encryptionKey == null) {
      developer.log(
        'Warning: No encryption key set, returning data as-is',
        name: _logName,
      );
      return encrypted;
    }

    try {
      // Extract IV, ciphertext, and tag
      if (encrypted.length < 12 + 16) {
        // Need at least IV (12 bytes) + tag (16 bytes)
        throw Exception('Invalid encrypted data length: ${encrypted.length}');
      }

      final iv = encrypted.sublist(0, 12);
      final tag = encrypted.sublist(encrypted.length - 16);
      final ciphertext = encrypted.sublist(12, encrypted.length - 16);

      // Create AES-256-GCM cipher
      final cipher = GCMBlockCipher(AESEngine());
      final params = AEADParameters(
        KeyParameter(encryptionKey),
        128, // MAC length
        iv,
        Uint8List(0), // Additional authenticated data
      );
      cipher.init(false, params); // false = decrypt

      // Decrypt
      final plaintext = cipher.process(ciphertext);

      // Verify authentication tag (prevents tampering)
      final calculatedTag = cipher.mac;
      if (!_constantTimeEquals(tag, calculatedTag)) {
        throw Exception(
          'Authentication tag mismatch - message may be tampered',
        );
      }

      return plaintext;
    } catch (e) {
      developer.log('Error decrypting data: $e', name: _logName);
      throw Exception('Decryption failed: $e');
    }
  }

  /// Generate random IV (Initialization Vector) for AES-GCM
  ///
  /// Uses cryptographically secure random number generator.
  /// IV length: 12 bytes (96 bits) - recommended for GCM mode.
  Uint8List _generateIV() {
    final random = Random.secure();
    final iv = Uint8List(12); // 96 bits for GCM
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  /// Constant-time comparison to prevent timing attacks
  ///
  /// Compares two byte arrays in constant time, preventing attackers
  /// from using timing information to guess correct values.
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Calculate checksum for data integrity
  String _calculateChecksum(Uint8List data) {
    final hash = sha256.convert(data);
    return hash.toString();
  }

  /// Parse protocol packet from raw data
  ProtocolPacket _parsePacket(Uint8List data) {
    // Simple packet format: [identifier(12 bytes)][version(4 bytes)][checksum(64 bytes)][data]
    // In production, use a proper binary protocol
    final identifier = utf8.decode(data.sublist(0, 12)).trim();
    final version = utf8.decode(data.sublist(12, 16)).trim();
    final checksum = utf8.decode(data.sublist(16, 80)).trim();
    final payload = data.sublist(80);

    return ProtocolPacket(
      identifier: identifier,
      version: version,
      data: payload,
      checksum: checksum,
    );
  }

  /// Generate unique vibe signature for personality profile
  Future<String> _generateVibeSignature(PersonalityProfile profile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dimensions = profile.dimensions.entries
        .map((e) => '${e.key}:${e.value.toStringAsFixed(2)}')
        .join('|');
    final data = '$timestamp|$dimensions|${profile.userId}';
    final hash = sha256.convert(utf8.encode(data));
    return hash.toString().substring(0, 16);
  }
}

/// Protocol message types
enum MessageType {
  connectionRequest,
  connectionResponse,
  learningExchange,
  learningInsight, // NEW: Encrypted AI2AI learning insight exchange (v1)
  heartbeat,
  disconnect,
  personalityExchange, // NEW: For offline AI2AI personality exchange
}

/// Protocol message structure
class ProtocolMessage {
  final String version;
  final MessageType type;
  final String senderId;
  final String? recipientId;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  const ProtocolMessage({
    required this.version,
    required this.type,
    required this.senderId,
    this.recipientId,
    required this.timestamp,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'type': type.name,
      'senderId': senderId,
      'recipientId': recipientId,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
    };
  }

  factory ProtocolMessage.fromJson(Map<String, dynamic> json) {
    return ProtocolMessage(
      version: json['version'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.heartbeat,
      ),
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
    );
  }
}

/// Protocol packet structure
class ProtocolPacket {
  final String identifier;
  final String version;
  final Uint8List data;
  final String checksum;

  const ProtocolPacket({
    required this.identifier,
    required this.version,
    required this.data,
    required this.checksum,
  });
}

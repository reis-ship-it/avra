import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots_ai/models/personality_profile.dart';

/// Service for secure cross-device personality profile sync
///
/// **Philosophy Alignment:**
/// - Local-first: Primary storage on-device, cloud is backup
/// - Encrypted: All cloud data encrypted with password-derived keys
/// - User-controlled: Opt-in/opt-out setting
/// - Privacy-preserving: Raw personality data never exposed
///
/// **Security:**
/// - Uses PBKDF2 for key derivation from user password
/// - AES-256-GCM for authenticated encryption
/// - Keys never stored or transmitted
/// - Password only used during login session
class PersonalitySyncService {
  static const String _logName = 'PersonalitySyncService';
  static const AppLogger _logger = AppLogger(
    defaultTag: _logName,
    minimumLevel: LogLevel.debug,
  );

  // PBKDF2 parameters
  static const int _pbkdf2Iterations = 100000; // Recommended for security
  static const int _saltLength = 32; // 32 bytes = 256 bits
  static const int _keyLength = 32; // 32 bytes = 256 bits for AES-256

  final SupabaseService _supabaseService;
  final StorageService _storageService;

  PersonalitySyncService({
    required SupabaseService supabaseService,
    required StorageService storageService,
  })  : _supabaseService = supabaseService,
        _storageService = storageService;

  /// Sync personality profile to cloud (encrypted)
  /// 
  /// [profile] - Personality profile to sync
  /// [password] - User password for encryption (never stored)
  /// 
  /// Returns true if sync successful, false otherwise
  Future<bool> syncToCloud({
    required PersonalityProfile profile,
    required String password,
  }) async {
    try {
      _logger.debug('Starting cloud sync for profile: ${profile.agentId}');

      // Derive encryption key from password
      final salt = _generateSalt();
      final key = _deriveKey(password, salt);

      // Encrypt profile data
      final encryptedData = await _encryptProfile(profile, key, salt);

      // Store encrypted data in cloud
      final success = await _storeEncryptedData(
        agentId: profile.agentId,
        encryptedData: encryptedData,
      );

      if (success) {
        _logger.debug('Cloud sync successful for profile: ${profile.agentId}');
      } else {
        _logger.warning('Cloud sync failed for profile: ${profile.agentId}');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.error(
        'Error during cloud sync: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Sync personality profile from cloud (decrypted)
  /// 
  /// [agentId] - Agent ID to sync
  /// [password] - User password for decryption (never stored)
  /// 
  /// Returns decrypted profile, or null if sync fails
  Future<PersonalityProfile?> syncFromCloud({
    required String agentId,
    required String password,
  }) async {
    try {
      _logger.debug('Starting cloud sync download for agent: $agentId');

      // Retrieve encrypted data from cloud
      final encryptedData = await _retrieveEncryptedData(agentId: agentId);
      if (encryptedData == null) {
        _logger.debug('No cloud data found for agent: $agentId');
        return null;
      }

      // Extract salt from encrypted data
      final salt = encryptedData['salt'] as Uint8List;
      final encryptedContent = encryptedData['encrypted'] as Uint8List;
      final nonce = encryptedData['nonce'] as Uint8List;

      // Derive decryption key from password
      final key = _deriveKey(password, salt);

      // Decrypt profile data
      final profile = await _decryptProfile(
        encryptedContent: encryptedContent,
        key: key,
        nonce: nonce,
      );

      if (profile != null) {
        _logger.debug('Cloud sync download successful for agent: $agentId');
      } else {
        _logger.warning('Cloud sync download failed for agent: $agentId');
      }

      return profile;
    } catch (e, stackTrace) {
      _logger.error(
        'Error during cloud sync download: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Generate random salt for key derivation
  Uint8List _generateSalt() {
    final secureRandom = FortunaRandom();
    final salt = Uint8List(_saltLength);
    secureRandom.nextBytes(salt);
    return salt;
  }

  /// Derive encryption key from password using PBKDF2
  Uint8List _deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _pbkdf2Iterations, _keyLength));

    final passwordBytes = utf8.encode(password);
    return pbkdf2.process(passwordBytes);
  }

  /// Encrypt personality profile
  Future<Map<String, dynamic>> _encryptProfile(
    PersonalityProfile profile,
    Uint8List key,
    Uint8List salt,
  ) async {
    // Serialize profile to JSON
    final profileJson = profile.toJson();
    final profileBytes = utf8.encode(jsonEncode(profileJson));

    // Generate nonce for AES-GCM
    final secureRandom = FortunaRandom();
    final nonce = Uint8List(12); // 96-bit nonce for GCM
    secureRandom.nextBytes(nonce);

    // Encrypt with AES-256-GCM
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true, // encrypt
        AEADParameters(
          KeyParameter(key),
          128, // mac size
          nonce,
          Uint8List(0), // no additional data
        ),
      );

    final encryptedBytes = cipher.process(profileBytes);

    return {
      'salt': salt,
      'nonce': nonce,
      'encrypted': encryptedBytes,
    };
  }

  /// Decrypt personality profile
  Future<PersonalityProfile?> _decryptProfile({
    required Uint8List encryptedContent,
    required Uint8List key,
    required Uint8List nonce,
  }) async {
    try {
      // Decrypt with AES-256-GCM
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false, // decrypt
          AEADParameters(
            KeyParameter(key),
            128, // mac size
            nonce,
            Uint8List(0), // no additional data
          ),
        );

      final decryptedBytes = cipher.process(encryptedContent);
      final decryptedJson = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;

      // Deserialize to PersonalityProfile
      return PersonalityProfile.fromJson(decryptedJson);
    } catch (e, stackTrace) {
      _logger.error(
        'Error decrypting profile: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Store encrypted data in cloud
  Future<bool> _storeEncryptedData({
    required String agentId,
    required Map<String, dynamic> encryptedData,
  }) async {
    try {
      // Convert encrypted data to base64 for storage
      final base64Salt = base64Encode(encryptedData['salt'] as Uint8List);
      final base64Nonce = base64Encode(encryptedData['nonce'] as Uint8List);
      final base64Encrypted = base64Encode(encryptedData['encrypted'] as Uint8List);

      final dataToStore = {
        'agent_id': agentId,
        'salt': base64Salt,
        'nonce': base64Nonce,
        'encrypted_data': base64Encrypted,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Store in Supabase (using agent_id as key)
      final response = await _supabaseService.supabase
          .from('personality_sync')
          .upsert(dataToStore);

      return response != null;
    } catch (e, stackTrace) {
      _logger.error(
        'Error storing encrypted data: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Retrieve encrypted data from cloud
  Future<Map<String, dynamic>?> _retrieveEncryptedData({
    required String agentId,
  }) async {
    try {
      // Retrieve from Supabase
      final response = await _supabaseService.supabase
          .from('personality_sync')
          .select()
          .eq('agent_id', agentId)
          .single();

      if (response == null || response.isEmpty) {
        return null;
      }

      // Convert from base64 back to bytes
      final salt = base64Decode(response['salt'] as String);
      final nonce = base64Decode(response['nonce'] as String);
      final encrypted = base64Decode(response['encrypted_data'] as String);

      return {
        'salt': salt,
        'nonce': nonce,
        'encrypted': encrypted,
      };
    } catch (e, stackTrace) {
      _logger.error(
        'Error retrieving encrypted data: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Check if cloud sync is enabled for user
  Future<bool> isCloudSyncEnabled() async {
    try {
      final enabled = await _storageService.getBool('cloud_sync_enabled');
      return enabled ?? false; // Default to false (opt-in)
    } catch (e) {
      _logger.warning('Error checking cloud sync setting: $e');
      return false;
    }
  }

  /// Enable/disable cloud sync
  Future<void> setCloudSyncEnabled(bool enabled) async {
    try {
      await _storageService.setBool('cloud_sync_enabled', enabled);
      _logger.debug('Cloud sync ${enabled ? 'enabled' : 'disabled'}');
    } catch (e, stackTrace) {
      _logger.error(
        'Error setting cloud sync: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

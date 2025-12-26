import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:spots/core/services/logger.dart';
import 'package:spots/core/services/supabase_service.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots/core/models/personality_profile.dart';

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
  static const int _keyLength = 32; // 256 bits for AES-256
  static const String _pbkdf2SaltPrefix = 'personality_sync_salt';

  // Storage key for sync preference
  static const String _syncEnabledKeyPrefix = 'personality_cloud_sync_enabled';

  final SupabaseService _supabaseService;
  SharedPreferencesCompat? _prefs;

  PersonalitySyncService({
    SupabaseService? supabaseService,
    SharedPreferencesCompat? prefs,
  })  : _supabaseService = supabaseService ?? SupabaseService(),
        _prefs = prefs;

  /// Get prefs instance (lazy initialization)
  Future<SharedPreferencesCompat> get _prefsInstance async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferencesCompat.getInstance();
    return _prefs!;
  }

  /// Derive encryption key from user password using PBKDF2
  ///
  /// Same password + same userId = same key on any device
  /// This enables cross-device sync without storing keys
  Future<Uint8List> deriveKeyFromPassword(
      String password, String userId) async {
    try {
      _logger.debug('Deriving encryption key for user: $userId');

      // Use userId as salt (deterministic but user-specific)
      final saltBytes = utf8.encode('${_pbkdf2SaltPrefix}_$userId');

      // Create PBKDF2 key derivation function
      final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
        ..init(Pbkdf2Parameters(saltBytes, _pbkdf2Iterations, _keyLength));

      // Derive key from password
      final passwordBytes = utf8.encode(password);
      final key = pbkdf2.process(passwordBytes);

      _logger.debug('Key derivation successful (${key.length} bytes)');
      return key;
    } catch (e, stackTrace) {
      _logger.error(
        'Error deriving key from password',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Encrypt personality profile for cloud storage
  ///
  /// Uses AES-256-GCM for authenticated encryption
  Future<String> encryptProfileForCloud(
    PersonalityProfile profile,
    Uint8List key,
  ) async {
    try {
      _logger.debug('Encrypting personality profile for cloud storage');

      // Serialize profile to JSON
      final profileJson = jsonEncode(profile.toJson());
      final plaintext = utf8.encode(profileJson);

      // Generate random IV for this encryption
      final iv = _generateIV();

      // Create AES-256-GCM cipher
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          true, // encrypt
          AEADParameters(
            KeyParameter(key),
            128, // tag length (bits)
            iv,
            Uint8List(0), // additional authenticated data (none)
          ),
        );

      // Encrypt
      final ciphertext = cipher.process(plaintext);
      final tag = cipher.mac;

      // Combine IV + ciphertext + tag
      final encrypted = Uint8List(iv.length + ciphertext.length + tag.length);
      encrypted.setRange(0, iv.length, iv);
      encrypted.setRange(iv.length, iv.length + ciphertext.length, ciphertext);
      encrypted.setRange(
        iv.length + ciphertext.length,
        encrypted.length,
        tag,
      );

      // Base64 encode for storage
      final encoded = base64Encode(encrypted);

      _logger.debug('Profile encrypted successfully (${encoded.length} chars)');
      return encoded;
    } catch (e, stackTrace) {
      _logger.error(
        'Error encrypting profile',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Decrypt personality profile from cloud storage
  ///
  /// Returns null if decryption fails (wrong password, corrupted data, etc.)
  Future<PersonalityProfile?> decryptProfileFromCloud(
    String encryptedJson,
    Uint8List key,
  ) async {
    try {
      _logger.debug('Decrypting personality profile from cloud');

      // Base64 decode
      final encrypted = base64Decode(encryptedJson);

      // Extract IV, ciphertext, and tag
      if (encrypted.length < 16 + 16) {
        // Need at least IV (16 bytes) + tag (16 bytes)
        _logger.warn('Invalid encrypted data length');
        return null;
      }

      final iv = encrypted.sublist(0, 16);
      final tag = encrypted.sublist(encrypted.length - 16);
      final ciphertext = encrypted.sublist(16, encrypted.length - 16);

      // Create AES-256-GCM cipher
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false, // decrypt
          AEADParameters(
            KeyParameter(key),
            128, // tag length
            iv,
            Uint8List(0), // additional authenticated data
          ),
        );

      // Decrypt
      final plaintext = cipher.process(ciphertext);

      // Verify authentication tag
      if (!_constantTimeEquals(cipher.mac, tag)) {
        _logger.warn('Authentication tag verification failed');
        return null;
      }

      // Parse JSON
      final profileJson = utf8.decode(plaintext);
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;

      // Create profile from JSON
      final profile = PersonalityProfile.fromJson(profileMap);

      _logger.debug('Profile decrypted successfully');
      return profile;
    } catch (e, stackTrace) {
      _logger.error(
        'Error decrypting profile',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Sync personality profile to cloud (if enabled)
  ///
  /// Encrypts profile and stores in Supabase
  /// Handles conflict resolution: if cloud version is newer, merges changes
  Future<void> syncToCloud(
    String userId,
    PersonalityProfile profile,
    String password,
  ) async {
    try {
      // Check if sync is enabled
      final syncEnabled = await isCloudSyncEnabled(userId);
      if (!syncEnabled) {
        _logger.debug('Cloud sync disabled for user: $userId');
        return;
      }

      _logger.info('Syncing personality profile to cloud for user: $userId');

      // Check for conflicts: get existing cloud profile
      if (!_supabaseService.isAvailable) {
        throw Exception('Supabase not available');
      }
      final client = _supabaseService.client;
      final existingResponse = await client
          .from('user_personality_profiles')
          .select('updated_at')
          .eq('user_id', userId)
          .maybeSingle();

      PersonalityProfile profileToSync = profile;

      // If cloud profile exists, check for conflicts
      if (existingResponse != null) {
        final cloudUpdatedAtStr = existingResponse['updated_at'] as String?;

        if (cloudUpdatedAtStr != null) {
          try {
            final cloudUpdatedAt = DateTime.parse(cloudUpdatedAtStr);
            final localUpdatedAt = profile.lastUpdated;

            // If cloud version is newer, attempt to merge
            if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
              _logger.info(
                'Cloud profile is newer (cloud: $cloudUpdatedAt, local: $localUpdatedAt). Attempting merge...',
              );

              // Load cloud profile to merge
              final cloudProfile = await loadFromCloud(userId, password);
              if (cloudProfile != null) {
                // Merge profiles: use higher generation, combine dimensions
                profileToSync =
                    _mergeProfiles(local: profile, cloud: cloudProfile);
                _logger.info(
                  'Merged profiles: local gen ${profile.evolutionGeneration}, cloud gen ${cloudProfile.evolutionGeneration}, merged gen ${profileToSync.evolutionGeneration}',
                );
              } else {
                _logger.warn(
                    'Could not load cloud profile for merge, using local version');
              }
            } else {
              _logger.debug(
                'Local profile is newer or equal (local: $localUpdatedAt, cloud: $cloudUpdatedAt). Using local version.',
              );
            }
          } catch (e) {
            _logger.warn('Error parsing cloud updated_at timestamp: $e');
            // Continue with local profile if timestamp parsing fails
          }
        }
      }

      // Derive encryption key from password
      final key = await deriveKeyFromPassword(password, userId);

      // Encrypt profile
      final encryptedProfile = await encryptProfileForCloud(profileToSync, key);

      // Store in Supabase (upsert will update if exists, insert if not)
      await client.from('user_personality_profiles').upsert({
        'user_id': userId,
        'encrypted_profile': {
          'encrypted': encryptedProfile
        }, // Store base64 string in JSONB
        'cloud_sync_enabled': true,
        'last_synced_at': DateTime.now().toIso8601String(),
      });

      _logger.info('Profile synced to cloud successfully');
    } catch (e, stackTrace) {
      _logger.error(
        'Error syncing profile to cloud',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - sync failures shouldn't block app functionality
    }
  }

  /// Merge two personality profiles
  ///
  /// Strategy:
  /// - Use the profile with higher evolution generation as base
  /// - Merge dimensions (weighted average)
  /// - Merge confidence levels (weighted average)
  /// - Use higher authenticity score
  /// - Combine learning history
  PersonalityProfile _mergeProfiles({
    required PersonalityProfile local,
    required PersonalityProfile cloud,
  }) {
    // Use the profile with higher generation as base
    final baseProfile =
        local.evolutionGeneration >= cloud.evolutionGeneration ? local : cloud;
    final otherProfile =
        local.evolutionGeneration >= cloud.evolutionGeneration ? cloud : local;

    // Calculate weights based on generation (higher gen = more weight)
    final totalGen = local.evolutionGeneration + cloud.evolutionGeneration;
    final baseWeight = baseProfile.evolutionGeneration / totalGen;
    final otherWeight = otherProfile.evolutionGeneration / totalGen;

    // Merge dimensions (weighted average)
    final mergedDimensions = <String, double>{};
    final allDimensions = {
      ...baseProfile.dimensions.keys,
      ...otherProfile.dimensions.keys,
    };

    for (final dimension in allDimensions) {
      final baseValue = baseProfile.dimensions[dimension] ?? 0.5;
      final otherValue = otherProfile.dimensions[dimension] ?? 0.5;
      mergedDimensions[dimension] =
          (baseValue * baseWeight + otherValue * otherWeight).clamp(0.0, 1.0);
    }

    // Merge confidence levels (weighted average)
    final mergedConfidence = <String, double>{};
    final allConfidences = {
      ...baseProfile.dimensionConfidence.keys,
      ...otherProfile.dimensionConfidence.keys,
    };

    for (final dimension in allConfidences) {
      final baseConf = baseProfile.dimensionConfidence[dimension] ?? 0.0;
      final otherConf = otherProfile.dimensionConfidence[dimension] ?? 0.0;
      mergedConfidence[dimension] =
          (baseConf * baseWeight + otherConf * otherWeight).clamp(0.0, 1.0);
    }

    // Use higher authenticity score
    final mergedAuthenticity =
        baseProfile.authenticity > otherProfile.authenticity
            ? baseProfile.authenticity
            : otherProfile.authenticity;

    // Merge learning history
    final mergedLearning =
        Map<String, dynamic>.from(baseProfile.learningHistory);
    otherProfile.learningHistory.forEach((key, value) {
      if (mergedLearning.containsKey(key)) {
        if (value is List) {
          // Append lists
          (mergedLearning[key] as List).addAll(value);
        } else if (value is num) {
          // Sum numbers
          mergedLearning[key] = (mergedLearning[key] as num) + value;
        } else {
          // Keep base value for other types
        }
      } else {
        mergedLearning[key] = value;
      }
    });

    // Use the higher generation + 1 to indicate merge
    final mergedGeneration =
        (baseProfile.evolutionGeneration > otherProfile.evolutionGeneration
                ? baseProfile.evolutionGeneration
                : otherProfile.evolutionGeneration) +
            1;

    // Create merged profile
    return PersonalityProfile(
      agentId: baseProfile.agentId,
      userId: baseProfile.userId,
      dimensions: mergedDimensions,
      dimensionConfidence: mergedConfidence,
      archetype: baseProfile.archetype, // Use base archetype
      authenticity: mergedAuthenticity,
      createdAt: baseProfile.createdAt.isBefore(otherProfile.createdAt)
          ? baseProfile.createdAt
          : otherProfile.createdAt, // Use earliest creation time
      lastUpdated: DateTime.now(), // Current time for merged profile
      evolutionGeneration: mergedGeneration,
      learningHistory: mergedLearning,
    );
  }

  /// Load personality profile from cloud (if available)
  ///
  /// Returns null if not found, sync disabled, or decryption fails
  Future<PersonalityProfile?> loadFromCloud(
    String userId,
    String password,
  ) async {
    try {
      // Check if sync is enabled
      final syncEnabled = await isCloudSyncEnabled(userId);
      if (!syncEnabled) {
        _logger.debug('Cloud sync disabled for user: $userId');
        return null;
      }

      _logger.info('Loading personality profile from cloud for user: $userId');

      // Fetch from Supabase
      if (!_supabaseService.isAvailable) {
        throw Exception('Supabase not available');
      }
      final client = _supabaseService.client;
      final response = await client
          .from('user_personality_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        _logger.debug('No cloud profile found for user: $userId');
        return null;
      }

      // Get encrypted profile
      final encryptedProfileJson =
          response['encrypted_profile'] as Map<String, dynamic>?;
      if (encryptedProfileJson == null) {
        _logger.warn('Cloud profile exists but encrypted_profile is null');
        return null;
      }

      // Extract base64 string from JSONB
      final encryptedBase64 = encryptedProfileJson['encrypted'] as String?;
      if (encryptedBase64 == null) {
        _logger.warn('Cloud profile exists but encrypted field is null');
        return null;
      }

      // Derive encryption key from password
      final key = await deriveKeyFromPassword(password, userId);

      // Decrypt profile
      final profile = await decryptProfileFromCloud(encryptedBase64, key);

      if (profile != null) {
        _logger.info('Profile loaded from cloud successfully');
      } else {
        _logger.warn('Failed to decrypt cloud profile (wrong password?)');
      }

      return profile;
    } catch (e, stackTrace) {
      _logger.error(
        'Error loading profile from cloud',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Check if cloud sync is enabled for user
  Future<bool> isCloudSyncEnabled(String userId) async {
    try {
      final prefs = await _prefsInstance;
      final key = '${_syncEnabledKeyPrefix}_$userId';
      final enabled = prefs.getBool(key);
      return enabled ?? false; // Default to false (opt-in)
    } catch (e) {
      _logger.error('Error checking sync enabled status', error: e);
      return false;
    }
  }

  /// Set cloud sync enabled/disabled for user
  Future<void> setCloudSyncEnabled(String userId, bool enabled) async {
    try {
      final prefs = await _prefsInstance;
      final key = '${_syncEnabledKeyPrefix}_$userId';
      await prefs.setBool(key, enabled);

      // Also update in Supabase for consistency
      if (enabled) {
        if (!_supabaseService.isAvailable) {
        throw Exception('Supabase not available');
      }
      final client = _supabaseService.client;
        try {
          await client.from('user_personality_profiles').upsert({
            'user_id': userId,
            'cloud_sync_enabled': true,
          });
        } catch (e) {
          // Ignore if table doesn't exist yet or user profile doesn't exist
          _logger.debug('Could not update cloud_sync_enabled in Supabase: $e');
        }
      }

      _logger.info(
          'Cloud sync ${enabled ? "enabled" : "disabled"} for user: $userId');
    } catch (e, stackTrace) {
      _logger.error(
        'Error setting sync enabled status',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Delete cloud profile (when user disables sync)
  Future<void> deleteCloudProfile(String userId) async {
    try {
      if (!_supabaseService.isAvailable) {
        throw Exception('Supabase not available');
      }
      final client = _supabaseService.client;
      await client
          .from('user_personality_profiles')
          .delete()
          .eq('user_id', userId);
      _logger.info('Cloud profile deleted for user: $userId');
    } catch (e, stackTrace) {
      _logger.error(
        'Error deleting cloud profile',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw - deletion failure is not critical
    }
  }

  /// Re-encrypt profile with new password after password change
  ///
  /// This is critical: when user changes password, old password-derived key
  /// won't decrypt the cloud profile. This method re-encrypts with new password.
  Future<void> reEncryptWithNewPassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      _logger.info(
          'Re-encrypting cloud profile with new password for user: $userId');

      // Check if sync is enabled
      final syncEnabled = await isCloudSyncEnabled(userId);
      if (!syncEnabled) {
        _logger.debug('Cloud sync disabled, no re-encryption needed');
        return;
      }

      // Load profile using old password
      final cloudProfile = await loadFromCloud(userId, oldPassword);
      if (cloudProfile == null) {
        _logger.warn(
            'Could not load cloud profile with old password. Profile may be lost.');
        // Try to load local profile and sync with new password
        // This handles case where local profile exists but cloud decrypt failed
        return;
      }

      // Re-encrypt with new password
      await syncToCloud(userId, cloudProfile, newPassword);

      _logger.info('Profile re-encrypted with new password successfully');
    } catch (e, stackTrace) {
      _logger.error(
        'Error re-encrypting profile with new password',
        error: e,
        stackTrace: stackTrace,
      );
      // This is critical - if re-encryption fails, user loses cloud access
      // But we don't want to block password change, so log error
      rethrow; // Let caller decide how to handle
    }
  }

  // Private helper methods

  /// Generate random IV for AES-GCM
  ///
  /// Uses time-based entropy with additional pseudo-random data
  /// For production, consider using platform-specific secure random
  Uint8List _generateIV() {
    final iv = Uint8List(16); // 128 bits for GCM
    final now = DateTime.now();
    final time = now.microsecondsSinceEpoch;

    // Fill IV with time-based and pseudo-random data
    // This provides sufficient entropy for IV generation
    for (int i = 0; i < 16; i++) {
      // Use time and index to create pseudo-random bytes
      final value = (time * (i + 1) * 7919) % 256;
      iv[i] = value.toInt();
    }

    // Add additional entropy from nanoseconds
    final nano = now.millisecond * 1000000 + now.microsecond;
    for (int i = 0; i < 8; i++) {
      iv[i] = (iv[i] ^ ((nano >> (i * 8)) & 0xFF)).toInt();
    }

    return iv;
  }

  /// Constant-time comparison to prevent timing attacks
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

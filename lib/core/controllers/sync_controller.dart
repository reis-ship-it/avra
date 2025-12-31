import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';

import 'package:spots/core/controllers/base/workflow_controller.dart';
import 'package:spots/core/controllers/base/controller_result.dart';
import 'package:spots/core/services/enhanced_connectivity_service.dart';
import 'package:spots_ai/services/personality_sync_service.dart';
import 'package:spots/core/services/storage_service.dart';
import 'package:spots_ai/models/personality_profile.dart';
import 'package:spots/core/ai/personality_learning.dart';

// Import for SharedPreferencesCompat (matches injection_container.dart)
import 'package:spots/core/services/storage_service.dart'
    show SharedPreferencesCompat;

/// Sync Controller
///
/// Orchestrates data synchronization between local and cloud storage.
/// Coordinates connectivity checks, conflict detection, and sync operations
/// for personality profiles and other user data.
///
/// **Responsibilities:**
/// - Check connectivity before sync
/// - Sync personality profile to/from cloud
/// - Detect and resolve conflicts
/// - Handle sync errors gracefully
/// - Return unified sync results
///
/// **Dependencies:**
/// - `EnhancedConnectivityService` - Check connectivity
/// - `PersonalitySyncService` - Sync personality profiles
/// - `PersonalityLearning` - Load local personality profile
/// - `StorageService` - Local storage operations
///
/// **Usage:**
/// ```dart
/// final controller = SyncController();
/// final result = await controller.syncUserData(
///   userId: 'user_123',
///   password: 'user_password',
///   scope: SyncScope.personality,
/// );
///
/// if (result.isSuccess) {
///   // Sync completed successfully
/// } else {
///   // Handle errors
/// }
/// ```
class SyncController implements WorkflowController<SyncInput, SyncResult> {
  static const String _logName = 'SyncController';

  final EnhancedConnectivityService _connectivityService;
  final PersonalitySyncService _personalitySyncService;
  final PersonalityLearning _personalityLearning;

  SyncController({
    EnhancedConnectivityService? connectivityService,
    PersonalitySyncService? personalitySyncService,
    PersonalityLearning? personalityLearning,
  })  : _connectivityService =
            connectivityService ?? EnhancedConnectivityService(),
        _personalitySyncService =
            personalitySyncService ?? PersonalitySyncService(),
        _personalityLearning = personalityLearning ??
            (() {
              // Use same pattern as injection_container.dart
              final prefs = GetIt.instance<SharedPreferencesCompat>();
              return PersonalityLearning.withPrefs(prefs);
            })();

  /// Sync user data to/from cloud
  ///
  /// Orchestrates the complete sync workflow:
  /// 1. Check connectivity
  /// 2. Load local data
  /// 3. Sync based on scope
  /// 4. Handle conflicts
  /// 5. Return unified result
  ///
  /// **Parameters:**
  /// - `userId`: User ID to sync data for
  /// - `password`: User password (for encryption key derivation)
  /// - `scope`: What data to sync (personality, preferences, all)
  ///
  /// **Returns:**
  /// SyncResult with success/error state and sync details
  Future<SyncResult> syncUserData({
    required String userId,
    required String password,
    SyncScope scope = SyncScope.all,
  }) async {
    try {
      developer.log('Starting sync for user: $userId, scope: $scope',
          name: _logName);

      // 1. Check connectivity
      final hasConnectivity = await _connectivityService.hasInternetAccess();
      if (!hasConnectivity) {
        developer.log('No internet connectivity, cannot sync', name: _logName);
        return const SyncResult.failure(
          error:
              'No internet connectivity. Please check your connection and try again.',
          errorCode: 'NO_CONNECTIVITY',
        );
      }

      // 2. Check if sync is enabled
      final syncEnabled =
          await _personalitySyncService.isCloudSyncEnabled(userId);
      if (!syncEnabled) {
        developer.log('Cloud sync disabled for user: $userId', name: _logName);
        return const SyncResult.failure(
          error:
              'Cloud sync is disabled. Enable it in settings to sync your data.',
          errorCode: 'SYNC_DISABLED',
        );
      }

      // 3. Sync based on scope
      final syncDetails = <String, dynamic>{};

      if (scope == SyncScope.personality || scope == SyncScope.all) {
        try {
          // Load local personality profile
          final localProfile =
              await _personalityLearning.initializePersonality(userId);

          // Sync to cloud
          await _personalitySyncService.syncToCloud(
            userId,
            localProfile,
            password,
          );

          syncDetails['personality'] = 'synced';
          developer.log('Personality profile synced successfully',
              name: _logName);
        } catch (e, stackTrace) {
          developer.log(
            'Error syncing personality profile',
            error: e,
            stackTrace: stackTrace,
            name: _logName,
          );
          syncDetails['personality'] = 'failed: ${e.toString()}';
          // Continue with other sync operations even if one fails
        }
      }

      // TODO(Phase 8.12): Add preferences profile sync when cloud sync is implemented
      // if (scope == SyncScope.preferences || scope == SyncScope.all) {
      //   // Sync preferences profile
      // }

      developer.log('Sync completed for user: $userId', name: _logName);
      return SyncResult.success(
        syncedItems: syncDetails,
        syncTimestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sync',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return SyncResult.failure(
        error: 'Sync failed: ${e.toString()}',
        errorCode: 'SYNC_FAILED',
      );
    }
  }

  /// Load data from cloud
  ///
  /// Downloads data from cloud and merges with local data.
  /// Handles conflicts by merging profiles.
  ///
  /// **Parameters:**
  /// - `userId`: User ID
  /// - `password`: User password (for decryption)
  /// - `scope`: What data to load
  ///
  /// **Returns:**
  /// SyncResult with loaded data
  Future<SyncResult> loadFromCloud({
    required String userId,
    required String password,
    SyncScope scope = SyncScope.all,
  }) async {
    try {
      developer.log('Loading data from cloud for user: $userId',
          name: _logName);

      // 1. Check connectivity
      final hasConnectivity = await _connectivityService.hasInternetAccess();
      if (!hasConnectivity) {
        return const SyncResult.failure(
          error:
              'No internet connectivity. Please check your connection and try again.',
          errorCode: 'NO_CONNECTIVITY',
        );
      }

      // 2. Check if sync is enabled
      final syncEnabled =
          await _personalitySyncService.isCloudSyncEnabled(userId);
      if (!syncEnabled) {
        return const SyncResult.failure(
          error:
              'Cloud sync is disabled. Enable it in settings to load your data.',
          errorCode: 'SYNC_DISABLED',
        );
      }

      final loadedItems = <String, dynamic>{};

      // 3. Load personality profile from cloud
      if (scope == SyncScope.personality || scope == SyncScope.all) {
        try {
          final cloudProfile = await _personalitySyncService.loadFromCloud(
            userId,
            password,
          );

          if (cloudProfile != null) {
            // PersonalitySyncService handles merging during syncToCloud
            // For loadFromCloud, we just return the cloud profile
            loadedItems['personality'] = cloudProfile;
            developer.log('Personality profile loaded from cloud',
                name: _logName);
          } else {
            loadedItems['personality'] = 'not_found';
          }
        } catch (e, stackTrace) {
          developer.log(
            'Error loading personality profile from cloud',
            error: e,
            stackTrace: stackTrace,
            name: _logName,
          );
          loadedItems['personality'] = 'failed: ${e.toString()}';
        }
      }

      return SyncResult.success(
        syncedItems: loadedItems,
        syncTimestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error loading from cloud',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return SyncResult.failure(
        error: 'Load failed: ${e.toString()}',
        errorCode: 'LOAD_FAILED',
      );
    }
  }

  // WorkflowController interface implementation

  @override
  Future<SyncResult> execute(SyncInput input) async {
    return await syncUserData(
      userId: input.userId,
      password: input.password,
      scope: input.scope,
    );
  }

  @override
  ValidationResult validate(SyncInput input) {
    final errors = <String, String>{};

    if (input.userId.isEmpty) {
      errors['userId'] = 'User ID is required';
    }

    if (input.password.isEmpty) {
      errors['password'] = 'Password is required';
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      fieldErrors: errors,
    );
  }

  @override
  Future<void> rollback(SyncResult result) async {
    // Sync operations are idempotent and don't require rollback
    // If sync fails, local data remains unchanged
    developer.log('Rollback not needed for sync operations', name: _logName);
  }
}

/// Sync scope - what data to sync
enum SyncScope {
  /// Sync personality profile only
  personality,

  /// Sync preferences profile only (future)
  preferences,

  /// Sync all available data
  all,
}

/// Input for sync operations
class SyncInput {
  final String userId;
  final String password;
  final SyncScope scope;

  const SyncInput({
    required this.userId,
    required this.password,
    this.scope = SyncScope.all,
  });
}

/// Result of sync operations
class SyncResult extends ControllerResult {
  final Map<String, dynamic> syncedItems;
  final DateTime? syncTimestamp;

  const SyncResult.success({
    required this.syncedItems,
    this.syncTimestamp,
  }) : super(
          success: true,
          error: null,
          errorCode: null,
        );

  const SyncResult.failure({
    required String super.error,
    super.errorCode,
    this.syncedItems = const {},
    this.syncTimestamp,
  }) : super(
          success: false,
        );

  /// Get synced personality profile (if available)
  PersonalityProfile? get personalityProfile {
    final personality = syncedItems['personality'];
    if (personality is PersonalityProfile) {
      return personality;
    }
    return null;
  }
}

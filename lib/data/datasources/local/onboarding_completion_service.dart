import 'package:avrai/core/services/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:avrai/data/datasources/local/sembast_database.dart';

class OnboardingCompletionService {
  static const String _logName = 'OnboardingCompletionService';
  static const String _completionKeyPrefix = 'onboarding_completed_';
  static const AppLogger _logger =
      AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);

  // In-memory cache to prevent race conditions (especially on web)
  static final Map<String, bool> _completionCache = {};

  /// Get the completion key for a specific user
  static String _getCompletionKey(String userId) =>
      '$_completionKeyPrefix$userId';

  /// Check if onboarding has been completed for a specific user
  static Future<bool> isOnboardingCompleted([String? userId]) async {
    try {
      // If no userId provided, return false (new user needs onboarding)
      if (userId == null || userId.isEmpty) {
        _logger.debug(
            '🔍 [CHECK] No userId provided, assuming onboarding not completed',
            tag: _logName);
        return false;
      }

      // Check cache first (for recently completed onboarding)
      if (_completionCache.containsKey(userId)) {
        final cached = _completionCache[userId]!;
        _logger.debug(
            '🔍 [CHECK_CACHE] Onboarding completion status from cache for user $userId: $cached',
            tag: _logName);
        return cached;
      }

      _logger.debug(
          '🔍 [CHECK_DB] Cache miss, checking database for user $userId...',
          tag: _logName);
      final db = await SembastDatabase.database;
      final completionKey = _getCompletionKey(userId);
      final record =
          await SembastDatabase.onboardingStore.record(completionKey).get(db);

      if (record != null) {
        final isCompleted = record['completed'] as bool? ?? false;
        final completedAt = record['completed_at'] as String?;
        // Update cache
        _completionCache[userId] = isCompleted;
        _logger.info(
            '🔍 [CHECK_DB] Onboarding completion status for user $userId: $isCompleted (completed_at: $completedAt)',
            tag: _logName);
        return isCompleted;
      }

      // Update cache with false
      _completionCache[userId] = false;
      _logger.info(
          '🔍 [CHECK_DB] No onboarding completion record found for user $userId',
          tag: _logName);
      return false;
    } catch (e) {
      _logger.error(
          '❌ [CHECK_ERROR] Error checking onboarding completion for user $userId',
          tag: _logName,
          error: e);
      // Return cached value if available, otherwise false
      final cachedValue = _completionCache[userId] ?? false;
      _logger.debug('🔍 [CHECK_ERROR] Returning cached value: $cachedValue',
          tag: _logName);
      return cachedValue;
    }
  }

  /// Mark onboarding as completed for a specific user
  /// Returns true if successfully marked and verified, false otherwise
  static Future<bool> markOnboardingCompleted(String userId) async {
    final startTime = DateTime.now();
    try {
      if (userId.isEmpty) {
        _logger.warn('Cannot mark onboarding completed: userId is empty',
            tag: _logName);
        return false;
      }

      _logger.info(
          '🚀 [MARK_START] Starting markOnboardingCompleted for user $userId',
          tag: _logName);

      final db = await SembastDatabase.database;
      final completionKey = _getCompletionKey(userId);

      // Step 1: Update cache immediately (before database write)
      _completionCache[userId] = true;
      _logger.debug('✅ [MARK_STEP1] Cache set to true for user $userId',
          tag: _logName);

      // Step 2: Write the completion record
      _logger.debug('📝 [MARK_STEP2] Writing to database for user $userId...',
          tag: _logName);
      await SembastDatabase.onboardingStore.record(completionKey).put(db, {
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
        'user_id': userId,
      });
      _logger.debug('✅ [MARK_STEP2] Database write completed for user $userId',
          tag: _logName);

      // Step 3: Force a commit by reading back in a transaction
      _logger.debug(
          '🔄 [MARK_STEP3] Verifying write in transaction for user $userId...',
          tag: _logName);
      bool transactionVerified = false;
      await db.transaction((txn) async {
        final record = await SembastDatabase.onboardingStore
            .record(completionKey)
            .get(txn);
        if (record == null) {
          _logger.warn(
              '⚠️ [MARK_STEP3] Write verification failed - record not found in transaction for user $userId',
              tag: _logName);
          transactionVerified = false;
        } else {
          final isCompleted = record['completed'] as bool? ?? false;
          _logger.debug(
              '✅ [MARK_STEP3] Write verified in transaction for user $userId: completed=$isCompleted',
              tag: _logName);
          transactionVerified = isCompleted;
        }
      });

      if (!transactionVerified) {
        _logger.error(
            '❌ [MARK_STEP3] Transaction verification failed for user $userId',
            tag: _logName);
        // Keep cache as true - write might still be in progress
        _completionCache[userId] = true;
        return false;
      }

      // Step 4: Additional verification with multiple strategies
      _logger.debug(
          '🔄 [MARK_STEP4] Starting multi-strategy verification for user $userId...',
          tag: _logName);

      // Strategy 1: Immediate check (should hit cache)
      bool verified1 = await isOnboardingCompleted(userId);
      _logger.debug(
          '🔍 [MARK_STEP4_STRAT1] Immediate check result: $verified1 (should be true from cache)',
          tag: _logName);

      // Strategy 2: Check after short delay (for web IndexedDB)
      await Future.delayed(const Duration(milliseconds: 100));
      bool verified2 = await isOnboardingCompleted(userId);
      _logger.debug(
          '🔍 [MARK_STEP4_STRAT2] Delayed check (100ms) result: $verified2',
          tag: _logName);

      // Strategy 3: Direct database read (bypass cache)
      bool verified3 = false;
      try {
        final record =
            await SembastDatabase.onboardingStore.record(completionKey).get(db);
        if (record != null) {
          verified3 = record['completed'] as bool? ?? false;
        }
        _logger.debug(
            '🔍 [MARK_STEP4_STRAT3] Direct DB read result: $verified3',
            tag: _logName);
      } catch (e) {
        _logger.warn('⚠️ [MARK_STEP4_STRAT3] Direct DB read failed: $e',
            tag: _logName);
      }

      // Strategy 4: Final check after longer delay (for slow IndexedDB)
      await Future.delayed(const Duration(milliseconds: 200));
      bool verified4 = await isOnboardingCompleted(userId);
      _logger.debug(
          '🔍 [MARK_STEP4_STRAT4] Final delayed check (300ms total) result: $verified4',
          tag: _logName);

      // All strategies should pass
      final allVerified = verified1 && verified2 && verified3 && verified4;
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;

      if (allVerified) {
        _logger.info(
            '✅ [MARK_SUCCESS] Onboarding marked as completed and fully verified for user $userId (took ${elapsed}ms)',
            tag: _logName);
        return true;
      } else {
        _logger.error(
            '❌ [MARK_PARTIAL] Onboarding marked but verification incomplete for user $userId. Results: cache=$verified1, delayed=$verified2, direct=$verified3, final=$verified4 (took ${elapsed}ms)',
            tag: _logName);
        // Keep cache as true even if verification fails (write might still be in progress)
        _completionCache[userId] = true;
        return false;
      }
    } catch (e, stackTrace) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      _logger.error(
          '❌ [MARK_ERROR] Error marking onboarding completed for user $userId (took ${elapsed}ms)',
          tag: _logName,
          error: e);
      _logger.debug('Stack trace: $stackTrace', tag: _logName);
      // Keep cache as true on error
      _completionCache[userId] = true;
      rethrow; // Re-throw to let caller know it failed
    }
  }

  /// Reset onboarding completion status for a specific user (for testing)
  static Future<void> resetOnboardingCompletion(String userId) async {
    try {
      // Clear cache first
      _completionCache.remove(userId);
      _logger.info('🗑️ [RESET] Cache cleared for user $userId', tag: _logName);

      final db = await SembastDatabase.database;
      final completionKey = _getCompletionKey(userId);

      // Delete the record within a transaction to ensure it's committed
      await db.transaction((txn) async {
        await SembastDatabase.onboardingStore.record(completionKey).delete(txn);
        _logger.info(
            '🗑️ [RESET] Database record deleted in transaction for user $userId',
            tag: _logName);
      });

      // Force a flush by reading back in a new transaction
      await db.transaction((txn) async {
        final record = await SembastDatabase.onboardingStore
            .record(completionKey)
            .get(txn);
        if (record == null) {
          _logger.info(
              '✅ [RESET] Onboarding completion status reset for user $userId (verified in transaction)',
              tag: _logName);
        } else {
          _logger.warn(
              '⚠️ [RESET] Record still exists after deletion for user $userId',
              tag: _logName);
        }
      });

      // Additional verification outside transaction
      final record =
          await SembastDatabase.onboardingStore.record(completionKey).get(db);
      if (record == null) {
        _logger.info(
            '✅ [RESET] Onboarding completion status reset for user $userId (verified outside transaction)',
            tag: _logName);
      } else {
        _logger.warn(
            '⚠️ [RESET] Record still exists after deletion for user $userId (outside transaction)',
            tag: _logName);
      }

      // Force a small delay to ensure all writes are flushed
      await Future.delayed(const Duration(milliseconds: 200));

      // Final verification after delay
      final finalRecord =
          await SembastDatabase.onboardingStore.record(completionKey).get(db);
      if (finalRecord == null) {
        _logger.info(
            '✅ [RESET] Final verification: Onboarding completion status reset for user $userId',
            tag: _logName);
      } else {
        _logger.warn(
            '⚠️ [RESET] Final verification: Record still exists for user $userId',
            tag: _logName);
      }
    } catch (e, stackTrace) {
      _logger.error('❌ [RESET] Error resetting onboarding completion',
          tag: _logName, error: e);
      _logger.debug('Stack trace: $stackTrace', tag: _logName);
    }
  }

  /// Clear the cache for a specific user (useful for testing)
  static void clearCache(String userId) {
    _completionCache.remove(userId);
    _logger.info('🗑️ [CACHE] Cache cleared for user $userId', tag: _logName);
  }

  /// Clear all cache (useful for testing)
  static void clearAllCache() {
    _completionCache.clear();
    _logger.info('🗑️ [CACHE] All cache cleared', tag: _logName);
  }
}

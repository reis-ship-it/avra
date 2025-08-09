import 'package:spots/core/services/logger.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:sembast/sembast.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';

class OnboardingCompletionService {
  static const String _logName = 'OnboardingCompletionService';
  static const String _completionKey = 'onboarding_completed';
  static const AppLogger _logger = AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      final db = await SembastDatabase.database;
      final record = await SembastDatabase.onboardingStore.record(_completionKey).get(db);
      
      if (record != null) {
        final isCompleted = record['completed'] as bool? ?? false;
        _logger.info('Onboarding completion status: $isCompleted', tag: _logName);
        return isCompleted;
      }
      
      _logger.info('No onboarding completion record found', tag: _logName);
      return false;
    } catch (e) {
      _logger.error('Error checking onboarding completion', tag: _logName, error: e);
      return false;
    }
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    try {
      final db = await SembastDatabase.database;
      await SembastDatabase.onboardingStore.record(_completionKey).put(db, {
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      });
      _logger.info('Onboarding marked as completed', tag: _logName);
    } catch (e) {
      _logger.error('Error marking onboarding completed', tag: _logName, error: e);
    }
  }

  /// Reset onboarding completion status (for testing)
  static Future<void> resetOnboardingCompletion() async {
    try {
      final db = await SembastDatabase.database;
      await SembastDatabase.onboardingStore.record(_completionKey).delete(db);
      _logger.info('Onboarding completion status reset', tag: _logName);
    } catch (e) {
      _logger.error('Error resetting onboarding completion', tag: _logName, error: e);
    }
  }
} 
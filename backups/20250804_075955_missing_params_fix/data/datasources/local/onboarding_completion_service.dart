import 'dart:developer' as developer;
import 'package:spots/core/models/unified_models.dart';import 'package:sembast/sembast.dart';
import 'package:spots/data/datasources/local/sembast/sembast/sembast_database.dart';

class OnboardingCompletionService {
  static const String _logName = 'OnboardingCompletionService';
  static const String _completionKey = 'onboarding_completed';

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      final db = await SembastDatabase.database;
      final record = await SembastDatabase.onboardingStore.record(_completionKey).get(db);
      
      if (record != null) {
        final isCompleted = record['completed'] as bool? ?? false;
        developer.log('Onboarding completion status: $isCompleted', name: _logName);
        return isCompleted;
      }
      
      developer.log('No onboarding completion record found', name: _logName);
      return false;
    } catch (e) {
      developer.log('Error checking onboarding completion: $e', name: _logName);
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
      developer.log('Onboarding marked as completed', name: _logName);
    } catch (e) {
      developer.log('Error marking onboarding completed: $e', name: _logName);
    }
  }

  /// Reset onboarding completion status (for testing)
  static Future<void> resetOnboardingCompletion() async {
    try {
      final db = await SembastDatabase.database;
      await SembastDatabase.onboardingStore.record(_completionKey).delete(db);
      developer.log('Onboarding completion status reset', name: _logName);
    } catch (e) {
      developer.log('Error resetting onboarding completion: $e', name: _logName);
    }
  }
} 
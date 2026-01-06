// ignore_for_file: avoid_print

import 'package:spots/data/datasources/local/onboarding_completion_service.dart';
import 'package:spots/data/datasources/local/sembast_database.dart';

/// Helper to reset onboarding for testing
Future<void> resetOnboardingForUser(String userId) async {
  print('🔄 Resetting onboarding for user: $userId');
  await SembastDatabase.database;
  await OnboardingCompletionService.resetOnboardingCompletion(userId);
  final isCompleted =
      await OnboardingCompletionService.isOnboardingCompleted(userId);
  print(
      '✅ Onboarding reset. Status: ${isCompleted ? "COMPLETED" : "NOT COMPLETED"}');
}

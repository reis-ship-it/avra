import 'package:avrai/data/datasources/local/onboarding_completion_service.dart';
// ignore_for_file: avoid_print - Script file
import 'package:avrai/data/datasources/local/sembast_database.dart';

void main() async {
  print('🔄 Resetting onboarding completion for demo-user-1...');

  // Initialize database
  await SembastDatabase.database;

  // Reset onboarding
  await OnboardingCompletionService.resetOnboardingCompletion('demo-user-1');

  // Verify it's reset
  final isCompleted =
      await OnboardingCompletionService.isOnboardingCompleted('demo-user-1');
  print(
      '✅ Onboarding reset complete. Status: ${isCompleted ? "COMPLETED" : "NOT COMPLETED"}');
}

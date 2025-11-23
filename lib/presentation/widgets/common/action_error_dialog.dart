/// Action Error Dialog Widget
/// 
/// Part of Feature Matrix Phase 1: Action Execution UI & Integration
/// 
/// Displays an error dialog when an AI action fails, showing:
/// - Error message
/// - Optional retry mechanism
/// - Intent context (what failed)
/// 
/// Uses AppColors and AppTheme for consistent styling per design token requirements.

import 'package:flutter/material.dart';
import 'package:spots/core/ai/action_models.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/core/theme/app_theme.dart';

/// Dialog widget that shows action failure details
class ActionErrorDialog extends StatelessWidget {
  /// The error message to display
  final String error;
  
  /// The intent that failed (optional)
  final ActionIntent? intent;
  
  /// Callback when user dismisses the dialog
  final VoidCallback onDismiss;
  
  /// Callback when user wants to retry (optional)
  final VoidCallback? onRetry;

  const ActionErrorDialog({
    super.key,
    required this.error,
    this.intent,
    required this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Action Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intent != null) ...[
            Text(
              _getFailureContext(intent!),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onDismiss();
            Navigator.of(context).pop();
          },
          child: Text(
            'Dismiss',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              onRetry!();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricGreen,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  String _getFailureContext(ActionIntent intent) {
    if (intent is CreateSpotIntent) {
      return 'Failed to create spot';
    } else if (intent is CreateListIntent) {
      return 'Failed to create list';
    } else if (intent is AddSpotToListIntent) {
      return 'Failed to add spot to list';
    }
    return 'Failed to execute action';
  }
}


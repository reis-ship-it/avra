/// Federated Participation History Widget
/// 
/// Part of Feature Matrix Phase 2: Medium Priority UI/UX
/// 
/// Widget showing user's participation history in federated learning:
/// - Participation history (user-specific)
/// - Contribution metrics (rounds participated, contributions made)
/// - Benefits earned from participation
/// - Participation streak
/// - Completion rate
/// 
/// Location: Settings/Account page (within Federated Learning section)
/// Uses AppColors and AppTheme for consistent styling per design token requirements.

import 'package:flutter/material.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Model representing user's participation history in federated learning
class ParticipationHistory {
  /// Total number of rounds user has participated in
  final int totalRoundsParticipated;
  
  /// Number of rounds completed successfully
  final int completedRounds;
  
  /// Total number of contributions (model updates) made
  final int totalContributions;
  
  /// List of benefits earned from participation
  final List<String> benefitsEarned;
  
  /// Date of last participation
  final DateTime? lastParticipationDate;
  
  /// Current participation streak (consecutive rounds)
  final int participationStreak;
  
  ParticipationHistory({
    required this.totalRoundsParticipated,
    required this.completedRounds,
    required this.totalContributions,
    required this.benefitsEarned,
    this.lastParticipationDate,
    required this.participationStreak,
  });
  
  /// Calculate completion rate (0.0-1.0)
  double get completionRate {
    if (totalRoundsParticipated == 0) return 0.0;
    return completedRounds / totalRoundsParticipated;
  }
  
  /// Calculate average contributions per round
  double get averageContributionsPerRound {
    if (totalRoundsParticipated == 0) return 0.0;
    return totalContributions / totalRoundsParticipated;
  }
}

/// Widget displaying user's federated learning participation history
class FederatedParticipationHistoryWidget extends StatelessWidget {
  /// User's participation history (null if no participation yet)
  final ParticipationHistory? participationHistory;
  
  const FederatedParticipationHistoryWidget({
    super.key,
    this.participationHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.electricGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: AppColors.electricGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Participation History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (participationHistory == null)
                _buildEmptyState()
              else
                _buildHistoryContent(participationHistory!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No participation history yet. Start participating in federated learning rounds to see your contributions here.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(ParticipationHistory history) {
    final completionRate = history.completionRate;
    final completionColor = _getCompletionColor(completionRate);
    
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Rounds',
                  '${history.totalRoundsParticipated}',
                  Icons.sync,
                  AppColors.electricGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '${history.completedRounds}',
                  Icons.check_circle,
                  AppColors.electricGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Contributions',
                  '${history.totalContributions}',
                  Icons.upload,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${history.participationStreak}',
                  Icons.local_fire_department,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Completion Rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: completionColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Completion Rate',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: completionColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionRate,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(completionColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Last Participation
          if (history.lastParticipationDate != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last participation: ${_formatDate(history.lastParticipationDate!)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Benefits Earned
          const Text(
            'Benefits Earned',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (history.benefitsEarned.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No benefits earned yet. Continue participating to unlock benefits!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            )
            else
              ...history.benefitsEarned.map((benefit) => _buildBenefitItem(benefit)),
        ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.electricGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.electricGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            size: 16,
            color: AppColors.electricGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.9) return AppColors.electricGreen;
    if (rate >= 0.7) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}


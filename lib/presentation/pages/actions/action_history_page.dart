/// Action History Page
/// 
/// Part of Feature Matrix Phase 1: Action Execution UI & Integration
/// 
/// Displays the history of executed actions with:
/// - List of all actions (most recent first)
/// - Action details (intent, result, timestamp)
/// - Undo functionality for successful actions
/// - Visual indicators for success/failure/undone status
/// 
/// Uses AppColors and AppTheme for consistent styling per design token requirements.

import 'package:flutter/material.dart';
import 'package:spots/core/ai/action_history_entry.dart';
import 'package:spots/core/services/action_history_service.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/core/theme/app_theme.dart';

/// Page that displays action execution history
/// 
/// Shows a scrollable list of all actions executed by the AI,
/// with the ability to undo successful actions.
class ActionHistoryPage extends StatefulWidget {
  final ActionHistoryService service;
  final String? userId; // Optional: filter by user ID

  const ActionHistoryPage({
    super.key,
    required this.service,
    this.userId,
  });

  @override
  State<ActionHistoryPage> createState() => _ActionHistoryPageState();
}

class _ActionHistoryPageState extends State<ActionHistoryPage> {
  List<ActionHistoryEntry> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await widget.service.getHistory(
      userId: widget.userId,
    );

    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUndo(ActionHistoryEntry entry) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.undo, color: AppColors.electricGreen),
            SizedBox(width: 8),
            Text('Undo Action'),
          ],
        ),
        content: Text(
          'Are you sure you want to undo this action? This cannot be reversed.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricGreen,
              foregroundColor: AppColors.black,
            ),
            child: const Text('Undo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.service.markAsUndone(entry.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action undone'),
            backgroundColor: AppColors.electricGreen,
          ),
        );
        _loadHistory(); // Refresh list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Action History'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.electricGreen,
              ),
            )
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No action history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actions executed by AI will appear here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _history[index];
        return _buildHistoryItem(entry);
      },
    );
  }

  Widget _buildHistoryItem(ActionHistoryEntry entry) {
    final icon = _getIconForIntent(entry.intent.type);
    final title = _getTitleForIntent(entry.intent.type);
    final subtitle = _getSubtitleForEntry(entry);
    final timeAgo = _formatTimeAgo(entry.timestamp);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: entry.isUndone
              ? AppColors.grey300
              : entry.result.success
                  ? AppColors.electricGreen.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: entry.isUndone
                        ? AppColors.grey200
                        : entry.result.success
                            ? AppColors.electricGreen.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: entry.isUndone
                        ? AppColors.grey600
                        : entry.result.success
                            ? AppColors.electricGreen
                            : AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with undone indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: entry.isUndone
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                decoration: entry.isUndone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (entry.isUndone)
                            Text(
                              '(Undone)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Result message
                      if (entry.result.successMessage != null || entry.result.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: entry.result.success
                                ? AppColors.electricGreen.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.result.success
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                size: 14,
                                color: entry.result.success
                                    ? AppColors.electricGreen
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  entry.result.successMessage ??
                                      entry.result.errorMessage ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: entry.result.success
                                        ? AppColors.electricGreen
                                        : AppColors.error,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      
                      // Timestamp
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Undo button
                if (entry.canUndo && !entry.isUndone)
                  IconButton(
                    icon: const Icon(Icons.undo),
                    color: AppColors.electricGreen,
                    onPressed: () => _handleUndo(entry),
                    tooltip: 'Undo',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIntent(String intentType) {
    switch (intentType) {
      case 'create_spot':
        return Icons.place;
      case 'create_list':
        return Icons.list;
      case 'add_spot_to_list':
        return Icons.add_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getTitleForIntent(String intentType) {
    switch (intentType) {
      case 'create_spot':
        return 'Create Spot';
      case 'create_list':
        return 'Create List';
      case 'add_spot_to_list':
        return 'Add Spot to List';
      default:
        return 'Unknown Action';
    }
  }

  String _getSubtitleForEntry(ActionHistoryEntry entry) {
    final intent = entry.intent;
    
    if (intent.type == 'create_spot') {
      final spotIntent = intent as dynamic;
      return spotIntent.name;
    } else if (intent.type == 'create_list') {
      final listIntent = intent as dynamic;
      return listIntent.title;
    } else if (intent.type == 'add_spot_to_list') {
      final addIntent = intent as dynamic;
      final spotName = addIntent.metadata['spotName'] ?? 'Spot';
      final listName = addIntent.metadata['listName'] ?? 'List';
      return 'Added $spotName to $listName';
    }
    
    return 'Action details';
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}


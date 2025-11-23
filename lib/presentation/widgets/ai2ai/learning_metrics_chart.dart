import 'package:flutter/material.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import 'package:spots/core/theme/colors.dart';

/// Widget displaying learning metrics as a chart
class LearningMetricsChart extends StatelessWidget {
  final RealTimeMetrics metrics;

  const LearningMetricsChart({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMetricBar(
              context,
              'Connection Throughput',
              metrics.connectionThroughput,
              'connections/sec',
            ),
            const SizedBox(height: 12),
            _buildMetricBar(
              context,
              'Matching Success Rate',
              metrics.matchingSuccessRate,
              '%',
              isPercentage: true,
            ),
            const SizedBox(height: 12),
            _buildMetricBar(
              context,
              'Learning Convergence Speed',
              metrics.learningConvergenceSpeed,
              '',
              isPercentage: true,
            ),
            const SizedBox(height: 12),
            _buildMetricBar(
              context,
              'Vibe Synchronization Quality',
              metrics.vibeSynchronizationQuality,
              '',
              isPercentage: true,
            ),
            const SizedBox(height: 12),
            _buildMetricBar(
              context,
              'Network Responsiveness',
              metrics.networkResponsiveness,
              '',
              isPercentage: true,
            ),
            const SizedBox(height: 12),
            _buildMetricBar(
              context,
              'Resource Utilization',
              (metrics.resourceUtilization.cpuUsage + 
               metrics.resourceUtilization.memoryUsage + 
               metrics.resourceUtilization.networkBandwidth + 
               metrics.resourceUtilization.storageUsage) / 4.0,
              '',
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(
    BuildContext context,
    String label,
    double value,
    String unit, {
    bool isPercentage = false,
  }) {
    final displayValue = isPercentage
        ? '${(value * 100).round()}%'
        : value.toStringAsFixed(2);
    final color = _getMetricColor(value, isPercentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$displayValue $unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isPercentage ? value : value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getMetricColor(double value, bool isPercentage) {
    final normalizedValue = isPercentage ? value : value.clamp(0.0, 1.0);
    if (normalizedValue >= 0.8) return AppColors.success;
    if (normalizedValue >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}


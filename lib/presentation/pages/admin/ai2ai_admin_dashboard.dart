import 'package:flutter/material.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import 'package:spots/core/monitoring/connection_monitor.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/presentation/widgets/ai2ai/network_health_gauge.dart';
import 'package:spots/presentation/widgets/ai2ai/connections_list.dart';
import 'package:spots/presentation/widgets/ai2ai/learning_metrics_chart.dart';
import 'package:spots/presentation/widgets/ai2ai/privacy_compliance_card.dart';
import 'package:spots/presentation/widgets/ai2ai/performance_issues_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

/// Admin Dashboard for AI2AI Network Monitoring
/// Displays network health, connections, learning metrics, privacy, and performance
class AI2AIAdminDashboard extends StatefulWidget {
  const AI2AIAdminDashboard({super.key});

  @override
  State<AI2AIAdminDashboard> createState() => _AI2AIAdminDashboardState();
}

class _AI2AIAdminDashboardState extends State<AI2AIAdminDashboard> {
  NetworkAnalytics? _networkAnalytics;
  ConnectionMonitor? _connectionMonitor;
  NetworkHealthReport? _healthReport;
  ActiveConnectionsOverview? _connectionsOverview;
  RealTimeMetrics? _realTimeMetrics;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadDashboardData();
  }

  Future<void> _initializeServices() async {
    try {
      final prefs = GetIt.instance<SharedPreferences>();
      _networkAnalytics = NetworkAnalytics(prefs: prefs);
      _connectionMonitor = ConnectionMonitor(prefs: prefs);
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  Future<void> _loadDashboardData() async {
    if (_networkAnalytics == null || _connectionMonitor == null) {
      await _initializeServices();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final healthReport = await _networkAnalytics!.analyzeNetworkHealth();
      final connectionsOverview = await _connectionMonitor!.getActiveConnectionsOverview();
      final realTimeMetrics = await _networkAnalytics!.collectRealTimeMetrics();

      setState(() {
        _healthReport = healthReport;
        _connectionsOverview = connectionsOverview;
        _realTimeMetrics = realTimeMetrics;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI2AI Network Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshDashboard,
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Network Health Gauge
                    if (_healthReport != null)
                      NetworkHealthGauge(healthReport: _healthReport!),

                    const SizedBox(height: 24),

                    // Connections List
                    if (_connectionsOverview != null)
                      ConnectionsList(overview: _connectionsOverview!),

                    const SizedBox(height: 24),

                    // Learning Metrics Chart
                    if (_realTimeMetrics != null)
                      LearningMetricsChart(metrics: _realTimeMetrics!),

                    const SizedBox(height: 24),

                    // Privacy Compliance Card
                    if (_healthReport != null)
                      PrivacyComplianceCard(
                        privacyMetrics: _healthReport!.privacyMetrics,
                      ),

                    const SizedBox(height: 24),

                    // Performance Issues List
                    if (_healthReport != null)
                      PerformanceIssuesList(
                        issues: _healthReport!.performanceIssues,
                        recommendations: _healthReport!.optimizationRecommendations,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}


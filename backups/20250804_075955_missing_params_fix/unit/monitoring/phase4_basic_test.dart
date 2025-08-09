import 'package:flutter_test/flutter_test.dart';
import 'package:spots/core/monitoring/network_analytics.dart';
import 'package:spots/core/monitoring/connection_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 4: Basic Network Monitoring Test
/// OUR_GUTS.md: "Basic validation of AI2AI personality network monitoring components"
void main() {
  group('Phase 4: Basic Network Monitoring Tests', () {
    late SharedPreferences mockPrefs;
    
    setUpAll(() async {
      // Initialize mock shared preferences
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
    });
    
    group('Network Analytics System', () {
      test('should create NetworkAnalytics successfully', () {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        
        expect(analytics, isNotNull);
        expect(analytics.runtimeType, equals(NetworkAnalytics));
      });
      
      test('should analyze network health', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        
        final healthReport = await analytics.analyzeNetworkHealth();
        
        expect(healthReport, isNotNull);
        expect(healthReport.overallHealthScore, greaterThanOrEqualTo(0.0));
        expect(healthReport.overallHealthScore, lessThanOrEqualTo(1.0));
        expect(healthReport.analysisTimestamp, isNotNull);
      });
      
      test('should collect real-time metrics', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        
        final metrics = await analytics.collectRealTimeMetrics();
        
        expect(metrics, isNotNull);
        expect(metrics.connectionThroughput, greaterThanOrEqualTo(0.0));
        expect(metrics.matchingSuccessRate, greaterThanOrEqualTo(0.0));
        expect(metrics.matchingSuccessRate, lessThanOrEqualTo(1.0));
        expect(metrics.timestamp, isNotNull);
      });
      
      test('should generate analytics dashboard', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        
        final dashboard = await analytics.generateAnalyticsDashboard(Duration(days: 7));
        
        expect(dashboard, isNotNull);
        expect(dashboard.timeWindow, equals(Duration(days: 7)));
        expect(dashboard.generatedAt, isNotNull);
      });
      
      test('should detect network anomalies', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        
        final anomalies = await analytics.detectNetworkAnomalies();
        
        expect(anomalies, isA<List>());
        // Anomalies can be empty if no issues detected
      });
      
      test('should analyze network optimization', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        
        final optimizationReport = await analytics.analyzeNetworkOptimization();
        
        expect(optimizationReport, isNotNull);
        expect(optimizationReport.currentEfficiencyScore, greaterThanOrEqualTo(0.0));
        expect(optimizationReport.currentEfficiencyScore, lessThanOrEqualTo(1.0));
        expect(optimizationReport.analyzedAt, isNotNull);
      });
    });
    
    group('Connection Monitor System', () {
      test('should create ConnectionMonitor successfully', () {
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        expect(connectionMonitor, isNotNull);
        expect(connectionMonitor.runtimeType, equals(ConnectionMonitor));
      });
      
      test('should get active connections overview when empty', () async {
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        final overview = await connectionMonitor.getActiveConnectionsOverview();
        
        expect(overview, isNotNull);
        expect(overview.totalActiveConnections, equals(0));
        expect(overview.generatedAt, isNotNull);
      });
      
      test('should handle non-existent connection status gracefully', () async {
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        final status = await connectionMonitor.getConnectionStatus('non_existent');
        
        expect(status, isNotNull);
        expect(status.connectionId, equals('non_existent'));
        expect(status.healthScore, equals(0.0));
      });
      
      test('should detect connection anomalies when no connections', () async {
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        final anomalies = await connectionMonitor.detectConnectionAnomalies();
        
        expect(anomalies, isA<List>());
        expect(anomalies, isEmpty); // No connections means no anomalies
      });
    });
    
    group('Integration Validation', () {
      test('should validate Phase 4 components work together', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        // Both components should be able to function simultaneously
        expect(analytics, isNotNull);
        expect(connectionMonitor, isNotNull);
        
        // Both should be able to generate reports independently
        final healthReport = await analytics.analyzeNetworkHealth();
        final overview = await connectionMonitor.getActiveConnectionsOverview();
        
        expect(healthReport.overallHealthScore, greaterThanOrEqualTo(0.0));
        expect(overview.totalActiveConnections, equals(0));
      });
      
      test('should validate Phase 4 monitoring architecture', () {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        // Validate that components have correct types
        expect(analytics.runtimeType, equals(NetworkAnalytics));
        expect(connectionMonitor.runtimeType, equals(ConnectionMonitor));
        
        // Both should use the same preferences system
        expect(analytics, isNotNull);
        expect(connectionMonitor, isNotNull);
      });
      
      test('should handle Phase 4 error scenarios gracefully', () async {
        final analytics = NetworkAnalytics(prefs: mockPrefs);
        final connectionMonitor = ConnectionMonitor(prefs: mockPrefs);
        
        // Both systems should handle empty/error states gracefully
        final healthReport = await analytics.analyzeNetworkHealth();
        final overview = await connectionMonitor.getActiveConnectionsOverview();
        
        // Should never return null, even in error states
        expect(healthReport, isNotNull);
        expect(overview, isNotNull);
      });
    });
  });
}
/// Tests for AI2AI Connections Page
///
/// Part of Feature Matrix Phase 1: Critical UI/UX
/// Section 1.2: Device Discovery UI - Integration Tests
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spots/core/network/device_discovery.dart';
import 'package:spots/core/ai2ai/connection_orchestrator.dart';
import 'package:spots/core/models/connection_metrics.dart';
import 'package:spots/presentation/pages/network/ai2ai_connections_page.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {});

  tearDown(() {
    GetIt.instance.reset();
  });

  group('AI2AIConnectionsPage Integration', () {
    // Removed: Property assignment tests
    // AI2AI connections page tests focus on business logic (page rendering, tab navigation, discovery toggle, settings navigation, network statistics, info dialog), not property assignment

    testWidgets(
        'should render page with all tabs, show discovery tab status and actions, navigate between tabs, toggle discovery, navigate to settings, show network statistics correctly, or open info dialog',
        (tester) async {
      // Test business logic: AI2AI connections page display and interactions
      _setupMockServices();
      await tester.pumpWidget(
        const MaterialApp(
          home: AI2AIConnectionsPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AI2AI Network'), findsOneWidget);
      expect(find.text('Discovery'), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
      expect(find.text('AI Connections'), findsOneWidget);
      expect(find.text('Discovery Inactive'), findsOneWidget);
      expect(find.text('Start Discovery'), findsOneWidget);
      expect(find.text('Network Statistics'), findsOneWidget);

      await tester.tap(find.text('Devices'));
      await tester.pumpAndSettle();
      expect(find.text('Discovery is off'), findsOneWidget);
      await tester.tap(find.text('AI Connections'));
      await tester.pumpAndSettle();
      expect(find.text('No Active AI Connections'), findsOneWidget);

      await tester.tap(find.text('Start Discovery'));
      await tester.pumpAndSettle();
      expect(find.text('Discovery Active'), findsOneWidget);
      expect(find.text('Stop Discovery'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Discovery Settings'), findsWidgets);

      final mockDiscovery = MockDeviceDiscoveryService();
      mockDiscovery.setDevices([
        DiscoveredDevice(
          deviceId: 'device-1',
          deviceName: 'Test Device',
          type: DeviceType.wifi,
          isSpotsEnabled: true,
          personalityData: const AnonymizedVibeData(
            personalityId: 'test-id',
            vibeSignature: 'signature',
            timestamp: '2025-01-01T00:00:00Z',
          ),
          discoveredAt: DateTime.now(),
        ),
      ]);
      final mockOrchestrator = MockVibeConnectionOrchestrator();
      GetIt.instance.registerSingleton<DeviceDiscoveryService>(mockDiscovery);
      GetIt.instance
          .registerSingleton<VibeConnectionOrchestrator>(mockOrchestrator);
      await tester.pumpWidget(
        const MaterialApp(
          home: AI2AIConnectionsPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1'), findsWidgets);
      expect(find.text('Discovered'), findsOneWidget);
      expect(find.text('AI Enabled'), findsOneWidget);

      _setupMockServices();
      await tester.pumpWidget(
        const MaterialApp(
          home: AI2AIConnectionsPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('How Discovery Works'));
      await tester.pumpAndSettle();
      expect(find.text('AI2AI Discovery'), findsOneWidget);
      expect(find.textContaining('Your AI broadcasts'), findsOneWidget);
    });
  });
}

/// Helper to setup mock services
void _setupMockServices() {
  final mockDiscovery = MockDeviceDiscoveryService();
  final mockOrchestrator = MockVibeConnectionOrchestrator();

  GetIt.instance.registerSingleton<DeviceDiscoveryService>(mockDiscovery);
  GetIt.instance
      .registerSingleton<VibeConnectionOrchestrator>(mockOrchestrator);
}

/// Mock DeviceDiscoveryService
class MockDeviceDiscoveryService extends DeviceDiscoveryService {
  List<DiscoveredDevice> _devices = [];
  bool _isScanning = false;

  MockDeviceDiscoveryService() : super(platform: null);

  void setDevices(List<DiscoveredDevice> devices) {
    _devices = devices;
  }

  @override
  Future<void> startDiscovery({
    Duration scanInterval = const Duration(seconds: 5),
    Duration deviceTimeout = const Duration(minutes: 2),
  }) async {
    _isScanning = true;
  }

  @override
  void stopDiscovery() {
    _isScanning = false;
  }

  @override
  List<DiscoveredDevice> getDiscoveredDevices() {
    return _devices;
  }

  @override
  DiscoveredDevice? getDevice(String deviceId) {
    return _devices.where((d) => d.deviceId == deviceId).firstOrNull;
  }
}

/// Mock VibeConnectionOrchestrator
class MockVibeConnectionOrchestrator extends VibeConnectionOrchestrator {
  List<ConnectionMetrics> _connections = [];

  MockVibeConnectionOrchestrator()
      : super(
          vibeAnalyzer: _createMockAnalyzer(),
          connectivity: _createMockConnectivity(),
        );

  void setConnections(List<ConnectionMetrics> connections) {
    _connections = connections;
  }

  @override
  List<ConnectionMetrics> getActiveConnections() {
    return _connections;
  }

  static _createMockAnalyzer() {
    throw UnimplementedError('Mock simplified for testing');
  }

  static _createMockConnectivity() {
    throw UnimplementedError('Mock simplified for testing');
  }
}

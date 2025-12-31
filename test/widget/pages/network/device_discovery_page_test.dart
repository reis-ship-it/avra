/// Tests for Device Discovery Status Page
///
/// Part of Feature Matrix Phase 1: Critical UI/UX
/// Section 1.2: Device Discovery UI
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spots/core/network/device_discovery.dart';
import 'package:spots/presentation/pages/network/device_discovery_page.dart';

void main() {
  setUpAll(() {});

  tearDown(() {
    GetIt.instance.reset();
  });

  group('DeviceDiscoveryPage', () {
    // Removed: Property assignment tests (data models instantiate correctly - property checks)
    // Device discovery page tests focus on business logic (page rendering, discovered devices display, info dialog), not property assignment

    testWidgets(
        'should render page with discovery inactive state, display discovered devices when scanning, or show info dialog when info button tapped',
        (tester) async {
      // Test business logic: Device discovery page display and interactions
      final mockService1 = MockDeviceDiscoveryService();
      GetIt.instance.registerSingleton<DeviceDiscoveryService>(mockService1);
      await tester.pumpWidget(
        const MaterialApp(
          home: DeviceDiscoveryPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Device Discovery'), findsOneWidget);
      expect(find.text('Discovery Inactive'), findsOneWidget);
      expect(find.text('Start Discovery'), findsOneWidget);

      final mockService2 = MockDeviceDiscoveryService();
      mockService2.setDevices([
        DiscoveredDevice(
          deviceId: 'device-1',
          deviceName: 'Test Device 1',
          type: DeviceType.wifi,
          isSpotsEnabled: true,
          signalStrength: -50,
          discoveredAt: DateTime.now(),
        ),
      ]);
      GetIt.instance.registerSingleton<DeviceDiscoveryService>(mockService2);
      await tester.pumpWidget(
        const MaterialApp(
          home: DeviceDiscoveryPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Discovery'));
      await tester.pumpAndSettle();
      expect(find.text('Discovery Active'), findsOneWidget);
      expect(find.textContaining('1 device found'), findsOneWidget);

      final mockService3 = MockDeviceDiscoveryService();
      GetIt.instance.registerSingleton<DeviceDiscoveryService>(mockService3);
      await tester.pumpWidget(
        const MaterialApp(
          home: DeviceDiscoveryPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text('About Device Discovery'), findsOneWidget);
      expect(find.textContaining('Privacy:'), findsOneWidget);
    });
  });
}

/// Mock implementation of DeviceDiscoveryService for testing
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

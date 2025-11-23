/// Stub implementation for device discovery when platform is not supported
/// Used in unit tests and unsupported platforms
import 'package:spots/core/network/device_discovery.dart';
import 'package:spots/core/ai/privacy_protection.dart';

/// Stub device discovery implementation
class StubDeviceDiscovery extends DeviceDiscoveryPlatform {
  @override
  bool isSupported() => false;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<List<DiscoveredDevice>> scanForDevices() async => [];

  @override
  Future<void> startAdvertising(AnonymizedVibeData vibeData) async {}

  @override
  Future<void> stopAdvertising() async {}

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async => {
    'platform': 'stub',
    'is_supported': false,
  };
}

/// Stub factory functions for unsupported platforms
/// These are used when conditional imports don't match any platform
DeviceDiscoveryPlatform createWebDeviceDiscovery() => StubDeviceDiscovery();
DeviceDiscoveryPlatform createAndroidDeviceDiscovery() => StubDeviceDiscovery();
DeviceDiscoveryPlatform createIOSDeviceDiscovery() => StubDeviceDiscovery();


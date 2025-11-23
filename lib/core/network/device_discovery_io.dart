/// IO platform implementations (Android/iOS)
/// This file is only imported when dart.library.io is available (mobile platforms)
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:spots/core/network/device_discovery.dart';
import 'package:spots/core/network/device_discovery_android.dart';
import 'package:spots/core/network/device_discovery_ios.dart';
import 'package:spots/core/network/device_discovery_factory.dart';

/// Create Android device discovery implementation
DeviceDiscoveryPlatform createAndroidDeviceDiscovery() {
  return AndroidDeviceDiscovery();
}

/// Create iOS device discovery implementation
DeviceDiscoveryPlatform createIOSDeviceDiscovery() {
  return IOSDeviceDiscovery();
}


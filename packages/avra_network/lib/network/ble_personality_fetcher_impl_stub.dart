import 'package:spots_network/network/device_discovery.dart';
import 'package:spots_network/network/models/anonymized_vibe_data.dart';

Future<AnonymizedVibeData?> fetchPersonalityDataOverBle(
  DiscoveredDevice device,
) async {
  // Non-IO / unsupported platforms.
  return null;
}


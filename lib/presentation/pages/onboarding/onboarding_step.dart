import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spots/core/services/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/injection_container.dart' as di;
import 'package:spots/core/services/permissions_persistence_service.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  final AppLogger _logger =
      const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  Map<Permission, PermissionStatus> _statuses = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  /// Load permissions from device and saved preferences
  Future<void> _loadPermissions() async {
    // First, load saved permissions from database (if any)
    try {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      if (authState is Authenticated) {
        final userId = authState.user.id;
        final permissionsService = di.sl<PermissionsPersistenceService>();
        final savedPermissions =
            await permissionsService.getUserPermissions(userId);

        if (savedPermissions != null && savedPermissions.isNotEmpty) {
          _logger.info(
              '📂 Loaded ${savedPermissions.length} saved permissions from database',
              tag: 'PermissionsPage');
          // Use saved permissions as initial state
          setState(() {
            _statuses = savedPermissions;
          });
        }
      }
    } catch (e) {
      _logger.warn('⚠️ Error loading saved permissions: $e',
          tag: 'PermissionsPage');
    }

    // Always refresh from device to get current actual status
    await _refreshStatuses();

    // Show permission dialog after statuses are loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showPermissionDialog();
      }
    });
  }

  Future<void> _refreshStatuses() async {
    // Skip permission checks on web - they're not supported
    if (kIsWeb) {
      setState(() => _statuses = {});
      return;
    }

    final permissions = <Permission>[
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
    ];
    final statuses = <Permission, PermissionStatus>{};
    for (final p in permissions) {
      try {
        statuses[p] = await p.status;
      } catch (e) {
        // Skip permissions that aren't supported on this platform
        continue;
      }
    }
    setState(() => _statuses = statuses);
  }

  Future<void> _requestAll() async {
    // Skip permission requests on web - they're not supported
    if (kIsWeb) {
      _logger.info('Skipping permission requests on web',
          tag: 'PermissionsPage');
      return;
    }

    setState(() => _loading = true);
    try {
      // Request permissions sequentially, starting with location (required for locationAlways)
      // iOS requires locationWhenInUse before locationAlways

      // 1. Location permissions (must be first, and locationWhenInUse before locationAlways)
      final locationWhenInUseStatus =
          await Permission.locationWhenInUse.request();
      _logger.info('Location when in use: $locationWhenInUseStatus',
          tag: 'PermissionsPage');

      // Only request locationAlways if locationWhenInUse was granted
      if (locationWhenInUseStatus.isGranted) {
        final locationAlwaysStatus = await Permission.locationAlways.request();
        _logger.info('Location always: $locationAlwaysStatus',
            tag: 'PermissionsPage');
      }

      // 2. Bluetooth permissions (can be requested together)
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();

      // 3. Nearby WiFi devices (if supported)
      try {
        await Permission.nearbyWifiDevices.request();
      } catch (e) {
        _logger.warn('Nearby WiFi devices permission not supported: $e',
            tag: 'PermissionsPage');
      }

      // Refresh statuses to get actual device permission state
      await _refreshStatuses();

      // Update UI immediately to reflect changes
      if (mounted) {
        setState(() {
          // Statuses already updated by _refreshStatuses
        });
      }

      // Save permissions to device storage
      await _savePermissionsToDevice();
    } catch (e) {
      _logger.error('Error requesting permissions',
          error: e, tag: 'PermissionsPage');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Save permissions to device storage (database)
  Future<void> _savePermissionsToDevice() async {
    try {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      if (authState is Authenticated) {
        final userId = authState.user.id;
        final permissionsService = di.sl<PermissionsPersistenceService>();
        await permissionsService.saveUserPermissions(userId, _statuses);
        _logger.info('✅ Permissions saved to device for user: $userId',
            tag: 'PermissionsPage');
      }
    } catch (e) {
      _logger.error('Error saving permissions to device',
          error: e, tag: 'PermissionsPage');
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    if (kIsWeb) {
      _logger.info('Skipping permission request on web: $permission',
          tag: 'PermissionsPage');
      return;
    }

    _logger.info('🔐 Requesting permission: $permission',
        tag: 'PermissionsPage');
    setState(() => _loading = true);
    try {
      final status = await permission.request();
      _logger.info('📋 Permission $permission status: $status',
          tag: 'PermissionsPage');

      // Refresh statuses to get actual device permission state
      await _refreshStatuses();

      // Update UI immediately to reflect changes
      if (mounted) {
        setState(() {
          // Statuses already updated by _refreshStatuses, this triggers rebuild
        });
      }

      // Save permissions to device storage
      await _savePermissionsToDevice();
    } catch (e, stackTrace) {
      _logger.error('❌ Error requesting permission $permission: $e',
          error: e, tag: 'PermissionsPage');
      _logger.debug('Stack trace: $stackTrace', tag: 'PermissionsPage');

      // Refresh statuses even on error to show current state
      await _refreshStatuses();
      if (mounted) {
        setState(() {
          // Trigger UI update
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _grantedCount {
    return _statuses.values.where((status) => status.isGranted).length;
  }

  int get _totalCount => _statuses.length;

  /// Shows a dialog explaining permissions and giving users options to grant them
  Future<void> _showPermissionDialog() async {
    if (kIsWeb) return;

    // Check if we have any denied or permanently denied permissions
    final hasDeniedPermissions = _statuses.values.any(
      (status) => status.isDenied || status.isPermanentlyDenied,
    );

    // If all permissions are granted, don't show dialog
    if (!hasDeniedPermissions &&
        _grantedCount == _totalCount &&
        _totalCount > 0) {
      return;
    }

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(child: Text('Enable Permissions')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPOTS needs certain permissions to provide the best experience:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.location_on,
                title: 'Location',
                description:
                    'Show nearby spots and enable location-based discovery',
              ),
              SizedBox(height: 8),
              _PermissionItem(
                icon: Icons.bluetooth,
                title: 'Bluetooth',
                description:
                    'Enable secure ai2ai device discovery and proximity awareness',
              ),
              SizedBox(height: 8),
              _PermissionItem(
                icon: Icons.wifi,
                title: 'WiFi Devices',
                description:
                    'Improve device discovery and connectivity quality',
              ),
              SizedBox(height: 16),
              Text(
                'You can grant permissions now or configure them in device settings.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // false = go to settings
            },
            child: const Text('Open Settings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // true = request in-app
            },
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );

    if (result == null) {
      // User dismissed dialog, don't do anything
      return;
    }

    if (result == true) {
      // User chose to grant permissions in-app
      await _requestAll();
    } else {
      // User chose to go to settings
      final opened = await openAppSettings();
      _logger.info('Opened app settings: $opened', tag: 'PermissionsPage');

      // Refresh statuses after returning from settings
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _refreshStatuses();
        }
      });
    }
  }

  /// Shows a dialog when a permission is permanently denied
  Future<void> _showPermanentlyDeniedDialog(Permission permission) async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '${permission.toString().split('.').last} permission is required but has been permanently denied. Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await openAppSettings();
    }
  }

  /// Get user-friendly permission name
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.locationWhenInUse:
        return 'Location Access';
      case Permission.locationAlways:
        return 'Background Location';
      case Permission.bluetooth:
        return 'Bluetooth';
      case Permission.bluetoothScan:
        return 'Bluetooth Scan';
      case Permission.bluetoothConnect:
        return 'Bluetooth Connect';
      case Permission.bluetoothAdvertise:
        return 'Bluetooth Advertise';
      case Permission.nearbyWifiDevices:
        return 'WiFi Devices';
      default:
        return permission.toString().split('.').last;
    }
  }

  /// Get user-friendly permission description
  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.locationWhenInUse:
        return 'Show nearby spots and personalize discovery';
      case Permission.locationAlways:
        return 'Enable background spot detection';
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothConnect:
      case Permission.bluetoothAdvertise:
        return 'Enable secure device discovery';
      case Permission.nearbyWifiDevices:
        return 'Improve device discovery quality';
      default:
        return '';
    }
  }

  /// Group permissions by category
  Map<String, List<MapEntry<Permission, PermissionStatus>>>
      _groupPermissions() {
    final groups = <String, List<MapEntry<Permission, PermissionStatus>>>{};

    for (final entry in _statuses.entries) {
      String category;
      if (entry.key == Permission.locationWhenInUse ||
          entry.key == Permission.locationAlways) {
        category = 'Location';
      } else if (entry.key == Permission.bluetooth ||
          entry.key == Permission.bluetoothScan ||
          entry.key == Permission.bluetoothConnect ||
          entry.key == Permission.bluetoothAdvertise) {
        category = 'Bluetooth';
      } else if (entry.key == Permission.nearbyWifiDevices) {
        category = 'WiFi';
      } else {
        category = 'Other';
      }

      groups.putIfAbsent(category, () => []).add(entry);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _statuses.isNotEmpty && _grantedCount == _totalCount;
    final groups = _groupPermissions();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary banner
          if (_statuses.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: allGranted
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: allGranted ? Colors.green : Colors.orange,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    allGranted ? Icons.check_circle : Icons.info_outline,
                    color: allGranted ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      allGranted
                          ? 'All permissions granted'
                          : '$_grantedCount of $_totalCount permissions granted',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: allGranted
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Simulator info note (shown when permissions are not granted)
          if (!allGranted && _statuses.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Note: Some permissions (especially Bluetooth and WiFi) may not be fully supported on iOS Simulator. Test on a real device for complete functionality.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Loading state
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Requesting permissions...'),
                  ],
                ),
              ),
            )
          else if (_statuses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Checking permissions...'),
              ),
            )
          else
            // Grouped permissions
            ...groups.entries.map((group) {
              final categoryName = group.key;
              final permissions = group.value;
              final categoryGranted =
                  permissions.every((e) => e.value.isGranted);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            categoryName == 'Location'
                                ? Icons.location_on
                                : categoryName == 'Bluetooth'
                                    ? Icons.bluetooth
                                    : Icons.wifi,
                            size: 20,
                            color: categoryGranted
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Permission items
                    ...permissions.map((entry) {
                      final permission = entry.key;
                      final status = entry.value;
                      final isGranted = status.isGranted;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isGranted
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            _getPermissionName(permission),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _getPermissionDescription(permission),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          trailing: Switch(
                            value: isGranted,
                            onChanged: _loading
                                ? null
                                : (value) async {
                                    // Always allow toggling - let the request handle the actual permission state
                                    setState(() {
                                      _statuses[permission] = value
                                          ? PermissionStatus.granted
                                          : PermissionStatus.denied;
                                    });

                                    if (value && !isGranted) {
                                      // Request permission
                                      await _requestPermission(permission);
                                      await _refreshStatuses();
                                      if (mounted) setState(() {});

                                      // Check if permanently denied after request
                                      final newStatus = _statuses[permission];
                                      if (newStatus != null &&
                                          newStatus.isPermanentlyDenied &&
                                          mounted) {
                                        await _showPermanentlyDeniedDialog(
                                            permission);
                                      } else if (newStatus != null &&
                                          !newStatus.isGranted &&
                                          mounted) {
                                        // Show helpful message for simulator limitations
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Some permissions may not be fully supported on iOS Simulator. Test on a real device for complete functionality.',
                                            ),
                                            duration:
                                                const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } else if (!value && isGranted) {
                                      // Refresh to show actual state
                                      await _refreshStatuses();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'To revoke permissions, please use your device settings.',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

          const SizedBox(height: 8),

          // Action buttons
          if (!allGranted) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) _refreshStatuses();
                  });
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : () async {
                      await _requestAll();
                      await _refreshStatuses();
                      if (mounted) {
                        final stillDenied = _statuses.values.any(
                          (status) =>
                              status.isDenied || status.isPermanentlyDenied,
                        );
                        if (stillDenied) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) _showPermissionDialog();
                          });
                        }
                      }
                    },
              icon: Icon(_loading ? Icons.hourglass_empty : Icons.security),
              label: Text(_loading
                  ? 'Requesting...'
                  : allGranted
                      ? 'All Granted ✓'
                      : 'Request All Permissions'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a permission item in the dialog
class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum OnboardingStepType {
  homebase,
  favoritePlaces,
  preferences,
  baselineLists,
  friends,
  socialMedia,
}

class OnboardingStep {
  final OnboardingStepType type;
  final String title;
  final String description;
  final Widget page;

  const OnboardingStep({
    required this.type,
    required this.title,
    required this.description,
    required this.page,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/core/services/agent_id_service.dart';
import 'package:spots/core/services/social_media_connection_service.dart';
import 'package:spots/injection_container.dart' as di;

/// Social Media Connection Page for Onboarding
/// Allows users to optionally connect their social media accounts
/// This enhances AI personality learning and enables friend discovery
class SocialMediaConnectionPage extends StatefulWidget {
  final Map<String, bool> connectedPlatforms;
  final Function(Map<String, bool>) onConnectionsChanged;

  const SocialMediaConnectionPage({
    super.key,
    required this.connectedPlatforms,
    required this.onConnectionsChanged,
  });

  @override
  State<SocialMediaConnectionPage> createState() =>
      _SocialMediaConnectionPageState();
}

class _SocialMediaConnectionPageState extends State<SocialMediaConnectionPage> {
  late Map<String, bool> _connectedPlatforms;

  bool _isConnecting = false;
  String? _connectingPlatform;

  @override
  void initState() {
    super.initState();
    // Initialize from parent
    _connectedPlatforms = Map<String, bool>.from(widget.connectedPlatforms);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect Social Media (Optional)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your social accounts to enhance your AI personality and discover friends who use SPOTS. You can skip this step and connect later in settings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: _connectedPlatforms.entries.map((entry) {
                final platform = entry.key;
                final isConnected = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: _getPlatformIcon(platform),
                    title: Text(platform),
                    subtitle: Text(
                      isConnected
                          ? 'Connected'
                          : 'Connect to enhance your AI personality',
                      style: TextStyle(
                        color: isConnected ? Colors.green : AppColors.grey600,
                      ),
                    ),
                    trailing: _isConnecting && _connectingPlatform == platform
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            value: isConnected,
                            onChanged: _isConnecting
                                ? null
                                : (value) {
                                    if (value) {
                                      _connectPlatform(platform);
                                    } else {
                                      _disconnectPlatform(platform);
                                    }
                                  },
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy Note: We only use your social data to enhance your AI personality and help you discover friends. You can disconnect anytime in settings.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _getPlatformIcon(String platform) {
    IconData icon;
    Color color;
    switch (platform) {
      case 'Instagram':
        icon = Icons.camera_alt;
        color = Colors.purple;
        break;
      case 'Facebook':
        icon = Icons.facebook;
        color = Colors.blue;
        break;
      case 'Twitter':
        icon = Icons.chat_bubble_outline;
        color = Colors.lightBlue;
        break;
      case 'TikTok':
        icon = Icons.music_note;
        color = Colors.black;
        break;
      case 'LinkedIn':
        icon = Icons.business;
        color = Colors.blue.shade700;
        break;
      default:
        icon = Icons.link;
        color = AppTheme.primaryColor;
    }
    return Icon(icon, color: color, size: 32);
  }

  Future<void> _connectPlatform(String platform) async {
    setState(() {
      _isConnecting = true;
      _connectingPlatform = platform;
    });

    try {
      // Get current user
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      if (authState is! Authenticated) {
        throw Exception('User not authenticated');
      }

      final userId = authState.user.id;

      // Get agentId for privacy
      final agentIdService = di.sl<AgentIdService>();
      final agentId = await agentIdService.getUserAgentId(userId);

      // Call service to run OAuth flow and store tokens
      final socialMediaService = di.sl<SocialMediaConnectionService>();
      await socialMediaService.connectPlatform(
        platform: platform.toLowerCase(), // 'instagram', 'facebook', etc.
        agentId: agentId, // Use agentId for privacy
        userId: userId, // For service lookup
      );

      if (mounted) {
        setState(() {
          _connectedPlatforms[platform] = true;
          _isConnecting = false;
          _connectingPlatform = null;
        });

        // Report changes to parent with real connection status
        widget.onConnectionsChanged(Map<String, bool>.from(_connectedPlatforms));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$platform connected successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectingPlatform = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect $platform: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _disconnectPlatform(String platform) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect $platform?'),
        content: Text(
          'Disconnecting $platform will stop using your social data to enhance your AI personality. You can reconnect anytime in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Get current user
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;
        if (authState is! Authenticated) {
          throw Exception('User not authenticated');
        }

        final userId = authState.user.id;

        // Get agentId for privacy
        final agentIdService = di.sl<AgentIdService>();
        final agentId = await agentIdService.getUserAgentId(userId);

        // Call service to disconnect and remove tokens
        final socialMediaService = di.sl<SocialMediaConnectionService>();
        await socialMediaService.disconnectPlatform(
          platform: platform.toLowerCase(),
          agentId: agentId,
        );

        setState(() {
          _connectedPlatforms[platform] = false;
        });

        // Report changes to parent
        widget.onConnectionsChanged(Map<String, bool>.from(_connectedPlatforms));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$platform disconnected'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect $platform: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

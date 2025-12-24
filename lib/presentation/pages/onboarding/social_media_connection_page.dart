import 'package:flutter/material.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/core/theme/colors.dart';

/// Social Media Connection Page for Onboarding
/// Allows users to optionally connect their social media accounts
/// This enhances AI personality learning and enables friend discovery
class SocialMediaConnectionPage extends StatefulWidget {
  const SocialMediaConnectionPage({super.key});

  @override
  State<SocialMediaConnectionPage> createState() =>
      _SocialMediaConnectionPageState();
}

class _SocialMediaConnectionPageState extends State<SocialMediaConnectionPage> {
  final Map<String, bool> _connectedPlatforms = {
    'Instagram': false,
    'Facebook': false,
    'Twitter': false,
    'TikTok': false,
    'LinkedIn': false,
  };

  bool _isConnecting = false;
  String? _connectingPlatform;

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
      // TODO: Implement actual OAuth connection when Phase 12 backend is ready
      // For now, this is a placeholder UI
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _connectedPlatforms[platform] = true;
          _isConnecting = false;
          _connectingPlatform = null;
        });

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
      setState(() {
        _connectedPlatforms[platform] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform disconnected'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

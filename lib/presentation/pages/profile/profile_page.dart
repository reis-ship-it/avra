import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/pages/settings/notifications_settings_page.dart';
import 'package:spots/presentation/pages/settings/privacy_settings_page.dart';
import 'package:spots/presentation/pages/settings/help_support_page.dart';
import 'package:spots/presentation/pages/settings/about_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  state.user.displayName
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      state.user.email
                                          .substring(0, 1)
                                          .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.user.displayName ?? 'User',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    Text(
                                      state.user.email,
                                  style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.offlineColor,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          state.isOffline
                                              ? Icons.wifi_off
                                              : Icons.wifi,
                                          size: 16,
                                          color: state.isOffline
                                              ? AppTheme.offlineColor
                                              : AppTheme.successColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          state.isOffline
                                              ? 'Offline'
                                              : 'Online',
                                          style: TextStyle(
                                            color: state.isOffline
                                                ? AppTheme.offlineColor
                                                : AppTheme.successColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Settings Items
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage your notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    subtitle: 'Manage your privacy settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showSignOutDialog(context);
                      },
                      // Use global ElevatedButtonTheme; color implied by theme
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(SignOutRequested());
              },
              // Use global ElevatedButtonTheme
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

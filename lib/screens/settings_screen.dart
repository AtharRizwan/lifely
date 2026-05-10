import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../widgets/tiles/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onThemeModeChanged});

  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: isDark,
              onChanged: onThemeModeChanged,
              title: const Text('Dark mode'),
              subtitle: const Text('Low contrast for focus'),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Account', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Divider(height: 1),
                Builder(
                  builder: (ctx) => ListTile(
                    leading: Icon(Icons.logout, color: Theme.of(ctx).colorScheme.error),
                    title: Text(
                      'Sign out',
                      style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                    ),
                    onTap: () {
                      _showSignOutDialog(context, store);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: const Text('Sync status'),
                  subtitle: const Text('Connected to cloud'),
                  trailing: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                  ),
                ),
                const Divider(height: 1),
                Builder(
                  builder: (ctx) => ListTile(
                    leading: Icon(Icons.delete_outline, color: Theme.of(ctx).colorScheme.error),
                    title: Text(
                      'Clear all data',
                      style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                    ),
                    onTap: () {
                      _showClearDataDialog(context, store);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SettingsTile(title: 'Version', value: '1.0.0'),
                const Divider(height: 1),
                SettingsTile(title: 'App', value: 'Lifely'),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, dynamic store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              store.logout();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, dynamic store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will delete all your tasks, moods, and planner blocks. Your profile will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              store.clearLocalData();
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
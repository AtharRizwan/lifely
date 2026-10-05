import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_store.dart';
import '../utils/constants.dart';
import '../utils/time.dart';
import '../widgets/tiles/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _resetStatus;
  bool _sendingReset = false;

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
              onChanged: (value) =>
                  store.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
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
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text('Reset password'),
                  subtitle: Text(
                    _resetStatus ?? 'Email a reset link to ${store.profile?.email ?? 'your address'}',
                  ),
                  trailing: _sendingReset
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _sendingReset ? null : () => _sendPasswordReset(store),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    'Sign out',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _showSignOutDialog(context, store),
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
                _buildSyncTile(store, theme),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  title: Text(
                    'Clear all data',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _showClearDataDialog(context, store),
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
                const SettingsTile(title: 'Version', value: AppStrings.appVersion),
                const Divider(height: 1),
                const SettingsTile(title: 'App', value: AppStrings.appName),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHelp(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncTile(AppStore store, ThemeData theme) {
    final String status;
    final Widget trailing;
    if (store.isSyncing) {
      status = 'Syncing…';
      trailing = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (store.syncError != null) {
      status = store.syncError!;
      trailing = Icon(Icons.error_outline, color: theme.colorScheme.error);
    } else if (store.lastSyncedAt != null) {
      status = 'Up to date · last synced ${formatClock(store.lastSyncedAt!)}';
      trailing = Icon(Icons.check_circle, color: AppColors.success);
    } else {
      status = 'Not synced yet this session';
      trailing = const Icon(Icons.cloud_queue_outlined);
    }
    return ListTile(
      leading: const Icon(Icons.cloud_sync_outlined),
      title: const Text('Sync status'),
      subtitle: Text(status),
      trailing: trailing,
      onTap: store.isSyncing ? null : store.refresh,
    );
  }

  Future<void> _sendPasswordReset(AppStore store) async {
    final email = store.profile?.email ?? '';
    if (email.isEmpty) return;
    setState(() {
      _sendingReset = true;
      _resetStatus = null;
    });
    final result = await store.sendPasswordReset(email);
    if (!mounted) return;
    setState(() {
      _sendingReset = false;
      _resetStatus = result == AuthResult.success
          ? 'Reset link sent to $email'
          : result == AuthResult.network
              ? 'No connection. Try again when you are online.'
              : "Couldn't send the reset link. Try again later.";
    });
  }

  void _showHelp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: AppStrings.appVersion,
      children: const [
        SizedBox(height: 8),
        Text('• Quick add understands dates like "essay tomorrow 3pm for 1h".'),
        SizedBox(height: 6),
        Text('• Log your mood in the Journal; the planner lightens your day when you feel stressed or low.'),
        SizedBox(height: 6),
        Text('• Alerts remind you about tasks due soon or overdue. Use Quiet mode in Adjust load to pause them.'),
        SizedBox(height: 6),
        Text('• Swipe planner blocks, moods or alerts to remove them.'),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AppStore store) {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              navigator.popUntil((route) => route.isFirst);
              store.logout();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppStore store) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This deletes all your tasks, moods, planner blocks and alerts, on this device and in the cloud. Your account stays.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              store.clearLocalData();
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

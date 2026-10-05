import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_store.dart';
import '../utils/navigation.dart';
import '../utils/validators.dart';
import '../widgets/tiles/settings_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final profile = store.profile;
    
    final joinedDate = profile?.joinedAt;
    final memberSince = joinedDate != null
        ? '${joinedDate.day}/${joinedDate.month}/${joinedDate.year}'
        : 'Today';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => openSettings(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name.substring(0, 1).toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? 'Student',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?.email ?? 'student@lifely.app',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit name',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditNameDialog(context, store),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Your progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: '${store.completedTasks}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.pending_outlined,
                  label: 'Pending',
                  value: '${store.pendingTasks}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.local_fire_department_outlined,
                  label: 'Task streak',
                  value: '${store.taskStreak} days',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.favorite_outline,
                  label: 'Mood streak',
                  value: '${store.moodStreak} days',
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Account info', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SettingsTile(title: 'Member since', value: memberSince),
          SettingsTile(
            title: 'Tasks completed',
            value: '${store.completedTasks}',
          ),
          SettingsTile(
            title: 'Planner blocks',
            value: '${store.plannerBlocks.length}',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog(context, store);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AppStore store) {
    showDialog(
      context: context,
      builder: (_) => _EditNameDialog(
        initialName: store.profile?.name ?? '',
        onSave: store.updateProfileName,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppStore store) {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              navigator.popUntil((route) => route.isFirst);
              onLogout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName, required this.onSave});

  final String initialName;
  final Future<void> Function(String name) onSave;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final validation = Validators.validateName(_controller.text);
    if (validation.isInvalid) {
      setState(() => _error = validation.errorMessage);
      return;
    }
    widget.onSave(_controller.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: 'Name', errorText: _error),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

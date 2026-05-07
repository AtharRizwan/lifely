import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/cards/insight_card.dart';
import '../widgets/tiles/settings_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final profile = store.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name.substring(0, 1).toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SettingsTile(title: 'Membership', value: 'Student plan'),
          const SettingsTile(title: 'Focus streak', value: '12 days'),
          const SettingsTile(title: 'Daily recap', value: '9:00 PM'),
          const SizedBox(height: 16),
          const InsightCard(
            title: 'Next checkpoint',
            body: 'Consistency compounds. Keep a light rhythm today.',
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () {
              store.clearLocalData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local data cleared.')),
              );
            },
            child: const Text('Clear local data'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Log out',
            onPressed: onLogout,
            useDefaultOnPressed: false,
          ),
        ],
      ),
    );
  }
}

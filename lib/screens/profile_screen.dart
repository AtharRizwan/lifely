import 'package:flutter/material.dart';

import '../widgets/buttons/primary_button.dart';
import '../widgets/cards/insight_card.dart';
import '../widgets/tiles/settings_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    child: const Text(
                      'A',
                      style: TextStyle(
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
                        Text('Athar Khan', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'athar@example.com',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
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

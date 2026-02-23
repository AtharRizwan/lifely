import 'package:flutter/material.dart';

import '../widgets/cards/insight_card.dart';
import '../widgets/tiles/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onThemeModeChanged});

  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: SwitchListTile(
              value: isDark,
              onChanged: onThemeModeChanged,
              title: const Text('Dark mode'),
              subtitle: const Text('Keep contrast low and focused'),
            ),
          ),
          const SizedBox(height: 12),
          SettingsTile(title: 'Theme', value: isDark ? 'Dark' : 'Light'),
          const SettingsTile(title: 'Font size', value: 'Default'),
          const SettingsTile(title: 'Layout density', value: 'Comfortable'),
          const SizedBox(height: 20),
          const InsightCard(
            title: 'Daily affirmation',
            body: 'Small steps compound. Focus on one task now.',
          ),
        ],
      ),
    );
  }
}

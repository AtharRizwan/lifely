import 'package:flutter/material.dart';

import '../utils/snackbar.dart';
import '../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../widgets/buttons/theme_toggle_button.dart';
import '../widgets/tiles/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Notifications',
          subtitle: 'Gentle nudges',
          actions: [
            ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => showSnackBar(
                context,
                'Notification filters are coming soon.',
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const NotificationTile(
                title: 'Lab report due tomorrow',
                body: 'Draft 2 pages to stay on track.',
                time: '2h ago',
              ),
              const SizedBox(height: 12),
              const NotificationTile(
                title: 'Missed: Stats quiz review',
                body: 'Reschedule for 7:30 pm?',
                time: 'Yesterday',
              ),
              const SizedBox(height: 12),
              const NotificationTile(
                title: 'Daily recap ready',
                body: '2 tasks done, 3 pending.',
                time: '9:05 pm',
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

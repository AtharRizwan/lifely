import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../widgets/buttons/theme_toggle_button.dart';
import '../widgets/tiles/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<Offset> _createSlideAnimation(double start, double end) {
    return Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));
  }

  Animation<double> _createFadeAnimation(double start, double end) {
    return Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeIn),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final notifications = store.notifications;
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Notifications',
          subtitle: 'Gentle nudges',
          actions: [
            ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () {
                if (notifications.isEmpty) return;
                store.clearNotifications();
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (notifications.isEmpty)
                Text(
                  'No notifications yet. You are all caught up.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...List.generate(notifications.length, (index) {
                  final start = (index * 0.2).clamp(0.0, 0.8);
                  final end = (start + 0.6).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FadeTransition(
                      opacity: _createFadeAnimation(start, end),
                      child: SlideTransition(
                        position: _createSlideAnimation(start, end),
                        child: NotificationTile(
                          title: notifications[index].title,
                          body: notifications[index].body,
                          time: _formatNotificationTime(
                            notifications[index].timestamp,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ]),
          ),
        ),
      ],
    );
  }
}

String _formatNotificationTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}

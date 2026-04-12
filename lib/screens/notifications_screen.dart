import 'package:flutter/material.dart';

import '../utils/snackbar.dart';
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
    return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              SlideTransition(
                position: _createSlideAnimation(0.0, 0.6),
                child: const NotificationTile(
                  title: 'Lab report due tomorrow',
                  body: 'Draft 2 pages to stay on track.',
                  time: '2h ago',
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _createSlideAnimation(0.2, 0.8),
                child: const NotificationTile(
                  title: 'Missed: Stats quiz review',
                  body: 'Reschedule for 7:30 pm?',
                  time: 'Yesterday',
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _createSlideAnimation(0.4, 1.0),
                child: const NotificationTile(
                  title: 'Daily recap ready',
                  body: '2 tasks done, 3 pending.',
                  time: '9:05 pm',
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_store.dart';
import '../models/app_models.dart';
import '../utils/navigation.dart';
import '../utils/time.dart';
import '../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../widgets/buttons/theme_toggle_button.dart';
import '../widgets/tiles/notification_tile.dart';
import '../widgets/ui_state/error_banners.dart';

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

  void _open(AppStore store, NotificationItem item) {
    store.markNotificationRead(item.id);
    final taskId = item.taskId;
    if (taskId != null && store.taskById(taskId) != null) {
      openTaskDetails(context, taskId);
    }
  }

  Future<void> _dismiss(AppStore store, NotificationItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    await store.removeNotification(item.id);
    messenger.showSnackBar(SnackBar(
      content: const Text('Alert dismissed'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => store.addNotification(item),
      ),
    ));
  }

  Future<void> _confirmClearAll(AppStore store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all alerts?'),
        content: const Text('Cleared reminders will not come back.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) await store.clearNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final notifications = store.notifications;
    final quietUntil = store.quietUntil;
    final unread = store.unreadCount;
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Notifications',
          subtitle: unread == 0 ? 'Gentle nudges' : '$unread unread',
          actions: [
            ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
            IconButton(
              tooltip: 'Mark all as read',
              icon: const Icon(Icons.done_all_rounded),
              onPressed: unread == 0 ? null : store.markAllNotificationsRead,
            ),
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: notifications.isEmpty ? null : () => _confirmClearAll(store),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (quietUntil != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_paused_outlined,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Quiet until ${formatClock(quietUntil)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: store.clearQuiet,
                          child: const Text('Turn off'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (notifications.isEmpty)
                const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'You are all caught up',
                  subtitle: 'Reminders for tasks due soon or overdue will show up here.',
                )
              else
                ...List.generate(notifications.length, (index) {
                  final item = notifications[index];
                  final start = (index * 0.2).clamp(0.0, 0.8);
                  final end = (start + 0.6).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FadeTransition(
                      opacity: _createFadeAnimation(start, end),
                      child: SlideTransition(
                        position: _createSlideAnimation(start, end),
                        child: Dismissible(
                          key: ValueKey(item.id),
                          onDismissed: (_) => _dismiss(store, item),
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.close_rounded),
                          ),
                          child: NotificationTile(
                            title: item.title,
                            body: item.body,
                            time: _formatNotificationTime(item.timestamp),
                            isUnread: item.isUnread,
                            onTap: () => _open(store, item),
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
  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }
  return formatShortDate(time);
}

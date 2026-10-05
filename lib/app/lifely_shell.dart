import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../screens/add/add_task_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/mood/mood_journal_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/planner/planner_screen.dart';

class LifelyShell extends StatefulWidget {
  const LifelyShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;
  final VoidCallback onLogout;

  @override
  State<LifelyShell> createState() => _LifelyShellState();
}

class _LifelyShellState extends State<LifelyShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Catch tasks that become due soon or overdue while the app stays open.
    _reminderTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) AppScope.read(context).generateReminders();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      AppScope.read(context).generateReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final unread = store.isQuiet ? 0 : store.unreadCount;
    final screens = [
      DashboardScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLogout: widget.onLogout,
      ),
      PlannerScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      AddTaskScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      MoodJournalScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      NotificationsScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Planner',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}

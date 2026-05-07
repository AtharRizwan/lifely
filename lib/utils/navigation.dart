import 'package:flutter/material.dart';

import '../screens/add/ocr_help_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/insights/streak_details_screen.dart';
import '../screens/mood/mood_history_screen.dart';
import '../screens/planner/adjust_load_screen.dart';
import '../screens/planner/day_view_screen.dart';
import '../screens/planner/daily_recap_screen.dart';
import '../screens/planner/week_editor_screen.dart';
import '../screens/tasks/all_tasks_screen.dart';
import '../screens/tasks/task_details_screen.dart';
import '../screens/profile_screen.dart';

Route _buildRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.05);
      const end = Offset.zero;
      const curve = Curves.easeOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

void openInsights(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const InsightsScreen()));
}

void openAllTasks(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const AllTasksScreen()));
}

void openTaskDetails(BuildContext context, String taskId) {
  Navigator.of(context).push(_buildRoute(TaskDetailsScreen(taskId: taskId)));
}

void openAdjustLoad(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const AdjustLoadScreen()));
}

void openDailyRecap(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const DailyRecapScreen()));
}

void openDayView(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const DayViewScreen()));
}

void openWeekEditor(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const WeekEditorScreen()));
}

void openMoodHistory(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const MoodHistoryScreen()));
}

void openStreakDetails(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const StreakDetailsScreen()));
}

void openOcrHelp(BuildContext context) {
  Navigator.of(context).push(_buildRoute(const OcrHelpScreen()));
}

void openProfile(BuildContext context, VoidCallback onLogout) {
  Navigator.of(context).push(_buildRoute(ProfileScreen(onLogout: onLogout)));
}

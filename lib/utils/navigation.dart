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

void openInsights(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const InsightsScreen()));
}

void openAllTasks(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const AllTasksScreen()));
}

void openTaskDetails(BuildContext context, String title) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskTitle: title)),
  );
}

void openAdjustLoad(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const AdjustLoadScreen()));
}

void openDailyRecap(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const DailyRecapScreen()));
}

void openDayView(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const DayViewScreen()));
}

void openWeekEditor(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const WeekEditorScreen()));
}

void openMoodHistory(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const MoodHistoryScreen()));
}

void openStreakDetails(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const StreakDetailsScreen()));
}

void openOcrHelp(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const OcrHelpScreen()));
}

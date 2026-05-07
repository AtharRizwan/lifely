import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/cards/achievement_grid.dart';
import '../../widgets/cards/progress_tracker_card.dart';
import '../../widgets/charts/chart_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ProgressTrackerCard(
            taskStreak: store.taskStreak,
            loadBalance: store.pendingTasks == 0
                ? 0.9
                : (store.completedTasks / (store.pendingTasks + store.completedTasks))
                    .clamp(0.2, 0.95),
            achievements: [
              'Mood streak - ${store.moodStreak} days',
              'Tasks completed - ${store.completedTasks}',
              'Planner blocks - ${store.plannerBlocks.length}',
            ],
          ),
          const SizedBox(height: 16),
          if (store.tasks.isEmpty && store.moods.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Add tasks and mood check-ins to unlock insights.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            )
          else ...[
            ChartCard(
              title: 'Task streaks',
              subtitle: 'Last 7 days',
              bars: _buildTaskBars(store.completedTasks),
            ),
            const SizedBox(height: 16),
            ChartCard(
              title: 'Load balance',
              subtitle: 'Focus vs. admin',
              bars: _buildBalanceBars(store.pendingTasks, store.completedTasks),
            ),
            const SizedBox(height: 16),
            AchievementGrid(
              items: _buildAchievements(store),
            ),
          ],
        ],
      ),
    );
  }
}

List<int> _buildTaskBars(int completed) {
  if (completed == 0) {
    return List<int>.filled(7, 0);
  }
  final base = (completed / 3).clamp(1, 6).round();
  return [base, base + 1, base, base + 2, base + 1, base, base + 1]
      .map((value) => value.clamp(0, 7))
      .toList();
}

List<int> _buildBalanceBars(int pending, int completed) {
  final total = pending + completed;
  if (total == 0) {
    return List<int>.filled(7, 0);
  }
  final balance = (completed / total * 7).clamp(1, 7).round();
  return List<int>.filled(7, balance);
}

List<String> _buildAchievements(store) {
  final achievements = <String>[];
  if (store.moodStreak >= 3) {
    achievements.add('Mood streak ${store.moodStreak} days');
  }
  if (store.completedTasks >= 3) {
    achievements.add('Completed ${store.completedTasks} tasks');
  }
  if (store.plannerBlocks.isNotEmpty) {
    achievements.add('Planner blocks added');
  }
  if (achievements.isEmpty) {
    achievements.add('Start logging to unlock achievements');
  }
  return achievements;
}

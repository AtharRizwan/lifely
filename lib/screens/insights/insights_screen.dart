import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../widgets/cards/achievement_grid.dart';
import '../../widgets/cards/progress_tracker_card.dart';
import '../../widgets/charts/chart_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final scheduler = AiScheduler();
    final prioritizer = AiTaskPrioritizer();
    final pending = store.tasks.where((t) => !t.isCompleted).toList();
    final prioritized = pending.isNotEmpty ? prioritizer.prioritize(store.tasks) : [];

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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          else ...[
            ChartCard(
              title: 'Task streaks',
              subtitle: 'Last 7 days',
              bars: _buildTaskBars(store.tasks),
            ),
            const SizedBox(height: 16),
            ChartCard(
              title: 'Load balance',
              subtitle: 'Focus vs. admin',
              bars: _buildBalanceBars(store.pendingTasks, store.completedTasks),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('AI Focus Windows', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildEnergyRow('Peak focus', scheduler.peakHours.map((h) => '$h:00').toList(), const Color(0xFF4CAF50), theme),
                    const SizedBox(height: 8),
                    _buildEnergyRow('Low energy', scheduler.lowHours.map((h) => '$h:00').toList(), const Color(0xFFFFB74D), theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (prioritized.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sort, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('AI Task Priority', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...prioritized.take(5).map((pt) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _priorityColor(pt.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pt.task.title, style: theme.textTheme.bodySmall),
                                  Text(
                                    pt.reasons.join(' · '),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _priorityLabel(pt.priority),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _priorityColor(pt.priority),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            AchievementGrid(
              items: _buildAchievements(store),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnergyRow(String label, List<String> times, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Wrap(
            spacing: 4,
            children: times.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(t, style: theme.textTheme.labelSmall?.copyWith(color: color)),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.critical:
        return const Color(0xFFE57373);
      case TaskPriority.high:
        return const Color(0xFFD8A15C);
      case TaskPriority.medium:
        return const Color(0xFF5B8E7D);
      case TaskPriority.low:
        return const Color(0xFF6C8A7B);
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.critical:
        return 'Critical';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  List<int> _buildTaskBars(List<dynamic> tasks) {
    if (tasks.isEmpty) {
      return List<int>.filled(7, 0);
    }
    final counts = <int, int>{};
    for (final task in tasks) {
      final day = task.scheduledAt.weekday;
      counts[day] = (counts[day] ?? 0) + (task.isCompleted ? 1 : 0);
    }
    return List.generate(7, (i) {
      final day = i + 1;
      return (counts[day] ?? 0).clamp(0, 7);
    });
  }

  List<int> _buildBalanceBars(int pending, int completed) {
    final total = pending + completed;
    if (total == 0) {
      return List<int>.filled(7, 0);
    }
    final balance = (completed / total * 7).clamp(1, 7).round();
    return List<int>.filled(7, balance);
  }

  List<String> _buildAchievements(AppStore store) {
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
}

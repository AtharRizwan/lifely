import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/constants.dart';
import '../../utils/time.dart';
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
    final prioritized = pending.isNotEmpty
        ? prioritizer.prioritize(store.tasks)
        : const <PrioritizedTask>[];
    final today = dateOnly(DateTime.now());
    final lastWeek = [for (var i = 6; i >= 0; i--) addDays(today, -i)];
    final dayLabels = [
      for (final day in lastWeek) weekdayShortNames[day.weekday - 1].substring(0, 2),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Insights'),
      ),
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
              'Planner streak - ${store.plannerStreak} days',
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
              title: 'Tasks completed',
              subtitle: 'Last 7 days',
              bars: _buildTaskBars(store.tasks, lastWeek),
              labels: dayLabels,
            ),
            const SizedBox(height: 16),
            ChartCard(
              title: 'Mood',
              subtitle: 'Last 7 days · 4 focused, 3 steady, 2 low energy, 1 stressed',
              bars: _buildMoodBars(store.moods, lastWeek),
              labels: dayLabels,
              barColor: AppColors.pink,
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
                    _buildEnergyRow('Peak focus', scheduler.peakHours.map((h) => '$h:00').toList(), AppColors.success, theme),
                    const SizedBox(height: 8),
                    _buildEnergyRow('Low energy', scheduler.lowHours.map((h) => '$h:00').toList(), AppColors.warning, theme),
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
        return AppColors.priorityCriticalColor;
      case TaskPriority.high:
        return AppColors.priorityHighColor;
      case TaskPriority.medium:
        return AppColors.priorityMediumColor;
      case TaskPriority.low:
        return AppColors.priorityLowColor;
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

  /// Tasks completed on each day in [days].
  List<int> _buildTaskBars(List<TaskItem> tasks, List<DateTime> days) {
    return [
      for (final day in days)
        tasks
            .where((task) =>
                task.isCompleted &&
                isSameDay(task.completedAt ?? task.scheduledAt, day))
            .length,
    ];
  }

  /// The latest mood logged on each day in [days], scored 1-4 (0 = none).
  List<int> _buildMoodBars(List<MoodEntry> moods, List<DateTime> days) {
    final advisor = AiMoodAdvisor();
    int score(String mood) {
      switch (advisor.normalizeMood(mood)) {
        case 'Focused':
          return 4;
        case 'Steady':
          return 3;
        case 'Low energy':
          return 2;
        case 'Stressed':
          return 1;
        default:
          return 0;
      }
    }

    return [
      for (final day in days)
        // Moods are kept newest first, so the first match is the day's latest.
        moods
            .where((entry) => isSameDay(entry.loggedAt, day))
            .map((entry) => score(entry.mood))
            .firstOrNull ?? 0,
    ];
  }

  List<String> _buildAchievements(AppStore store) {
    final achievements = <String>[];
    if (store.moodStreak >= 3) {
      achievements.add('Mood streak ${store.moodStreak} days');
    }
    if (store.completedTasks >= 3) {
      achievements.add('Completed ${store.completedTasks} tasks');
    }
    if (store.plannerStreak >= 3) {
      achievements.add('Planned ${store.plannerStreak} days in a row');
    } else if (store.plannerBlocks.isNotEmpty) {
      achievements.add('Planner blocks added');
    }
    if (achievements.isEmpty) {
      achievements.add('Start logging to unlock achievements');
    }
    return achievements;
  }
}

import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../utils/navigation.dart';
import '../../utils/time.dart';
import '../tiles/checklist_item.dart';

/// The three most urgent tasks due in the week starting [weekStart], plus any
/// already finished that week.
class WeekOverviewCard extends StatelessWidget {
  const WeekOverviewCard({super.key, this.weekStart});

  /// Monday of the week to summarise; defaults to the current week.
  final DateTime? weekStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final monday = weekStart ?? startOfWeek(DateTime.now());
    final nextMonday = addDays(monday, 7);
    final weekTasks = store.tasks
        .where((task) =>
            !task.scheduledAt.isBefore(monday) &&
            task.scheduledAt.isBefore(nextMonday))
        .toList();
    final topPending = AiTaskPrioritizer()
        .prioritize(weekTasks)
        .take(3)
        .map((prioritized) => prioritized.task)
        .toList();
    final doneCount = weekTasks.where((task) => task.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Core milestones', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              weekTasks.isEmpty
                  ? 'Nothing due this week yet.'
                  : '$doneCount of ${weekTasks.length} tasks done this week',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            if (topPending.isEmpty)
              Text(
                weekTasks.isEmpty
                    ? 'Add tasks with a due date to populate your week.'
                    : 'Everything due this week is done.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...topPending.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => openTaskDetails(context, task.id),
                    child: ChecklistItem(
                      text: '${task.title} · ${formatShortDate(task.scheduledAt)}',
                      done: task.isCompleted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

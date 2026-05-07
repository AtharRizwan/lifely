import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../tiles/checklist_item.dart';

class WeekOverviewCard extends StatelessWidget {
  const WeekOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final tasks = store.tasks.take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Core milestones', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Text(
                'No milestones yet. Add tasks to populate your week.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChecklistItem(text: task.title, done: task.isCompleted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

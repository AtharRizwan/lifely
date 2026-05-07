import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../buttons/primary_button.dart';
import '../tiles/mini_stat.dart';

class ProgressTeaserCard extends StatelessWidget {
  const ProgressTeaserCard({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress highlights', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              store.tasks.isEmpty
                  ? 'Add tasks to start tracking your rhythm.'
                  : 'Your weekly rhythm is coming into focus.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MiniStat(label: 'Streak', value: '${store.taskStreak}d'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniStat(
                    label: 'Balance',
                    value: store.tasks.isEmpty
                        ? '0%'
                        : '${(store.completedTasks / store.tasks.length * 100).round()}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniStat(label: 'Achv.', value: '${store.completedTasks}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Open insights', onPressed: onOpen),
          ],
        ),
      ),
    );
  }
}

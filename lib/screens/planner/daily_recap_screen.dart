import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../utils/time.dart';
import '../../widgets/cards/recap_card.dart';

class DailyRecapScreen extends StatelessWidget {
  const DailyRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final now = DateTime.now();
    final completed = store.completedOn(now);
    final pending = store.pendingDueBy(now);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Daily recap'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RecapCard(
            completed: completed.length,
            pending: pending.length,
            mood: store.latestMoodLabel,
          ),
          const SizedBox(height: 12),
          Text('Finished today', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            Text(
              'Nothing finished yet today.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            ...completed.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(task.title),
                    subtitle: Text(task.category),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Still due today', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            Text(
              'Nothing left for today.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            ...pending.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(
                      Icons.radio_button_unchecked,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      task.isOverdue(now) && !isSameDay(task.scheduledAt, now)
                          ? '${task.category} · overdue since ${formatShortDate(task.scheduledAt)}'
                          : '${task.category} · ${formatClock(task.scheduledAt)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Mark complete',
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        store.completeTask(task.id);
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

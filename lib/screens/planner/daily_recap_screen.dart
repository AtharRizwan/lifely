import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/cards/recap_card.dart';

class DailyRecapScreen extends StatelessWidget {
  const DailyRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final completed = store.tasks.where((task) => task.isCompleted).toList();
    final pending = store.tasks.where((task) => !task.isCompleted).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Daily recap')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RecapCard(
            completed: completed.length,
            pending: pending.length,
            mood: store.latestMoodLabel,
          ),
          const SizedBox(height: 12),
          Text('Finished tasks', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            Text(
              'No tasks completed yet.',
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
          Text('Pending tasks', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            Text(
              'Nothing pending right now.',
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
                    subtitle: Text(task.category),
                    trailing: IconButton(
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

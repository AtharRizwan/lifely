import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/snackbar.dart';
import '../../widgets/buttons/primary_button.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final task = store.tasks.firstWhere(
      (item) => item.id == taskId,
      orElse: () => TaskItem(
        id: taskId,
        title: 'Task',
        subtitle: 'Details unavailable',
        category: 'General',
        accent: theme.colorScheme.primary.value,
        scheduledAt: DateTime.now(),
        estimatedMinutes: 45,
        isCompleted: false,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: 'task-hero-${task.title}',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        task.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            color: Color(task.accent),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(task.category, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Color(task.accent),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Est. ${task.estimatedMinutes} min',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: task.isCompleted ? 'Completed' : 'Mark complete',
            onPressed: task.isCompleted
                ? null
                : () {
                    store.completeTask(task.id);
                    showSnackBar(context, 'Task marked complete.');
                  },
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              store.rescheduleTask(
                task.id,
                task.scheduledAt.add(const Duration(days: 1)),
              );
              showSnackBar(context, 'Task rescheduled for tomorrow.');
            },
            child: const Text('Reschedule'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              store.removeTask(task.id);
              Navigator.of(context).pop();
            },
            child: const Text('Remove task'),
          ),
        ],
      ),
    );
  }
}

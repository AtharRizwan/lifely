import 'package:flutter/material.dart';

import '../../utils/snackbar.dart';
import '../../widgets/buttons/primary_button.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key, required this.taskTitle});

  final String taskTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: 'task-hero-$taskTitle',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(taskTitle, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        'Scheduled today - 45 min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text('Academics', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text('Est. 45 min', style: theme.textTheme.bodyMedium),
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
            label: 'Mark complete',
            onPressed: () => showSnackBar(context, 'Task marked complete.'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () =>
                showSnackBar(context, 'Task rescheduled for tomorrow.'),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }
}

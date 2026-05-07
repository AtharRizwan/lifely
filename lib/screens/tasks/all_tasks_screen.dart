import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../utils/navigation.dart';
import '../../widgets/cards/task_card.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final tasks = store.tasks;
    return Scaffold(
      appBar: AppBar(title: const Text('All tasks')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (tasks.isEmpty)
            Text(
              'No tasks yet. Add one from Quick add.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  title: task.title,
                  subtitle: task.subtitle,
                  badge: task.category,
                  accent: Color(task.accent),
                  isCompleted: task.isCompleted,
                  onTap: () => openTaskDetails(context, task.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

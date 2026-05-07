import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/snackbar.dart';
import '../../widgets/cards/action_card.dart';

class AdjustLoadScreen extends StatelessWidget {
  const AdjustLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Adjust load')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ActionCard(
            title: 'Move one task',
            subtitle: 'Shift a low-priority task to tomorrow.',
            actionLabel: 'Reschedule',
            onAction: () {
              final task = store.tasks.firstWhere(
                (task) => !task.isCompleted,
                orElse: () => store.tasks.isNotEmpty
                    ? store.tasks.first
                    : TaskItem(
                        id: 'none',
                        title: 'Task',
                        subtitle: 'No tasks available',
                        category: 'General',
                        accent: 0xFF6C8A7B,
                        scheduledAt: DateTime.now(),
                        estimatedMinutes: 30,
                        isCompleted: false,
                      ),
              );
              if (task.id == 'none') {
                showSnackBar(context, 'No tasks to reschedule.');
                return;
              }
              store.rescheduleTask(
                task.id,
                task.scheduledAt.add(const Duration(days: 1)),
              );
              showSnackBar(context, 'Task moved to tomorrow.');
            },
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Create a focus block',
            subtitle: 'Reserve 90 minutes for deep work.',
            actionLabel: 'Add block',
            onAction: () {
              store.addPlannerBlock(
                PlannerBlock(
                  id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
                  timeLabel: '3:30',
                  title: 'Focus block',
                  detail: '90 min deep work',
                  accent: 0xFF5B8E7D,
                ),
              );
              showSnackBar(context, 'Focus block added.');
            },
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Quiet notifications',
            subtitle: 'Mute alerts for the next 2 hours.',
            actionLabel: 'Enable',
            onAction: () {
              store.addNotification(
                NotificationItem(
                  id: 'note-${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Quiet mode enabled',
                  body: 'Notifications muted for 2 hours.',
                  timestamp: DateTime.now(),
                  isUnread: true,
                ),
              );
              showSnackBar(context, 'Quiet mode enabled.');
            },
          ),
        ],
      ),
    );
  }
}

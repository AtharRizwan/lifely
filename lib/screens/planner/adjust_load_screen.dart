import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/snackbar.dart';
import '../../widgets/cards/action_card.dart';

class AdjustLoadScreen extends StatelessWidget {
  const AdjustLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final latestMood = store.moods.isNotEmpty ? store.moods.first : null;
    final moodAdvisor = AiMoodAdvisor();
    final suggestion = moodAdvisor.generate(store.tasks, latestMood, store.pendingTasks);

    return Scaffold(
      appBar: AppBar(title: const Text('Adjust load')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                      Text('AI Load Advisor', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suggestion.message,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ...suggestion.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(child: Text(tip, style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  Text(
                    'Suggested category: ${suggestion.suggestedCategory}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('Best times for categories', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...['Academics', 'Wellness', 'Admin', 'Social'].map((cat) {
            final scheduler = AiScheduler();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_categoryIcon(cat), color: _categoryColor(cat)),
                title: Text(cat),
                subtitle: Text(scheduler.suggestBestTime(cat)),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Academics':
        return Icons.school_outlined;
      case 'Wellness':
        return Icons.favorite_outline;
      case 'Admin':
        return Icons.build_outlined;
      case 'Social':
        return Icons.people_outline;
      default:
        return Icons.task_outlined;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Academics':
        return const Color(0xFF5B8E7D);
      case 'Wellness':
        return const Color(0xFFE57373);
      case 'Admin':
        return const Color(0xFFD8A15C);
      case 'Social':
        return const Color(0xFF7986CB);
      default:
        return const Color(0xFF6C8A7B);
    }
  }
}

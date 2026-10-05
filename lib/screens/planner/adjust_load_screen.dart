import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../utils/constants.dart';
import '../../utils/time.dart';
import '../../widgets/cards/action_card.dart';
import '../../widgets/sheets/planner_block_sheet.dart';

class AdjustLoadScreen extends StatefulWidget {
  const AdjustLoadScreen({super.key});

  @override
  State<AdjustLoadScreen> createState() => _AdjustLoadScreenState();
}

class _AdjustLoadScreenState extends State<AdjustLoadScreen> {
  String? _moveStatus;

  Future<void> _moveOneTask(AppStore store) async {
    final now = DateTime.now();
    final dueToday = store.tasksOn(now).where((task) => !task.isCompleted).toList();
    final prioritized = AiTaskPrioritizer().prioritize(dueToday);
    if (prioritized.isEmpty) {
      setState(() => _moveStatus = 'Nothing pending today to move.');
      return;
    }
    // prioritize() puts the most urgent first, so the last is the least.
    final task = prioritized.last.task;
    final original = task.scheduledAt;
    final tomorrow = addDays(original, 1);
    final messenger = ScaffoldMessenger.of(context);
    await store.rescheduleTask(task.id, tomorrow);
    if (!mounted) return;
    setState(() => _moveStatus = 'Moved "${task.title}" to ${formatDueLabel(tomorrow, now)}.');
    messenger.showSnackBar(SnackBar(
      content: Text('Moved "${task.title}" to tomorrow'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          store.rescheduleTask(task.id, original);
          if (mounted) setState(() => _moveStatus = null);
        },
      ),
    ));
  }

  Future<void> _addFocusBlock(AppStore store) async {
    final start = AiScheduler().nextPeakSlot(DateTime.now(), store.plannerBlocks);
    final block = await showPlannerBlockSheet(
      context,
      start: start,
      durationMinutes: 90,
      title: 'Focus block',
      detail: AppStrings.deepWorkDetail,
    );
    if (block != null) await store.addPlannerBlock(block);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final moodAdvisor = AiMoodAdvisor();
    final suggestion = moodAdvisor.generate(store.tasks, store.latestMood, store.pendingTasks);
    final quietUntil = store.quietUntil;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Adjust load'),
      ),
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
            subtitle: _moveStatus ?? "Shift today's least urgent task to tomorrow.",
            actionLabel: 'Reschedule',
            onAction: () => _moveOneTask(store),
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Create a focus block',
            subtitle: 'Reserve 90 minutes in your next free peak-focus slot.',
            actionLabel: 'Add block',
            onAction: () => _addFocusBlock(store),
          ),
          const SizedBox(height: 12),
          if (quietUntil != null)
            ActionCard(
              title: 'Quiet mode is on',
              subtitle: 'New reminders are paused until ${formatClock(quietUntil)}.',
              actionLabel: 'Turn off',
              onAction: store.clearQuiet,
            )
          else
            ActionCard(
              title: 'Quiet notifications',
              subtitle: 'Pause new reminders for the next 2 hours.',
              actionLabel: 'Enable',
              onAction: () => store.setQuietFor(const Duration(hours: 2)),
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
                leading: Icon(_categoryIcon(cat), color: AppColors.forCategory(cat)),
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
}

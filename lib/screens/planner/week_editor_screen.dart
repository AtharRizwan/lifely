import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/constants.dart';
import '../../widgets/cards/action_card.dart';

class WeekEditorScreen extends StatelessWidget {
  const WeekEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit week'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ActionCard(
            title: 'Adjust study blocks',
            subtitle: 'Balance deep work across days.',
            actionLabel: 'Update blocks',
            onAction: () {
              store.addPlannerBlock(
                PlannerBlock(
                  id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
                  timeLabel: AppStrings.defaultFocusTime,
                  title: 'Deep work block',
                  detail: AppStrings.libraryDetail,
                  accent: AppStrings.defaultFocusAccent,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Add recurring tasks',
            subtitle: 'Daily recap and review.',
            actionLabel: 'Add recurring',
            onAction: () {
              store.addTask(
                TaskItem(
                  id: 'task-${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Daily recap',
                  subtitle: 'Review tasks and mood',
                  category: 'Routine',
                  accent: 0xFF6C8A7B,
                  scheduledAt: DateTime.now().add(const Duration(hours: 8)),
                  estimatedMinutes: 15,
                  isCompleted: false,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tiles/checklist_item.dart';

class WeekOverviewCard extends StatelessWidget {
  const WeekOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Core milestones', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            const ChecklistItem(text: 'Draft lab report outline', done: true),
            const SizedBox(height: 8),
            const ChecklistItem(text: 'Study group agenda', done: false),
            const SizedBox(height: 8),
            const ChecklistItem(text: 'Quiz practice set', done: false),
          ],
        ),
      ),
    );
  }
}

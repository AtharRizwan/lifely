import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';

class SummaryBulletList extends StatelessWidget {
  const SummaryBulletList({super.key, required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (bullets.isEmpty) {
      return Text(
        'Paste notes above and tap Summarize to generate bullets.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    return Column(
      children: bullets
          .map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(bullet, style: theme.textTheme.bodyMedium),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    final store = AppScope.of(context);
                    store.addTask(TaskItem(
                      id: 'task-${DateTime.now().millisecondsSinceEpoch}-${bullet.hashCode}',
                      title: bullet,
                      subtitle: 'From notes - Today',
                      category: 'Academics',
                      accent: 0xFF5B8E7D,
                      scheduledAt: DateTime.now(),
                      estimatedMinutes: 30,
                      isCompleted: false,
                    ));
                  },
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

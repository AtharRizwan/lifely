import 'package:flutter/material.dart';

class RecapCard extends StatelessWidget {
  const RecapCard({
    super.key,
    required this.completed,
    required this.pending,
    required this.mood,
  });

  final int completed;
  final int pending;
  final String mood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = completed > 0 || pending > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily recap', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            if (!hasData)
              Text(
                'Add tasks to see a recap summary.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else ...[
              Text(
                'Completed: $completed',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Pending: $pending',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Mood: $mood',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

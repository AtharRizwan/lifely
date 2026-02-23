import 'package:flutter/material.dart';

class MoodHistoryTile extends StatelessWidget {
  const MoodHistoryTile({
    super.key,
    required this.mood,
    required this.time,
    required this.note,
  });

  final String mood;
  final String time;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mood, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(note, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

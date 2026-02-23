import 'package:flutter/material.dart';

import '../buttons/primary_button.dart';
import '../tiles/mini_stat.dart';

class ProgressTeaserCard extends StatelessWidget {
  const ProgressTeaserCard({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress highlights', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Your weekly rhythm is steady. Open insights for charts and trends.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: MiniStat(label: 'Streak', value: '5 days'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MiniStat(label: 'Balance', value: '68%'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MiniStat(label: 'Achv.', value: '3'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Open insights', onPressed: onOpen),
          ],
        ),
      ),
    );
  }
}

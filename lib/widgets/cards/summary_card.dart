import 'package:flutter/material.dart';

import '../lists/summary_bullet_list.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SummaryBulletList(bullets: bullets),
          ],
        ),
      ),
    );
  }
}

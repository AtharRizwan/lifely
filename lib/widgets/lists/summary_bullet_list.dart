import 'package:flutter/material.dart';

import '../../utils/snackbar.dart';

class SummaryBulletList extends StatelessWidget {
  const SummaryBulletList({super.key, required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (bullets.isEmpty) {
      return Text(
        'Generate a summary to see 3-5 bullets here.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                  onTap: () =>
                      showSnackBar(context, 'Task created from bullet.'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

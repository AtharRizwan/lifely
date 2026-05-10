import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/tiles/timeline_entry.dart';

class DayViewScreen extends StatelessWidget {
  const DayViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final blocks = store.plannerBlocks;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Day view'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: blocks.isEmpty
            ? [
                Text(
                  'No blocks yet. Add one in week editor.',
                  style: theme.textTheme.bodyMedium,
                ),
              ]
            : blocks
                .map(
                  (block) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TimelineEntry(
                      time: block.timeLabel,
                      title: block.title,
                      detail: block.detail,
                      accent: Color(block.accent),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

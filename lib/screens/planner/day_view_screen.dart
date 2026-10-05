import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../utils/navigation.dart';
import '../../utils/time.dart';
import '../../widgets/tiles/timeline_entry.dart';
import '../../widgets/ui_state/error_banners.dart';

/// Everything on one day: due tasks and planner blocks, in time order.
class DayViewScreen extends StatelessWidget {
  const DayViewScreen({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final now = DateTime.now();

    final entries = <({DateTime time, Widget child})>[
      for (final task in store.tasksOn(day))
        (
          time: task.scheduledAt,
          child: TimelineEntry(
            time: formatClock(task.scheduledAt),
            title: task.title,
            detail: task.isCompleted
                ? 'Task · ${task.category} · done'
                : 'Task · ${task.category} · ${task.estimatedMinutes} min',
            accent: Color(task.accent),
            onTap: () => openTaskDetails(context, task.id),
          ),
        ),
      for (final block in store.plannerBlocksOn(day))
        (
          time: block.start,
          child: TimelineEntry(
            time: formatClock(block.start),
            title: block.title,
            detail: 'Until ${formatClock(block.end)}'
                '${block.detail.isEmpty ? '' : ' · ${block.detail}'}',
            accent: Color(block.accent),
          ),
        ),
    ]..sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(formatRelativeDay(day, now)),
      ),
      body: entries.isEmpty
          ? const EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Nothing planned',
              subtitle: 'Add a block from the Planner or a task with this due date.',
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: entry.child,
                      ))
                  .toList(),
            ),
    );
  }
}

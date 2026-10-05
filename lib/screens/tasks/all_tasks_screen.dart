import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/navigation.dart';
import '../../utils/time.dart';
import '../../widgets/cards/task_card.dart';
import '../../widgets/inputs/category_chip.dart';
import '../../widgets/ui_state/error_banners.dart';

enum _TaskFilter { all, pending, overdue, done }

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  _TaskFilter _filter = _TaskFilter.pending;

  static const _labels = {
    _TaskFilter.all: 'All',
    _TaskFilter.pending: 'Pending',
    _TaskFilter.overdue: 'Overdue',
    _TaskFilter.done: 'Done',
  };

  List<TaskItem> _apply(List<TaskItem> tasks, DateTime now) {
    final filtered = tasks.where((task) {
      switch (_filter) {
        case _TaskFilter.all:
          return true;
        case _TaskFilter.pending:
          return !task.isCompleted;
        case _TaskFilter.overdue:
          return task.isOverdue(now);
        case _TaskFilter.done:
          return task.isCompleted;
      }
    }).toList();
    if (_filter == _TaskFilter.done) {
      // Most recently finished first.
      filtered.sort((a, b) => (b.completedAt ?? b.scheduledAt)
          .compareTo(a.completedAt ?? a.scheduledAt));
    } else {
      filtered.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    }
    return filtered;
  }

  String _emptyMessage() {
    switch (_filter) {
      case _TaskFilter.all:
        return 'No tasks yet. Add one from Quick add.';
      case _TaskFilter.pending:
        return 'Nothing pending. Enjoy the breathing room.';
      case _TaskFilter.overdue:
        return 'Nothing overdue. You are on track.';
      case _TaskFilter.done:
        return 'No completed tasks yet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final now = DateTime.now();
    final tasks = _apply(store.tasks, now);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('All tasks'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _TaskFilter.values
                .map((filter) => CategoryChip(
                      label: _labels[filter]!,
                      selected: _filter == filter,
                      onTap: () => setState(() => _filter = filter),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            EmptyState(
              icon: Icons.task_alt_rounded,
              title: _emptyMessage(),
            )
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  title: task.title,
                  subtitle: task.isOverdue(now)
                      ? 'Overdue · ${formatDueLabel(task.scheduledAt, now)}'
                      : formatDueLabel(task.scheduledAt, now),
                  badge: task.category,
                  accent: Color(task.accent),
                  isCompleted: task.isCompleted,
                  heroTag: TaskCard.taskHeroTag(task.id),
                  onTap: () => openTaskDetails(context, task.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

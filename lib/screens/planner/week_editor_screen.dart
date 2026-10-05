import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/time.dart';
import '../../widgets/sheets/planner_block_sheet.dart';

enum _BlockAction { edit, repeat, delete }

/// Plan a whole week of blocks: add per day, edit, delete, or copy a block to
/// the rest of the week.
class WeekEditorScreen extends StatefulWidget {
  const WeekEditorScreen({super.key});

  @override
  State<WeekEditorScreen> createState() => _WeekEditorScreenState();
}

class _WeekEditorScreenState extends State<WeekEditorScreen> {
  DateTime _weekStart = startOfWeek(DateTime.now());
  String? _status;

  Future<void> _addBlock(AppStore store, DateTime day) async {
    final now = DateTime.now();
    final start = isSameDay(day, now)
        ? DateTime(now.year, now.month, now.day, now.hour + 1)
        : DateTime(day.year, day.month, day.day, 9);
    final block = await showPlannerBlockSheet(context, start: start);
    if (block != null) await store.addPlannerBlock(block);
  }

  Future<void> _onAction(AppStore store, PlannerBlock block, _BlockAction action) async {
    switch (action) {
      case _BlockAction.edit:
        final updated = await showPlannerBlockSheet(context, initial: block);
        if (updated != null) await store.updatePlannerBlock(updated);
        break;
      case _BlockAction.repeat:
        final added = await _repeatOnRestOfWeek(store, block);
        if (!mounted) return;
        setState(() => _status = added == 0
            ? '"${block.title}" is already on the rest of the week.'
            : 'Copied "${block.title}" to $added more ${added == 1 ? 'day' : 'days'}.');
        break;
      case _BlockAction.delete:
        await store.removePlannerBlock(block.id);
        break;
    }
  }

  /// Copies [block] to the following weekdays (through Friday, or through
  /// Sunday for a weekend block), skipping days that already have it.
  Future<int> _repeatOnRestOfWeek(AppStore store, PlannerBlock block) async {
    final lastWeekday = block.start.weekday < DateTime.friday
        ? DateTime.friday
        : DateTime.sunday;
    var added = 0;
    for (var weekday = block.start.weekday + 1; weekday <= lastWeekday; weekday++) {
      final start = addDays(block.start, weekday - block.start.weekday);
      final alreadyThere = store.plannerBlocksOn(start).any((existing) =>
          existing.title == block.title &&
          existing.start.hour == start.hour &&
          existing.start.minute == start.minute);
      if (alreadyThere) continue;
      // A plain copy: the original's task link only applies to its own day.
      await store.addPlannerBlock(PlannerBlock(
        id: 'plan-${DateTime.now().millisecondsSinceEpoch}-$weekday',
        start: start,
        durationMinutes: block.durationMinutes,
        title: block.title,
        detail: block.detail,
        accent: block.accent,
      ));
      added++;
    }
    return added;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final now = DateTime.now();
    final isCurrentWeek = isSameDay(_weekStart, startOfWeek(now));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit week'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous week',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() {
                  _weekStart = addDays(_weekStart, -7);
                  _status = null;
                }),
              ),
              Expanded(
                child: Text(
                  isCurrentWeek ? 'This week' : 'Week of ${formatShortDate(_weekStart)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Next week',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => setState(() {
                  _weekStart = addDays(_weekStart, 7);
                  _status = null;
                }),
              ),
            ],
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _status!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          for (var offset = 0; offset < 7; offset++)
            _buildDay(store, theme, addDays(_weekStart, offset), now),
        ],
      ),
    );
  }

  Widget _buildDay(AppStore store, ThemeData theme, DateTime day, DateTime now) {
    final blocks = store.plannerBlocksOn(day);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isSameDay(day, now)
                          ? 'Today · ${formatShortDate(day)}'
                          : formatShortDate(day),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add block on ${formatShortDate(day)}',
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => _addBlock(store, day),
                  ),
                ],
              ),
              if (blocks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No blocks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              else
                ...blocks.map((block) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(block.accent),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(block.title),
                      subtitle: Text(
                        '${formatClock(block.start)} - ${formatClock(block.end)}',
                      ),
                      onTap: () => _onAction(store, block, _BlockAction.edit),
                      trailing: PopupMenuButton<_BlockAction>(
                        onSelected: (action) => _onAction(store, block, action),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: _BlockAction.edit, child: Text('Edit')),
                          PopupMenuItem(
                            value: _BlockAction.repeat,
                            child: Text('Repeat on rest of week'),
                          ),
                          PopupMenuItem(value: _BlockAction.delete, child: Text('Delete')),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

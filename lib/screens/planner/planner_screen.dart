import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/constants.dart';
import '../../utils/navigation.dart';
import '../../utils/time.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/week_overview_card.dart';
import '../../widgets/sheets/planner_block_sheet.dart';
import '../../widgets/tiles/section_header.dart';
import '../../widgets/tiles/timeline_entry.dart';
import '../../widgets/tiles/week_strip.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _weekStart = startOfWeek(DateTime.now());
  int _selectedDay = DateTime.now().weekday;

  DateTime get _selectedDate => addDays(_weekStart, _selectedDay - 1);

  void _shiftWeek(int weeks) {
    setState(() => _weekStart = addDays(_weekStart, 7 * weeks));
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _weekStart = startOfWeek(now);
      _selectedDay = now.weekday;
    });
  }

  DateTime _defaultBlockStart(DateTime day) {
    final now = DateTime.now();
    if (isSameDay(day, now)) {
      return DateTime(now.year, now.month, now.day, now.hour + 1);
    }
    return DateTime(day.year, day.month, day.day, 9);
  }

  Future<void> _addBlock(AppStore store) async {
    final block = await showPlannerBlockSheet(
      context,
      start: _defaultBlockStart(_selectedDate),
    );
    if (block != null) await store.addPlannerBlock(block);
  }

  Future<void> _editBlock(AppStore store, PlannerBlock block) async {
    final updated = await showPlannerBlockSheet(context, initial: block);
    if (updated != null) await store.updatePlannerBlock(updated);
  }

  Future<void> _removeBlock(AppStore store, PlannerBlock block) async {
    final messenger = ScaffoldMessenger.of(context);
    final removed = await store.removePlannerBlock(block.id);
    if (removed == null) return;
    messenger.showSnackBar(SnackBar(
      content: const Text('Block removed'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => store.addPlannerBlock(removed),
      ),
    ));
  }

  PlannerBlock _blockFromSuggestion(ScheduledBlock suggestion, int index) {
    return PlannerBlock(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}-$index',
      start: suggestion.start,
      durationMinutes: suggestion.durationMinutes,
      title: suggestion.taskTitle,
      detail: suggestion.reason,
      accent: AppColors.categoryAccent(suggestion.category),
      taskId: suggestion.taskId,
    );
  }

  Future<void> _addSuggestions(AppStore store, List<ScheduledBlock> suggestions) async {
    for (var i = 0; i < suggestions.length; i++) {
      await store.addPlannerBlock(_blockFromSuggestion(suggestions[i], i));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final now = DateTime.now();
    final selectedDate = _selectedDate;
    final dayName = weekdayLongNames[_selectedDay - 1];

    final dayTasks = store.tasksOn(selectedDate);
    final dayBlocks = store.plannerBlocksOn(selectedDate);

    final scheduler = AiScheduler();
    final mood = scheduler.effectiveMood(store.latestMood, now);
    final suggestions = scheduler.schedule(
      store.tasks,
      day: selectedDate,
      now: now,
      mood: store.latestMood,
      existing: store.plannerBlocks,
    );

    final markedDays = <int>{
      for (final task in store.tasks)
        if (!task.scheduledAt.isBefore(_weekStart) &&
            task.scheduledAt.isBefore(addDays(_weekStart, 7)))
          task.scheduledAt.weekday,
      for (final block in store.plannerBlocks)
        if (!block.start.isBefore(_weekStart) &&
            block.start.isBefore(addDays(_weekStart, 7)))
          block.start.weekday,
    };
    final isCurrentWeek = isSameDay(_weekStart, startOfWeek(now));

    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Planner',
          subtitle: '$dayName · Week ${isoWeekNumber(selectedDate)}',
          actions: [
            ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _shiftWeek(-1),
                  ),
                  Expanded(
                    child: Text(
                      isCurrentWeek
                          ? 'This week'
                          : 'Week of ${formatShortDate(_weekStart)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  if (!isCurrentWeek)
                    TextButton(onPressed: _goToToday, child: const Text('Today')),
                  IconButton(
                    tooltip: 'Next week',
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _shiftWeek(1),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              WeekStrip(
                weekStart: _weekStart,
                selectedDay: _selectedDay,
                markedDays: markedDays,
                onDaySelected: (day) => setState(() => _selectedDay = day),
              ),
              const SizedBox(height: 18),
              if (dayTasks.isNotEmpty) ...[
                SectionHeader(
                  title: 'Tasks for ${weekdayShortNames[_selectedDay - 1]}',
                  action: '${dayTasks.length}',
                ),
                const SizedBox(height: 10),
                ...dayTasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TimelineEntry(
                    time: formatClock(task.scheduledAt),
                    title: task.title,
                    detail: task.isCompleted
                        ? '${task.category} · done'
                        : '${task.category} · ${task.estimatedMinutes} min',
                    accent: Color(task.accent),
                    onTap: () => openTaskDetails(context, task.id),
                  ),
                )),
                const SizedBox(height: 18),
              ],
              if (suggestions.isNotEmpty) ...[
                SectionHeader(
                  title: 'AI Schedule',
                  action: suggestions.length > 1 ? 'Add all' : null,
                  onActionTap: () => _addSuggestions(store, suggestions),
                ),
                if (mood != 'Steady') ...[
                  const SizedBox(height: 4),
                  Text(
                    'Shaped by your "$mood" check-in · up to '
                    '${scheduler.dailyCapMinutes(mood) ~/ 60} h of tasks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                ...suggestions.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildScheduledBlock(entry.value, theme, () {
                    store.addPlannerBlock(_blockFromSuggestion(entry.value, entry.key));
                  }),
                )),
                const SizedBox(height: 18),
              ],
              SectionHeader(
                title: 'My timeline',
                action: 'Day view',
                onActionTap: () => openDayView(context, selectedDate),
              ),
              const SizedBox(height: 10),
              if (dayBlocks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'No blocks on ${formatRelativeDay(selectedDate, now).toLowerCase()}.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                ...dayBlocks.map(
                  (block) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(block.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeBlock(store, block),
                      child: TimelineEntry(
                        time: block.timeLabel,
                        title: block.title,
                        detail: block.detail.isEmpty
                            ? '${block.durationMinutes} min'
                            : '${block.detail} · ${block.durationMinutes} min',
                        accent: Color(block.accent),
                        onTap: () => _editBlock(store, block),
                      ),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => _addBlock(store),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add block'),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Week view',
                action: 'Edit',
                onActionTap: () => openWeekEditor(context),
              ),
              const SizedBox(height: 10),
              WeekOverviewCard(weekStart: _weekStart),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledBlock(ScheduledBlock block, ThemeData theme, VoidCallback onAdd) {
    final isPeak = block.energyLevel == 'High focus';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPeak
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${formatClock(block.start)} - ${formatClock(block.end)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isPeak ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPeak
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    block.energyLevel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isPeak ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(block.taskTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              block.reason,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAdd,
                child: const Text('Add to planner'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

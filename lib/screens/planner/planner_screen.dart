import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/navigation.dart';
import '../../utils/snackbar.dart';
import '../../utils/constants.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/week_overview_card.dart';
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
  int _selectedDay = DateTime.now().weekday;
  DateTime get _selectedDate {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    return now.add(Duration(days: _selectedDay - currentWeekday));
  }

  List<TaskItem> get _tasksForSelectedDay {
    final store = AppScope.of(context);
    return store.tasks.where((task) {
      return task.scheduledAt.year == _selectedDate.year &&
          task.scheduledAt.month == _selectedDate.month &&
          task.scheduledAt.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final allBlocks = store.plannerBlocks;

    final scheduler = AiScheduler();
    final scheduleBlocks = scheduler.schedule(store.tasks);

    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[_selectedDay - 1];
    final weekOfYear = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil();
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Planner',
          subtitle: '$dayName - Week $weekOfYear',
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
              WeekStrip(
                selectedDay: _selectedDay,
                onDaySelected: (day) => setState(() => _selectedDay = day),
              ),
              const SizedBox(height: 18),
              if (_tasksForSelectedDay.isNotEmpty) ...[
                SectionHeader(
                  title: 'Tasks for ${dayName.substring(0, 3)}',
                  action: '${_tasksForSelectedDay.length}',
                  onActionTap: () {},
                ),
                const SizedBox(height: 10),
                ..._tasksForSelectedDay.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TimelineEntry(
                    time: '${task.scheduledAt.hour}:${task.scheduledAt.minute.toString().padLeft(2, '0')}',
                    title: task.title,
                    detail: task.category,
                    accent: Color(task.accent),
                  ),
                )),
                const SizedBox(height: 18),
              ],
              if (scheduleBlocks.isNotEmpty) ...[
                SectionHeader(
                  title: 'AI Schedule',
                  action: '',
                  onActionTap: () {},
                ),
                const SizedBox(height: 10),
                ...scheduleBlocks.map((block) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildScheduledBlock(block, theme, store),
                )),
                const SizedBox(height: 18),
              ],
              SectionHeader(
                title: 'My Timeline',
                action: 'Day view',
                onActionTap: () => openDayView(context),
              ),
              const SizedBox(height: 10),
              if (allBlocks.isEmpty)
                Text(
                  'No blocks yet. Add one in week editor.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...allBlocks.map(
                  (block) => Dismissible(
                    key: Key(block.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: theme.colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      store.removePlannerBlock(block.id);
                      showSnackBar(context, 'Block removed.');
                    },
                    child: TimelineEntry(
                      time: block.timeLabel,
                      title: block.title,
                      detail: block.detail,
                      accent: Color(block.accent),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Week view',
                action: 'Edit',
                onActionTap: () => openWeekEditor(context),
              ),
              const SizedBox(height: 10),
              const WeekOverviewCard(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledBlock(ScheduledBlock block, ThemeData theme, dynamic store) {
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
                    '${block.startHour}:00 - ${block.endHour}:00',
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
                onPressed: () {
                  _showScheduleActions(context, block, store);
                },
                child: const Text('Add to planner'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleActions(BuildContext context, ScheduledBlock block, dynamic store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${block.taskTitle}" — ${block.startHour}:00 to ${block.endHour}:00 (${block.energyLevel})'),
        action: SnackBarAction(
          label: 'Add',
          onPressed: () {
            store.addPlannerBlock(
              _createPlannerBlock(block),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Block added to planner.')),
            );
          },
        ),
      ),
    );
  }

  PlannerBlock _createPlannerBlock(ScheduledBlock block) {
    return PlannerBlock(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      timeLabel: '${block.startHour}:00',
      title: block.taskTitle,
      detail: '${block.energyLevel} — ${block.reason}',
      accent: block.energyLevel == 'High focus' ? 0xFF5B8E7D : 0xFFFFB74D,
    );
  }
}

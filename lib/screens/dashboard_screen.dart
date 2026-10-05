import 'package:flutter/material.dart';

import '../ai/ai_planning_engine.dart';
import '../data/app_scope.dart';
import '../utils/navigation.dart';
import '../utils/time.dart';
import '../utils/constants.dart';
import '../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../widgets/buttons/theme_toggle_button.dart';
import '../widgets/cards/gradient_hero_card.dart';
import '../widgets/cards/metric_tile.dart';
import '../widgets/cards/progress_teaser_card.dart';
import '../widgets/cards/recap_card.dart';
import '../widgets/cards/task_card.dart';
import '../widgets/tiles/section_header.dart';
import '../widgets/ui_state/error_banners.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;
  final VoidCallback onLogout;

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.critical:
        return AppColors.priorityCriticalColor;
      case TaskPriority.high:
        return AppColors.priorityHighColor;
      case TaskPriority.medium:
        return AppColors.priorityMediumColor;
      case TaskPriority.low:
        return AppColors.priorityLowColor;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.critical:
        return 'Critical';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Widget _buildMoodSuggestionCard(MoodAwareSuggestion suggestion, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(suggestion.message, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            if (suggestion.tips.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...suggestion.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(tip, style: theme.textTheme.bodySmall)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Category: ${suggestion.suggestedCategory}', style: theme.textTheme.labelSmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Load: ${suggestion.adjustedLoad.toStringAsFixed(1)}', style: theme.textTheme.labelSmall),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final greeting = timeBasedGreeting(DateTime.now());
    final userName = store.profile?.name ?? 'Student';
    final completed = store.completedTasks;
    final pending = store.pendingTasks;

    final prioritizer = AiTaskPrioritizer();
    final prioritized = pending > 0
        ? prioritizer.prioritize(store.tasks)
        : const <PrioritizedTask>[];
    final topTasks = prioritized.take(3).toList();

    final moodAdvisor = AiMoodAdvisor();
    final moodSuggestion =
        moodAdvisor.generate(store.tasks, store.latestMood, pending);

    final now = DateTime.now();
    final todayTasks = store.tasksOn(now);
    final doneToday = todayTasks.where((task) => task.isCompleted).length;
    final overdue = store.tasks.where((task) => task.isOverdue(now)).length;

    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: '$greeting, $userName',
          subtitle: moodSuggestion.message,
          actions: [
            ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () => openProfile(context, onLogout),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (store.syncError != null) ...[
                ErrorBanner(
                  message: store.syncError!,
                  isDismissible: false,
                  actionLabel: store.isSyncing ? null : 'Retry',
                  onAction: store.refresh,
                ),
                const SizedBox(height: 14),
              ],
              GradientHeroCard(
                title: todayTasks.isEmpty
                    ? 'A clear day so far'
                    : doneToday == todayTasks.length
                        ? 'Everything for today is done'
                        : 'Start with one clear win',
                body: todayTasks.length == 1
                    ? '1 task planned today'
                    : '${todayTasks.length} tasks planned today',
                footer: todayTasks.isEmpty
                    ? (overdue > 0
                        ? '$overdue overdue from earlier days'
                        : 'Add a task to plan your day')
                    : '$doneToday of ${todayTasks.length} done'
                        '${overdue > 0 ? ' · $overdue overdue' : ''}',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Focus',
                      value: '$completed done',
                      detail: '$pending pending',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MetricTile(
                      label: 'Mood',
                      value: store.latestMoodLabel,
                      detail: 'Streak ${store.moodStreak} days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (topTasks.isNotEmpty) ...[
                SectionHeader(
                  title: 'AI Priority',
                  action: 'See all',
                  onActionTap: () => openAllTasks(context),
                ),
                const SizedBox(height: 10),
                ...topTasks.map((pt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    title: pt.task.title,
                    subtitle: pt.task.isOverdue(now)
                        ? 'Overdue · ${formatDueLabel(pt.task.scheduledAt, now)}'
                        : 'Due ${formatDueLabel(pt.task.scheduledAt, now)}',
                    badge: _priorityLabel(pt.priority),
                    accent: _priorityColor(pt.priority),
                    isCompleted: pt.task.isCompleted,
                    heroTag: TaskCard.taskHeroTag(pt.task.id),
                    onTap: () => openTaskDetails(context, pt.task.id),
                  ),
                )),
                const SizedBox(height: 20),
              ],
              SectionHeader(
                title: 'Mood suggestion',
                action: 'Adjust load',
                onActionTap: () => openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              _buildMoodSuggestionCard(moodSuggestion, theme),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Daily recap',
                action: 'Open',
                onActionTap: () => openDailyRecap(context),
              ),
              const SizedBox(height: 10),
              RecapCard(
                completed: store.completedOn(now).length,
                pending: store.pendingDueBy(now).length,
                mood: store.latestMoodLabel,
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Personal progress tracker',
                action: 'Open',
                onActionTap: () => openInsights(context),
              ),
              const SizedBox(height: 10),
              ProgressTeaserCard(onOpen: () => openInsights(context)),
            ]),
          ),
        ),
      ],
    );
  }
}

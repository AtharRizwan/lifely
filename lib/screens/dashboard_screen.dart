import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../utils/navigation.dart';
import '../utils/time.dart';
import '../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../widgets/banners/offline_banner.dart';
import '../widgets/buttons/theme_toggle_button.dart';
import '../widgets/cards/gradient_hero_card.dart';
import '../widgets/cards/insight_card.dart';
import '../widgets/cards/metric_tile.dart';
import '../widgets/cards/progress_teaser_card.dart';
import '../widgets/cards/recap_card.dart';
import '../widgets/cards/task_card.dart';
import '../widgets/tiles/section_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final greeting = timeBasedGreeting(DateTime.now());
    final userName = store.profile?.name ?? 'Student';
    final todaysTasks = store.tasks.take(3).toList();
    final completed = store.completedTasks;
    final pending = store.pendingTasks;
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: '$greeting, $userName',
          subtitle: 'Plan your day with calm focus',
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
              GradientHeroCard(
                title: 'Start with one clear win',
                body: '${pending + completed} tasks planned today',
                footer: 'Add tasks to see your recap',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Focus',
                      value: '${completed} done',
                      detail: '${pending} pending',
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
              SectionHeader(
                title: 'Today\'s tasks',
                action: 'See all',
                onActionTap: () => openAllTasks(context),
              ),
              const SizedBox(height: 10),
              if (todaysTasks.isEmpty)
                Text(
                  'No tasks yet. Add one to get started.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...todaysTasks
                    .map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          title: task.title,
                          subtitle: task.subtitle,
                          badge: task.category,
                          accent: Color(task.accent),
                          isCompleted: task.isCompleted,
                          onTap: () => openTaskDetails(context, task.id),
                        ),
                      ),
                    )
                    .toList(),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Suggestion',
                action: 'Adjust load',
                onActionTap: () => openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              const InsightCard(
                title: 'Focus: one high-impact task.',
                body:
                    'Add your top task to get a focused suggestion here.',
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Daily recap',
                action: 'Open',
                onActionTap: () => openDailyRecap(context),
              ),
              const SizedBox(height: 10),
              RecapCard(
                completed: completed,
                pending: pending,
                mood: store.latestMoodLabel,
              ),
              const SizedBox(height: 28),
              const OfflineBanner(text: 'Offline mode - 2 items pending sync'),
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

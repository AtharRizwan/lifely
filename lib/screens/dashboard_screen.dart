import 'package:flutter/material.dart';

import 'settings_screen.dart';
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
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = timeBasedGreeting(DateTime.now());
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: '$greeting, Athar',
          subtitle: 'Midterm week - Focus window 2:00-5:00',
          actions: [
            ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SettingsScreen(onThemeModeChanged: onThemeModeChanged),
                  ),
                );
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const GradientHeroCard(
                title: 'Today, keep it tight',
                body: '3 tasks - 1 class - 1 reflection',
                footer: 'Recap ready at 9:00 pm',
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Focus',
                      value: '2h 40m',
                      detail: 'Deep work',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: MetricTile(
                      label: 'Mood',
                      value: 'Steady',
                      detail: 'Logged 1 hr ago',
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
              TaskCard(
                title: 'Read Chapter 5',
                subtitle: 'Cognitive Science - 7:00 pm',
                badge: 'Academics',
                accent: theme.colorScheme.primary,
                onTap: () => openTaskDetails(context, 'Read Chapter 5'),
              ),
              const SizedBox(height: 12),
              TaskCard(
                title: 'Lab report outline',
                subtitle: 'Bio 204 - 2:30 pm',
                badge: 'Deadline',
                accent: const Color(0xFFD8A15C),
                onTap: () => openTaskDetails(context, 'Lab report outline'),
              ),
              const SizedBox(height: 12),
              TaskCard(
                title: 'TA office hours',
                subtitle: 'Stats - 4:10 pm',
                badge: 'Calendar',
                accent: const Color(0xFF6C8A7B),
                onTap: () => openTaskDetails(context, 'TA office hours'),
              ),
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
                    'Shift low-priority items to tomorrow for a cleaner block.',
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Daily recap',
                action: 'Open',
                onActionTap: () => openDailyRecap(context),
              ),
              const SizedBox(height: 10),
              const RecapCard(completed: 2, pending: 3, mood: 'Steady'),
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

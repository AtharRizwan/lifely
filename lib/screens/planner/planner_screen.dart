import 'package:flutter/material.dart';

import '../../utils/navigation.dart';
import '../../utils/snackbar.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/week_overview_card.dart';
import '../../widgets/tiles/section_header.dart';
import '../../widgets/tiles/timeline_entry.dart';
import '../../widgets/tiles/week_strip.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Planner',
          subtitle: 'Thursday - Week 6',
          actions: [
            ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () =>
                  showSnackBar(context, 'Calendar view is coming soon.'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const WeekStrip(),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Timeline',
                action: 'Day view',
                onActionTap: () => openDayView(context),
              ),
              const SizedBox(height: 10),
              TimelineEntry(
                time: '9:00',
                title: 'Neuroscience lecture',
                detail: 'Hall B',
                accent: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              const TimelineEntry(
                time: '11:30',
                title: 'Library focus',
                detail: 'Chapter 5 notes',
                accent: Color(0xFF6C8A7B),
              ),
              const SizedBox(height: 12),
              const TimelineEntry(
                time: '2:30',
                title: 'Lab report outline',
                detail: 'Submit to portal',
                accent: Color(0xFFD8A15C),
              ),
              const SizedBox(height: 12),
              TimelineEntry(
                time: '4:10',
                title: 'TA office hours',
                detail: 'Stats Q&A',
                accent: theme.colorScheme.primary,
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
}

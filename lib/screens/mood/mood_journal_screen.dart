import 'package:flutter/material.dart';

import '../../utils/navigation.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/insight_card.dart';
import '../../widgets/cards/metric_tile.dart';
import '../../widgets/inputs/mood_chip.dart';
import '../../widgets/tiles/section_header.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  String _selectedMood = 'Steady';

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Mood journal',
          subtitle: 'Check in with yourself',
          actions: [
            ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              onPressed: () => openInsights(context),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionHeader(
                title: 'Today',
                action: 'History',
                onActionTap: () => openMoodHistory(context),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MoodChip(
                    label: 'Focused',
                    selected: _selectedMood == 'Focused',
                    onTap: () => _selectMood('Focused'),
                  ),
                  MoodChip(
                    label: 'Steady',
                    selected: _selectedMood == 'Steady',
                    onTap: () => _selectMood('Steady'),
                  ),
                  MoodChip(
                    label: 'Stressed',
                    selected: _selectedMood == 'Stressed',
                    onTap: () => _selectMood('Stressed'),
                  ),
                  MoodChip(
                    label: 'Low energy',
                    selected: _selectedMood == 'Low energy',
                    onTap: () => _selectMood('Low energy'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What is driving your mood today?',
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Suggestion',
                action: 'Adjust load',
                onActionTap: () => openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              const InsightCard(
                title: 'Keep the next block light.',
                body: 'Finish one core task, then reset.',
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Streaks',
                action: 'Details',
                onActionTap: () => openStreakDetails(context),
              ),
              const SizedBox(height: 10),
              const MetricTile(
                label: 'Mood streak',
                value: '5 days',
                detail: 'Consistent check-ins',
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

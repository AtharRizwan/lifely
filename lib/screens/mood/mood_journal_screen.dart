import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';
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
  final TextEditingController _noteController = TextEditingController();

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  void _saveMood(BuildContext context) {
    final store = AppScope.of(context);
    final entry = MoodEntry(
      id: 'mood-${DateTime.now().millisecondsSinceEpoch}',
      mood: _selectedMood,
      note: _noteController.text.trim().isEmpty
          ? 'Mood logged.'
          : _noteController.text.trim(),
      loggedAt: DateTime.now(),
    );
    store.addMood(entry);
    _noteController.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Mood saved.')));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
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
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What is driving your mood today?',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _saveMood(context),
                  child: const Text('Save mood'),
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Suggestion',
                action: 'Adjust load',
                onActionTap: () => openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              Text(
                store.tasks.isEmpty
                    ? 'Add a task to get a focus suggestion.'
                    : 'Your next task is within reach. Consider a short reset after.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                    ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Streaks',
                action: 'Details',
                onActionTap: () => openStreakDetails(context),
              ),
              const SizedBox(height: 10),
              MetricTile(
                label: 'Mood streak',
                value: '${store.moodStreak} days',
                detail: 'Consistent check-ins',
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

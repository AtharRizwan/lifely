import 'package:flutter/material.dart';

import '../../ai/ai_planning_engine.dart';
import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../utils/navigation.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
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
    final latestMood = store.moods.isNotEmpty ? store.moods.first : null;
    final moodAdvisor = AiMoodAdvisor();
    final suggestion = moodAdvisor.generate(store.tasks, latestMood, store.pendingTasks);
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
                title: 'AI Suggestion',
                action: 'Adjust load',
                onActionTap: () => openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              suggestion.message,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...suggestion.tips.take(2).map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 14, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(tip, style: Theme.of(context).textTheme.labelSmall)),
                          ],
                        ),
                      )),
                    ],
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

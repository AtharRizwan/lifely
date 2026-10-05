import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/time.dart';
import '../../widgets/tiles/mood_history_tile.dart';
import '../../widgets/ui_state/error_banners.dart';

class MoodHistoryScreen extends StatelessWidget {
  const MoodHistoryScreen({super.key});

  Future<void> _remove(BuildContext context, AppStore store, MoodEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);
    final removed = await store.removeMood(entry.id);
    if (removed == null) return;
    messenger.showSnackBar(SnackBar(
      content: const Text('Mood entry deleted'),
      action: SnackBarAction(label: 'Undo', onPressed: () => store.addMood(removed)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final moods = store.moods;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mood history'),
      ),
      body: moods.isEmpty
          ? const EmptyState(
              icon: Icons.mood_outlined,
              title: 'No moods yet',
              subtitle: 'Log your first check-in from the Journal tab.',
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: moods
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(entry.id),
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
                        onDismissed: (_) => _remove(context, store, entry),
                        child: MoodHistoryTile(
                          mood: entry.mood,
                          time: _formatMoodTime(entry.loggedAt),
                          note: entry.note,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

String _formatMoodTime(DateTime time) {
  final now = DateTime.now();
  final clock = formatClock(time);
  final dayDiff = daysBetween(time, now);
  if (dayDiff == 0) {
    return 'Today - $clock';
  }
  if (dayDiff == 1) {
    return 'Yesterday - $clock';
  }
  return '${formatShortDate(time)} - $clock';
}

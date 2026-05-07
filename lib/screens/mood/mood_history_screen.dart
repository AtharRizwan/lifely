import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/tiles/mood_history_tile.dart';

class MoodHistoryScreen extends StatelessWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final moods = store.moods;
    return Scaffold(
      appBar: AppBar(title: const Text('Mood history')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: moods.isEmpty
            ? [
                Text(
                  'No moods yet. Log your first check-in.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]
            : moods
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MoodHistoryTile(
                      mood: entry.mood,
                      time: _formatMoodTime(entry.loggedAt),
                      note: entry.note,
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
  final today = DateTime(now.year, now.month, now.day);
  final loggedDay = DateTime(time.year, time.month, time.day);
  final dayDiff = today.difference(loggedDay).inDays;
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour >= 12 ? 'pm' : 'am';
  if (dayDiff == 0) {
    return 'Today - $hour:$minute $suffix';
  }
  if (dayDiff == 1) {
    return 'Yesterday - $hour:$minute $suffix';
  }
  return '${time.month}/${time.day} - $hour:$minute $suffix';
}

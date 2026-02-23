import 'package:flutter/material.dart';

import '../../widgets/tiles/mood_history_tile.dart';

class MoodHistoryScreen extends StatelessWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood history')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          MoodHistoryTile(
            mood: 'Steady',
            time: 'Today - 2:05 pm',
            note: 'Felt focused after the morning lecture.',
          ),
          SizedBox(height: 12),
          MoodHistoryTile(
            mood: 'Focused',
            time: 'Yesterday - 6:15 pm',
            note: 'Completed lab outline.',
          ),
          SizedBox(height: 12),
          MoodHistoryTile(
            mood: 'Low energy',
            time: 'Tue - 9:10 pm',
            note: 'Long day, need rest.',
          ),
        ],
      ),
    );
  }
}

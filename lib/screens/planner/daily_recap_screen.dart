import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/cards/recap_card.dart';
import '../../widgets/tiles/simple_list_tile.dart';

class DailyRecapScreen extends StatelessWidget {
  const DailyRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final completed = store.tasks.where((task) => task.isCompleted).toList();
    final pending = store.tasks.where((task) => !task.isCompleted).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Daily recap')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RecapCard(
            completed: completed.length,
            pending: pending.length,
            mood: store.latestMoodLabel,
          ),
          const SizedBox(height: 12),
          SimpleListTile(
            icon: Icons.check_circle_outline,
            title: 'Finished tasks',
            subtitle: completed.isEmpty
                ? 'No tasks completed yet.'
                : completed.map((task) => task.title).take(3).join(', '),
          ),
          const SizedBox(height: 10),
          SimpleListTile(
            icon: Icons.pending_actions_outlined,
            title: 'Pending tasks',
            subtitle: pending.isEmpty
                ? 'Nothing pending right now.'
                : pending.map((task) => task.title).take(3).join(', '),
          ),
        ],
      ),
    );
  }
}

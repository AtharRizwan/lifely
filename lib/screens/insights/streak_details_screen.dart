import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/cards/metric_tile.dart';

class StreakDetailsScreen extends StatelessWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Streak details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          MetricTile(
            label: 'Mood streak',
            value: '${store.moodStreak} days',
            detail: 'Days in a row with a mood check-in',
          ),
          const SizedBox(height: 12),
          MetricTile(
            label: 'Completion streak',
            value: '${store.taskStreak} days',
            detail: 'Days in a row with a task completed',
          ),
          const SizedBox(height: 12),
          MetricTile(
            label: 'Planner streak',
            value: '${store.plannerStreak} days',
            detail: 'Days in a row with a planner block',
          ),
        ],
      ),
    );
  }
}

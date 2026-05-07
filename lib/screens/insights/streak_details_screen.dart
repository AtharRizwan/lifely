import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../widgets/cards/metric_tile.dart';

class StreakDetailsScreen extends StatelessWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Streak details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          MetricTile(
            label: 'Mood streak',
            value: '${store.moodStreak} days',
            detail: 'Consistent check-ins',
          ),
          const SizedBox(height: 12),
          MetricTile(
            label: 'Completion streak',
            value: '${store.taskStreak} days',
            detail: 'Daily tasks completed',
          ),
          const SizedBox(height: 12),
          MetricTile(
            label: 'Planner streak',
            value: '${store.plannerBlocks.isEmpty ? 0 : 7} days',
            detail: 'Weekly planning sessions',
          ),
        ],
      ),
    );
  }
}

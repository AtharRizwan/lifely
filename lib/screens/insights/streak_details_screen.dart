import 'package:flutter/material.dart';

import '../../widgets/cards/metric_tile.dart';

class StreakDetailsScreen extends StatelessWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          MetricTile(
            label: 'Mood streak',
            value: '5 days',
            detail: 'Consistent check-ins',
          ),
          SizedBox(height: 12),
          MetricTile(
            label: 'Completion streak',
            value: '3 days',
            detail: 'Daily tasks completed',
          ),
          SizedBox(height: 12),
          MetricTile(
            label: 'Planner streak',
            value: '7 days',
            detail: 'Weekly planning sessions',
          ),
        ],
      ),
    );
  }
}

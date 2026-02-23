import 'package:flutter/material.dart';

import '../../widgets/cards/achievement_grid.dart';
import '../../widgets/cards/progress_tracker_card.dart';
import '../../widgets/charts/chart_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProgressTrackerCard(
            taskStreak: 5,
            loadBalance: 0.68,
            achievements: [
              'Focus streak - 5 days',
              'Planner consistency - 82%',
              'Weekly balance - On track',
            ],
          ),
          const SizedBox(height: 16),
          const ChartCard(
            title: 'Task streaks',
            subtitle: 'Last 7 days',
            bars: [3, 4, 2, 5, 6, 4, 5],
          ),
          const SizedBox(height: 16),
          const ChartCard(
            title: 'Load balance',
            subtitle: 'Focus vs. admin',
            bars: [6, 3, 7, 4, 5, 6, 4],
          ),
          const SizedBox(height: 16),
          const AchievementGrid(
            items: [
              'Early bird',
              'Consistency',
              'Inbox zero',
              'Wellness',
              'Deep work',
              'Weekly reset',
            ],
          ),
        ],
      ),
    );
  }
}

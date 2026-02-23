import 'package:flutter/material.dart';

class ProgressTrackerCard extends StatelessWidget {
  const ProgressTrackerCard({
    super.key,
    required this.taskStreak,
    required this.loadBalance,
    required this.achievements,
  });

  final int taskStreak;
  final double loadBalance;
  final List<String> achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balancePercent = (loadBalance * 100).round().clamp(0, 100);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Task streak', style: theme.textTheme.titleMedium),
                Text('$taskStreak days', style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 10),
            StreakBars(activeCount: taskStreak.clamp(0, 7)),
            const SizedBox(height: 16),
            Text('Load balance', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: loadBalance.clamp(0, 1),
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$balancePercent%'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Achievements', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...achievements.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreakBars extends StatelessWidget {
  const StreakBars({super.key, required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(7, (index) {
        final isActive = index < activeCount;
        return Expanded(
          child: Container(
            height: 10,
            margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

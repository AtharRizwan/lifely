import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bars,
  });

  final String title;
  final String subtitle;
  final List<int> bars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = bars.isEmpty ? 1 : bars.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                final value = bars[index];
                final height = maxValue == 0
                    ? 4.0
                    : (80 * (value / safeMax)).clamp(4.0, 80.0);
                return Expanded(
                  child: Container(
                    height: height,
                    margin: EdgeInsets.only(
                      right: index == bars.length - 1 ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

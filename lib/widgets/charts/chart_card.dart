import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bars,
    this.barColor,
    this.labels,
  });

  final String title;
  final String subtitle;
  final List<int> bars;
  final Color? barColor;

  /// One label per bar; defaults to Monday-first weekday initials.
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = bars.isEmpty ? 1 : bars.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;
    final color = barColor ?? AppColors.primary;

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
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: safeMax.toDouble() + 2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${bars[groupIndex]}',
                          theme.textTheme.bodySmall!,
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days =
                              labels ?? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          if (value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: theme.textTheme.labelSmall,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(bars.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: bars[index].toDouble(),
                          color: color,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
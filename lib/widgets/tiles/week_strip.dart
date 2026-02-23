import 'package:flutter/material.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isActive = index == 3;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  days[index],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${index + 10}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

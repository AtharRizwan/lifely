import 'package:flutter/material.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.selectedDay, required this.onDaySelected});

  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final dayDate = now.add(Duration(days: index + 1 - todayWeekday));
        final isActive = index + 1 == selectedDay;
        return Expanded(
          child: GestureDetector(
            onTap: () => onDaySelected(index + 1),
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
                    '${dayDate.day}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isActive
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

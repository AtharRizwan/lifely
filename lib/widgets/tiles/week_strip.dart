import 'package:flutter/material.dart';

import '../../utils/time.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.weekStart,
    this.markedDays = const {},
  });

  /// Weekday of the selected day, 1 (Monday) to 7 (Sunday).
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  /// Monday of the week to show; defaults to the current week.
  final DateTime? weekStart;

  /// Weekdays (1-7) that have tasks or blocks, shown with a dot.
  final Set<int> markedDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monday = weekStart ?? startOfWeek(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekdayShortNames.length, (index) {
        final dayDate = addDays(monday, index);
        final isActive = index + 1 == selectedDay;
        final isToday = isSameDay(dayDate, now);
        final foreground = isActive ? Colors.white : theme.colorScheme.onSurface;
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
                  color: isToday && !isActive
                      ? theme.colorScheme.primary
                      : (theme.dividerTheme.color ?? Colors.transparent),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    weekdayShortNames[index],
                    style: theme.textTheme.labelSmall?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dayDate.day}',
                    style: theme.textTheme.titleSmall?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: markedDays.contains(index + 1)
                          ? (isActive ? Colors.white : theme.colorScheme.primary)
                          : Colors.transparent,
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

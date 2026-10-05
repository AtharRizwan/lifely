import 'package:flutter/material.dart';

import '../../utils/time.dart';

/// Asks for a new due date for a task currently due at [current]. Resolves to
/// the chosen time, or null if dismissed.
Future<DateTime?> showRescheduleSheet(BuildContext context, DateTime current) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1, current.hour, current.minute);
  final nextWeek = DateTime(now.year, now.month, now.day + 7, current.hour, current.minute);
  final laterToday = DateTime(now.year, now.month, now.day, now.hour + 3);

  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final navigator = Navigator.of(sheetContext);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSameDay(laterToday, now))
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Later today'),
                subtitle: Text(formatClock(laterToday)),
                onTap: () => navigator.pop(laterToday),
              ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Tomorrow'),
              subtitle: Text(formatDueLabel(tomorrow, now)),
              onTap: () => navigator.pop(tomorrow),
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: const Text('Next week'),
              subtitle: Text(formatDueLabel(nextWeek, now)),
              onTap: () => navigator.pop(nextWeek),
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined),
              title: const Text('Pick date & time'),
              onTap: () async {
                final picked = await _pickDateTime(sheetContext, current);
                if (picked != null) navigator.pop(picked);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime current) async {
  final now = DateTime.now();
  final initial = current.isBefore(now) ? now : current;
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: dateOnly(now),
    lastDate: DateTime(now.year + 3, 12, 31),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(current),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

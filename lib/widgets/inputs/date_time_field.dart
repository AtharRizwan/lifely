import 'package:flutter/material.dart';

import '../../utils/time.dart';

/// A date button and a time button side by side, opening the platform
/// pickers. Calls [onChanged] with the combined date and time.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.showDate = true,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final bool showDate;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    // The picker asserts that initialDate lies within the range.
    final earliest = DateTime(now.year - 1);
    final latest = DateTime(now.year + 3, 12, 31);
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: value.isBefore(earliest) ? dateOnly(value) : earliest,
      lastDate: value.isAfter(latest) ? value : latest,
    );
    if (picked == null) return;
    onChanged(DateTime(
      picked.year,
      picked.month,
      picked.day,
      value.hour,
      value.minute,
    ));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked == null) return;
    onChanged(DateTime(
      value.year,
      value.month,
      value.day,
      picked.hour,
      picked.minute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            if (showDate) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(formatRelativeDay(value, DateTime.now())),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickTime(context),
                icon: const Icon(Icons.schedule_outlined, size: 18),
                label: Text(formatClock(value)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

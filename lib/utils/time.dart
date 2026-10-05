String timeBasedGreeting(DateTime now) {
  final hour = now.hour;
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 17) {
    return 'Good afternoon';
  }
  return 'Good evening';
}

const weekdayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const weekdayLongNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _monthShortNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime dateOnly(DateTime time) => DateTime(time.year, time.month, time.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Monday of the week containing [day].
DateTime startOfWeek(DateTime day) =>
    DateTime(day.year, day.month, day.day - (day.weekday - 1));

/// [day] shifted by whole calendar days (safe across DST changes).
DateTime addDays(DateTime day, int days) => DateTime(
      day.year,
      day.month,
      day.day + days,
      day.hour,
      day.minute,
    );

/// Whole calendar days from [from] to [to] (negative if [to] is earlier).
/// Counted in UTC so a DST change can't turn a day into 23 hours.
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// ISO-8601 week number.
int isoWeekNumber(DateTime day) {
  final date = dateOnly(day);
  final thursday = addDays(date, 4 - date.weekday);
  // Compare in UTC so a DST shift can't shave an hour off the day count.
  final dayOfYear = DateTime.utc(thursday.year, thursday.month, thursday.day)
      .difference(DateTime.utc(thursday.year, 1, 1))
      .inDays;
  return (dayOfYear ~/ 7) + 1;
}

/// "3:05 PM"
String formatClock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

/// "Today", "Tomorrow", "Yesterday", or "Tue 14 Oct".
String formatRelativeDay(DateTime day, DateTime now) {
  final diff = daysBetween(now, day);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return formatShortDate(day);
}

/// "Tue 14 Oct"
String formatShortDate(DateTime day) =>
    '${weekdayShortNames[day.weekday - 1]} ${day.day} ${_monthShortNames[day.month - 1]}';

/// "Today, 3:05 PM"
String formatDueLabel(DateTime due, DateTime now) =>
    '${formatRelativeDay(due, now)}, ${formatClock(due)}';

/// Number of consecutive days, ending today or yesterday, that appear in
/// [days]. A run whose latest day is older than yesterday counts as broken.
int consecutiveDayStreak(Iterable<DateTime> days, DateTime today) {
  final unique = days.map(dateOnly).toSet();
  if (unique.isEmpty) return 0;
  final todayDate = dateOnly(today);
  var cursor = unique.contains(todayDate)
      ? todayDate
      : addDays(todayDate, -1);
  var streak = 0;
  while (unique.contains(cursor)) {
    streak++;
    cursor = addDays(cursor, -1);
  }
  return streak;
}

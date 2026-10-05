import '../models/app_models.dart';
import '../utils/time.dart';

/// Builds in-app reminders from the current tasks and moods. Every reminder has
/// a deterministic id, so running the engine repeatedly never duplicates one.
class ReminderEngine {
  const ReminderEngine();

  static const dueSoonWindow = Duration(hours: 2);
  static const digestHour = 6;
  static const moodCheckInHour = 18;

  /// Returns reminders whose ids are not in [knownIds] (already shown or
  /// dismissed). Returns nothing while quiet mode ([quietUntil]) is active.
  List<NotificationItem> compute({
    required List<TaskItem> tasks,
    required List<MoodEntry> moods,
    required Set<String> knownIds,
    required DateTime now,
    DateTime? quietUntil,
  }) {
    if (quietUntil != null && now.isBefore(quietUntil)) return const [];

    final result = <NotificationItem>[];
    void emit(String id, String title, String body, {String? taskId}) {
      if (knownIds.contains(id) || result.any((item) => item.id == id)) return;
      result.add(NotificationItem(
        id: id,
        title: title,
        body: body,
        timestamp: now,
        isUnread: true,
        taskId: taskId,
      ));
    }

    final pending = tasks.where((task) => !task.isCompleted).toList();

    if (now.hour >= digestHour) {
      final dueToday =
          pending.where((task) => isSameDay(task.scheduledAt, now)).length;
      if (dueToday > 0) {
        emit(
          'rem-digest-${dayKey(now)}',
          dueToday == 1 ? '1 task due today' : '$dueToday tasks due today',
          'Open the planner to see where they fit.',
        );
      }
    }

    for (final task in pending) {
      if (task.scheduledAt.isBefore(now)) {
        emit(
          'rem-overdue-${task.id}-${dayKey(task.scheduledAt)}',
          'Overdue: ${task.title}',
          'Was due ${formatDueLabel(task.scheduledAt, now)}. Reschedule it or finish it now.',
          taskId: task.id,
        );
      } else if (task.scheduledAt.difference(now) <= dueSoonWindow) {
        emit(
          'rem-soon-${task.id}-${task.scheduledAt.millisecondsSinceEpoch}',
          'Due soon: ${task.title}',
          'Due at ${formatClock(task.scheduledAt)} · about ${task.estimatedMinutes} min of work.',
          taskId: task.id,
        );
      }
    }

    if (now.hour >= moodCheckInHour &&
        !moods.any((mood) => isSameDay(mood.loggedAt, now))) {
      emit(
        'rem-mood-${dayKey(now)}',
        'How was today?',
        'Take a moment to log your mood in the journal.',
      );
    }

    return result;
  }

  static String dayKey(DateTime day) =>
      '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
}

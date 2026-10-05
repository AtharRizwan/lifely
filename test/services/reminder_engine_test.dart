import 'package:flutter_test/flutter_test.dart';
import 'package:lifely/models/app_models.dart';
import 'package:lifely/services/reminder_engine.dart';

TaskItem _task(String id, DateTime due, {bool done = false}) {
  return TaskItem(
    id: id,
    title: 'Task $id',
    subtitle: '',
    category: 'Academics',
    accent: 0xFF5B8E7D,
    scheduledAt: due,
    estimatedMinutes: 30,
    isCompleted: done,
  );
}

void main() {
  const engine = ReminderEngine();
  // Monday 5 October 2026.
  final morning = DateTime(2026, 10, 5, 10, 0);
  final evening = DateTime(2026, 10, 5, 19, 0);

  List<String> idsFor({
    required List<TaskItem> tasks,
    List<MoodEntry> moods = const [],
    Set<String> knownIds = const {},
    required DateTime now,
    DateTime? quietUntil,
  }) {
    return engine
        .compute(
          tasks: tasks,
          moods: moods,
          knownIds: knownIds,
          now: now,
          quietUntil: quietUntil,
        )
        .map((item) => item.id)
        .toList();
  }

  test('flags overdue tasks once per due day and links the task', () {
    final items = engine.compute(
      tasks: [_task('a', DateTime(2026, 10, 4, 15))],
      moods: const [],
      knownIds: const {},
      now: morning,
    );
    final overdue = items.singleWhere((item) => item.id.startsWith('rem-overdue'));
    expect(overdue.id, 'rem-overdue-a-20261004');
    expect(overdue.taskId, 'a');
    expect(overdue.isUnread, isTrue);
  });

  test('warns about tasks due within two hours only', () {
    final ids = idsFor(
      tasks: [
        _task('soon', DateTime(2026, 10, 5, 11, 30)),
        _task('later', DateTime(2026, 10, 5, 13, 0)),
      ],
      now: morning,
    );
    expect(ids.where((id) => id.startsWith('rem-soon')), hasLength(1));
    expect(ids.any((id) => id.contains('soon-soon')), isTrue);
  });

  test('sends one digest for tasks due today', () {
    final items = engine.compute(
      tasks: [
        _task('a', DateTime(2026, 10, 5, 13)),
        _task('b', DateTime(2026, 10, 5, 16)),
        _task('c', DateTime(2026, 10, 6, 9)),
      ],
      moods: const [],
      knownIds: const {},
      now: morning,
    );
    final digest = items.singleWhere((item) => item.id == 'rem-digest-20261005');
    expect(digest.title, '2 tasks due today');
  });

  test('asks for a mood check-in in the evening when none was logged', () {
    expect(idsFor(tasks: const [], now: evening), contains('rem-mood-20261005'));
    expect(idsFor(tasks: const [], now: morning), isEmpty);

    final logged = MoodEntry(
      id: 'm',
      mood: 'Steady',
      note: '',
      loggedAt: DateTime(2026, 10, 5, 12),
    );
    expect(idsFor(tasks: const [], moods: [logged], now: evening), isEmpty);
  });

  test('ignores completed tasks', () {
    expect(
      idsFor(tasks: [_task('a', DateTime(2026, 10, 4, 15), done: true)], now: morning),
      isEmpty,
    );
  });

  test('never repeats a reminder that was already shown or dismissed', () {
    final tasks = [
      _task('a', DateTime(2026, 10, 4, 15)),
      _task('b', DateTime(2026, 10, 5, 11)),
    ];
    final first = idsFor(tasks: tasks, now: morning);
    expect(first, isNotEmpty);
    expect(first.toSet(), hasLength(first.length));

    final second = idsFor(tasks: tasks, knownIds: first.toSet(), now: morning);
    expect(second, isEmpty);
  });

  test('stays silent during quiet mode', () {
    final tasks = [_task('a', DateTime(2026, 10, 4, 15))];
    expect(
      idsFor(tasks: tasks, now: morning, quietUntil: morning.add(const Duration(hours: 1))),
      isEmpty,
    );
    expect(
      idsFor(tasks: tasks, now: morning, quietUntil: morning.subtract(const Duration(minutes: 1))),
      isNotEmpty,
    );
  });
}

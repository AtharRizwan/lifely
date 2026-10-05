import 'package:flutter_test/flutter_test.dart';
import 'package:lifely/ai/ai_planning_engine.dart';
import 'package:lifely/models/app_models.dart';

TaskItem _task(
  String id,
  String title, {
  required DateTime due,
  int minutes = 60,
  String category = 'Academics',
  bool done = false,
}) {
  return TaskItem(
    id: id,
    title: title,
    subtitle: '',
    category: category,
    accent: 0xFF5B8E7D,
    scheduledAt: due,
    estimatedMinutes: minutes,
    isCompleted: done,
  );
}

void main() {
  group('AiTaskPrioritizer', () {
    test('orders by urgency score, highest first', () {
      final now = DateTime.now();
      final relaxed = _task('a', 'Tidy desk',
          due: now.add(const Duration(days: 10)), category: 'Routine');
      final urgent = _task('b', 'Final exam prep', due: now.add(const Duration(hours: 3)));
      final overdue = _task('c', 'Lab report', due: now.subtract(const Duration(hours: 2)));

      final ranked = AiTaskPrioritizer().prioritize([relaxed, urgent, overdue]);

      // Exam due within 24h with two high-impact keywords (65) beats an
      // overdue lab report (55); a routine task due in 10 days comes last.
      expect(ranked.map((p) => p.task.id), ['b', 'c', 'a']);
      expect(ranked.first.priority, TaskPriority.critical);
      expect(ranked.last.priority, TaskPriority.low);
    });

    test('skips completed tasks', () {
      final now = DateTime.now();
      final ranked = AiTaskPrioritizer().prioritize([
        _task('a', 'Done thing', due: now, done: true),
        _task('b', 'Open thing', due: now),
      ]);
      expect(ranked.map((p) => p.task.id), ['b']);
    });
  });

  group('AiMoodAdvisor.normalizeMood', () {
    test('maps each journal mood to itself', () {
      final advisor = AiMoodAdvisor();
      for (final mood in ['Focused', 'Steady', 'Stressed', 'Low energy']) {
        expect(advisor.normalizeMood(mood), mood);
      }
    });
  });

  group('AiScheduler', () {
    final scheduler = AiScheduler();
    // Monday 5 October 2026, before the planning day starts at 8:00.
    final morning = DateTime(2026, 10, 5, 7, 0);
    final today = DateTime(2026, 10, 5);

    test('schedules only pending tasks due that day, most urgent first', () {
      final blocks = scheduler.schedule(
        [
          _task('exam', 'Final exam prep', due: DateTime(2026, 10, 5, 18)),
          _task('laundry', 'Laundry', due: DateTime(2026, 10, 5, 20), minutes: 30, category: 'Routine'),
          _task('later', 'Next week essay', due: DateTime(2026, 10, 12, 9)),
          _task('done', 'Finished', due: DateTime(2026, 10, 5, 9), done: true),
        ],
        day: today,
        now: morning,
      );

      expect(blocks.map((b) => b.taskId), ['exam', 'laundry']);
      expect(blocks.first.start, DateTime(2026, 10, 5, 8));
      expect(blocks[1].start, DateTime(2026, 10, 5, 9));
    });

    test('includes overdue tasks when planning today', () {
      final blocks = scheduler.schedule(
        [_task('old', 'Overdue reading', due: DateTime(2026, 10, 3, 12))],
        day: today,
        now: morning,
      );
      expect(blocks.single.taskId, 'old');
      expect(blocks.single.reason, contains('Overdue'));
    });

    test('caps the day when the latest mood is stressed', () {
      final tasks = [
        for (var i = 0; i < 4; i++)
          _task('t$i', 'Task $i', due: DateTime(2026, 10, 5, 20), minutes: 90),
      ];
      final stressed = MoodEntry(
        id: 'm',
        mood: 'Stressed',
        note: '',
        loggedAt: morning.subtract(const Duration(hours: 1)),
      );

      final steadyBlocks = scheduler.schedule(tasks, day: today, now: morning);
      final stressedBlocks =
          scheduler.schedule(tasks, day: today, now: morning, mood: stressed);

      int total(List<ScheduledBlock> blocks) =>
          blocks.fold(0, (sum, block) => sum + block.durationMinutes);
      expect(total(stressedBlocks), lessThanOrEqualTo(scheduler.dailyCapMinutes('Stressed')));
      expect(stressedBlocks.length, lessThan(steadyBlocks.length));
    });

    test('ignores a mood check-in older than a day', () {
      final stale = MoodEntry(
        id: 'm',
        mood: 'Stressed',
        note: '',
        loggedAt: morning.subtract(const Duration(days: 2)),
      );
      expect(scheduler.effectiveMood(stale, morning), 'Steady');
    });

    test('avoids hours taken by existing blocks and past hours', () {
      final existing = [
        PlannerBlock(
          id: 'b',
          start: DateTime(2026, 10, 5, 15),
          durationMinutes: 120,
          title: 'Lecture',
          detail: '',
          accent: 0,
        ),
      ];
      final afternoon = DateTime(2026, 10, 5, 14, 30);
      final blocks = scheduler.schedule(
        [_task('a', 'Problem set', due: DateTime(2026, 10, 5, 21))],
        day: today,
        now: afternoon,
        existing: existing,
      );
      // 14:00 has passed, 15:00 and 16:00 belong to the lecture.
      expect(blocks.single.start, DateTime(2026, 10, 5, 17));
    });

    test('skips tasks already placed on the planner that day', () {
      final existing = [
        PlannerBlock(
          id: 'b',
          start: DateTime(2026, 10, 5, 9),
          durationMinutes: 60,
          title: 'Problem set',
          detail: '',
          accent: 0,
          taskId: 'a',
        ),
      ];
      final blocks = scheduler.schedule(
        [_task('a', 'Problem set', due: DateTime(2026, 10, 5, 21))],
        day: today,
        now: morning,
        existing: existing,
      );
      expect(blocks, isEmpty);
    });

    test('returns nothing for a day in the past', () {
      final blocks = scheduler.schedule(
        [_task('a', 'Old', due: DateTime(2026, 10, 4, 12))],
        day: DateTime(2026, 10, 4),
        now: morning,
      );
      expect(blocks, isEmpty);
    });
  });
}

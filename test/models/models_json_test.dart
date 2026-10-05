import 'package:flutter_test/flutter_test.dart';
import 'package:lifely/models/app_models.dart';

void main() {
  group('PlannerBlock', () {
    test('reads blocks saved before dates existed', () {
      final block = PlannerBlock.fromJson({
        'id': 'plan-1',
        'timeLabel': '15:30',
        'title': 'Focus block',
        'detail': 'Library',
        'accent': 0xFF5B8E7D,
      });
      final now = DateTime.now();
      expect(block.start, DateTime(now.year, now.month, now.day, 15, 30));
      expect(block.durationMinutes, 60);
      expect(block.timeLabel, '15:30');
      expect(block.taskId, isNull);
    });

    test('round-trips through JSON', () {
      final block = PlannerBlock(
        id: 'plan-2',
        start: DateTime(2026, 10, 5, 9, 0),
        durationMinutes: 90,
        title: 'Essay',
        detail: '',
        accent: 0xFF7986CB,
        taskId: 'task-1',
      );
      final copy = PlannerBlock.fromJson(block.toJson());
      expect(copy.start, block.start);
      expect(copy.durationMinutes, 90);
      expect(copy.taskId, 'task-1');
      expect(copy.end, DateTime(2026, 10, 5, 10, 30));
    });
  });

  group('TaskItem', () {
    test('reads tasks saved before completedAt existed', () {
      final task = TaskItem.fromJson({
        'id': 'task-1',
        'title': 'Read',
        'subtitle': 'Quick add - Today',
        'category': 'Academics',
        'scheduledAt': '2026-10-05T10:00:00.000',
        'isCompleted': true,
      });
      expect(task.completedAt, isNull);
      expect(task.estimatedMinutes, 45);
    });

    test('copyWith can set and clear completedAt', () {
      final task = TaskItem(
        id: 't',
        title: 'Read',
        subtitle: '',
        category: 'Academics',
        accent: 0,
        scheduledAt: DateTime(2026, 10, 5),
        estimatedMinutes: 30,
        isCompleted: false,
      );
      final done = task.copyWith(isCompleted: true, completedAt: DateTime(2026, 10, 5, 12));
      expect(TaskItem.fromJson(done.toJson()).completedAt, DateTime(2026, 10, 5, 12));

      final undone = done.copyWith(isCompleted: false, clearCompletedAt: true);
      expect(undone.completedAt, isNull);
      expect(undone.isCompleted, isFalse);
    });
  });

  test('NotificationItem reads items saved without a taskId', () {
    final item = NotificationItem.fromJson({
      'id': 'note-1',
      'title': 'Quiet mode enabled',
      'body': 'Notifications muted for 2 hours.',
      'timestamp': '2026-10-05T10:00:00.000',
      'isUnread': true,
    });
    expect(item.taskId, isNull);
    expect(item.copyWith(isUnread: false).isUnread, isFalse);
  });
}

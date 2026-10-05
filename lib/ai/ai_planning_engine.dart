import '../models/app_models.dart';
import '../utils/constants.dart';
import '../utils/time.dart';

enum TaskPriority { critical, high, medium, low }

class PrioritizedTask {
  const PrioritizedTask({
    required this.task,
    required this.priority,
    required this.score,
    required this.reasons,
  });

  final TaskItem task;
  final TaskPriority priority;
  final double score;
  final List<String> reasons;
}

class AiTaskPrioritizer {
  static const _urgencyPatterns = [
    'urgent', 'asap', 'immediately', 'tomorrow', 'today', 'overdue',
    'critical', 'priority', 'rush', 'emergency', 'important',
  ];
  static const _highImpactKeywords = {
    'exam', 'midterm', 'final', 'quiz', 'test', 'presentation',
    'deadline', 'due', 'submission', 'paper', 'project', 'thesis',
  };

  List<PrioritizedTask> prioritize(List<TaskItem> tasks) {
    if (tasks.isEmpty) return [];

    final now = DateTime.now();
    final scored = tasks
        .where((t) => !t.isCompleted)
        .map((task) {
          final score = _computeScore(task, now);
          return PrioritizedTask(
            task: task,
            priority: _classifyPriority(score),
            score: score,
            reasons: _generateReasons(task, score, now),
          );
        })
        .toList()
      // Most urgent first; earlier due date breaks ties.
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        return a.task.scheduledAt.compareTo(b.task.scheduledAt);
      });
    return scored;
  }

  double scoreOf(TaskItem task, DateTime now) => _computeScore(task, now);

  double _computeScore(TaskItem task, DateTime now) {
    double score = 0;
    final title = task.title.toLowerCase();
    final subtitle = task.subtitle.toLowerCase();

    final hoursUntilDue = task.scheduledAt.difference(now).inHours;
    if (hoursUntilDue < 0) {
      score += AiScoring.overdueScore;
    } else if (hoursUntilDue < 24) {
      score += AiScoring.within24hScore;
    } else if (hoursUntilDue < 48) {
      score += AiScoring.within48hScore;
    } else if (hoursUntilDue < 72) {
      score += AiScoring.within72hScore;
    } else if (hoursUntilDue < 168) {
      score += AiScoring.withinWeekScore;
    }

    for (final keyword in _urgencyPatterns) {
      if (title.contains(keyword) || subtitle.contains(keyword)) {
        score += AiScoring.urgencyKeywordScore;
      }
    }

    for (final keyword in _highImpactKeywords) {
      if (title.contains(keyword) || subtitle.contains(keyword)) {
        score += AiScoring.impactKeywordScore;
      }
    }

    if (task.estimatedMinutes <= 15) {
      score += AiScoring.quickTaskBonus;
    } else if (task.estimatedMinutes > 120) {
      score += AiScoring.longTaskBonus;
    }

    switch (task.category) {
      case 'Academics':
        score += AiScoring.academicsBonus;
        break;
      case 'Admin':
        score += AiScoring.adminBonus;
        break;
      case 'Wellness':
        score += AiScoring.wellnessBonus;
        break;
      case 'Routine':
        score += AiScoring.routinePenalty;
        break;
    }

    return score;
  }

  TaskPriority _classifyPriority(double score) {
    if (score >= AiScoring.criticalThreshold) return TaskPriority.critical;
    if (score >= AiScoring.highThreshold) return TaskPriority.high;
    if (score >= AiScoring.mediumThreshold) return TaskPriority.medium;
    return TaskPriority.low;
  }

  List<String> _generateReasons(TaskItem task, double score, DateTime now) {
    final reasons = <String>[];
    final hoursUntilDue = task.scheduledAt.difference(now).inHours;
    final title = task.title.toLowerCase();

    if (hoursUntilDue < 0) {
      reasons.add('Overdue by ${-hoursUntilDue}h');
    } else if (hoursUntilDue < 24) {
      reasons.add('Due within 24h');
    } else if (hoursUntilDue < 72) {
      reasons.add('Due in ${(hoursUntilDue / 24).ceil()} days');
    }

    for (final keyword in _highImpactKeywords) {
      if (title.contains(keyword)) {
        reasons.add('High-impact: $keyword');
        break;
      }
    }

    if (task.estimatedMinutes <= 30) {
      reasons.add('Quick win (${task.estimatedMinutes} min)');
    } else if (task.estimatedMinutes > 90) {
      reasons.add('Long task (${task.estimatedMinutes} min) — plan a block');
    }

    for (final keyword in _urgencyPatterns) {
      if (title.contains(keyword)) {
        reasons.add('Marked as urgent');
        break;
      }
    }

    return reasons;
  }
}

class MoodAwareSuggestion {
  const MoodAwareSuggestion({
    required this.message,
    required this.adjustedLoad,
    required this.suggestedCategory,
    required this.tips,
  });

  final String message;
  final double adjustedLoad;
  final String suggestedCategory;
  final List<String> tips;
}

class AiMoodAdvisor {
  static const _positiveTips = [
    'Great energy! Take on a challenging task now.',
    'You are in flow. Tackle something important.',
    'Use this momentum for deep work.',
    'High focus detected. Good time for learning.',
    'Ideal for tackling tough material.',
  ];
  static const _neutralTips = [
    'Break big tasks into smaller steps.',
    'Batch similar tasks together.',
    'Take short breaks between tasks.',
    'Stay hydrated and keep a steady pace.',
    'Mix easy and harder tasks for balance.',
  ];
  static const _stressTips = [
    'Start with just one small task.',
    'Take a 5-minute break before continuing.',
    'Consider rescheduling low-priority items.',
    'A short walk can reset your focus.',
    'Light tasks are fine today — no pressure.',
  ];
  static const _lowEnergyTips = [
    'Keep tasks light and short today.',
    'Avoid high-effort work if possible.',
    'Good day for admin and review tasks.',
    'Rest is also productive.',
    'Energy will return — don\'t force it.',
  ];

  MoodAwareSuggestion generate(List<TaskItem> tasks, MoodEntry? latestMood, int pendingCount) {
    final moodLabel = latestMood?.mood ?? 'Steady';
    final normalizedMood = normalizeMood(moodLabel);

    final adjustedLoad = _computeAdjustedLoad(normalizedMood, pendingCount);
    final message = _generateMessage(normalizedMood, pendingCount);
    final category = _suggestCategory(normalizedMood);
    final tips = _generateTips(normalizedMood);

    return MoodAwareSuggestion(
      message: message,
      adjustedLoad: adjustedLoad,
      suggestedCategory: category,
      tips: tips,
    );
  }

  double _computeAdjustedLoad(String mood, int pendingCount) {
    switch (mood) {
      case 'Focused':
        return (pendingCount * AiScoring.focusedLoadMultiplier).clamp(0.0, 10.0);
      case 'Steady':
        return (pendingCount * AiScoring.steadyLoadMultiplier).clamp(0.0, 10.0);
      case 'Stressed':
        return (pendingCount * AiScoring.stressedLoadMultiplier).clamp(0.0, 10.0);
      case 'Low energy':
        return (pendingCount * AiScoring.lowEnergyLoadMultiplier).clamp(0.0, 10.0);
      default:
        return pendingCount.toDouble().clamp(0.0, 10.0);
    }
  }

  String _generateMessage(String mood, int pendingCount) {
    switch (mood) {
      case 'Focused':
        return 'Your energy is high. This is a great time for demanding tasks.';
      case 'Steady':
        return 'You are in a good headspace. Keep a balanced pace.';
      case 'Stressed':
        return 'Ease up. Focus on completion over volume today.';
      case 'Low energy':
        return 'Rest and light tasks. Don\'t push too hard.';
      default:
        return 'Stay steady. Manage your load mindfully.';
    }
  }

  String _suggestCategory(String mood) {
    switch (mood) {
      case 'Focused':
        return 'Academics';
      case 'Stressed':
        return 'Wellness';
      case 'Low energy':
        return 'Admin';
      default:
        return 'Routine';
    }
  }

  List<String> _generateTips(String mood) {
    switch (mood) {
      case 'Focused':
        return _positiveTips.take(3).toList();
      case 'Steady':
        return _neutralTips.take(3).toList();
      case 'Stressed':
        return _stressTips.take(3).toList();
      case 'Low energy':
        return _lowEnergyTips.take(3).toList();
      default:
        return _neutralTips.take(3).toList();
    }
  }

  String normalizeMood(String mood) {
    final lower = mood.toLowerCase();
    // Low energy is checked first: "low energy" also contains "energ".
    if (lower.contains('low') || lower.contains('tired') || lower.contains('exhaust')) {
      return 'Low energy';
    } else if (lower.contains('stress') || lower.contains('anx') || lower.contains('overwhelm')) {
      return 'Stressed';
    } else if (lower.contains('focus') || lower.contains('productive') || lower.contains('energ')) {
      return 'Focused';
    } else if (lower.contains('happy') || lower.contains('great') || lower.contains('good') || lower.contains('calm')) {
      return 'Focused';
    }
    return 'Steady';
  }
}

class ScheduledBlock {
  const ScheduledBlock({
    required this.taskId,
    required this.start,
    required this.durationMinutes,
    required this.taskTitle,
    required this.category,
    required this.reason,
    required this.energyLevel,
  });

  final String taskId;
  final DateTime start;
  final int durationMinutes;
  final String taskTitle;
  final String category;
  final String reason;
  final String energyLevel;

  DateTime get end => start.add(Duration(minutes: durationMinutes));
}

class AiScheduler {
  static const _peakHours = [AiScoring.peakHours, AiScoring.peakHoursEnd, AiScoring.afternoonPeakStart, AiScoring.afternoonPeakEnd];
  static const _lowHours = [AiScoring.lowEnergyHour1, AiScoring.lowEnergyHour2, AiScoring.lowEnergyHour3, AiScoring.lowEnergyHour4];
  static const _dayStartHour = 8;
  static const _dayEndHour = 22;
  static const _lunchHour = 12;

  /// The mood that should shape today's plan. Check-ins older than a day are
  /// ignored so a stale "Stressed" doesn't keep shrinking the schedule.
  String effectiveMood(MoodEntry? mood, DateTime now) {
    if (mood == null || now.difference(mood.loggedAt).inHours >= 24) {
      return 'Steady';
    }
    return AiMoodAdvisor().normalizeMood(mood.mood);
  }

  int dailyCapMinutes(String mood) {
    switch (mood) {
      case 'Focused':
        return AiScoring.focusedDailyMinutes;
      case 'Stressed':
        return AiScoring.stressedDailyMinutes;
      case 'Low energy':
        return AiScoring.lowEnergyDailyMinutes;
      default:
        return AiScoring.steadyDailyMinutes;
    }
  }

  /// Proposes time blocks on [day] for pending tasks due that day (plus
  /// overdue ones when [day] is today), skipping hours already taken by
  /// [existing] blocks and capping the total by mood.
  List<ScheduledBlock> schedule(
    List<TaskItem> tasks, {
    required DateTime day,
    required DateTime now,
    MoodEntry? mood,
    List<PlannerBlock> existing = const [],
  }) {
    final today = dateOnly(now);
    final target = dateOnly(day);
    if (target.isBefore(today)) return [];
    final isToday = target == today;

    final dayBlocks = existing.where((b) => isSameDay(b.start, target)).toList();
    final plannedTaskIds = dayBlocks
        .where((b) => b.taskId != null)
        .map((b) => b.taskId!)
        .toSet();

    final candidates = tasks.where((task) {
      if (task.isCompleted || plannedTaskIds.contains(task.id)) return false;
      final due = dateOnly(task.scheduledAt);
      return due == target || (isToday && due.isBefore(target));
    }).toList();
    if (candidates.isEmpty) return [];

    final normalizedMood = effectiveMood(mood, now);
    final lighterDay =
        normalizedMood == 'Stressed' || normalizedMood == 'Low energy';
    final prioritizer = AiTaskPrioritizer();
    final scores = {
      for (final task in candidates) task.id: prioritizer.scoreOf(task, now),
    };
    candidates.sort((a, b) {
      if (lighterDay) {
        // Short tasks first so progress comes quickly on a hard day.
        final byLength = a.estimatedMinutes.compareTo(b.estimatedMinutes);
        if (byLength != 0) return byLength;
      }
      return scores[b.id]!.compareTo(scores[a.id]!);
    });

    final busy = _busyHours(dayBlocks, target);
    final firstHour = isToday && now.hour + 1 > _dayStartHour
        ? now.hour + 1
        : _dayStartHour;
    var remainingMinutes = dailyCapMinutes(normalizedMood);

    final blocks = <ScheduledBlock>[];
    for (final task in candidates) {
      if (task.estimatedMinutes > remainingMinutes) continue;
      final hoursNeeded = (task.estimatedMinutes / 60).ceil().clamp(1, 3);
      final preferPeak = normalizedMood == 'Focused' &&
          scores[task.id]! >= AiScoring.highThreshold;
      final startHour =
          _findSlot(busy, firstHour, hoursNeeded, preferPeak: preferPeak);
      if (startHour == null) continue;

      for (var h = startHour; h < startHour + hoursNeeded; h++) {
        busy.add(h);
      }
      remainingMinutes -= task.estimatedMinutes;

      blocks.add(ScheduledBlock(
        taskId: task.id,
        start: DateTime(target.year, target.month, target.day, startHour),
        durationMinutes: task.estimatedMinutes,
        taskTitle: task.title,
        category: task.category,
        reason: _reason(task, startHour, normalizedMood, target),
        energyLevel: _energyLevel(startHour),
      ));
    }

    blocks.sort((a, b) => a.start.compareTo(b.start));
    return blocks;
  }

  /// Start of the next free peak-focus hour, today if possible, otherwise
  /// tomorrow.
  DateTime nextPeakSlot(DateTime now, List<PlannerBlock> existing, {int hours = 2}) {
    for (var offset = 0; offset < 7; offset++) {
      final day = addDays(dateOnly(now), offset);
      final busy = _busyHours(
        existing.where((b) => isSameDay(b.start, day)).toList(),
        day,
      );
      final firstHour =
          offset == 0 && now.hour + 1 > _dayStartHour ? now.hour + 1 : _dayStartHour;
      final hour = _findSlot(busy, firstHour, hours, preferPeak: true);
      if (hour != null) {
        return DateTime(day.year, day.month, day.day, hour);
      }
    }
    final tomorrow = addDays(dateOnly(now), 1);
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, AiScoring.peakHours);
  }

  Set<int> _busyHours(List<PlannerBlock> dayBlocks, DateTime day) {
    final busy = <int>{_lunchHour};
    for (final block in dayBlocks) {
      for (var h = 0; h < 24; h++) {
        final slotStart = DateTime(day.year, day.month, day.day, h);
        final slotEnd = DateTime(day.year, day.month, day.day, h + 1);
        if (block.start.isBefore(slotEnd) && block.end.isAfter(slotStart)) {
          busy.add(h);
        }
      }
    }
    return busy;
  }

  int? _findSlot(Set<int> busy, int firstHour, int hours, {required bool preferPeak}) {
    bool fits(int start) {
      if (start < firstHour || start + hours > _dayEndHour) return false;
      for (var h = start; h < start + hours; h++) {
        if (busy.contains(h)) return false;
      }
      return true;
    }

    if (preferPeak) {
      for (final hour in _peakHours) {
        if (fits(hour)) return hour;
      }
    }
    for (var hour = firstHour; hour + hours <= _dayEndHour; hour++) {
      if (fits(hour)) return hour;
    }
    return null;
  }

  String _energyLevel(int startHour) {
    if (_peakHours.contains(startHour)) return 'High focus';
    if (_lowHours.contains(startHour)) return 'Low energy';
    return 'Moderate';
  }

  String _reason(TaskItem task, int startHour, String mood, DateTime target) {
    if (dateOnly(task.scheduledAt).isBefore(target)) {
      return 'Overdue — clear it early';
    }
    if (mood == 'Focused' && _peakHours.contains(startHour)) {
      return 'Peak focus window while you feel focused';
    }
    if (mood == 'Stressed' || mood == 'Low energy') {
      return task.estimatedMinutes <= 30
          ? 'Short task to build momentum'
          : 'Kept to a lighter load today';
    }
    if (_peakHours.contains(startHour)) return 'Peak focus window';
    if (task.estimatedMinutes <= 30) return 'Quick task — flexible slot';
    return 'Due ${formatClock(task.scheduledAt)}';
  }

  String suggestBestTime(String category) {
    switch (category) {
      case 'Academics':
        return '9:00 - 11:00 AM (peak focus)';
      case 'Wellness':
        return '6:00 - 8:00 PM (wind down)';
      case 'Admin':
        return '1:00 - 2:00 PM (low energy slot)';
      case 'Social':
        return '5:00 - 7:00 PM (after study hours)';
      case 'Group work':
        return '3:00 - 5:00 PM (collaborative window)';
      default:
        return '10:00 AM - 12:00 PM';
    }
  }

  List<int> get peakHours => _peakHours;
  List<int> get lowHours => _lowHours;
}

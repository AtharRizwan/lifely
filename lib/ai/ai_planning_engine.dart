import '../models/app_models.dart';
import '../utils/constants.dart';

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
    final sorted = tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => _computeScore(a, now).compareTo(_computeScore(b, now)));

    return sorted.map((task) {
      final score = _computeScore(task, now);
      final priority = _classifyPriority(score);
      final reasons = _generateReasons(task, score, now);
      return PrioritizedTask(
        task: task,
        priority: priority,
        score: score,
        reasons: reasons,
      );
    }).toList();
  }

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
    if (lower.contains('focus') || lower.contains('productive') || lower.contains('energ')) {
      return 'Focused';
    } else if (lower.contains('stress') || lower.contains('anx') || lower.contains('overwhelm')) {
      return 'Stressed';
    } else if (lower.contains('low') || lower.contains('tired') || lower.contains('exhaust')) {
      return 'Low energy';
    } else if (lower.contains('happy') || lower.contains('great') || lower.contains('good') || lower.contains('calm')) {
      return 'Focused';
    }
    return 'Steady';
  }
}

class ScheduledBlock {
  const ScheduledBlock({
    required this.startHour,
    required this.endHour,
    required this.taskTitle,
    required this.reason,
    required this.energyLevel,
  });

  final int startHour;
  final int endHour;
  final String taskTitle;
  final String reason;
  final String energyLevel;
}

class AiScheduler {
  static const _peakHours = [AiScoring.peakHours, AiScoring.peakHoursEnd, AiScoring.afternoonPeakStart, AiScoring.afternoonPeakEnd];
  static const _lowHours = [AiScoring.lowEnergyHour1, AiScoring.lowEnergyHour2, AiScoring.lowEnergyHour3, AiScoring.lowEnergyHour4];

  List<ScheduledBlock> schedule(List<TaskItem> tasks) {
    if (tasks.isEmpty) return [];

    final blocks = <ScheduledBlock>[];
    final availableSlots = [8, 9, 10, 11, 13, 14, 15, 16, 17, 18];
    int slotIndex = 0;

    final sorted = List<TaskItem>.from(tasks.where((t) => !t.isCompleted))
      ..sort((a, b) => a.estimatedMinutes.compareTo(b.estimatedMinutes));

    for (final task in sorted) {
      if (slotIndex >= availableSlots.length) break;

      final startHour = availableSlots[slotIndex];
      final durationSlots = (task.estimatedMinutes / 60).ceil().clamp(1, 3);
      final endHour = (startHour + durationSlots).clamp(0, 22);

      final energyLevel = _peakHours.contains(startHour)
          ? 'High focus'
          : _lowHours.contains(startHour)
              ? 'Low energy'
              : 'Moderate';

      String reason;
      if (_peakHours.contains(startHour)) {
        reason = 'Peak focus window';
      } else if (task.estimatedMinutes <= 30) {
        reason = 'Quick task — flexible slot';
      } else {
        reason = 'Scheduled for ${durationSlots}h block';
      }

      blocks.add(ScheduledBlock(
        startHour: startHour,
        endHour: endHour,
        taskTitle: task.title,
        reason: reason,
        energyLevel: energyLevel,
      ));

      slotIndex += durationSlots.clamp(1, 2);
    }

    return blocks;
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

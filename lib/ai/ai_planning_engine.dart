import '../models/app_models.dart';

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
      score += 50;
    } else if (hoursUntilDue < 24) {
      score += 40;
    } else if (hoursUntilDue < 48) {
      score += 30;
    } else if (hoursUntilDue < 72) {
      score += 20;
    } else if (hoursUntilDue < 168) {
      score += 10;
    }

    for (final keyword in _urgencyPatterns) {
      if (title.contains(keyword) || subtitle.contains(keyword)) {
        score += 15;
      }
    }

    for (final keyword in _highImpactKeywords) {
      if (title.contains(keyword) || subtitle.contains(keyword)) {
        score += 10;
      }
    }

    if (task.estimatedMinutes <= 15) {
      score += 5;
    } else if (task.estimatedMinutes > 120) {
      score += 3;
    }

    switch (task.category) {
      case 'Academics':
        score += 5;
        break;
      case 'Admin':
        score += 3;
        break;
      case 'Wellness':
        score += 2;
        break;
      case 'Routine':
        score -= 5;
        break;
    }

    return score;
  }

  TaskPriority _classifyPriority(double score) {
    if (score >= 50) return TaskPriority.critical;
    if (score >= 30) return TaskPriority.high;
    if (score >= 15) return TaskPriority.medium;
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

    final adjustedLoad = _computeAdjustedLoad(moodLabel, pendingCount);
    final message = _generateMessage(moodLabel, pendingCount);
    final category = _suggestCategory(moodLabel);
    final tips = _generateTips(moodLabel);

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
        return (pendingCount * 1.2).clamp(0.0, 10.0);
      case 'Steady':
        return pendingCount.toDouble().clamp(0.0, 10.0);
      case 'Stressed':
        return (pendingCount * 0.5).clamp(0.0, 10.0);
      case 'Low energy':
        return (pendingCount * 0.3).clamp(0.0, 10.0);
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
  static const _peakHours = [9, 10, 11, 14, 15];
  static const _lowHours = [13, 20, 21, 22];

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

import '../utils/constants.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.joinedAt,
  });

  final String name;
  final String email;
  final DateTime joinedAt;

  UserProfile copyWith({String? name}) {
    return UserProfile(
      name: name ?? this.name,
      email: email,
      joinedAt: joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Student',
      email: json['email'] as String? ?? 'student@lifely.app',
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.accent,
    required this.scheduledAt,
    required this.estimatedMinutes,
    required this.isCompleted,
    this.completedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int accent;
  final DateTime scheduledAt;
  final int estimatedMinutes;
  final bool isCompleted;
  final DateTime? completedAt;

  bool isOverdue(DateTime now) => !isCompleted && scheduledAt.isBefore(now);

  TaskItem copyWith({
    String? title,
    String? subtitle,
    String? category,
    int? accent,
    DateTime? scheduledAt,
    int? estimatedMinutes,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      accent: accent ?? this.accent,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'accent': accent,
      'scheduledAt': scheduledAt.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      accent: json['accent'] as int? ?? AppColors.neutralSlate,
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
          DateTime.now(),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 45,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    );
  }
}

class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.loggedAt,
  });

  final String id;
  final String mood;
  final String note;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: json['mood'] as String,
      note: json['note'] as String? ?? '',
      loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class PlannerBlock {
  const PlannerBlock({
    required this.id,
    required this.start,
    required this.durationMinutes,
    required this.title,
    required this.detail,
    required this.accent,
    this.taskId,
  });

  final String id;
  final DateTime start;
  final int durationMinutes;
  final String title;
  final String detail;
  final int accent;

  /// Set when the block was created from a task by the AI scheduler.
  final String? taskId;

  DateTime get end => start.add(Duration(minutes: durationMinutes));

  String get timeLabel =>
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

  PlannerBlock copyWith({
    String? id,
    DateTime? start,
    int? durationMinutes,
    String? title,
    String? detail,
    int? accent,
  }) {
    return PlannerBlock(
      id: id ?? this.id,
      start: start ?? this.start,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      accent: accent ?? this.accent,
      taskId: taskId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'durationMinutes': durationMinutes,
      'timeLabel': timeLabel,
      'title': title,
      'detail': detail,
      'accent': accent,
      'taskId': taskId,
    };
  }

  factory PlannerBlock.fromJson(Map<String, dynamic> json) {
    return PlannerBlock(
      id: json['id'] as String,
      start: DateTime.tryParse(json['start'] as String? ?? '') ??
          _parseLegacyTimeLabel(json['timeLabel'] as String?),
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      title: json['title'] as String? ?? 'Block',
      detail: json['detail'] as String? ?? '',
      accent: json['accent'] as int? ?? AppColors.neutralSlate,
      taskId: json['taskId'] as String?,
    );
  }

  /// Blocks saved before dates existed only stored an 'HH:mm' label, so they
  /// are placed on today.
  static DateTime _parseLegacyTimeLabel(String? label) {
    final now = DateTime.now();
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(label ?? '');
    final hour = match != null ? int.parse(match.group(1)!) : 9;
    final minute = match != null ? int.parse(match.group(2)!) : 0;
    return DateTime(now.year, now.month, now.day, hour.clamp(0, 23), minute.clamp(0, 59));
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isUnread,
    this.taskId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isUnread;
  final String? taskId;

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isUnread: isUnread ?? this.isUnread,
      taskId: taskId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isUnread': isUnread,
      'taskId': taskId,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isUnread: json['isUnread'] as bool? ?? true,
      taskId: json['taskId'] as String?,
    );
  }
}

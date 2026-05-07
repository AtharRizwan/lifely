class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.joinedAt,
  });

  final String name;
  final String email;
  final DateTime joinedAt;

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
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int accent;
  final DateTime scheduledAt;
  final int estimatedMinutes;
  final bool isCompleted;

  TaskItem copyWith({
    String? title,
    String? subtitle,
    String? category,
    int? accent,
    DateTime? scheduledAt,
    int? estimatedMinutes,
    bool? isCompleted,
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
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: json['category'] as String,
      accent: json['accent'] as int? ?? 0xFF6C8A7B,
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
          DateTime.now(),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 45,
      isCompleted: json['isCompleted'] as bool? ?? false,
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
    required this.timeLabel,
    required this.title,
    required this.detail,
    required this.accent,
  });

  final String id;
  final String timeLabel;
  final String title;
  final String detail;
  final int accent;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeLabel': timeLabel,
      'title': title,
      'detail': detail,
      'accent': accent,
    };
  }

  factory PlannerBlock.fromJson(Map<String, dynamic> json) {
    return PlannerBlock(
      id: json['id'] as String,
      timeLabel: json['timeLabel'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String,
      accent: json['accent'] as int? ?? 0xFF6C8A7B,
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isUnread;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isUnread': isUnread,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isUnread: json['isUnread'] as bool? ?? true,
    );
  }
}

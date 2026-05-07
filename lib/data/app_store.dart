import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

enum AuthResult { success, notFound, wrongPassword, emailTaken }

class AppStore extends ChangeNotifier {
  AppStore({SharedPreferences? preferences}) : _preferences = preferences;

  static const _keyUser = 'lifely_user_profile';
  static const _keyCredentials = 'lifely_credentials';
  static const _keyTasks = 'lifely_tasks';
  static const _keyMoods = 'lifely_moods';
  static const _keyPlanner = 'lifely_planner';
  static const _keyNotifications = 'lifely_notifications';
  static const _keyTheme = 'lifely_theme_mode';

  SharedPreferences? _preferences;

  bool _isHydrated = false;
  bool get isHydrated => _isHydrated;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  final List<TaskItem> _tasks = [];
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  final List<MoodEntry> _moods = [];
  List<MoodEntry> get moods => List.unmodifiable(_moods);

  final List<PlannerBlock> _planner = [];
  List<PlannerBlock> get plannerBlocks => List.unmodifiable(_planner);

  final List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  bool get isAuthenticated => _profile != null;

  Map<String, String> _credentials = {};

  void _hydrateCredentials() {
    final raw = _preferences?.getString(_keyCredentials);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _credentials = decoded.map((k, v) => MapEntry(k, v.toString()));
    }
  }

  Future<void> _persistCredentials() async {
    await _preferences?.setString(_keyCredentials, jsonEncode(_credentials));
  }

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
    _hydrate();
  }

  void _hydrate() {
    if (_preferences == null) {
      return;
    }
    final userRaw = _preferences!.getString(_keyUser);
    if (userRaw != null) {
      _profile = UserProfile.fromJson(jsonDecode(userRaw));
    }

    _themeMode = _decodeTheme(_preferences!.getString(_keyTheme));

    _tasks
      ..clear()
      ..addAll(_decodeList(_keyTasks, TaskItem.fromJson));

    _moods
      ..clear()
      ..addAll(_decodeList(_keyMoods, MoodEntry.fromJson));

    _planner
      ..clear()
      ..addAll(_decodeList(_keyPlanner, PlannerBlock.fromJson));

    _notifications
      ..clear()
      ..addAll(_decodeList(_keyNotifications, NotificationItem.fromJson));

    _hydrateCredentials();

    _isHydrated = true;
    notifyListeners();
  }

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _preferences?.getStringList(key);
    if (raw == null) {
      return [];
    }
    return raw
        .map((entry) => fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persistList(String key, List<Object> values) async {
    await _preferences?.setStringList(
      key,
      values.map((value) => jsonEncode(value)).toList(),
    );
  }

  ThemeMode _decodeTheme(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> _persistThemeMode() async {
    await _preferences?.setString(
      _keyTheme,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _persistThemeMode();
    notifyListeners();
  }

  Future<AuthResult> signUp({required String name, required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_credentials.containsKey(normalizedEmail)) {
      return AuthResult.emailTaken;
    }
    _credentials[normalizedEmail] = _hashPassword(password);
    _profile = UserProfile(name: name.trim(), email: normalizedEmail, joinedAt: DateTime.now());
    await _preferences?.setString(_keyUser, jsonEncode(_profile!.toJson()));
    await _persistCredentials();
    notifyListeners();
    return AuthResult.success;
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final storedHash = _credentials[normalizedEmail];
    if (storedHash == null) {
      return AuthResult.notFound;
    }
    if (storedHash != _hashPassword(password)) {
      return AuthResult.wrongPassword;
    }
    _profile = UserProfile(name: _profile?.name ?? 'Student', email: normalizedEmail, joinedAt: _profile?.joinedAt ?? DateTime.now());
    final profileRaw = _preferences?.getString(_keyUser);
    if (profileRaw != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileRaw));
    }
    notifyListeners();
    return AuthResult.success;
  }

  String _hashPassword(String password) {
    return password.hashCode.toString();
  }

  Future<void> logout() async {
    _profile = null;
    await _preferences?.remove(_keyUser);
    notifyListeners();
  }

  Future<void> clearLocalData({bool keepProfile = true}) async {
    _tasks.clear();
    _moods.clear();
    _planner.clear();
    _notifications.clear();
    await _persistList(_keyTasks, []);
    await _persistList(_keyMoods, []);
    await _persistList(_keyPlanner, []);
    await _persistList(_keyNotifications, []);
    if (!keepProfile) {
      _profile = null;
      await _preferences?.remove(_keyUser);
    }
    notifyListeners();
  }

  void addTask(TaskItem task) {
    _tasks.insert(0, task);
    _persistList(_keyTasks, _tasks.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _persistList(_keyTasks, _tasks.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void updateTask(TaskItem updated) {
    final index = _tasks.indexWhere((task) => task.id == updated.id);
    if (index == -1) {
      return;
    }
    _tasks[index] = updated;
    _persistList(_keyTasks, _tasks.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void completeTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }
    _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    _persistList(_keyTasks, _tasks.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void rescheduleTask(String id, DateTime newDate) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }
    _tasks[index] = _tasks[index].copyWith(scheduledAt: newDate);
    _persistList(_keyTasks, _tasks.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void addMood(MoodEntry entry) {
    _moods.insert(0, entry);
    _persistList(_keyMoods, _moods.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void addPlannerBlock(PlannerBlock block) {
    _planner.add(block);
    _persistList(_keyPlanner, _planner.map((item) => item.toJson()).toList());
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    _persistList(
      _keyNotifications,
      _notifications.map((item) => item.toJson()).toList(),
    );
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _persistList(_keyNotifications, []);
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isUnread: false);
    _persistList(
      _keyNotifications,
      _notifications.map((item) => item.toJson()).toList(),
    );
    notifyListeners();
  }

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  String get latestMoodLabel =>
      _moods.isNotEmpty ? _moods.first.mood : 'Steady';

  int get moodStreak {
    if (_moods.isEmpty) {
      return 0;
    }
    final sorted = [..._moods]..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    int streak = 0;
    DateTime? last;
    for (final entry in sorted) {
      final day = DateTime(entry.loggedAt.year, entry.loggedAt.month, entry.loggedAt.day);
      if (last == null) {
        streak = 1;
        last = day;
        continue;
      }
      final difference = last.difference(day).inDays;
      if (difference == 0) {
        continue;
      }
      if (difference == 1) {
        streak += 1;
        last = day;
      } else {
        break;
      }
    }
    return streak;
  }

  int get taskStreak {
    final completedDates = _tasks
        .where((task) => task.isCompleted)
        .map(
          (task) => DateTime(
            task.scheduledAt.year,
            task.scheduledAt.month,
            task.scheduledAt.day,
          ),
        )
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (completedDates.isEmpty) {
      return 0;
    }
    int streak = 0;
    DateTime? last;
    for (final date in completedDates) {
      if (last == null) {
        streak = 1;
        last = date;
        continue;
      }
      final difference = last.difference(date).inDays;
      if (difference == 1) {
        streak += 1;
        last = date;
      } else if (difference == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

}

extension on NotificationItem {
  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

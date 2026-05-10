import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';
import '../services/firebase_service.dart';

enum AuthResult { success, notFound, wrongPassword, emailTaken, invalidEmail, invalidInput, weakPassword, userDisabled, tooManyRequests, failure }

class AppStore extends ChangeNotifier {
  AppStore({SharedPreferences? preferences}) : _preferences = preferences;

  static const _keyUser = 'lifely_user_profile';
  static const _keyTheme = 'lifely_theme_mode';
  static const _keyTasksCache = 'lifely_tasks_cache';
  static const _keyMoodsCache = 'lifely_moods_cache';
  static const _keyPlannerCache = 'lifely_planner_cache';
  static const _keyNotificationsCache = 'lifely_notifications_cache';

  final FirebaseService _firebase = FirebaseService.instance;
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

  bool get isAuthenticated => _profile != null && _firebase.isAuthenticated;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
    
    await _firebase.initialize();
    
    _themeMode = _decodeTheme(_preferences!.getString(_keyTheme));
    
    if (_firebase.isAuthenticated) {
      await _loadFromFirebase();
      _profile = UserProfile(
        name: _firebase.getUserName() ?? 'Student',
        email: _firebase.getEmail() ?? '',
        joinedAt: DateTime.now(),
      );
    }
    
    _isHydrated = true;
    notifyListeners();
  }

  Future<void> _loadFromFirebase() async {
    debugPrint('_loadFromFirebase: start');
    try {
      final tasks = await _firebase.getTasks();
      debugPrint('_loadFromFirebase: got tasks ${tasks.length}');
      _tasks
        ..clear()
        ..addAll(tasks);
      await _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());
    } catch (e) {
      debugPrint('_loadFromFirebase: Failed to load tasks - $e');
      _loadFromCache();
    }

    try {
      final moods = await _firebase.getMoods();
      debugPrint('_loadFromFirebase: got moods ${moods.length}');
      _moods
        ..clear()
        ..addAll(moods);
      await _cacheList(_keyMoodsCache, _moods.map((m) => m.toJson()).toList());
    } catch (e) {
      debugPrint('_loadFromFirebase: Failed to load moods - $e');
    }

    try {
      final planner = await _firebase.getPlannerBlocks();
      _planner
        ..clear()
        ..addAll(planner);
      await _cacheList(_keyPlannerCache, _planner.map((p) => p.toJson()).toList());
    } catch (e) {
      debugPrint('_loadFromFirebase: Failed to load planner - $e');
    }

    try {
      final notifications = await _firebase.getNotifications();
      _notifications
        ..clear()
        ..addAll(notifications);
      await _cacheList(_keyNotificationsCache, _notifications.map((n) => n.toJson()).toList());
    } catch (e) {
      debugPrint('_loadFromFirebase: Failed to load notifications - $e');
    }
    debugPrint('_loadFromFirebase: done');
  }

  void _loadFromCache() {
    _tasks
      ..clear()
      ..addAll(_decodeList(_keyTasksCache, TaskItem.fromJson));

    _moods
      ..clear()
      ..addAll(_decodeList(_keyMoodsCache, MoodEntry.fromJson));

    _planner
      ..clear()
      ..addAll(_decodeList(_keyPlannerCache, PlannerBlock.fromJson));

    _notifications
      ..clear()
      ..addAll(_decodeList(_keyNotificationsCache, NotificationItem.fromJson));
  }

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _preferences?.getStringList(key);
    if (raw == null) return [];
    return raw
        .map((entry) => fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _cacheList(String key, List<Map<String, dynamic>> values) async {
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

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    debugPrint('AppStore: signUp started');
    final result = await _firebase.signUp(
      name: name,
      email: email,
      password: password,
    );
    debugPrint('AppStore: signUp firebase result: $result');

    switch (result) {
      case AuthServiceResult.success:
        _profile = UserProfile(
          name: name.trim(),
          email: email.trim().toLowerCase(),
          joinedAt: DateTime.now(),
        );
        _preferences?.setString(_keyUser, jsonEncode(_profile!.toJson()));
        notifyListeners();
        debugPrint('AppStore: about to call _loadFromFirebase');
        _loadFromFirebase();
        debugPrint('AppStore: _loadFromFirebase called');
        return AuthResult.success;
      case AuthServiceResult.emailTaken:
        return AuthResult.emailTaken;
      case AuthServiceResult.invalidEmail:
        return AuthResult.invalidEmail;
      case AuthServiceResult.weakPassword:
        return AuthResult.weakPassword;
      case AuthServiceResult.invalidInput:
        return AuthResult.invalidInput;
      default:
        return AuthResult.failure;
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _firebase.signIn(
      email: email,
      password: password,
    );

    switch (result) {
      case AuthServiceResult.success:
        final uid = _firebase.currentUserId;
        final profile = uid.isNotEmpty ? await _firebase.getUserProfile(uid) : null;
        _profile = profile ??
            UserProfile(
              name: 'Student',
              email: email.trim().toLowerCase(),
              joinedAt: DateTime.now(),
            );
        _preferences?.setString(_keyUser, jsonEncode(_profile!.toJson()));
        
        await _loadFromFirebase();
        
        notifyListeners();
        return AuthResult.success;
      case AuthServiceResult.notFound:
        return AuthResult.notFound;
      case AuthServiceResult.wrongPassword:
        return AuthResult.wrongPassword;
      case AuthServiceResult.invalidEmail:
        return AuthResult.invalidEmail;
      case AuthServiceResult.invalidInput:
        return AuthResult.invalidInput;
      case AuthServiceResult.userDisabled:
        return AuthResult.userDisabled;
      case AuthServiceResult.tooManyRequests:
        return AuthResult.tooManyRequests;
      default:
        return AuthResult.failure;
    }
  }

  Future<void> logout() async {
    _profile = null;
    _tasks.clear();
    _moods.clear();
    _planner.clear();
    _notifications.clear();
    await _preferences?.remove(_keyUser);
    await _firebase.signOut();
    notifyListeners();
  }

  Future<void> clearLocalData({bool keepProfile = true}) async {
    _tasks.clear();
    _moods.clear();
    _planner.clear();
    _notifications.clear();
    await _cacheList(_keyTasksCache, []);
    await _cacheList(_keyMoodsCache, []);
    await _cacheList(_keyPlannerCache, []);
    await _cacheList(_keyNotificationsCache, []);
    
    try {
      await _firebase.clearAllData();
    } catch (e) {
      debugPrint('AppStore: Failed to clear all data - $e');
    }
    
    if (!keepProfile) {
      _profile = null;
      await _preferences?.remove(_keyUser);
    }
    notifyListeners();
  }

  Future<void> clearTasks() async {
    _tasks.clear();
    await _cacheList(_keyTasksCache, []);
    notifyListeners();

    try {
      await _firebase.clearTasks();
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> addTask(TaskItem task) async {
    _tasks.insert(0, task);
    await _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.addTask(task);
    } catch (e) {
      debugPrint('AppStore: Failed to add task - $e');
    }
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.removeTask(id);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> updateTask(TaskItem updated) async {
    final index = _tasks.indexWhere((task) => task.id == updated.id);
    if (index == -1) {
      return;
    }
    _tasks[index] = updated;
    await _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.updateTask(updated);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> completeTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }
    _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    await _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.completeTask(id);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> rescheduleTask(String id, DateTime newDate) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }
    _tasks[index] = _tasks[index].copyWith(scheduledAt: newDate);
    await _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.rescheduleTask(id, newDate);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> addMood(MoodEntry entry) async {
    _moods.insert(0, entry);
    await _cacheList(_keyMoodsCache, _moods.map((m) => m.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.addMood(entry);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> removeMood(String id) async {
    _moods.removeWhere((mood) => mood.id == id);
    await _cacheList(_keyMoodsCache, _moods.map((m) => m.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.removeMood(id);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> clearMoods() async {
    _moods.clear();
    await _cacheList(_keyMoodsCache, []);
    notifyListeners();

    try {
      await _firebase.clearMoods();
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> addPlannerBlock(PlannerBlock block) async {
    _planner.add(block);
    await _cacheList(_keyPlannerCache, _planner.map((p) => p.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.addPlannerBlock(block);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> removePlannerBlock(String id) async {
    _planner.removeWhere((block) => block.id == id);
    await _cacheList(_keyPlannerCache, _planner.map((p) => p.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.removePlannerBlock(id);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> updatePlannerBlock(PlannerBlock block) async {
    final index = _planner.indexWhere((b) => b.id == block.id);
    if (index == -1) return;
    
    _planner[index] = block;
    await _cacheList(_keyPlannerCache, _planner.map((p) => p.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.updatePlannerBlock(block);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> addNotification(NotificationItem item) async {
    _notifications.insert(0, item);
    await _cacheList(_keyNotificationsCache, _notifications.map((n) => n.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.addNotification(item);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> clearNotifications() async {
    _notifications.clear();
    await _cacheList(_keyNotificationsCache, []);
    notifyListeners();

    try {
      await _firebase.clearNotifications();
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
  }

  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isUnread: false);
    await _cacheList(_keyNotificationsCache, _notifications.map((n) => n.toJson()).toList());
    notifyListeners();

    try {
      await _firebase.markNotificationRead(id);
    } catch (e) {
      debugPrint('AppStore: Failed to remove task - $e');
    }
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
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';
import '../services/firebase_service.dart';
import '../services/reminder_engine.dart';
import '../utils/time.dart';

enum AuthResult {
  success,
  notFound,
  wrongPassword,
  invalidCredentials,
  emailTaken,
  invalidEmail,
  invalidInput,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,
  failure,
}

class AppStore extends ChangeNotifier {
  AppStore({SharedPreferences? preferences}) : _preferences = preferences;

  static const _keyUser = 'lifely_user_profile';
  static const _keyTheme = 'lifely_theme_mode';
  static const _keyTasksCache = 'lifely_tasks_cache';
  static const _keyMoodsCache = 'lifely_moods_cache';
  static const _keyPlannerCache = 'lifely_planner_cache';
  static const _keyNotificationsCache = 'lifely_notifications_cache';
  static const _keyCacheOwner = 'lifely_cache_owner';
  static const _keyQuietUntil = 'lifely_quiet_until';
  static const _keyDismissedReminders = 'lifely_dismissed_reminders';
  static const _dismissedRetentionDays = 14;

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

  String? _syncError;
  /// Set when the last cloud read or write failed; local data is still saved.
  String? get syncError => _syncError;

  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  DateTime? _quietUntil;
  Timer? _quietTimer;

  bool get isAuthenticated => _profile != null && _firebase.isAuthenticated;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();

    await _firebase.initialize();

    _themeMode = _decodeTheme(_preferences!.getString(_keyTheme));

    if (_firebase.isAuthenticated) {
      final uid = _firebase.currentUserId;
      final cachedProfile = _decodeProfile();
      final owner = _preferences!.getString(_keyCacheOwner);
      // Caches written before the owner key existed are trusted only when the
      // cached profile belongs to the signed-in account.
      final ownsCache = owner == uid ||
          (owner == null &&
              cachedProfile != null &&
              cachedProfile.email == _firebase.getEmail()?.toLowerCase());

      if (ownsCache) {
        _loadFromCache();
        _profile = cachedProfile;
      } else {
        await _clearCaches();
      }
      _quietUntil = DateTime.tryParse(_preferences!.getString(_keyQuietUntil) ?? '');
      _scheduleQuietExpiry();

      _profile ??= UserProfile(
        name: _firebase.getUserName() ?? 'Student',
        email: _firebase.getEmail() ?? '',
        joinedAt: _firebase.accountCreatedAt ?? DateTime.now(),
      );

      // Cached data is on screen right away; the cloud copy follows.
      unawaited(_loadRemote(uid));
    }

    _isHydrated = true;
    notifyListeners();
  }

  Future<void> _loadRemote(String uid) async {
    final remoteProfile = await _firebase.getUserProfile(uid);
    if (remoteProfile != null) {
      _profile = remoteProfile;
      await _preferences?.setString(_keyUser, jsonEncode(remoteProfile.toJson()));
    }
    await refresh();
  }

  /// Reloads every collection from Firestore. A collection that fails to load
  /// keeps its cached copy.
  Future<void> refresh() async {
    if (!_firebase.isAuthenticated) return;
    _isSyncing = true;
    notifyListeners();

    final failed = <String>[];
    Future<void> load<T>(
      String label,
      Future<List<T>> Function() fetch,
      List<T> target,
      String cacheKey,
      Map<String, dynamic> Function(T) toJson,
    ) async {
      try {
        final items = await fetch();
        target
          ..clear()
          ..addAll(items);
        await _cacheList(cacheKey, target.map(toJson).toList());
      } catch (e) {
        debugPrint('AppStore: failed to load $label - $e');
        failed.add(label);
      }
    }

    await load('tasks', _firebase.getTasks, _tasks, _keyTasksCache, (t) => t.toJson());
    await load('moods', _firebase.getMoods, _moods, _keyMoodsCache, (m) => m.toJson());
    await load('planner', _firebase.getPlannerBlocks, _planner, _keyPlannerCache, (p) => p.toJson());
    await load('notifications', _firebase.getNotifications, _notifications, _keyNotificationsCache, (n) => n.toJson());
    _sortCollections();
    await _preferences?.setString(_keyCacheOwner, _firebase.currentUserId);

    if (failed.isEmpty) {
      _syncError = null;
      _lastSyncedAt = DateTime.now();
    } else {
      _syncError = "Couldn't load your ${failed.join(', ')} from the cloud.";
    }
    _isSyncing = false;
    notifyListeners();
    await generateReminders();
  }

  /// Runs a cloud write. Local state has already been updated and cached, so a
  /// failure only marks the store as out of sync.
  Future<void> _sync(String label, Future<void> Function() operation) async {
    final hadError = _syncError;
    try {
      await operation();
      _syncError = null;
      _lastSyncedAt = DateTime.now();
    } catch (e) {
      debugPrint('AppStore: failed to $label - $e');
      _syncError = "Couldn't $label in the cloud. It's saved on this device.";
    }
    if (hadError != _syncError) {
      notifyListeners();
    }
  }

  void _sortCollections() {
    _moods.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _planner.sort((a, b) => a.start.compareTo(b.start));
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

    _sortCollections();
  }

  UserProfile? _decodeProfile() {
    final raw = _preferences?.getString(_keyUser);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _preferences?.getStringList(key);
    if (raw == null) return [];
    final items = <T>[];
    for (final entry in raw) {
      try {
        items.add(fromJson(jsonDecode(entry) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('AppStore: skipped unreadable cache entry in $key - $e');
      }
    }
    return items;
  }

  Future<void> _cacheList(String key, List<Map<String, dynamic>> values) async {
    await _preferences?.setStringList(
      key,
      values.map((value) => jsonEncode(value)).toList(),
    );
  }

  Future<void> _persistTasks() =>
      _cacheList(_keyTasksCache, _tasks.map((t) => t.toJson()).toList());

  Future<void> _persistMoods() =>
      _cacheList(_keyMoodsCache, _moods.map((m) => m.toJson()).toList());

  Future<void> _persistPlanner() =>
      _cacheList(_keyPlannerCache, _planner.map((p) => p.toJson()).toList());

  Future<void> _persistNotifications() => _cacheList(
      _keyNotificationsCache, _notifications.map((n) => n.toJson()).toList());

  Future<void> _clearCaches() async {
    for (final key in [
      _keyTasksCache,
      _keyMoodsCache,
      _keyPlannerCache,
      _keyNotificationsCache,
      _keyCacheOwner,
      _keyDismissedReminders,
      _keyQuietUntil,
    ]) {
      await _preferences?.remove(key);
    }
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

  // ---------------------------------------------------------------- Auth --

  AuthResult _mapAuthResult(AuthServiceResult result) {
    switch (result) {
      case AuthServiceResult.success:
        return AuthResult.success;
      case AuthServiceResult.notFound:
        return AuthResult.notFound;
      case AuthServiceResult.wrongPassword:
        return AuthResult.wrongPassword;
      case AuthServiceResult.invalidCredentials:
        return AuthResult.invalidCredentials;
      case AuthServiceResult.emailTaken:
        return AuthResult.emailTaken;
      case AuthServiceResult.invalidEmail:
        return AuthResult.invalidEmail;
      case AuthServiceResult.invalidInput:
        return AuthResult.invalidInput;
      case AuthServiceResult.weakPassword:
        return AuthResult.weakPassword;
      case AuthServiceResult.userDisabled:
        return AuthResult.userDisabled;
      case AuthServiceResult.tooManyRequests:
        return AuthResult.tooManyRequests;
      case AuthServiceResult.network:
        return AuthResult.network;
      case AuthServiceResult.failure:
        return AuthResult.failure;
    }
  }

  /// Makes sure cached data from a different account is never shown.
  Future<void> _claimCacheFor(String uid) async {
    if (_preferences?.getString(_keyCacheOwner) != uid) {
      await _clearCaches();
      _tasks.clear();
      _moods.clear();
      _planner.clear();
      _notifications.clear();
    }
    await _preferences?.setString(_keyCacheOwner, uid);
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _firebase.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (result != AuthServiceResult.success) {
      return _mapAuthResult(result);
    }

    await _claimCacheFor(_firebase.currentUserId);
    _profile = UserProfile(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      joinedAt: DateTime.now(),
    );
    await _preferences?.setString(_keyUser, jsonEncode(_profile!.toJson()));
    notifyListeners();
    unawaited(refresh());
    return AuthResult.success;
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _firebase.signIn(
      email: email,
      password: password,
    );
    if (result != AuthServiceResult.success) {
      return _mapAuthResult(result);
    }

    final uid = _firebase.currentUserId;
    await _claimCacheFor(uid);
    final profile = uid.isNotEmpty ? await _firebase.getUserProfile(uid) : null;
    _profile = profile ??
        UserProfile(
          name: _firebase.getUserName() ?? 'Student',
          email: email.trim().toLowerCase(),
          joinedAt: _firebase.accountCreatedAt ?? DateTime.now(),
        );
    await _preferences?.setString(_keyUser, jsonEncode(_profile!.toJson()));
    _quietUntil = null;

    await refresh();
    return AuthResult.success;
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    final result = await _firebase.sendPasswordResetEmail(email.trim());
    return _mapAuthResult(result);
  }

  Future<void> updateProfileName(String name) async {
    final current = _profile;
    if (current == null) return;
    _profile = current.copyWith(name: name.trim());
    await _preferences?.setString(_keyUser, jsonEncode(_profile!.toJson()));
    notifyListeners();
    await _sync('update your name', () => _firebase.updateDisplayName(name.trim()));
  }

  Future<void> logout() async {
    _profile = null;
    _tasks.clear();
    _moods.clear();
    _planner.clear();
    _notifications.clear();
    _syncError = null;
    _lastSyncedAt = null;
    _quietUntil = null;
    _quietTimer?.cancel();
    await _preferences?.remove(_keyUser);
    await _clearCaches();
    await _firebase.signOut();
    notifyListeners();
  }

  Future<void> clearLocalData({bool keepProfile = true}) async {
    _tasks.clear();
    _moods.clear();
    _planner.clear();
    _notifications.clear();
    await _persistTasks();
    await _persistMoods();
    await _persistPlanner();
    await _persistNotifications();

    if (!keepProfile) {
      _profile = null;
      await _preferences?.remove(_keyUser);
    }
    notifyListeners();

    await _sync('clear your data', _firebase.clearAllData);
  }

  // --------------------------------------------------------------- Tasks --

  Future<void> clearTasks() async {
    _tasks.clear();
    await _persistTasks();
    notifyListeners();

    await _sync('clear tasks', _firebase.clearTasks);
  }

  Future<void> addTask(TaskItem task) async {
    _tasks.insert(0, task);
    await _persistTasks();
    notifyListeners();

    await generateReminders();
    await _sync('save the task', () => _firebase.addTask(task));
  }

  /// Removes the task and returns it so the caller can offer Undo.
  Future<TaskItem?> removeTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return null;
    final removed = _tasks.removeAt(index);
    await _persistTasks();
    notifyListeners();

    await _sync('remove the task', () => _firebase.removeTask(id));
    return removed;
  }

  Future<void> updateTask(TaskItem updated) async {
    final index = _tasks.indexWhere((task) => task.id == updated.id);
    if (index == -1) {
      return;
    }
    _tasks[index] = updated;
    await _persistTasks();
    notifyListeners();

    await generateReminders();
    await _sync('update the task', () => _firebase.updateTask(updated));
  }

  Future<void> completeTask(String id) async {
    final task = taskById(id);
    if (task == null) return;
    await updateTask(task.copyWith(isCompleted: true, completedAt: DateTime.now()));
  }

  Future<void> uncompleteTask(String id) async {
    final task = taskById(id);
    if (task == null) return;
    await updateTask(task.copyWith(isCompleted: false, clearCompletedAt: true));
  }

  Future<void> rescheduleTask(String id, DateTime newDate) async {
    final task = taskById(id);
    if (task == null) return;
    await updateTask(task.copyWith(scheduledAt: newDate));
  }

  TaskItem? taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// Pending and completed tasks due on [day], earliest first.
  List<TaskItem> tasksOn(DateTime day) {
    return _tasks.where((task) => isSameDay(task.scheduledAt, day)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Tasks finished on [day] (by completion time when known).
  List<TaskItem> completedOn(DateTime day) {
    return _tasks
        .where((task) =>
            task.isCompleted && isSameDay(task.completedAt ?? task.scheduledAt, day))
        .toList();
  }

  /// Pending tasks due on [day] or earlier (so overdue ones are included),
  /// earliest first.
  List<TaskItem> pendingDueBy(DateTime day) {
    final nextDay = addDays(dateOnly(day), 1);
    return _tasks
        .where((task) => !task.isCompleted && task.scheduledAt.isBefore(nextDay))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // --------------------------------------------------------------- Moods --

  Future<void> addMood(MoodEntry entry) async {
    _moods
      ..add(entry)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    await _persistMoods();
    notifyListeners();

    await _sync('save your mood', () => _firebase.addMood(entry));
  }

  /// Removes the entry and returns it so the caller can offer Undo.
  Future<MoodEntry?> removeMood(String id) async {
    final index = _moods.indexWhere((mood) => mood.id == id);
    if (index == -1) return null;
    final removed = _moods.removeAt(index);
    await _persistMoods();
    notifyListeners();

    await _sync('remove the mood entry', () => _firebase.removeMood(id));
    return removed;
  }

  Future<void> clearMoods() async {
    _moods.clear();
    await _persistMoods();
    notifyListeners();

    await _sync('clear moods', _firebase.clearMoods);
  }

  // ------------------------------------------------------------- Planner --

  Future<void> addPlannerBlock(PlannerBlock block) async {
    _planner
      ..add(block)
      ..sort((a, b) => a.start.compareTo(b.start));
    await _persistPlanner();
    notifyListeners();

    await _sync('save the planner block', () => _firebase.addPlannerBlock(block));
  }

  /// Removes the block and returns it so the caller can offer Undo.
  Future<PlannerBlock?> removePlannerBlock(String id) async {
    final index = _planner.indexWhere((block) => block.id == id);
    if (index == -1) return null;
    final removed = _planner.removeAt(index);
    await _persistPlanner();
    notifyListeners();

    await _sync('remove the planner block', () => _firebase.removePlannerBlock(id));
    return removed;
  }

  Future<void> updatePlannerBlock(PlannerBlock block) async {
    final index = _planner.indexWhere((b) => b.id == block.id);
    if (index == -1) return;

    _planner[index] = block;
    _planner.sort((a, b) => a.start.compareTo(b.start));
    await _persistPlanner();
    notifyListeners();

    await _sync('update the planner block', () => _firebase.updatePlannerBlock(block));
  }

  /// Blocks starting on [day], earliest first.
  List<PlannerBlock> plannerBlocksOn(DateTime day) {
    return _planner.where((block) => isSameDay(block.start, day)).toList();
  }

  // ------------------------------------------------------- Notifications --

  Future<void> addNotification(NotificationItem item) async {
    _notifications.insert(0, item);
    await _persistNotifications();
    notifyListeners();

    await _sync('save the notification', () => _firebase.addNotification(item));
  }

  Future<void> removeNotification(String id) async {
    final before = _notifications.length;
    _notifications.removeWhere((item) => item.id == id);
    if (_notifications.length == before) return;
    await _rememberDismissed([id]);
    await _persistNotifications();
    notifyListeners();

    await _sync('remove the notification', () => _firebase.removeNotification(id));
  }

  Future<void> clearNotifications() async {
    await _rememberDismissed(_notifications.map((item) => item.id));
    _notifications.clear();
    await _persistNotifications();
    notifyListeners();

    await _sync('clear notifications', _firebase.clearNotifications);
  }

  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || !_notifications[index].isUnread) {
      return;
    }
    _notifications[index] = _notifications[index].copyWith(isUnread: false);
    await _persistNotifications();
    notifyListeners();

    await _sync('update the notification', () => _firebase.markNotificationRead(id));
  }

  Future<void> markAllNotificationsRead() async {
    final unreadIds = [
      for (final item in _notifications)
        if (item.isUnread) item.id,
    ];
    if (unreadIds.isEmpty) return;
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isUnread: false);
    }
    await _persistNotifications();
    notifyListeners();

    await _sync('update notifications', () => _firebase.markAllNotificationsRead(unreadIds));
  }

  int get unreadCount => _notifications.where((item) => item.isUnread).length;

  /// Adds any due-soon, overdue, daily digest or mood check-in reminders that
  /// haven't been shown or dismissed yet.
  Future<void> generateReminders() async {
    if (!isAuthenticated) return;
    final known = {
      for (final item in _notifications) item.id,
      ..._dismissedReminderIds(),
    };
    final fresh = const ReminderEngine().compute(
      tasks: _tasks,
      moods: _moods,
      knownIds: known,
      now: DateTime.now(),
      quietUntil: _quietUntil,
    );
    if (fresh.isEmpty) return;

    // Inserted before any await so overlapping calls can't add duplicates.
    _notifications.insertAll(0, fresh);
    await _persistNotifications();
    notifyListeners();

    for (final item in fresh) {
      await _sync('save the reminder', () => _firebase.addNotification(item));
    }
  }

  Set<String> _dismissedReminderIds() {
    final raw = _preferences?.getStringList(_keyDismissedReminders) ?? const [];
    return raw.map((entry) => entry.split('@').first).toSet();
  }

  /// Remembers dismissed reminder ids (as "id@yyyymmdd") so they are not
  /// recreated, keeping only the last [_dismissedRetentionDays] days.
  Future<void> _rememberDismissed(Iterable<String> ids) async {
    final reminderIds = ids.where((id) => id.startsWith('rem-')).toList();
    if (reminderIds.isEmpty) return;
    final now = DateTime.now();
    final cutoff = ReminderEngine.dayKey(addDays(now, -_dismissedRetentionDays));
    final today = ReminderEngine.dayKey(now);
    final kept = (_preferences?.getStringList(_keyDismissedReminders) ?? const <String>[])
        .where((entry) => entry.split('@').last.compareTo(cutoff) >= 0)
        .toList()
      ..addAll(reminderIds.map((id) => '$id@$today'));
    await _preferences?.setStringList(_keyDismissedReminders, kept);
  }

  // ---------------------------------------------------------- Quiet mode --

  /// When quiet mode ends, or null if it is off.
  DateTime? get quietUntil {
    final until = _quietUntil;
    return until != null && DateTime.now().isBefore(until) ? until : null;
  }

  bool get isQuiet => quietUntil != null;

  Future<void> setQuietFor(Duration duration) async {
    _quietUntil = DateTime.now().add(duration);
    await _preferences?.setString(_keyQuietUntil, _quietUntil!.toIso8601String());
    _scheduleQuietExpiry();
    notifyListeners();
  }

  Future<void> clearQuiet() async {
    _quietUntil = null;
    _quietTimer?.cancel();
    await _preferences?.remove(_keyQuietUntil);
    notifyListeners();
    await generateReminders();
  }

  void _scheduleQuietExpiry() {
    _quietTimer?.cancel();
    final until = quietUntil;
    if (until == null) return;
    _quietTimer = Timer(until.difference(DateTime.now()), () {
      notifyListeners();
      generateReminders();
    });
  }

  @override
  void dispose() {
    _quietTimer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------- Summaries --

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  MoodEntry? get latestMood => _moods.isNotEmpty ? _moods.first : null;

  String get latestMoodLabel =>
      _moods.isNotEmpty ? _moods.first.mood : 'Steady';

  int get moodStreak => consecutiveDayStreak(
        _moods.map((entry) => entry.loggedAt),
        DateTime.now(),
      );

  int get taskStreak => consecutiveDayStreak(
        _tasks
            .where((task) => task.isCompleted)
            .map((task) => task.completedAt ?? task.scheduledAt),
        DateTime.now(),
      );

  int get plannerStreak => consecutiveDayStreak(
        _planner.map((block) => block.start),
        DateTime.now(),
      );
}

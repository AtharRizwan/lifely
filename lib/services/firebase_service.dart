import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_models.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _tasksCollection = 'tasks';
  static const String _moodsCollection = 'moods';
  static const String _plannerCollection = 'planner';
  static const String _notificationsCollection = 'notifications';

  String? _currentUserId;

  String get currentUserId => _currentUserId ?? '';

  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> initialize() async {
    _currentUserId = _auth.currentUser?.uid;
  }

  User? get currentUser => _auth.currentUser;

  DateTime? get accountCreatedAt => _auth.currentUser?.metadata.creationTime;

  String? getEmail() {
    return _auth.currentUser?.email;
  }

  String? getUserName() {
    return _auth.currentUser?.displayName;
  }

  Future<AuthServiceResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthServiceResult.invalidInput;
    }
    if (password.length < 6) {
      return AuthServiceResult.weakPassword;
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        debugPrint('FirebaseAuth signUp error: user is null after create');
        return AuthServiceResult.failure;
      }

      _currentUserId = user.uid;

      try {
        await user.updateDisplayName(name).timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('FirebaseAuth signUp displayName update skipped: $e');
      }

      try {
        await _createUserProfile(user.uid, name, email)
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('FirebaseAuth signUp profile creation skipped: $e');
      }

      return AuthServiceResult.success;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth signUp error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          return AuthServiceResult.emailTaken;
        case 'invalid-email':
          return AuthServiceResult.invalidEmail;
        case 'weak-password':
          return AuthServiceResult.weakPassword;
        case 'network-request-failed':
          return AuthServiceResult.network;
        case 'too-many-requests':
          return AuthServiceResult.tooManyRequests;
        default:
          return AuthServiceResult.failure;
      }
    } catch (e) {
      debugPrint('FirebaseAuth signUp error: $e');
      return AuthServiceResult.failure;
    }
  }

  Future<AuthServiceResult> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthServiceResult.invalidInput;
    }
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUserId = credential.user?.uid;

      return AuthServiceResult.success;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth signIn error: ${e.code} - ${e.message}');
      return _mapSignInError(e.code);
    } catch (e) {
      debugPrint('FirebaseAuth signIn error: $e');
      return AuthServiceResult.failure;
    }
  }

  AuthServiceResult _mapSignInError(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthServiceResult.notFound;
      case 'wrong-password':
        return AuthServiceResult.wrongPassword;
      // Projects with email enumeration protection (the default for new
      // projects) report both wrong email and wrong password this way.
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return AuthServiceResult.invalidCredentials;
      case 'invalid-email':
        return AuthServiceResult.invalidEmail;
      case 'user-disabled':
        return AuthServiceResult.userDisabled;
      case 'too-many-requests':
        return AuthServiceResult.tooManyRequests;
      case 'network-request-failed':
        return AuthServiceResult.network;
      default:
        return AuthServiceResult.failure;
    }
  }

  Future<AuthServiceResult> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      return AuthServiceResult.invalidInput;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthServiceResult.success;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth password reset error: ${e.code} - ${e.message}');
      return _mapSignInError(e.code);
    } catch (e) {
      debugPrint('FirebaseAuth password reset error: $e');
      return AuthServiceResult.failure;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserId = null;
  }

  Future<void> _createUserProfile(String uid, String name, String email) async {
    await _firestore.collection(_usersCollection).doc(uid).set({
      'name': name,
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserProfile(
        name: data['name'] ?? 'Student',
        email: data['email'] ?? '',
        joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
    await _userDoc(user.uid).set({'name': name}, SetOptions(merge: true));
  }

  DocumentReference _userDoc(String? uid) {
    final userId = uid ?? _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user');
    }
    return _firestore.collection(_usersCollection).doc(userId);
  }

  CollectionReference _tasksCollectionRef(String? uid) {
    return _userDoc(uid).collection(_tasksCollection);
  }

  CollectionReference _moodsCollectionRef(String? uid) {
    return _userDoc(uid).collection(_moodsCollection);
  }

  CollectionReference _plannerCollectionRef(String? uid) {
    return _userDoc(uid).collection(_plannerCollection);
  }

  CollectionReference _notificationsCollectionRef(String? uid) {
    return _userDoc(uid).collection(_notificationsCollection);
  }

  Future<void> addTask(TaskItem task) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _tasksCollectionRef(userId).doc(task.id).set(task.toJson());
  }

  Future<void> updateTask(TaskItem task) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _tasksCollectionRef(userId).doc(task.id).set(task.toJson());
  }

  Future<void> removeTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _tasksCollectionRef(userId).doc(taskId).delete();
  }

  Stream<List<TaskItem>> watchTasks() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _tasksCollectionRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskItem.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<TaskItem>> getTasks() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _tasksCollectionRef(userId).get();
    return snapshot.docs
        .map((doc) => TaskItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMood(MoodEntry entry) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _moodsCollectionRef(userId).doc(entry.id).set(entry.toJson());
  }

  Stream<List<MoodEntry>> watchMoods() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _moodsCollectionRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MoodEntry.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<MoodEntry>> getMoods() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _moodsCollectionRef(userId).get();
    return snapshot.docs
        .map((doc) => MoodEntry.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addPlannerBlock(PlannerBlock block) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _plannerCollectionRef(userId).doc(block.id).set(block.toJson());
  }

  Future<void> removePlannerBlock(String blockId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _plannerCollectionRef(userId).doc(blockId).delete();
  }

  Future<void> updatePlannerBlock(PlannerBlock block) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _plannerCollectionRef(userId).doc(block.id).set(block.toJson());
  }

  Stream<List<PlannerBlock>> watchPlannerBlocks() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _plannerCollectionRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlannerBlock.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<PlannerBlock>> getPlannerBlocks() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _plannerCollectionRef(userId).get();
    return snapshot.docs
        .map((doc) => PlannerBlock.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addNotification(NotificationItem item) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _notificationsCollectionRef(userId).doc(item.id).set(item.toJson());
  }

  Future<void> removeNotification(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _notificationsCollectionRef(userId).doc(notificationId).delete();
  }

  Future<void> removeMood(String moodId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _moodsCollectionRef(userId).doc(moodId).delete();
  }

  Future<void> clearMoods() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _deleteAll(_moodsCollectionRef(userId));
  }

  Future<void> clearTasks() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _deleteAll(_tasksCollectionRef(userId));
  }

  Stream<List<NotificationItem>> watchNotifications() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _notificationsCollectionRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationItem.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<NotificationItem>> getNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _notificationsCollectionRef(userId).get();
    return snapshot.docs
        .map((doc) => NotificationItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _notificationsCollectionRef(userId).doc(notificationId).update({
      'isUnread': false,
    });
  }

  Future<void> markAllNotificationsRead(Iterable<String> notificationIds) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final collection = _notificationsCollectionRef(userId);
    final batch = _firestore.batch();
    for (final id in notificationIds) {
      batch.update(collection.doc(id), {'isUnread': false});
    }
    await batch.commit();
  }

  Future<void> clearNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _deleteAll(_notificationsCollectionRef(userId));
  }

  Future<void> clearAllData() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _deleteAll(_tasksCollectionRef(userId));
    await _deleteAll(_moodsCollectionRef(userId));
    await _deleteAll(_plannerCollectionRef(userId));
    await _deleteAll(_notificationsCollectionRef(userId));
  }

  /// Deletes every document in [collection], in batches of at most 500
  /// (Firestore's per-batch write limit).
  Future<void> _deleteAll(CollectionReference collection) async {
    final snapshot = await collection.get();
    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += 500) {
      final batch = _firestore.batch();
      for (final doc in docs.skip(i).take(500)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

enum AuthServiceResult {
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

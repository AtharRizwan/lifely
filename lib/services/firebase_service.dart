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
    _currentUserId = _auth.currentUser?.uid ?? '';
  }

  User? get currentUser => _auth.currentUser;

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
      if (e.code == 'email-already-in-use') {
        return AuthServiceResult.emailTaken;
      }
      if (e.code == 'invalid-email') {
        return AuthServiceResult.invalidEmail;
      }
      if (e.code == 'weak-password') {
        return AuthServiceResult.weakPassword;
      }
      debugPrint('FirebaseAuth signUp error: ${e.code} - ${e.message}');
      return AuthServiceResult.failure;
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
      switch (e.code) {
        case 'user-not-found':
          return AuthServiceResult.notFound;
        case 'wrong-password':
          return AuthServiceResult.wrongPassword;
        case 'invalid-email':
          return AuthServiceResult.invalidEmail;
        case 'user-disabled':
          return AuthServiceResult.userDisabled;
        case 'too-many-requests':
          return AuthServiceResult.tooManyRequests;
        default:
          return AuthServiceResult.failure;
      }
    } catch (e) {
      debugPrint('FirebaseAuth signIn error: $e');
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
    
    await _tasksCollectionRef(userId).doc(task.id).update(task.toJson());
  }

  Future<void> removeTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    await _tasksCollectionRef(userId).doc(taskId).delete();
  }

  Future<void> completeTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    await _tasksCollectionRef(userId).doc(taskId).update({'isCompleted': true});
  }

  Future<void> rescheduleTask(String taskId, DateTime newDate) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    await _tasksCollectionRef(userId).doc(taskId).update({
      'scheduledAt': newDate.toIso8601String(),
    });
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
    
    await _plannerCollectionRef(userId).doc(block.id).update(block.toJson());
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

  Future<void> removeMood(String moodId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    await _moodsCollectionRef(userId).doc(moodId).delete();
  }

  Future<void> clearMoods() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    final snapshot = await _moodsCollectionRef(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> clearTasks() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    final snapshot = await _tasksCollectionRef(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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

  Future<void> clearNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollectionRef(userId).get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  Future<void> clearAllData() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    await _tasksCollectionRef(userId).get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    
    await _moodsCollectionRef(userId).get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    
    await _plannerCollectionRef(userId).get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    
    await _notificationsCollectionRef(userId).get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}

enum AuthServiceResult {
  success,
  notFound,
  wrongPassword,
  emailTaken,
  invalidEmail,
  invalidInput,
  weakPassword,
  userDisabled,
  tooManyRequests,
  failure,
}

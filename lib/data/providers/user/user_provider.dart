// TODO: null 체크 전략 통일 - 필수 작업은 Exception, 선택적 작업은 return
// 👤 User Provider
//
// Manages user data operations with Firestore integration.
// Handles user CRUD operations, profile updates, and gamification data.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/user/user_model.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class User extends _$User {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  UserModel? build() {
    return null;
  }

  // ========================================
  // User CRUD Operations
  // ========================================

  /// Load user from Firestore
  Future<void> loadUser(String uid) async {
    try {
      AppLogger.info('Loading user data', tag: 'User', data: {'uid': uid});

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        AppLogger.warning('User document not found, creating new user', tag: 'User');
        // Create new user document if it doesn't exist
        await createUser(uid);
        return;
      }

      state = UserModel.fromFirestore(doc);
      AppLogger.info('User data loaded successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to load user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '사용자 정보를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Create new user in Firestore
  Future<void> createUser(
    String uid, {
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider provider = AuthProvider.email,
    bool isEmailVerified = false,
  }) async {
    try {
      AppLogger.info('Creating new user', tag: 'User', data: {'uid': uid});

      final user = UserModel.fromFirebase(
        uid: uid,
        provider: provider,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isEmailVerified: isEmailVerified,
      );

      await _firestore.collection('users').doc(uid).set(user.toFirestore());

      state = user;
      AppLogger.info('User created successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to create user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '사용자 정보를 생성하는데 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Create guest user
  Future<void> createGuestUser(String uid) async {
    try {
      AppLogger.info('Creating guest user', tag: 'User', data: {'uid': uid});

      final user = UserModel.guest(uid);

      await _firestore.collection('users').doc(uid).set(user.toFirestore());

      state = user;
      AppLogger.info('Guest user created successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to create guest user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '게스트 사용자 생성에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? currentGrade,
  }) async {
    if (state == null) {
      throw const DataException(message: '사용자 정보가 없습니다');
    }

    try {
      AppLogger.info('Updating user profile', tag: 'User');

      final updatedUser = state!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        currentGrade: currentGrade,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updatedUser.toFirestore());

      state = updatedUser;
      AppLogger.info('User profile updated successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to update profile', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '프로필 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete user data from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      AppLogger.info('Deleting user data', tag: 'User', data: {'uid': uid});

      await _firestore.collection('users').doc(uid).delete();

      state = null;
      AppLogger.info('User data deleted successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to delete user', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '사용자 데이터 삭제에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Clear user state
  void clearUser() {
    state = null;
    AppLogger.info('User state cleared', tag: 'User');
  }

  // ========================================
  // Learning Progress
  // ========================================

  /// Add XP to user
  Future<void> addXp(int amount) async {
    if (state == null) return;
    if (amount <= 0 || amount > 200) return; // Firestore rules: max +200

    try {
      AppLogger.info('Adding XP', tag: 'User', data: {'amount': amount});

      int newXp = state!.xp + amount;
      int newTotalXp = state!.totalXp + amount;
      int newLevel = state!.level;

      // Check for level up
      while (newXp >= state!.xpNeededForNextLevel) {
        newXp -= state!.xpNeededForNextLevel;
        newLevel++;
        AppLogger.info('Level up!', tag: 'User', data: {'newLevel': newLevel});
      }

      final updatedUser = state!.copyWith(
        xp: newXp,
        totalXp: newTotalXp,
        level: newLevel,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'xp': newXp,
        'totalXp': newTotalXp,
        'level': newLevel,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to add XP', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Update streak
  Future<void> updateStreak() async {
    if (state == null) return;

    try {
      AppLogger.info('Updating streak', tag: 'User');

      final now = DateTime.now();
      int newStreak = state!.streak;
      int newLongestStreak = state!.longestStreak;

      if (state!.shouldBreakStreak) {
        // Break streak
        newStreak = 1;
        AppLogger.info('Streak broken, starting new streak', tag: 'User');
      } else if (state!.shouldUpdateStreak) {
        // Continue streak
        newStreak = state!.streak + 1;
        if (newStreak > newLongestStreak) {
          newLongestStreak = newStreak;
        }
        AppLogger.info('Streak continued', tag: 'User', data: {'streak': newStreak});
      }

      final updatedUser = state!.copyWith(
        streak: newStreak,
        longestStreak: newLongestStreak,
        lastStudyDate: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'streak': newStreak,
        'longestStreak': newLongestStreak,
        'lastStudyDate': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      // 학습 날짜 기록 (캘린더용)
      await _recordStudyDate(state!.uid, now);

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to update streak', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// 학습 날짜를 Firestore에 기록
  Future<void> _recordStudyDate(String uid, DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('studyDates')
          .doc(dateKey)
          .set({
        'date': Timestamp.fromDate(date),
        'year': date.year,
        'month': date.month,
        'day': date.day,
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('Failed to record study date', tag: 'User', error: e);
    }
  }

  /// 특정 월의 학습 날짜 목록 가져오기
  /// studyDates 컬렉션에서 먼저 조회하고, 실패 시 lessonProgress에서 추출
  Future<Set<int>> getStudyDatesForMonth(int year, int month) async {
    if (state == null) return {};

    final uid = state!.uid;

    // 1차: studyDates 컬렉션에서 조회 시도
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('studyDates')
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => doc.data()['day'] as int)
            .toSet();
      }
    } catch (e) {
      AppLogger.info('studyDates collection not available, falling back to lessonProgress', tag: 'User');
    }

    // 2차: lessonProgress의 lastAttemptedAt/completedAt에서 학습 날짜 추출
    try {
      final progressSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('lessonProgress')
          .get();

      final dates = <int>{};
      for (final doc in progressSnapshot.docs) {
        final data = doc.data();

        for (final field in ['lastAttemptedAt', 'completedAt']) {
          final ts = data[field] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            if (date.year == year && date.month == month) {
              dates.add(date.day);
            }
          }
        }
      }

      return dates;
    } catch (e) {
      AppLogger.error('Failed to get study dates from lessonProgress', tag: 'User', error: e);
      return {};
    }
  }

  // ========================================
  // Gamification
  // ========================================

  /// Use a heart (decrements by 1 and sets lastHeartLostAt)
  Future<bool> useHeart() async {
    if (state == null || !state!.hasHearts) return false;

    try {
      AppLogger.info('Using heart', tag: 'User');

      final now = DateTime.now();
      final newHearts = state!.hearts - 1;

      final updatedUser = state!.copyWith(
        hearts: newHearts,
        lastHeartLostAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'hearts': newHearts,
        'lastHeartLostAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      state = updatedUser;
      return true;
    } catch (e, st) {
      AppLogger.error('Failed to use heart', tag: 'User', error: e, stackTrace: st);
      return false;
    }
  }

  /// Update hearts count directly (used by heart regen system)
  Future<void> updateHearts(int newHearts, {bool clearLastHeartLostAt = false}) async {
    if (state == null) return;

    try {
      final now = DateTime.now();
      final clamped = newHearts.clamp(0, state!.maxHearts);

      final updates = <String, dynamic>{
        'hearts': clamped,
        'updatedAt': Timestamp.fromDate(now),
      };
      if (clearLastHeartLostAt) {
        updates['lastHeartLostAt'] = null;
      }

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = state!.copyWith(
        hearts: clamped,
        updatedAt: now,
      );

      if (clearLastHeartLostAt) {
        // copyWith can't set nullable to null, so rebuild
        state = UserModel(
          uid: state!.uid,
          email: state!.email,
          displayName: state!.displayName,
          photoUrl: state!.photoUrl,
          phoneNumber: state!.phoneNumber,
          authProvider: state!.authProvider,
          isGuest: state!.isGuest,
          isEmailVerified: state!.isEmailVerified,
          role: state!.role,
          createdAt: state!.createdAt,
          updatedAt: now,
          lastLoginAt: state!.lastLoginAt,
          level: state!.level,
          xp: state!.xp,
          totalXp: state!.totalXp,
          dailyXP: state!.dailyXP,
          streak: state!.streak,
          longestStreak: state!.longestStreak,
          lastStudyDate: state!.lastStudyDate,
          hearts: clamped,
          maxHearts: state!.maxHearts,
          lastHeartLostAt: null,
          gems: state!.gems,
          league: state!.league,
          achievements: state!.achievements,
          streakFreezes: state!.streakFreezes,
          lastFreezeUsedAt: state!.lastFreezeUsedAt,
          currentGrade: state!.currentGrade,
          preferredLanguage: state!.preferredLanguage,
          notificationsEnabled: state!.notificationsEnabled,
          soundEnabled: state!.soundEnabled,
          dailyGoalMinutes: state!.dailyGoalMinutes,
          dailyReminderEnabled: state!.dailyReminderEnabled,
          reminderHour: state!.reminderHour,
          reminderMinute: state!.reminderMinute,
          streakReminderEnabled: state!.streakReminderEnabled,
          achievementAlertEnabled: state!.achievementAlertEnabled,
          weeklyReportEnabled: state!.weeklyReportEnabled,
        );
      }
    } catch (e, st) {
      AppLogger.error('Failed to update hearts', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Refill hearts
  Future<void> refillHearts() async {
    if (state == null) return;

    try {
      AppLogger.info('Refilling hearts', tag: 'User');

      final updatedUser = state!.copyWith(
        hearts: state!.maxHearts,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'hearts': state!.maxHearts,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to refill hearts', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Add gems
  Future<void> addGems(int amount) async {
    if (state == null) return;

    try {
      AppLogger.info('Adding gems', tag: 'User', data: {'amount': amount});

      final newGems = state!.gems + amount;

      final updatedUser = state!.copyWith(
        gems: newGems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'gems': newGems,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to add gems', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Spend gems
  Future<bool> spendGems(int amount) async {
    if (state == null || state!.gems < amount) return false;

    try {
      AppLogger.info('Spending gems', tag: 'User', data: {'amount': amount});

      final newGems = state!.gems - amount;

      final updatedUser = state!.copyWith(
        gems: newGems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'gems': newGems,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });

      state = updatedUser;
      return true;
    } catch (e, st) {
      AppLogger.error('Failed to spend gems', tag: 'User', error: e, stackTrace: st);
      return false;
    }
  }

  /// Add achievement
  Future<void> addAchievement(String achievementId) async {
    if (state == null || state!.achievements.contains(achievementId)) return;

    try {
      AppLogger.info('Adding achievement', tag: 'User', data: {'achievementId': achievementId});

      final newAchievements = [...state!.achievements, achievementId];

      final updatedUser = state!.copyWith(
        achievements: newAchievements,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'achievements': newAchievements,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to add achievement', tag: 'User', error: e, stackTrace: st);
    }
  }

  /// Update league
  Future<void> updateLeague(String newLeague) async {
    if (state == null) return;

    try {
      AppLogger.info('Updating league', tag: 'User', data: {'newLeague': newLeague});

      final updatedUser = state!.copyWith(
        league: newLeague,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'league': newLeague,
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to update league', tag: 'User', error: e, stackTrace: st);
    }
  }

  // ========================================
  // Settings
  // ========================================

  /// Update user settings
  Future<void> updateSettings({
    String? preferredLanguage,
    bool? notificationsEnabled,
    bool? soundEnabled,
    int? dailyGoalMinutes,
  }) async {
    if (state == null) return;

    try {
      AppLogger.info('Updating user settings', tag: 'User');

      final updatedUser = state!.copyWith(
        preferredLanguage: preferredLanguage,
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
        dailyGoalMinutes: dailyGoalMinutes,
        updatedAt: DateTime.now(),
      );

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(updatedUser.updatedAt),
      };

      if (preferredLanguage != null) updates['preferredLanguage'] = preferredLanguage;
      if (notificationsEnabled != null) updates['notificationsEnabled'] = notificationsEnabled;
      if (soundEnabled != null) updates['soundEnabled'] = soundEnabled;
      if (dailyGoalMinutes != null) updates['dailyGoalMinutes'] = dailyGoalMinutes;

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = updatedUser;
      AppLogger.info('User settings updated successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to update settings', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '설정 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  // ========================================
  // Notification Settings
  // ========================================

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? streakReminderEnabled,
    bool? achievementAlertEnabled,
    bool? weeklyReportEnabled,
  }) async {
    if (state == null) return;

    try {
      AppLogger.info('Updating notification settings', tag: 'User');

      final now = DateTime.now();
      final updatedUser = state!.copyWith(
        dailyReminderEnabled: dailyReminderEnabled,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        streakReminderEnabled: streakReminderEnabled,
        achievementAlertEnabled: achievementAlertEnabled,
        weeklyReportEnabled: weeklyReportEnabled,
        updatedAt: now,
      );

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(now),
      };

      if (dailyReminderEnabled != null) updates['dailyReminderEnabled'] = dailyReminderEnabled;
      if (reminderHour != null) updates['reminderHour'] = reminderHour;
      if (reminderMinute != null) updates['reminderMinute'] = reminderMinute;
      if (streakReminderEnabled != null) updates['streakReminderEnabled'] = streakReminderEnabled;
      if (achievementAlertEnabled != null) updates['achievementAlertEnabled'] = achievementAlertEnabled;
      if (weeklyReportEnabled != null) updates['weeklyReportEnabled'] = weeklyReportEnabled;

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = updatedUser;
      AppLogger.info('Notification settings updated', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to update notification settings', tag: 'User', error: e, stackTrace: st);
    }
  }

  // ========================================
  // Streak Freeze
  // ========================================

  /// Update streak freeze count in Firestore
  Future<void> updateStreakFreezes(int freezes, {DateTime? lastUsedAt}) async {
    if (state == null) return;

    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'streakFreezes': freezes,
        'updatedAt': Timestamp.fromDate(now),
      };
      if (lastUsedAt != null) {
        updates['lastFreezeUsedAt'] = Timestamp.fromDate(lastUsedAt);
      }

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update(updates);

      state = state!.copyWith(
        streakFreezes: freezes,
        lastFreezeUsedAt: lastUsedAt,
        updatedAt: now,
      );
    } catch (e, st) {
      AppLogger.error('Failed to update streak freezes', tag: 'User', error: e, stackTrace: st);
    }
  }

  // ========================================
  // Last Login Tracking
  // ========================================

  /// Update last login timestamp
  Future<void> updateLastLogin() async {
    if (state == null) return;

    try {
      final now = DateTime.now();

      final updatedUser = state!.copyWith(
        lastLoginAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(state!.uid)
          .update({
        'lastLoginAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      state = updatedUser;
    } catch (e, st) {
      AppLogger.error('Failed to update last login', tag: 'User', error: e, stackTrace: st);
      // Don't throw - this is a non-critical operation
    }
  }

  // ========================================
  // Reset Progress
  // ========================================

  /// Reset all learning progress (XP, level, streak, achievements)
  Future<void> resetProgress() async {
    if (state == null) return;

    try {
      AppLogger.info('Resetting user progress', tag: 'User');

      final now = DateTime.now();
      final uid = state!.uid;

      // Reset user stats
      final updatedUser = state!.copyWith(
        xp: 0,
        totalXp: 0,
        level: 1,
        streak: 0,
        longestStreak: 0,
        hearts: 5,
        gems: 0,
        achievements: [],
        league: 'Bronze',
        lastStudyDate: null,
        updatedAt: now,
      );

      // Update user document
      await _firestore.collection('users').doc(uid).update({
        'xp': 0,
        'totalXp': 0,
        'level': 1,
        'streak': 0,
        'longestStreak': 0,
        'hearts': 5,
        'gems': 0,
        'achievements': [],
        'league': 'Bronze',
        'lastStudyDate': null,
        'updatedAt': Timestamp.fromDate(now),
      });

      // Delete all lesson progress
      final lessonProgressRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('lessonProgress');
      final lessonProgressDocs = await lessonProgressRef.get();
      final batch = _firestore.batch();
      for (final doc in lessonProgressDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete all wrong answers
      final wrongAnswersRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('wrongAnswers');
      final wrongAnswersDocs = await wrongAnswersRef.get();
      for (final doc in wrongAnswersDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete all achievements
      final achievementsRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('achievements');
      final achievementsDocs = await achievementsRef.get();
      for (final doc in achievementsDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      state = updatedUser;
      AppLogger.info('User progress reset successfully', tag: 'User');
    } catch (e, st) {
      AppLogger.error('Failed to reset progress', tag: 'User', error: e, stackTrace: st);
      throw DataException(
        message: '학습 진행 상태 초기화에 실패했습니다',
        originalError: e,
        stackTrace: st,
      );
    }
  }
}

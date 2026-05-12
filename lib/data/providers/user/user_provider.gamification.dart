// 👤 User provider — gamification (hearts / gems / achievements / league)
//
// part of user_provider.dart.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'user_provider.dart';

extension UserGamification on User {
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
          leagueUpdateEnabled: state!.leagueUpdateEnabled,
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
}

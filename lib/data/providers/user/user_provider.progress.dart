// 👤 User provider — learning progress
//
// part of user_provider.dart. Owns XP, streak, study date tracking, and progress reset.

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'user_provider.dart';

extension UserProgress on User {
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

      // 학습 날짜 기록 (캘린더용) — fire-and-forget. 보상 흐름을 막지 않는다.
      unawaited(_recordStudyDate(state!.uid, now));

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

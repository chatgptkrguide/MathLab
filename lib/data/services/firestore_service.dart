import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/progress_model.dart';

/// Firestore 데이터베이스 서비스
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== 사용자 프로필 ====================

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('사용자 프로필 업데이트 실패: $e');
    }
  }

  /// XP 추가
  Future<void> addXP(String userId, int xp, {String? category}) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception('사용자를 찾을 수 없습니다.');

        final currentXP = userDoc.data()!['totalXP'] as int? ?? 0;
        final newTotalXP = currentXP + xp;
        final newLevel = UserModel.calculateLevel(newTotalXP);

        final updateData = {
          'totalXP': newTotalXP,
          'level': newLevel,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        };

        // 카테고리별 XP 추가
        if (category != null) {
          final categoryXP = Map<String, int>.from(userDoc.data()!['categoryXP'] as Map? ?? {});
          categoryXP[category] = (categoryXP[category] ?? 0) + xp;
          updateData['categoryXP'] = categoryXP;
        }

        transaction.update(userRef, updateData);
      });
    } catch (e) {
      throw Exception('XP 추가 실패: $e');
    }
  }

  /// 스트릭 업데이트
  Future<void> updateStreak(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception('사용자를 찾을 수 없습니다.');

        final lastStudyDate = (userDoc.data()!['lastStudyDate'] as Timestamp?)?.toDate();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        int newStreak = userDoc.data()!['streak'] as int? ?? 0;

        if (lastStudyDate != null) {
          final lastStudy = DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
          final difference = today.difference(lastStudy).inDays;

          if (difference == 1) {
            // 연속 학습
            newStreak++;
          } else if (difference > 1) {
            // 스트릭 끊김
            newStreak = 1;
          }
          // difference == 0: 오늘 이미 학습함, 스트릭 유지
        } else {
          // 첫 학습
          newStreak = 1;
        }

        transaction.update(userRef, {
          'streak': newStreak,
          'lastStudyDate': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      });
    } catch (e) {
      throw Exception('스트릭 업데이트 실패: $e');
    }
  }

  /// 업적 추가
  Future<void> addAchievement(String userId, String achievementId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'achievements': FieldValue.arrayUnion([achievementId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('업적 추가 실패: $e');
    }
  }

  // ==================== 학습 진행상황 ====================

  /// 진행상황 생성 또는 업데이트
  Future<void> saveProgress(ProgressModel progress) async {
    try {
      final progressId = '${progress.userId}_${progress.lessonId}';
      await _firestore
          .collection('progress')
          .doc(progressId)
          .set(progress.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('진행상황 저장 실패: $e');
    }
  }

  /// 사용자의 진행상황 가져오기
  Future<List<ProgressModel>> getUserProgress(String userId, {String? grade}) async {
    try {
      Query query = _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId);

      if (grade != null) {
        query = query.where('grade', isEqualTo: grade);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProgressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('진행상황 조회 실패: $e');
    }
  }

  /// 특정 레슨 진행상황 가져오기
  Future<ProgressModel?> getLessonProgress(String userId, String lessonId) async {
    try {
      final progressId = '${userId}_$lessonId';
      final doc = await _firestore.collection('progress').doc(progressId).get();

      if (doc.exists) {
        return ProgressModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('레슨 진행상황 조회 실패: $e');
    }
  }

  /// 문제 완료 기록
  Future<void> recordProblemCompletion({
    required String userId,
    required String grade,
    required String chapter,
    required String lessonId,
    required bool isCorrect,
    required int xpEarned,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 진행상황 업데이트
        final progressId = '${userId}_$lessonId';
        final progressRef = _firestore.collection('progress').doc(progressId);
        final progressDoc = await transaction.get(progressRef);

        final now = DateTime.now();

        if (progressDoc.exists) {
          // 기존 진행상황 업데이트
          final data = progressDoc.data()!;
          final newProblemsCompleted = (data['problemsCompleted'] as int? ?? 0) + 1;
          final newCorrectAnswers = (data['correctAnswers'] as int? ?? 0) + (isCorrect ? 1 : 0);
          final newXP = (data['xpEarned'] as int? ?? 0) + xpEarned;

          transaction.update(progressRef, {
            'problemsCompleted': newProblemsCompleted,
            'correctAnswers': newCorrectAnswers,
            'xpEarned': newXP,
            'updatedAt': Timestamp.fromDate(now),
          });
        } else {
          // 새 진행상황 생성
          final progress = ProgressModel(
            userId: userId,
            grade: grade,
            chapter: chapter,
            lessonId: lessonId,
            problemsCompleted: 1,
            correctAnswers: isCorrect ? 1 : 0,
            xpEarned: xpEarned,
            createdAt: now,
            updatedAt: now,
          );
          transaction.set(progressRef, progress.toFirestore());
        }

        // 사용자 프로필 업데이트
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'totalProblemsCompleted': FieldValue.increment(1),
          'correctAnswers': FieldValue.increment(isCorrect ? 1 : 0),
          'updatedAt': Timestamp.fromDate(now),
        });
      });

      // XP 추가
      await addXP(userId, xpEarned, category: chapter);

      // 스트릭 업데이트
      await updateStreak(userId);

      // 일일 학습 기록 업데이트
      await _recordDailyStudy(userId, xpEarned, chapter);

    } catch (e) {
      throw Exception('문제 완료 기록 실패: $e');
    }
  }

  /// 일일 학습 기록
  Future<void> _recordDailyStudy(String userId, int xpEarned, String category) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyId = '${userId}_${today.toIso8601String().split('T')[0]}';

      final dailyRef = _firestore.collection('daily_studies').doc(dailyId);
      final dailyDoc = await dailyRef.get();

      if (dailyDoc.exists) {
        // 오늘 기록 업데이트
        final categoryProgress = Map<String, int>.from(dailyDoc.data()!['categoryProgress'] as Map? ?? {});
        categoryProgress[category] = (categoryProgress[category] ?? 0) + 1;

        await dailyRef.update({
          'problemsCompleted': FieldValue.increment(1),
          'xpEarned': FieldValue.increment(xpEarned),
          'categoryProgress': categoryProgress,
        });
      } else {
        // 새 일일 기록 생성
        final dailyStudy = DailyStudyModel(
          userId: userId,
          date: today,
          problemsCompleted: 1,
          xpEarned: xpEarned,
          categoryProgress: {category: 1},
          createdAt: now,
        );
        await dailyRef.set(dailyStudy.toFirestore());
      }
    } catch (e) {
      print('일일 학습 기록 실패: $e');
    }
  }

  /// 사용자의 일일 학습 기록 가져오기
  Future<List<DailyStudyModel>> getDailyStudies(String userId, {int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('daily_studies')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DailyStudyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('일일 학습 기록 조회 실패: $e');
    }
  }

  // ==================== 리더보드 ====================

  /// 주간 리더보드 가져오기
  Future<List<UserModel>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('리더보드 조회 실패: $e');
    }
  }

  /// 사용자 순위 가져오기
  Future<int> getUserRank(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return -1;

      final userXP = userDoc.data()!['totalXP'] as int? ?? 0;

      final higherUsers = await _firestore
          .collection('users')
          .where('totalXP', isGreaterThan: userXP)
          .get();

      return higherUsers.docs.length + 1;
    } catch (e) {
      throw Exception('사용자 순위 조회 실패: $e');
    }
  }
}

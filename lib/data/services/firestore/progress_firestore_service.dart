import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/utils/logger.dart';
import '../../models/learning/progress_model.dart';
import '../../models/learning/wrong_answer.dart';

/// 학습 진행상황 관련 Firestore 서비스
///
/// 역할:
/// - 학습 진행상황 CRUD
/// - 문제 완료 기록
/// - 일일 학습 기록
/// - 오답 노트 관리
class ProgressFirestoreService {
  final FirebaseFirestore _firestore;

  ProgressFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
  Future<List<ProgressModel>> getUserProgress(String userId,
      {String? grade}) async {
    try {
      Query query =
          _firestore.collection('progress').where('userId', isEqualTo: userId);

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
  Future<ProgressModel?> getLessonProgress(
      String userId, String lessonId) async {
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

  // ==================== 문제 완료 기록 ====================

  /// 문제 완료 기록
  Future<void> recordProblemCompletion({
    required String userId,
    required String grade,
    required String chapter,
    required String lessonId,
    required bool isCorrect,
    required int xpEarned,
    required Function(String, int, {String? category}) addXP,
    required Function(String) updateStreak,
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
          final newProblemsCompleted =
              (data['problemsCompleted'] as int? ?? 0) + 1;
          final newCorrectAnswers =
              (data['correctAnswers'] as int? ?? 0) + (isCorrect ? 1 : 0);
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

  // ==================== 일일 학습 기록 ====================

  /// 일일 학습 기록
  Future<void> _recordDailyStudy(
      String userId, int xpEarned, String category) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyId = '${userId}_${today.toIso8601String().split('T')[0]}';

      final dailyRef = _firestore.collection('daily_studies').doc(dailyId);
      final dailyDoc = await dailyRef.get();

      if (dailyDoc.exists) {
        // 오늘 기록 업데이트
        final categoryProgress = Map<String, int>.from(
            dailyDoc.data()!['categoryProgress'] as Map? ?? {});
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
      Logger.error('일일 학습 기록 실패', error: e, tag: 'ProgressFirestoreService');
    }
  }

  /// 사용자의 일일 학습 기록 가져오기
  Future<List<DailyStudyModel>> getDailyStudies(String userId,
      {int days = 7}) async {
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

  // ==================== 오답 노트 ====================

  /// 오답 저장 (서브컬렉션)
  Future<void> saveWrongAnswer(String uid, WrongAnswer wrongAnswer) async {
    try {
      Logger.info('Firestore에 오답 저장: ${wrongAnswer.id}',
          tag: 'ProgressFirestoreService');

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wrongAnswers')
          .doc(wrongAnswer.id)
          .set({
        'problemId': wrongAnswer.problem.id,
        'selectedAnswerIndex': wrongAnswer.selectedAnswerIndex,
        'timestamp': Timestamp.fromDate(wrongAnswer.timestamp),
        'reviewCount': wrongAnswer.reviewCount,
        'lastReviewDate': wrongAnswer.lastReviewDate != null
            ? Timestamp.fromDate(wrongAnswer.lastReviewDate!)
            : null,
        'isMastered': wrongAnswer.isMastered,
        'syncedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      Logger.info('오답 저장 완료', tag: 'ProgressFirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '오답 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProgressFirestoreService',
      );
      throw Exception('오답 저장 실패: $e');
    }
  }

  /// 오답 목록 조회
  Future<List<Map<String, dynamic>>> getWrongAnswers(String uid) async {
    try {
      Logger.info('Firestore에서 오답 목록 조회: $uid', tag: 'ProgressFirestoreService');

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wrongAnswers')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        '오답 목록 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProgressFirestoreService',
      );
      throw Exception('오답 목록 조회 실패: $e');
    }
  }

  /// 오답 실시간 감지
  Stream<List<Map<String, dynamic>>> watchWrongAnswers(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('wrongAnswers')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e, stackTrace) {
      Logger.error(
        '오답 스트림 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProgressFirestoreService',
      );
      return Stream.value([]);
    }
  }
}

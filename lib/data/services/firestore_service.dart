import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user.dart';
import '../models/learning/progress_model.dart';
import '../models/learning/wrong_answer.dart';
import '../models/gamification/league.dart';
import '../../shared/utils/logger.dart';

/// Firestore 데이터베이스 서비스
/// Phase 2: Firebase 통합을 위한 확장 버전
class FirestoreService {
  // Singleton 패턴
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== 사용자 프로필 ====================

  /// 사용자 프로필 저장 (생성 또는 업데이트)
  Future<void> saveUserProfile(String uid, User user) async {
    try {
      Logger.info('Firestore에 사용자 프로필 저장: $uid', tag: 'FirestoreService');

      await _firestore.collection('users').doc(uid).set(
        user.toFirestore(),
        SetOptions(merge: true),
      );

      Logger.info('사용자 프로필 저장 완료', tag: 'FirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('사용자 프로필 저장 실패: $e');
    }
  }

  /// 사용자 프로필 조회
  Future<User?> getUserProfile(String uid) async {
    try {
      Logger.info('Firestore에서 사용자 프로필 조회: $uid', tag: 'FirestoreService');

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        Logger.warning('사용자 프로필을 찾을 수 없음: $uid', tag: 'FirestoreService');
        return null;
      }

      return User.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('사용자 프로필 조회 실패: $e');
    }
  }

  /// 사용자 프로필 실시간 감지
  Stream<User?> watchUserProfile(String uid) {
    try {
      return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        return User.fromFirestore(snapshot);
      });
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 스트림 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      return Stream.value(null);
    }
  }

  /// 사용자 프로필 업데이트 (기존 메서드 유지)
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
        final newLevel = User.calculateLevel(newTotalXP);

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
      Logger.error('일일 학습 기록 실패', error: e, tag: 'FirestoreService');
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
  Future<List<User>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => User.fromFirestore(doc))
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

  // ==================== 오답 노트 ====================

  /// 오답 저장 (서브컬렉션)
  Future<void> saveWrongAnswer(String uid, WrongAnswer wrongAnswer) async {
    try {
      Logger.info('Firestore에 오답 저장: ${wrongAnswer.id}', tag: 'FirestoreService');

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

      Logger.info('오답 저장 완료', tag: 'FirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '오답 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('오답 저장 실패: $e');
    }
  }

  /// 오답 목록 조회
  Future<List<Map<String, dynamic>>> getWrongAnswers(String uid) async {
    try {
      Logger.info('Firestore에서 오답 목록 조회: $uid', tag: 'FirestoreService');

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wrongAnswers')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e, stackTrace) {
      Logger.error(
        '오답 목록 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
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
        return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      });
    } catch (e, stackTrace) {
      Logger.error(
        '오답 스트림 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      return Stream.value([]);
    }
  }

  // ==================== 리그 ====================

  /// 현재 리그 조회
  Future<League?> getCurrentLeague(String leagueId) async {
    try {
      Logger.info('Firestore에서 리그 조회: $leagueId', tag: 'FirestoreService');

      final doc = await _firestore.collection('leagues').doc(leagueId).get();

      if (!doc.exists) {
        Logger.warning('리그를 찾을 수 없음: $leagueId', tag: 'FirestoreService');
        return null;
      }

      return League.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error(
        '리그 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('리그 조회 실패: $e');
    }
  }

  /// 리그 실시간 감지
  Stream<League?> watchLeague(String leagueId) {
    try {
      return _firestore.collection('leagues').doc(leagueId).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        return League.fromFirestore(snapshot);
      });
    } catch (e, stackTrace) {
      Logger.error(
        '리그 스트림 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      return Stream.value(null);
    }
  }

  /// 리그 참가자 업데이트 (트랜잭션 사용)
  Future<void> updateLeagueParticipant(
    String leagueId,
    String userId,
    Map<String, dynamic> participantData,
  ) async {
    try {
      Logger.info('리그 참가자 업데이트: $leagueId, $userId', tag: 'FirestoreService');

      final leagueRef = _firestore.collection('leagues').doc(leagueId);

      await _firestore.runTransaction((transaction) async {
        final leagueDoc = await transaction.get(leagueRef);

        if (!leagueDoc.exists) {
          throw Exception('리그를 찾을 수 없습니다: $leagueId');
        }

        final data = leagueDoc.data()!;
        final participants = List<Map<String, dynamic>>.from(
          data['participants'] as List? ?? [],
        );

        // 기존 참가자 찾기
        final existingIndex = participants.indexWhere(
          (p) => p['userId'] == userId,
        );

        if (existingIndex >= 0) {
          // 기존 참가자 업데이트
          participants[existingIndex] = {
            ...participants[existingIndex],
            ...participantData,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          };
        } else {
          // 새 참가자 추가
          participants.add({
            'userId': userId,
            ...participantData,
            'joinedAt': Timestamp.fromDate(DateTime.now()),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }

        // 순위 재계산 (XP 기준 내림차순)
        participants.sort((a, b) {
          final aXp = a['xp'] as int? ?? 0;
          final bXp = b['xp'] as int? ?? 0;
          return bXp.compareTo(aXp);
        });

        // 순위 업데이트
        for (int i = 0; i < participants.length; i++) {
          participants[i]['rank'] = i + 1;
        }

        // Firestore 업데이트
        transaction.update(leagueRef, {
          'participants': participants,
          'participantCount': participants.length,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      Logger.info('리그 참가자 업데이트 완료', tag: 'FirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 참가자 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('리그 참가자 업데이트 실패: $e');
    }
  }

  /// 리그 생성
  Future<void> createLeague(League league) async {
    try {
      Logger.info('리그 생성: ${league.id}', tag: 'FirestoreService');

      await _firestore
          .collection('leagues')
          .doc(league.id)
          .set(league.toFirestore());

      Logger.info('리그 생성 완료', tag: 'FirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('리그 생성 실패: $e');
    }
  }

  /// 리그 종료 처리
  Future<void> finalizeLeague(String leagueId) async {
    try {
      Logger.info('리그 종료 처리: $leagueId', tag: 'FirestoreService');

      final leagueRef = _firestore.collection('leagues').doc(leagueId);

      await _firestore.runTransaction((transaction) async {
        final leagueDoc = await transaction.get(leagueRef);

        if (!leagueDoc.exists) {
          throw Exception('리그를 찾을 수 없습니다: $leagueId');
        }

        final data = leagueDoc.data()!;
        final participants = List<Map<String, dynamic>>.from(
          data['participants'] as List? ?? [],
        );

        // 최종 순위 확정
        participants.sort((a, b) {
          final aXp = a['xp'] as int? ?? 0;
          final bXp = b['xp'] as int? ?? 0;
          return bXp.compareTo(aXp);
        });

        for (int i = 0; i < participants.length; i++) {
          participants[i]['finalRank'] = i + 1;
        }

        // 리그 종료 상태 업데이트
        transaction.update(leagueRef, {
          'participants': participants,
          'status': 'completed',
          'endedAt': Timestamp.fromDate(DateTime.now()),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      Logger.info('리그 종료 처리 완료', tag: 'FirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '리그 종료 처리 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('리그 종료 처리 실패: $e');
    }
  }

  /// 사용자를 리그에 할당
  Future<void> assignUserToLeague(String userId, String leagueId) async {
    try {
      Logger.info('사용자를 리그에 할당: $userId → $leagueId', tag: 'FirestoreService');

      await _firestore.collection('users').doc(userId).update({
        'currentLeagueId': leagueId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      Logger.info('사용자 리그 할당 완료', tag: 'FirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 리그 할당 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'FirestoreService',
      );
      throw Exception('사용자 리그 할당 실패: $e');
    }
  }
}

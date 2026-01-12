import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/utils/logger.dart';
import '../../models/user/user.dart';

/// 사용자 관련 Firestore 서비스
///
/// 역할:
/// - 사용자 프로필 CRUD
/// - XP 및 레벨 관리
/// - 스트릭 관리
/// - 업적 관리
/// - 리더보드 및 순위 조회
class UserFirestoreService {
  final FirebaseFirestore _firestore;

  UserFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== 사용자 프로필 ====================

  /// 사용자 프로필 저장 (생성 또는 업데이트)
  Future<void> saveUserProfile(String uid, User user) async {
    try {
      Logger.info('Firestore에 사용자 프로필 저장: $uid', tag: 'UserFirestoreService');

      await _firestore.collection('users').doc(uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );

      Logger.info('사용자 프로필 저장 완료', tag: 'UserFirestoreService');
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 저장 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserFirestoreService',
      );
      throw Exception('사용자 프로필 저장 실패: $e');
    }
  }

  /// 사용자 프로필 조회
  Future<User?> getUserProfile(String uid) async {
    try {
      Logger.info('Firestore에서 사용자 프로필 조회: $uid', tag: 'UserFirestoreService');

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        Logger.warning('사용자 프로필을 찾을 수 없음: $uid', tag: 'UserFirestoreService');
        return null;
      }

      return User.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserFirestoreService',
      );
      throw Exception('사용자 프로필 조회 실패: $e');
    }
  }

  /// 사용자 프로필 실시간 감지
  Stream<User?> watchUserProfile(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) return null;
        return User.fromFirestore(snapshot);
      });
    } catch (e, stackTrace) {
      Logger.error(
        '사용자 프로필 스트림 생성 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'UserFirestoreService',
      );
      return Stream.value(null);
    }
  }

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('사용자 프로필 업데이트 실패: $e');
    }
  }

  // ==================== XP 및 레벨 관리 ====================

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
          final categoryXP = Map<String, int>.from(
              userDoc.data()!['categoryXP'] as Map? ?? {});
          categoryXP[category] = (categoryXP[category] ?? 0) + xp;
          updateData['categoryXP'] = categoryXP;
        }

        transaction.update(userRef, updateData);
      });
    } catch (e) {
      throw Exception('XP 추가 실패: $e');
    }
  }

  // ==================== 스트릭 관리 ====================

  /// 스트릭 업데이트
  Future<void> updateStreak(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception('사용자를 찾을 수 없습니다.');

        final lastStudyDate =
            (userDoc.data()!['lastStudyDate'] as Timestamp?)?.toDate();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        int newStreak = userDoc.data()!['streak'] as int? ?? 0;

        if (lastStudyDate != null) {
          final lastStudy = DateTime(
              lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
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

  // ==================== 업적 관리 ====================

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

  // ==================== 리더보드 ====================

  /// 주간 리더보드 가져오기
  Future<List<User>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
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

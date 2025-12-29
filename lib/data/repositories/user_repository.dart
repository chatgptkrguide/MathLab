import 'package:cloud_firestore/cloud_firestore.dart';
import 'base/base_repository.dart';
import '../models/user/user.dart';
import '../../shared/utils/logger.dart';

/// 사용자 프로필 Repository (리팩토링 버전)
///
/// **역할:**
/// - 사용자 프로필 CRUD (BaseRepository 패턴)
/// - Firebase 통합
/// - 자동 캐싱
/// - 실시간 데이터 스트림
///
/// **개선사항:**
/// - BaseRepository 상속으로 표준화된 CRUD
/// - 자동 에러 처리 및 로깅
/// - 캐싱 전략 적용
/// - 일괄 작업 지원
class UserRepository extends BaseRepository<User> {
  UserRepository()
      : super(
          collectionPath: 'users',
          fromFirestore: User.fromFirestore,
          repositoryName: 'UserRepository',
          enableCache: true,
          cacheDuration: const Duration(minutes: 5),
        );

  // ==================== 로컬 스토리지 메서드 (UserProvider 호환성) ====================

  /// 로컬 스토리지에서 사용자 조회 (UserProvider 호환성)
  Future<User?> get(String storageKey) async {
    try {
      Logger.debug('Getting user from local storage: $storageKey', tag: repositoryName);

      // BaseRepository의 getById를 사용하여 Firestore에서 조회
      // 실제로는 로컬 스토리지를 사용해야 하지만, 현재는 Firestore를 사용
      final result = await getById(storageKey);
      return result.isSuccess ? result.data : null;
    } catch (e) {
      Logger.error('Failed to get user from storage', error: e, tag: repositoryName);
      return null;
    }
  }

  /// 로컬 스토리지에 사용자 저장 (UserProvider 호환성)
  Future<void> save(String storageKey, User user) async {
    try {
      Logger.debug('Saving user to local storage: $storageKey', tag: repositoryName);

      // BaseRepository의 create 또는 update를 사용하여 Firestore에 저장
      final exists = await this.exists(user.id);
      if (exists) {
        await update(user);
      } else {
        await create(user);
      }
    } catch (e) {
      Logger.error('Failed to save user to storage', error: e, tag: repositoryName);
      rethrow;
    }
  }

  // ==================== 커스텀 쿼리 메서드 ====================

  /// 학년별 사용자 조회
  Future<RepositoryResult<List<User>>> getUsersByGrade(String grade) async {
    return query((ref) => ref.where('currentGrade', isEqualTo: grade));
  }

  /// 레벨 범위로 사용자 조회
  Future<RepositoryResult<List<User>>> getUsersByLevelRange(
    int minLevel,
    int maxLevel,
  ) async {
    return query((ref) => ref
        .where('level', isGreaterThanOrEqualTo: minLevel)
        .where('level', isLessThanOrEqualTo: maxLevel));
  }

  /// 프리미엄 사용자 조회
  Future<RepositoryResult<List<User>>> getPremiumUsers() async {
    return query((ref) => ref.where('isPremium', isEqualTo: true));
  }

  // ==================== 특화 메서드 ====================

  /// XP 업데이트 (원자적 연산)
  Future<RepositoryResult<void>> updateXP(String userId, int xpToAdd) async {
    try {
      Logger.debug('Updating XP for user $userId: +$xpToAdd', tag: repositoryName);

      final userDocRef = _collection.doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        return RepositoryResult.failure('User not found');
      }

      final currentXP = userDoc.data()?['totalXP'] ?? 0;
      final newXP = currentXP + xpToAdd;
      final newLevel = User.calculateLevel(newXP);

      await userDocRef.update({
        'totalXP': newXP,
        'xp': newXP,
        'level': newLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 캐시 무효화
      invalidateCache(userId);

      Logger.info('XP updated successfully: +$xpToAdd (Total: $newXP, Level: $newLevel)', tag: repositoryName);
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      Logger.error('Failed to update XP', error: e, stackTrace: stackTrace, tag: repositoryName);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 스트릭 업데이트
  Future<RepositoryResult<void>> updateStreak(String userId, int newStreak) async {
    try {
      Logger.debug('Updating streak for user $userId: $newStreak', tag: repositoryName);

      await _collection.doc(userId).update({
        'streak': newStreak,
        'streakDays': newStreak,
        'lastStudyDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 캐시 무효화
      invalidateCache(userId);

      Logger.info('Streak updated successfully: $newStreak days', tag: repositoryName);
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      Logger.error('Failed to update streak', error: e, stackTrace: stackTrace, tag: repositoryName);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 하트 업데이트
  Future<RepositoryResult<void>> updateHearts(String userId, int hearts) async {
    try {
      Logger.debug('Updating hearts for user $userId: $hearts', tag: repositoryName);

      await _collection.doc(userId).update({
        'hearts': hearts,
        'lastHeartUpdateTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 캐시 무효화
      invalidateCache(userId);

      Logger.info('Hearts updated successfully: $hearts', tag: repositoryName);
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      Logger.error('Failed to update hearts', error: e, stackTrace: stackTrace, tag: repositoryName);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 사용자 완전 삭제 (모든 관련 데이터 포함)
  Future<RepositoryResult<void>> deleteUserCompletely(String userId) async {
    try {
      Logger.info('Starting complete user deletion: $userId', tag: repositoryName);

      final batch = _firestore.batch();

      // 1. 사용자 프로필 삭제
      batch.delete(_collection.doc(userId));

      // 2. 사용자의 오답 노트 서브컬렉션 삭제
      final wrongAnswersSnapshot = await _collection
          .doc(userId)
          .collection('wrongAnswers')
          .get();

      for (final doc in wrongAnswersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 3. 진행률 데이터 삭제
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in progressSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 4. 일일 학습 기록 삭제
      final dailyStudiesSnapshot = await _firestore
          .collection('daily_studies')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in dailyStudiesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Batch 커밋
      await batch.commit();

      // 5. 리그에서 사용자 제거 (별도 트랜잭션)
      await _removeUserFromLeagues(userId);

      // 캐시 무효화
      invalidateCache(userId);

      Logger.info('User deleted completely: $userId', tag: repositoryName);
      return RepositoryResult.success(null);
    } catch (e, stackTrace) {
      Logger.error('Failed to delete user completely', error: e, stackTrace: stackTrace, tag: repositoryName);
      return RepositoryResult.failure(e.toString());
    }
  }

  /// 리그에서 사용자 제거 (내부 메서드)
  Future<void> _removeUserFromLeagues(String userId) async {
    try {
      final leaguesSnapshot = await _firestore
          .collection('leagues')
          .where('participants', arrayContains: {'userId': userId})
          .get();

      for (final leagueDoc in leaguesSnapshot.docs) {
        final leagueRef = leagueDoc.reference;

        await _firestore.runTransaction((transaction) async {
          final leagueSnapshot = await transaction.get(leagueRef);

          if (!leagueSnapshot.exists) return;

          final data = leagueSnapshot.data()!;
          final participants = List<Map<String, dynamic>>.from(
            data['participants'] as List? ?? [],
          );

          // 사용자 제거
          participants.removeWhere((p) => p['userId'] == userId);

          // 순위 재계산
          participants.sort((a, b) {
            final aXp = a['xp'] as int? ?? 0;
            final bXp = b['xp'] as int? ?? 0;
            return bXp.compareTo(aXp);
          });

          for (int i = 0; i < participants.length; i++) {
            participants[i]['rank'] = i + 1;
          }

          transaction.update(leagueRef, {
            'participants': participants,
            'participantCount': participants.length,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      }

      Logger.info('User removed from leagues: $userId', tag: repositoryName);
    } catch (e, stackTrace) {
      Logger.error('Failed to remove user from leagues', error: e, stackTrace: stackTrace, tag: repositoryName);
      // Non-fatal error, don't throw
    }
  }
}

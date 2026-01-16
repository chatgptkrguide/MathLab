import '../models/gamification/achievement.dart';
import 'base/base_repository.dart';

/// 업적 Repository
///
/// 업적 데이터 CRUD 및 관리
/// - 업적 목록 조회
/// - 업적 해제 처리
/// - 진행률 업데이트
class AchievementRepository extends BaseRepository<Achievement> {
  AchievementRepository()
      : super(
          collectionPath: 'achievements',
          fromFirestore: Achievement.fromFirestore,
          repositoryName: 'AchievementRepository',
          enableCache: true,
          cacheDuration: const Duration(minutes: 10),
        );

  /// 사용자의 업적 목록 조회
  Future<RepositoryResult<List<Achievement>>> getUserAchievements(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('unlockedAt', descending: true),
    );
  }

  /// 해제된 업적 목록 조회
  Future<RepositoryResult<List<Achievement>>> getUnlockedAchievements(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('isUnlocked', isEqualTo: true)
          .orderBy('unlockedAt', descending: true),
    );
  }

  /// 미해제 업적 목록 조회
  Future<RepositoryResult<List<Achievement>>> getLockedAchievements(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('isUnlocked', isEqualTo: false)
          .orderBy('id'),
    );
  }

  /// 카테고리별 업적 조회
  Future<RepositoryResult<List<Achievement>>> getAchievementsByCategory(
    String userId,
    String category,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('requiredProgress'),
    );
  }

  /// 업적 진행률 업데이트
  Future<RepositoryResult<Achievement>> updateProgress(
    String achievementId,
    int currentProgress,
  ) async {
    try {
      final result = await getById(achievementId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          result.error ?? 'Achievement not found',
        );
      }

      final achievement = result.data!;
      final isUnlocked = currentProgress >= achievement.requiredValue;

      final updated = achievement.copyWith(
        currentValue: currentProgress,
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked && achievement.unlockedAt == null
            ? DateTime.now()
            : achievement.unlockedAt,
      );

      final updateResult = await update(updated);
      if (!updateResult.isSuccess) {
        return RepositoryResult.failure(
          updateResult.error ?? 'Failed to update',
        );
      }

      return RepositoryResult.success(updated);
    } catch (e) {
      return RepositoryResult.failure(
        'Failed to update achievement progress: $e',
      );
    }
  }

  /// 업적 해제 처리
  Future<RepositoryResult<Achievement>> unlockAchievement(
    String achievementId,
  ) async {
    try {
      final result = await getById(achievementId);
      if (!result.isSuccess || result.data == null) {
        return RepositoryResult.failure(
          result.error ?? 'Achievement not found',
        );
      }

      final achievement = result.data!;
      if (achievement.isUnlocked) {
        return RepositoryResult.success(achievement);
      }

      final unlocked = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        currentValue: achievement.requiredValue,
      );

      final updateResult = await update(unlocked);
      if (!updateResult.isSuccess) {
        return RepositoryResult.failure(
          updateResult.error ?? 'Failed to update',
        );
      }

      return RepositoryResult.success(unlocked);
    } catch (e) {
      return RepositoryResult.failure(
        'Failed to unlock achievement: $e',
      );
    }
  }

  /// 진행 중인 업적 조회 (해제되지 않았지만 진행률이 있는 업적)
  Future<RepositoryResult<List<Achievement>>> getInProgressAchievements(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('isUnlocked', isEqualTo: false)
          .where('currentProgress', isGreaterThan: 0)
          .orderBy('currentProgress', descending: true),
    );
  }
}

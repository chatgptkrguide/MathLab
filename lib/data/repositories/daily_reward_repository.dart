import '../models/gamification/daily_reward.dart';
import 'base/base_repository.dart';

class DailyRewardRepository extends BaseRepository<DailyReward> {
  DailyRewardRepository()
      : super(
          collectionPath: 'daily_rewards',
          fromFirestore: DailyReward.fromFirestore,
          repositoryName: 'DailyRewardRepository',
          enableCache: true,
          cacheDuration: const Duration(hours: 1),
        );

  Future<RepositoryResult<DailyReward?>> getUserReward(String userId) async {
    final result = await getById(userId);
    if (result.isSuccess && result.data != null) {
      return result;
    }
    return RepositoryResult.success(data: null);
  }

  Future<RepositoryResult<DailyReward>> claimReward(
    String userId,
    int day,
  ) async {
    final result = await getUserReward(userId);
    final now = DateTime.now();

    if (result.data == null) {
      final newReward = DailyReward(
        id: userId,
        userId: userId,
        currentStreak: 1,
        lastClaimDate: now,
      );
      return create(newReward);
    }

    final reward = result.data!;
    final lastClaim = reward.lastClaimDate;
    final daysSinceLastClaim = now.difference(lastClaim).inDays;

    int newStreak = reward.currentStreak;
    if (daysSinceLastClaim == 1) {
      newStreak++;
    } else if (daysSinceLastClaim > 1) {
      newStreak = 1;
    }

    final updated = reward.copyWith(
      currentStreak: newStreak,
      lastClaimDate: now,
    );
    return update(updated);
  }
}

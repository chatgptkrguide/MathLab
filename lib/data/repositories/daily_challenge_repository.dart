import '../models/gamification/daily_challenge.dart';
import 'base/base_repository.dart';

class DailyChallengeRepository extends BaseRepository<DailyChallenge> {
  DailyChallengeRepository()
      : super(
          collectionPath: 'daily_challenges',
          fromFirestore: DailyChallenge.fromFirestore,
          repositoryName: 'DailyChallengeRepository',
          enableCache: true,
          cacheDuration: const Duration(hours: 1),
        );

  Future<RepositoryResult<DailyChallenge?>> getTodayChallenge(
    String userId,
  ) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .limit(1),
    );

    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      return RepositoryResult.success(data: result.data!.first);
    }
    return RepositoryResult.success(data: null);
  }

  Future<RepositoryResult<List<DailyChallenge>>> getUserChallenges(
    String userId, {
    int limit = 30,
  }) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit),
    );
  }

  Future<RepositoryResult<DailyChallenge>> completeChallenge(
    String challengeId,
  ) async {
    final result = await getById(challengeId);
    if (!result.isSuccess || result.data == null) {
      return RepositoryResult.failure(error: 'Challenge not found');
    }

    final completed = result.data!.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    return update(completed);
  }
}

import '../models/learning/level_test.dart';
import 'base/base_repository.dart';

class LevelTestRepository extends BaseRepository<LevelTest> {
  LevelTestRepository()
      : super(
          collectionPath: 'level_tests',
          fromFirestore: LevelTest.fromFirestore,
          repositoryName: 'LevelTestRepository',
          enableCache: true,
        );

  Future<RepositoryResult<List<LevelTest>>> getUserLevelTests(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true),
    );
  }

  Future<RepositoryResult<LevelTest?>> getLatestLevelTest(
    String userId,
  ) async {
    final result = await getUserLevelTests(userId);
    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      return RepositoryResult.success(data: result.data!.first);
    }
    return RepositoryResult.success(data: null);
  }

  Future<RepositoryResult<LevelTest>> completeLevelTest(
    String testId,
    int score,
    int determinedLevel,
  ) async {
    final result = await getById(testId);
    if (!result.isSuccess || result.data == null) {
      return RepositoryResult.failure(error: 'Level test not found');
    }

    final completed = result.data!.copyWith(
      score: score,
      determinedLevel: determinedLevel,
      completedAt: DateTime.now(),
    );
    return update(completed);
  }
}

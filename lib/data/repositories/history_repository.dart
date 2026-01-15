import '../models/learning/study_session.dart';
import 'base/base_repository.dart';

class HistoryRepository extends BaseRepository<StudySession> {
  HistoryRepository()
      : super(
          collectionPath: 'study_sessions',
          fromFirestore: StudySession.fromFirestore,
          repositoryName: 'HistoryRepository',
          enableCache: true,
          cacheDuration: const Duration(minutes: 5),
        );

  Future<RepositoryResult<List<StudySession>>> getUserHistory(
    String userId, {
    int limit = 50,
  }) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('startedAt', descending: true)
          .limit(limit),
    );
  }

  Future<RepositoryResult<List<StudySession>>> getHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('startedAt', isGreaterThanOrEqualTo: startDate)
          .where('startedAt', isLessThanOrEqualTo: endDate)
          .orderBy('startedAt', descending: true),
    );
  }

  Future<RepositoryResult<int>> getTotalStudyTime(String userId) async {
    final result = await getUserHistory(userId);
    if (!result.isSuccess || result.data == null) {
      return RepositoryResult.success(data: 0);
    }

    final totalMinutes = result.data!.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );
    return RepositoryResult.success(data: totalMinutes);
  }
}

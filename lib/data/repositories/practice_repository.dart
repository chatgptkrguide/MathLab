import '../models/learning/practice_session.dart';
import 'base/base_repository.dart';

class PracticeRepository extends BaseRepository<PracticeSession> {
  PracticeRepository()
      : super(
          collectionPath: 'practice_sessions',
          fromFirestore: PracticeSession.fromFirestore,
          repositoryName: 'PracticeRepository',
          enableCache: true,
        );

  Future<RepositoryResult<List<PracticeSession>>> getUserPracticeSessions(
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

  Future<RepositoryResult<List<PracticeSession>>> getPracticeByTopic(
    String userId,
    String topic,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('topic', isEqualTo: topic)
          .orderBy('startedAt', descending: true),
    );
  }
}

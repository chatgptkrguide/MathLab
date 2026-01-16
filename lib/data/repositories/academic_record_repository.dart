import '../models/learning/academic_record.dart';
import 'base/base_repository.dart';

class AcademicRecordRepository extends BaseRepository<AcademicRecord> {
  AcademicRecordRepository()
      : super(
          collectionPath: 'academic_records',
          fromFirestore: AcademicRecord.fromFirestore,
          repositoryName: 'AcademicRecordRepository',
          enableCache: true,
        );

  Future<RepositoryResult<List<AcademicRecord>>> getUserRecords(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true),
    );
  }

  Future<RepositoryResult<List<AcademicRecord>>> getRecordsBySubject(
    String userId,
    String subject,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('subject', isEqualTo: subject)
          .orderBy('date', descending: true),
    );
  }

  Future<RepositoryResult<double>> getAverageGrade(
    String userId,
    String subject,
  ) async {
    final result = await getRecordsBySubject(userId, subject);
    if (!result.isSuccess || result.data == null || result.data!.isEmpty) {
      return RepositoryResult.success(0.0);
    }

    // 각 레코드에서 해당 과목의 점수를 가져와서 평균 계산
    final scores = result.data!
        .where((record) => record.scores.containsKey(subject))
        .map((record) => record.scores[subject]!.score)
        .toList();

    if (scores.isEmpty) {
      return RepositoryResult.success(0.0);
    }

    final average = scores.reduce((a, b) => a + b) / scores.length;
    return RepositoryResult.success(average);
  }
}

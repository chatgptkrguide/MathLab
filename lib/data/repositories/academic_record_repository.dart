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
      return RepositoryResult.success(data: 0.0);
    }

    final average = result.data!.fold<double>(
          0.0,
          (sum, record) => sum + record.grade,
        ) /
        result.data!.length;

    return RepositoryResult.success(data: average);
  }
}

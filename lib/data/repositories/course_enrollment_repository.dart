import '../models/learning/course_enrollment.dart';
import 'base/base_repository.dart';

class CourseEnrollmentRepository extends BaseRepository<CourseEnrollment> {
  CourseEnrollmentRepository()
      : super(
          collectionPath: 'course_enrollments',
          fromFirestore: CourseEnrollment.fromFirestore,
          repositoryName: 'CourseEnrollmentRepository',
          enableCache: true,
        );

  Future<RepositoryResult<List<CourseEnrollment>>> getUserEnrollments(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .orderBy('enrolledAt', descending: true),
    );
  }

  Future<RepositoryResult<List<CourseEnrollment>>> getActiveEnrollments(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('enrolledAt', descending: true),
    );
  }

  Future<RepositoryResult<bool>> isEnrolled(
    String userId,
    String courseId,
  ) async {
    final result = await query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1),
    );

    return RepositoryResult.success(
      data: result.isSuccess && result.data != null && result.data!.isNotEmpty,
    );
  }

  Future<RepositoryResult<CourseEnrollment>> enrollCourse(
    String userId,
    String courseId,
  ) async {
    final enrollment = CourseEnrollment(
      id: '',
      userId: userId,
      courseId: courseId,
      enrolledAt: DateTime.now(),
      status: 'active',
      progress: 0,
    );
    return create(enrollment);
  }

  Future<RepositoryResult<CourseEnrollment>> updateProgress(
    String enrollmentId,
    int progress,
  ) async {
    final result = await getById(enrollmentId);
    if (!result.isSuccess || result.data == null) {
      return RepositoryResult.failure(error: 'Enrollment not found');
    }

    final updated = result.data!.copyWith(
      progress: progress,
      status: progress >= 100 ? 'completed' : 'active',
      completedAt: progress >= 100 ? DateTime.now() : null,
    );
    return update(updated);
  }
}

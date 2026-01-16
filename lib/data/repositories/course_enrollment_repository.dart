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
          .orderBy('enrolledDate', descending: true),
    );
  }

  Future<RepositoryResult<List<CourseEnrollment>>> getActiveEnrollments(
    String userId,
  ) async {
    return query(
      (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: EnrollmentStatus.active.name)
          .orderBy('enrolledDate', descending: true),
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
      result.isSuccess && result.data != null && result.data!.isNotEmpty,
    );
  }

  Future<RepositoryResult<CourseEnrollment>> enrollCourse(
    String userId,
    String courseId,
    String courseName,
  ) async {
    final now = DateTime.now();
    final enrollmentId = '${userId}_${courseId}_${now.millisecondsSinceEpoch}';

    final enrollment = CourseEnrollment(
      id: enrollmentId,
      userId: userId,
      courseId: courseId,
      courseName: courseName,
      enrolledDate: now,
      status: EnrollmentStatus.active,
      progressPercentage: 0.0,
    );

    final createResult = await create(enrollment);
    if (!createResult.isSuccess) {
      return RepositoryResult.failure(
        createResult.error ?? 'Failed to enroll course',
      );
    }

    return RepositoryResult.success(enrollment);
  }

  Future<RepositoryResult<CourseEnrollment>> updateProgress(
    String enrollmentId,
    double progressPercentage,
  ) async {
    final result = await getById(enrollmentId);
    if (!result.isSuccess || result.data == null) {
      return RepositoryResult.failure('Enrollment not found');
    }

    final enrollment = result.data!;
    final status = progressPercentage >= 100
        ? EnrollmentStatus.completed
        : EnrollmentStatus.active;

    final updated = enrollment.copyWith(
      progressPercentage: progressPercentage,
      status: status,
      lastAccessDate: DateTime.now(),
    );

    final updateResult = await update(updated);
    if (!updateResult.isSuccess) {
      return RepositoryResult.failure(
        updateResult.error ?? 'Failed to update progress',
      );
    }

    return RepositoryResult.success(updated);
  }
}

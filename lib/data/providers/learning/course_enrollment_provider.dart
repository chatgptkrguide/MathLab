import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../services/course_enrollment_service.dart';
import '../user/user_provider.dart';
import '../../../shared/utils/logger.dart';

/// 과정 수강 서비스 프로바이더
final courseEnrollmentServiceProvider = Provider<CourseEnrollmentService>((ref) {
  return CourseEnrollmentService();
});

/// 모든 수강 과정 프로바이더
final allEnrollmentsProvider =
    FutureProvider.autoDispose<List<CourseEnrollment>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(courseEnrollmentServiceProvider);
  return await service.getAllEnrollments(user.id);
});

/// 활성 수강 과정 프로바이더
final activeEnrollmentsProvider =
    FutureProvider.autoDispose<List<CourseEnrollment>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(courseEnrollmentServiceProvider);
  return await service.getActiveEnrollments(user.id);
});

/// 완료된 수강 과정 프로바이더
final completedEnrollmentsProvider =
    FutureProvider.autoDispose<List<CourseEnrollment>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(courseEnrollmentServiceProvider);
  return await service.getCompletedEnrollments(user.id);
});

/// 상태별 수강 과정 프로바이더
final enrollmentsByStatusProvider = FutureProvider.autoDispose
    .family<List<CourseEnrollment>, EnrollmentStatus>((ref, status) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];

  final service = ref.read(courseEnrollmentServiceProvider);
  return await service.getEnrollmentsByStatus(user.id, status);
});

/// 특정 과정 조회 프로바이더
final enrollmentByCourseIdProvider = FutureProvider.autoDispose
    .family<CourseEnrollment?, String>((ref, courseId) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;

  final service = ref.read(courseEnrollmentServiceProvider);
  return await service.getEnrollmentByCourseId(user.id, courseId);
});

/// 추가 가능한 과정 수 프로바이더
final availableSlotsProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return CourseEnrollmentService.maxEnrollments;

  final service = ref.read(courseEnrollmentServiceProvider);
  return await service.getAvailableSlots(user.id);
});

/// 과정 수강 액션 프로바이더
final courseEnrollmentActionsProvider = Provider((ref) {
  return CourseEnrollmentActions(ref);
});

/// 과정 수강 액션 클래스
class CourseEnrollmentActions {
  final Ref _ref;

  CourseEnrollmentActions(this._ref);

  /// 새 과정 등록
  Future<CourseEnrollment?> enrollCourse({
    required String courseId,
    required String courseName,
    required int totalLessons,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'CourseEnrollment');
        return null;
      }

      final service = _ref.read(courseEnrollmentServiceProvider);
      final enrollment = await service.enrollCourse(
        userId: user.id,
        courseId: courseId,
        courseName: courseName,
        totalLessons: totalLessons,
      );

      if (enrollment != null) {
        // 관련 프로바이더 새로고침
        _ref.invalidate(allEnrollmentsProvider);
        _ref.invalidate(activeEnrollmentsProvider);
        _ref.invalidate(availableSlotsProvider);

        Logger.info(
          '과정 등록 완료: $courseName',
          tag: 'CourseEnrollment',
        );
      } else {
        Logger.warning(
          '과정 등록 실패: 최대 수강 과정 수 초과 또는 중복 등록',
          tag: 'CourseEnrollment',
        );
      }

      return enrollment;
    } catch (e, stackTrace) {
      Logger.error(
        '과정 등록 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
      return null;
    }
  }

  /// 진행률 업데이트
  Future<void> updateProgress({
    required String enrollmentId,
    required int completedLessons,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'CourseEnrollment');
        return;
      }

      final service = _ref.read(courseEnrollmentServiceProvider);
      await service.updateProgress(
        enrollmentId: enrollmentId,
        completedLessons: completedLessons,
      );

      // 관련 프로바이더 새로고침
      _ref.invalidate(allEnrollmentsProvider);
      _ref.invalidate(activeEnrollmentsProvider);
      _ref.invalidate(completedEnrollmentsProvider);

      Logger.info(
        '진행률 업데이트 완료: $completedLessons',
        tag: 'CourseEnrollment',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '진행률 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
      rethrow;
    }
  }

  /// 과정 중단
  Future<void> dropCourse(String enrollmentId) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'CourseEnrollment');
        return;
      }

      final service = _ref.read(courseEnrollmentServiceProvider);
      await service.dropCourse(enrollmentId);

      // 관련 프로바이더 새로고침
      _ref.invalidate(allEnrollmentsProvider);
      _ref.invalidate(activeEnrollmentsProvider);
      _ref.invalidate(availableSlotsProvider);

      Logger.info('과정 중단 완료: $enrollmentId', tag: 'CourseEnrollment');
    } catch (e, stackTrace) {
      Logger.error(
        '과정 중단 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
      rethrow;
    }
  }

  /// 과정 일시 중지
  Future<void> pauseCourse(String enrollmentId) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'CourseEnrollment');
        return;
      }

      final service = _ref.read(courseEnrollmentServiceProvider);
      await service.pauseCourse(enrollmentId);

      // 관련 프로바이더 새로고침
      _ref.invalidate(allEnrollmentsProvider);
      _ref.invalidate(activeEnrollmentsProvider);

      Logger.info('과정 일시 중지 완료: $enrollmentId', tag: 'CourseEnrollment');
    } catch (e, stackTrace) {
      Logger.error(
        '과정 일시 중지 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
      rethrow;
    }
  }

  /// 과정 재개
  Future<void> resumeCourse(String enrollmentId) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'CourseEnrollment');
        return;
      }

      final service = _ref.read(courseEnrollmentServiceProvider);
      await service.resumeCourse(enrollmentId);

      // 관련 프로바이더 새로고침
      _ref.invalidate(allEnrollmentsProvider);
      _ref.invalidate(activeEnrollmentsProvider);

      Logger.info('과정 재개 완료: $enrollmentId', tag: 'CourseEnrollment');
    } catch (e, stackTrace) {
      Logger.error(
        '과정 재개 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
      rethrow;
    }
  }

  /// 마지막 접근 시간 업데이트
  Future<void> updateLastAccess(String enrollmentId) async {
    try {
      final service = _ref.read(courseEnrollmentServiceProvider);
      await service.updateLastAccess(enrollmentId);
    } catch (e, stackTrace) {
      Logger.error(
        '마지막 접근 시간 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
    }
  }

  /// 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) {
        Logger.warning('사용자 정보 없음', tag: 'CourseEnrollment');
        return;
      }

      final service = _ref.read(courseEnrollmentServiceProvider);
      await service.clearAllData();

      // 모든 프로바이더 새로고침
      _ref.invalidate(allEnrollmentsProvider);
      _ref.invalidate(activeEnrollmentsProvider);
      _ref.invalidate(completedEnrollmentsProvider);
      _ref.invalidate(availableSlotsProvider);

      Logger.info('과정 수강 데이터 초기화 완료', tag: 'CourseEnrollment');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollment',
      );
      rethrow;
    }
  }
}

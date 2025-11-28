import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../../shared/utils/logger.dart';

/// 과정 수강 관리 서비스
class CourseEnrollmentService {
  static const String _enrollmentsKey = 'course_enrollments';

  /// 최대 수강 과정 수 (CourseEnrollmentLimits에서 가져옴)
  static int get _maxEnrollments => CourseEnrollmentLimits.maxConcurrentCourses;

  /// 모든 수강 과정 조회
  Future<List<CourseEnrollment>> getAllEnrollments(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enrollmentsJson = prefs.getString(_enrollmentsKey);

      if (enrollmentsJson == null) return [];

      final List<dynamic> enrollmentsList = jsonDecode(enrollmentsJson);
      final allEnrollments = enrollmentsList
          .map((json) => CourseEnrollment.fromJson(json))
          .where((enrollment) => enrollment.userId == userId)
          .toList();

      // 등록일 기준 내림차순 정렬 (최신순)
      allEnrollments.sort((a, b) => b.enrolledDate.compareTo(a.enrolledDate));
      return allEnrollments;
    } catch (e, stackTrace) {
      Logger.error(
        '수강 과정 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollmentService',
      );
      return [];
    }
  }

  /// 새 과정 등록
  Future<CourseEnrollment?> enrollCourse({
    required String userId,
    required String courseId,
    required String courseName,
    required int totalLessons,
  }) async {
    try {
      // 현재 등록된 과정 수 확인
      final currentEnrollments = await getAllEnrollments(userId);
      final activeEnrollments = currentEnrollments
          .where((e) => e.status == EnrollmentStatus.active)
          .toList();

      if (activeEnrollments.length >= _maxEnrollments) {
        Logger.warning(
          '최대 수강 과정 수 초과: ${activeEnrollments.length}/$_maxEnrollments',
          tag: 'CourseEnrollmentService',
        );
        return null;
      }

      // 이미 등록된 과정인지 확인
      final existingEnrollment = currentEnrollments.firstWhere(
        (e) => e.courseId == courseId && e.status != EnrollmentStatus.dropped,
        orElse: () => CourseEnrollment(
          id: '',
          userId: '',
          courseId: '',
          courseName: '',
          enrolledDate: DateTime.now(),
          status: EnrollmentStatus.dropped,
        ),
      );

      if (existingEnrollment.id.isNotEmpty) {
        Logger.warning('이미 등록된 과정: $courseId', tag: 'CourseEnrollmentService');
        return null;
      }

      // 새 수강 과정 생성
      final newEnrollment = CourseEnrollment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        courseId: courseId,
        courseName: courseName,
        enrolledDate: DateTime.now(),
        status: EnrollmentStatus.active,
        totalLessons: totalLessons,
        completedLessons: 0,
        lastAccessDate: DateTime.now(),
        progressPercentage: 0.0,
      );

      final prefs = await SharedPreferences.getInstance();
      final enrollmentsJson = prefs.getString(_enrollmentsKey);

      List<CourseEnrollment> enrollments = [];
      if (enrollmentsJson != null) {
        final List<dynamic> enrollmentsList = jsonDecode(enrollmentsJson);
        enrollments = enrollmentsList
            .map((json) => CourseEnrollment.fromJson(json))
            .toList();
      }

      enrollments.add(newEnrollment);
      await _saveAllEnrollments(enrollments);

      Logger.info('과정 등록 완료: $courseName', tag: 'CourseEnrollmentService');
      return newEnrollment;
    } catch (e, stackTrace) {
      Logger.error(
        '과정 등록 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollmentService',
      );
      return null;
    }
  }

  /// 수강 진행률 업데이트
  Future<void> updateProgress({
    required String enrollmentId,
    required int completedLessons,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enrollmentsJson = prefs.getString(_enrollmentsKey);

      if (enrollmentsJson == null) {
        throw Exception('수강 과정을 찾을 수 없습니다');
      }

      final List<dynamic> enrollmentsList = jsonDecode(enrollmentsJson);
      final enrollments = enrollmentsList
          .map((json) => CourseEnrollment.fromJson(json))
          .toList();

      final index = enrollments.indexWhere((e) => e.id == enrollmentId);
      if (index == -1) {
        throw Exception('수강 과정을 찾을 수 없습니다');
      }

      final enrollment = enrollments[index];
      final progressPercentage = enrollment.calculatedProgress;

      // 진행 상태 업데이트
      EnrollmentStatus newStatus = enrollment.status;
      if (completedLessons >= enrollment.totalLessons) {
        newStatus = EnrollmentStatus.completed;
      }

      enrollments[index] = enrollment.copyWith(
        completedLessons: completedLessons,
        progressPercentage: progressPercentage,
        lastAccessDate: DateTime.now(),
        status: newStatus,
      );

      await _saveAllEnrollments(enrollments);

      Logger.info(
        '진행률 업데이트: $completedLessons/${enrollment.totalLessons}',
        tag: 'CourseEnrollmentService',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '진행률 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollmentService',
      );
      rethrow;
    }
  }

  /// 수강 상태 변경
  Future<void> updateStatus({
    required String enrollmentId,
    required EnrollmentStatus status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enrollmentsJson = prefs.getString(_enrollmentsKey);

      if (enrollmentsJson == null) {
        throw Exception('수강 과정을 찾을 수 없습니다');
      }

      final List<dynamic> enrollmentsList = jsonDecode(enrollmentsJson);
      final enrollments = enrollmentsList
          .map((json) => CourseEnrollment.fromJson(json))
          .toList();

      final index = enrollments.indexWhere((e) => e.id == enrollmentId);
      if (index == -1) {
        throw Exception('수강 과정을 찾을 수 없습니다');
      }

      enrollments[index] = enrollments[index].copyWith(status: status);
      await _saveAllEnrollments(enrollments);

      Logger.info('수강 상태 변경: ${status.label}', tag: 'CourseEnrollmentService');
    } catch (e, stackTrace) {
      Logger.error(
        '수강 상태 변경 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollmentService',
      );
      rethrow;
    }
  }

  /// 과정 중단
  Future<void> dropCourse(String enrollmentId) async {
    await updateStatus(
      enrollmentId: enrollmentId,
      status: EnrollmentStatus.dropped,
    );
  }

  /// 과정 일시 중지
  Future<void> pauseCourse(String enrollmentId) async {
    await updateStatus(
      enrollmentId: enrollmentId,
      status: EnrollmentStatus.paused,
    );
  }

  /// 과정 재개
  Future<void> resumeCourse(String enrollmentId) async {
    await updateStatus(
      enrollmentId: enrollmentId,
      status: EnrollmentStatus.active,
    );
  }

  /// 상태별 수강 과정 조회
  Future<List<CourseEnrollment>> getEnrollmentsByStatus(
    String userId,
    EnrollmentStatus status,
  ) async {
    final allEnrollments = await getAllEnrollments(userId);
    return allEnrollments.where((e) => e.status == status).toList();
  }

  /// 활성 수강 과정 조회
  Future<List<CourseEnrollment>> getActiveEnrollments(String userId) async {
    return await getEnrollmentsByStatus(userId, EnrollmentStatus.active);
  }

  /// 완료된 수강 과정 조회
  Future<List<CourseEnrollment>> getCompletedEnrollments(String userId) async {
    return await getEnrollmentsByStatus(userId, EnrollmentStatus.completed);
  }

  /// 특정 과정 조회
  Future<CourseEnrollment?> getEnrollmentByCourseId(
    String userId,
    String courseId,
  ) async {
    final allEnrollments = await getAllEnrollments(userId);
    try {
      return allEnrollments.firstWhere(
        (e) => e.courseId == courseId && e.status != EnrollmentStatus.dropped,
      );
    } catch (e) {
      return null;
    }
  }

  /// 마지막 접근 시간 업데이트
  Future<void> updateLastAccess(String enrollmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enrollmentsJson = prefs.getString(_enrollmentsKey);

      if (enrollmentsJson == null) return;

      final List<dynamic> enrollmentsList = jsonDecode(enrollmentsJson);
      final enrollments = enrollmentsList
          .map((json) => CourseEnrollment.fromJson(json))
          .toList();

      final index = enrollments.indexWhere((e) => e.id == enrollmentId);
      if (index == -1) return;

      enrollments[index] =
          enrollments[index].copyWith(lastAccessDate: DateTime.now());
      await _saveAllEnrollments(enrollments);
    } catch (e, stackTrace) {
      Logger.error(
        '마지막 접근 시간 업데이트 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollmentService',
      );
    }
  }

  /// 모든 수강 과정 저장
  Future<void> _saveAllEnrollments(List<CourseEnrollment> enrollments) async {
    final prefs = await SharedPreferences.getInstance();
    final enrollmentsJson =
        jsonEncode(enrollments.map((e) => e.toJson()).toList());
    await prefs.setString(_enrollmentsKey, enrollmentsJson);
  }

  /// 모든 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_enrollmentsKey);
      Logger.info('수강 과정 데이터 초기화 완료', tag: 'CourseEnrollmentService');
    } catch (e, stackTrace) {
      Logger.error(
        '데이터 초기화 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'CourseEnrollmentService',
      );
      rethrow;
    }
  }

  /// 최대 수강 과정 수 확인
  static int get maxEnrollments => _maxEnrollments;

  /// 추가 가능한 과정 수 확인
  Future<int> getAvailableSlots(String userId) async {
    final activeEnrollments = await getActiveEnrollments(userId);
    return _maxEnrollments - activeEnrollments.length;
  }
}

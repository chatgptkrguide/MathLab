import 'package:flutter/foundation.dart';

/// 과정 수강 제한 상수
class CourseEnrollmentLimits {
  /// 최대 동시 수강 가능 과정 수
  static const int maxConcurrentCourses = 10;

  /// 최소 수강 과정 수
  static const int minCourses = 1;
}

/// 과정 수강 데이터 모델
/// 사용자가 여러 과정을 동시에 수강할 수 있도록 관리합니다.
@immutable
class CourseEnrollment {
  /// 수강 ID
  final String id;

  /// 사용자 ID
  final String userId;

  /// 과정 ID
  final String courseId;

  /// 과정명
  final String courseName;

  /// 수강 시작일
  final DateTime enrolledDate;

  /// 수강 상태
  final EnrollmentStatus status;

  /// 완료한 레슨 수
  final int completedLessons;

  /// 전체 레슨 수
  final int totalLessons;

  /// 마지막 접속일
  final DateTime? lastAccessDate;

  /// 진행률 (%)
  final double progressPercentage;

  const CourseEnrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.courseName,
    required this.enrolledDate,
    required this.status,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.lastAccessDate,
    this.progressPercentage = 0.0,
  });

  /// 진행률 계산
  double get calculatedProgress {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons) * 100;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'courseName': courseName,
      'enrolledDate': enrolledDate.toIso8601String(),
      'status': status.name,
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'lastAccessDate': lastAccessDate?.toIso8601String(),
      'progressPercentage': progressPercentage,
    };
  }

  /// JSON에서 생성
  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      enrolledDate: DateTime.parse(json['enrolledDate'] as String),
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EnrollmentStatus.active,
      ),
      completedLessons: json['completedLessons'] as int? ?? 0,
      totalLessons: json['totalLessons'] as int? ?? 0,
      lastAccessDate: json['lastAccessDate'] != null
          ? DateTime.parse(json['lastAccessDate'] as String)
          : null,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 복사 (업데이트용)
  CourseEnrollment copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? courseName,
    DateTime? enrolledDate,
    EnrollmentStatus? status,
    int? completedLessons,
    int? totalLessons,
    DateTime? lastAccessDate,
    double? progressPercentage,
  }) {
    return CourseEnrollment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      enrolledDate: enrolledDate ?? this.enrolledDate,
      status: status ?? this.status,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      lastAccessDate: lastAccessDate ?? this.lastAccessDate,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseEnrollment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CourseEnrollment(id: $id, userId: $userId, courseId: $courseId, courseName: $courseName, status: ${status.label})';
  }
}

/// 수강 상태
enum EnrollmentStatus {
  /// 진행 중
  active('진행 중', '📖'),

  /// 일시정지
  paused('일시정지', '⏸️'),

  /// 완료
  completed('완료', '✅'),

  /// 중단
  dropped('중단', '🚫'),

  /// 취소
  cancelled('취소', '❌');

  const EnrollmentStatus(this.label, this.emoji);

  final String label;
  final String emoji;
}

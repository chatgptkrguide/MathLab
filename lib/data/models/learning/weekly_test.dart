import 'package:flutter/foundation.dart';

/// 주간테스트 모델
@immutable
class WeeklyTest {
  /// 테스트 ID
  final String id;

  /// 테스트 제목 (예: "2024년 11월 4주차 주간테스트")
  final String title;

  /// 주차 정보 (예: "2024-W48")
  final String weekCode;

  /// 선생님 ID
  final String teacherId;

  /// 선생님 이름
  final String teacherName;

  /// 대상 학급 ID
  final String classId;

  /// 생성일
  final DateTime createdAt;

  /// 시험 날짜
  final DateTime testDate;

  /// 제출 마감일
  final DateTime dueDate;

  /// 총 문항 수
  final int totalQuestions;

  /// 배점
  final int totalPoints;

  /// 테스트 설명
  final String? description;

  /// 제출한 학생 수
  final int submittedCount;

  /// 전체 학생 수
  final int totalStudents;

  const WeeklyTest({
    required this.id,
    required this.title,
    required this.weekCode,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.createdAt,
    required this.testDate,
    required this.dueDate,
    required this.totalQuestions,
    required this.totalPoints,
    this.description,
    this.submittedCount = 0,
    required this.totalStudents,
  });

  /// 제출까지 남은 시간 (일)
  int get daysUntilDue {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff;
  }

  /// 제출 기한이 지났는지
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate);
  }

  /// 제출률 (%)
  double get submissionRate {
    if (totalStudents == 0) return 0.0;
    return (submittedCount / totalStudents) * 100;
  }

  /// 미제출자 수
  int get notSubmittedCount {
    return totalStudents - submittedCount;
  }

  factory WeeklyTest.fromJson(Map<String, dynamic> json) {
    return WeeklyTest(
      id: json['id'] as String,
      title: json['title'] as String,
      weekCode: json['weekCode'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      classId: json['classId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      testDate: DateTime.parse(json['testDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      totalQuestions: json['totalQuestions'] as int,
      totalPoints: json['totalPoints'] as int,
      description: json['description'] as String?,
      submittedCount: json['submittedCount'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weekCode': weekCode,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classId': classId,
      'createdAt': createdAt.toIso8601String(),
      'testDate': testDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'totalQuestions': totalQuestions,
      'totalPoints': totalPoints,
      'description': description,
      'submittedCount': submittedCount,
      'totalStudents': totalStudents,
    };
  }

  WeeklyTest copyWith({
    String? id,
    String? title,
    String? weekCode,
    String? teacherId,
    String? teacherName,
    String? classId,
    DateTime? createdAt,
    DateTime? testDate,
    DateTime? dueDate,
    int? totalQuestions,
    int? totalPoints,
    String? description,
    int? submittedCount,
    int? totalStudents,
  }) {
    return WeeklyTest(
      id: id ?? this.id,
      title: title ?? this.title,
      weekCode: weekCode ?? this.weekCode,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      classId: classId ?? this.classId,
      createdAt: createdAt ?? this.createdAt,
      testDate: testDate ?? this.testDate,
      dueDate: dueDate ?? this.dueDate,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      description: description ?? this.description,
      submittedCount: submittedCount ?? this.submittedCount,
      totalStudents: totalStudents ?? this.totalStudents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WeeklyTest(id: $id, title: $title, weekCode: $weekCode)';
  }
}

import 'package:flutter/foundation.dart';

/// 주간테스트 제출 모델
@immutable
class WeeklyTestSubmission {
  /// 제출 ID
  final String id;

  /// 주간테스트 ID
  final String weeklyTestId;

  /// 학생 ID
  final String studentId;

  /// 학생 이름
  final String studentName;

  /// 제출 여부
  final bool isSubmitted;

  /// 제출 시간
  final DateTime? submittedAt;

  /// OMR 사진 URL
  final String? omrPhotoUrl;

  /// 점수 (채점 후)
  final int? score;

  /// 만점
  final int totalPoints;

  /// 선생님 확인 시간
  final DateTime? gradedAt;

  /// 선생님 피드백
  final String? feedback;

  const WeeklyTestSubmission({
    required this.id,
    required this.weeklyTestId,
    required this.studentId,
    required this.studentName,
    this.isSubmitted = false,
    this.submittedAt,
    this.omrPhotoUrl,
    this.score,
    required this.totalPoints,
    this.gradedAt,
    this.feedback,
  });

  /// 채점되었는지
  bool get isGraded => score != null;

  /// 득점률 (%)
  double? get scorePercentage {
    if (score == null || totalPoints == 0) return null;
    return (score! / totalPoints) * 100;
  }

  factory WeeklyTestSubmission.fromJson(Map<String, dynamic> json) {
    return WeeklyTestSubmission(
      id: json['id'] as String,
      weeklyTestId: json['weeklyTestId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      isSubmitted: json['isSubmitted'] as bool? ?? false,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      omrPhotoUrl: json['omrPhotoUrl'] as String?,
      score: json['score'] as int?,
      totalPoints: json['totalPoints'] as int,
      gradedAt: json['gradedAt'] != null
          ? DateTime.parse(json['gradedAt'] as String)
          : null,
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weeklyTestId': weeklyTestId,
      'studentId': studentId,
      'studentName': studentName,
      'isSubmitted': isSubmitted,
      'submittedAt': submittedAt?.toIso8601String(),
      'omrPhotoUrl': omrPhotoUrl,
      'score': score,
      'totalPoints': totalPoints,
      'gradedAt': gradedAt?.toIso8601String(),
      'feedback': feedback,
    };
  }

  WeeklyTestSubmission copyWith({
    String? id,
    String? weeklyTestId,
    String? studentId,
    String? studentName,
    bool? isSubmitted,
    DateTime? submittedAt,
    String? omrPhotoUrl,
    int? score,
    int? totalPoints,
    DateTime? gradedAt,
    String? feedback,
  }) {
    return WeeklyTestSubmission(
      id: id ?? this.id,
      weeklyTestId: weeklyTestId ?? this.weeklyTestId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submittedAt: submittedAt ?? this.submittedAt,
      omrPhotoUrl: omrPhotoUrl ?? this.omrPhotoUrl,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      gradedAt: gradedAt ?? this.gradedAt,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTestSubmission &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WeeklyTestSubmission(id: $id, studentName: $studentName, isSubmitted: $isSubmitted)';
  }
}

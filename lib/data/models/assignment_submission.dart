import 'package:flutter/foundation.dart';

/// 과제 제출 상태
enum SubmissionStatus {
  /// 제출 전
  notSubmitted('미제출', '⏳'),

  /// 제출 완료
  submitted('제출 완료', '✅'),

  /// 확인 완료
  confirmed('확인 완료', '🎯');

  const SubmissionStatus(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// 과제 제출 모델
@immutable
class AssignmentSubmission {
  /// 제출 ID
  final String id;

  /// 과제 ID
  final String assignmentId;

  /// 학생 ID
  final String studentId;

  /// 학생 이름
  final String studentName;

  /// 제출 상태
  final SubmissionStatus status;

  /// 제출 시간
  final DateTime? submittedAt;

  /// 제출 사진 URL 목록
  final List<String> photoUrls;

  /// 선생님 확인 시간
  final DateTime? confirmedAt;

  /// 선생님 피드백
  final String? feedback;

  /// 점수 (선택적)
  final int? score;

  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.submittedAt,
    this.photoUrls = const [],
    this.confirmedAt,
    this.feedback,
    this.score,
  });

  /// 제출했는지
  bool get isSubmitted => status != SubmissionStatus.notSubmitted;

  /// 확인되었는지
  bool get isConfirmed => status == SubmissionStatus.confirmed;

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      status: SubmissionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SubmissionStatus.notSubmitted,
      ),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      feedback: json['feedback'] as String?,
      score: json['score'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'status': status.name,
      'submittedAt': submittedAt?.toIso8601String(),
      'photoUrls': photoUrls,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'feedback': feedback,
      'score': score,
    };
  }

  AssignmentSubmission copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? studentName,
    SubmissionStatus? status,
    DateTime? submittedAt,
    List<String>? photoUrls,
    DateTime? confirmedAt,
    String? feedback,
    int? score,
  }) {
    return AssignmentSubmission(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      photoUrls: photoUrls ?? this.photoUrls,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      feedback: feedback ?? this.feedback,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentSubmission &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AssignmentSubmission(id: $id, studentName: $studentName, status: ${status.label})';
  }
}

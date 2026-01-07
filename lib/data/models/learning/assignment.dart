import 'package:flutter/foundation.dart';

/// 과제 상태
enum AssignmentStatus {
  /// 진행 중
  active('진행 중', '📝'),

  /// 마감
  closed('마감', '🔒'),

  /// 초안
  draft('초안', '✏️');

  const AssignmentStatus(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// 과제 모델
@immutable
class Assignment {
  /// 과제 ID
  final String id;

  /// 과제 제목
  final String title;

  /// 과제 설명
  final String description;

  /// 선생님 ID
  final String teacherId;

  /// 선생님 이름
  final String teacherName;

  /// 대상 학급 ID
  final String classId;

  /// 과제 상태
  final AssignmentStatus status;

  /// 생성일
  final DateTime createdAt;

  /// 마감일
  final DateTime dueDate;

  /// 첨부파일 URL 목록
  final List<String>? attachmentUrls;

  /// 제출한 학생 수
  final int submittedCount;

  /// 전체 학생 수
  final int totalStudents;

  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.status,
    required this.createdAt,
    required this.dueDate,
    this.attachmentUrls,
    this.submittedCount = 0,
    required this.totalStudents,
  });

  /// 마감까지 남은 시간 (일)
  int get daysUntilDue {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff;
  }

  /// 마감되었는지
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate);
  }

  /// 제출률 (%)
  double get submissionRate {
    if (totalStudents == 0) return 0.0;
    return (submittedCount / totalStudents) * 100;
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      classId: json['classId'] as String,
      status: AssignmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AssignmentStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      attachmentUrls: (json['attachmentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      submittedCount: json['submittedCount'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classId': classId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'attachmentUrls': attachmentUrls,
      'submittedCount': submittedCount,
      'totalStudents': totalStudents,
    };
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    String? teacherId,
    String? teacherName,
    String? classId,
    AssignmentStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? attachmentUrls,
    int? submittedCount,
    int? totalStudents,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      classId: classId ?? this.classId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      submittedCount: submittedCount ?? this.submittedCount,
      totalStudents: totalStudents ?? this.totalStudents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assignment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, status: ${status.label})';
  }
}

import 'package:flutter/foundation.dart';

/// 사용자 역할 (선생님/학생)
enum UserRole {
  /// 학생
  student('학생', '📚'),

  /// 선생님
  teacher('선생님', '👨‍🏫');

  const UserRole(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// 사용자 역할 정보
@immutable
class UserRoleInfo {
  /// 사용자 ID
  final String userId;

  /// 역할
  final UserRole role;

  /// 담당 학급 (선생님인 경우)
  final List<String>? classIds;

  /// 소속 학급 (학생인 경우)
  final String? classId;

  /// 역할 부여 날짜
  final DateTime assignedAt;

  const UserRoleInfo({
    required this.userId,
    required this.role,
    this.classIds,
    this.classId,
    required this.assignedAt,
  });

  /// 선생님인지 확인
  bool get isTeacher => role == UserRole.teacher;

  /// 학생인지 확인
  bool get isStudent => role == UserRole.student;

  factory UserRoleInfo.fromJson(Map<String, dynamic> json) {
    return UserRoleInfo(
      userId: json['userId'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.student,
      ),
      classIds: (json['classIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      classId: json['classId'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role.name,
      'classIds': classIds,
      'classId': classId,
      'assignedAt': assignedAt.toIso8601String(),
    };
  }

  UserRoleInfo copyWith({
    String? userId,
    UserRole? role,
    List<String>? classIds,
    String? classId,
    DateTime? assignedAt,
  }) {
    return UserRoleInfo(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      classIds: classIds ?? this.classIds,
      classId: classId ?? this.classId,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleInfo &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserRoleInfo(userId: $userId, role: ${role.label})';
  }
}

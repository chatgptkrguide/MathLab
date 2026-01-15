import 'package:flutter/foundation.dart';

/// 친구 요청 상태
enum FriendRequestStatus {
  /// 보류 중 (요청 대기)
  pending,

  /// 수락됨
  accepted,

  /// 거절됨
  rejected,
}

/// 친구 모델
@immutable
class Friend {
  final String id;
  final String userId;
  final String name;
  final String? profileImageUrl;
  final int level;
  final int xp;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const Friend({
    required this.id,
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.level,
    required this.xp,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
    this.acceptedAt,
  });

  /// photoUrl getter for backward compatibility
  String? get photoUrl => profileImageUrl;

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      level: json['level'] as int,
      xp: json['xp'] as int,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'level': level,
      'xp': xp,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
    };
  }

  Friend copyWith({
    String? id,
    String? userId,
    String? name,
    String? profileImageUrl,
    int? level,
    int? xp,
    FriendRequestStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}

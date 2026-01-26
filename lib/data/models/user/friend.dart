import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 친구 정보 모델
class Friend extends Equatable {
  /// 친구 ID
  final String id;

  /// 친구 UID
  final String uid;

  /// 친구 이름
  final String name;

  /// 프로필 이미지 URL
  final String? profileImageUrl;

  /// 레벨
  final int level;

  /// XP (경험치)
  final int xp;

  /// 스트릭 (연속 학습일)
  final int streak;

  /// 친구 상태 (pending, accepted, rejected)
  final String status;

  /// 친구 요청을 보낸 사용자 ID
  final String fromUserId;

  /// 친구 요청을 받은 사용자 ID
  final String toUserId;

  /// 생성일
  final DateTime createdAt;

  /// 수락일 (승인된 경우에만)
  final DateTime? acceptedAt;

  const Friend({
    required this.id,
    required this.uid,
    required this.name,
    this.profileImageUrl,
    required this.level,
    required this.xp,
    required this.streak,
    required this.status,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    this.acceptedAt,
  });

  /// Firestore 문서에서 Friend 객체 생성
  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Friend(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown',
      profileImageUrl: data['profileImageUrl'] as String?,
      level: data['level'] as int? ?? 1,
      xp: data['xp'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      status: data['status'] as String? ?? 'pending',
      fromUserId: data['fromUserId'] as String? ?? '',
      toUserId: data['toUserId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Map에서 Friend 객체 생성
  factory Friend.fromMap(Map<String, dynamic> map, String id) {
    return Friend(
      id: id,
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      profileImageUrl: map['profileImageUrl'] as String?,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      status: map['status'] as String? ?? 'pending',
      fromUserId: map['fromUserId'] as String? ?? '',
      toUserId: map['toUserId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Friend 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'level': level,
      'xp': xp,
      'streak': streak,
      'status': status,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }

  /// 친구 복사 (일부 필드 변경)
  Friend copyWith({
    String? id,
    String? uid,
    String? name,
    String? profileImageUrl,
    int? level,
    int? xp,
    int? streak,
    String? status,
    String? fromUserId,
    String? toUserId,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return Friend(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      status: status ?? this.status,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        name,
        profileImageUrl,
        level,
        xp,
        streak,
        status,
        fromUserId,
        toUserId,
        createdAt,
        acceptedAt,
      ];
}

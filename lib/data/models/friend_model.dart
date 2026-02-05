// 👥 Friend Model
//
// Represents friend relationships and social features

class FriendModel {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String? friendAvatar;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    this.friendAvatar,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      friendName: json['friendName'] as String,
      friendAvatar: json['friendAvatar'] as String?,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'friendId': friendId,
        'friendName': friendName,
        'friendAvatar': friendAvatar,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
      };

  /// Check if friendship is active
  bool get isActive => status == FriendshipStatus.accepted;

  /// Check if friendship is pending
  bool get isPending => status == FriendshipStatus.pending;

  /// Get status label
  String get statusLabel {
    switch (status) {
      case FriendshipStatus.pending:
        return '대기중';
      case FriendshipStatus.accepted:
        return '친구';
      case FriendshipStatus.blocked:
        return '차단됨';
    }
  }

  FriendModel copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendName,
    String? friendAvatar,
    FriendshipStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return FriendModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendAvatar: friendAvatar ?? this.friendAvatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}

/// Friendship status
enum FriendshipStatus {
  pending, // Friend request sent but not accepted
  accepted, // Friends
  blocked, // Blocked
}

/// Friend request model
class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserAvatar;
  final String toUserId;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserAvatar,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserAvatar: json['fromUserAvatar'] as String?,
      toUserId: json['toUserId'] as String,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'fromUserAvatar': fromUserAvatar,
        'toUserId': toUserId,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
      };

  /// Check if request is pending
  bool get isPending => status == RequestStatus.pending;

  /// Get time since request
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  FriendRequestModel copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? fromUserAvatar,
    String? toUserId,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserAvatar: fromUserAvatar ?? this.fromUserAvatar,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

/// Friend request status
enum RequestStatus {
  pending, // Waiting for response
  accepted, // Request accepted
  rejected, // Request rejected
}

/// Friend activity model
class FriendActivityModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final ActivityType type;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const FriendActivityModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
    required this.description,
    this.metadata,
    required this.timestamp,
  });

  factory FriendActivityModel.fromJson(Map<String, dynamic> json) {
    return FriendActivityModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.other,
      ),
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'type': type.name,
        'description': description,
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Get activity icon
  String get activityIcon {
    switch (type) {
      case ActivityType.lessonCompleted:
        return '✅';
      case ActivityType.achievementUnlocked:
        return '🏅';
      case ActivityType.streakMilestone:
        return '🔥';
      case ActivityType.leaguePromotion:
        return '🏆';
      case ActivityType.perfectScore:
        return '💯';
      case ActivityType.other:
        return '📌';
    }
  }

  /// Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

/// Activity type
enum ActivityType {
  lessonCompleted, // Lesson completed
  achievementUnlocked, // Achievement unlocked
  streakMilestone, // Streak milestone reached
  leaguePromotion, // League promotion
  perfectScore, // Perfect score achieved
  other, // Other activities
}

// 👥 Team Model
//
// Represents study teams for group learning and competition

import '../../core/utils/app_logger.dart';

enum TeamRole { leader, member }

class TeamModel {
  final String id;
  final String name;
  final String? description;
  final String? iconEmoji;
  final String leaderId;
  final List<String> memberIds;
  final int maxMembers;
  final int totalXp;
  final int weeklyXp;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeamModel({
    required this.id,
    required this.name,
    this.description,
    this.iconEmoji,
    required this.leaderId,
    required this.memberIds,
    this.maxMembers = 10,
    this.totalXp = 0,
    this.weeklyXp = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconEmoji: json['iconEmoji'] as String?,
      leaderId: json['leaderId'] as String,
      memberIds: List<String>.from(json['memberIds'] ?? []),
      maxMembers: json['maxMembers'] as int? ?? 10,
      totalXp: json['totalXp'] as int? ?? 0,
      weeklyXp: json['weeklyXp'] as int? ?? 0,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconEmoji': iconEmoji,
        'leaderId': leaderId,
        'memberIds': memberIds,
        'maxMembers': maxMembers,
        'totalXp': totalXp,
        'weeklyXp': weeklyXp,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  int get memberCount => memberIds.length;
  bool get isFull => memberCount >= maxMembers;

  bool isMember(String userId) => memberIds.contains(userId);
  bool isLeader(String userId) => leaderId == userId;

  String get displayIcon => iconEmoji ?? '📚';

  TeamModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconEmoji,
    String? leaderId,
    List<String>? memberIds,
    int? maxMembers,
    int? totalXp,
    int? weeklyXp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      leaderId: leaderId ?? this.leaderId,
      memberIds: memberIds ?? this.memberIds,
      maxMembers: maxMembers ?? this.maxMembers,
      totalXp: totalXp ?? this.totalXp,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    // Firestore Timestamp - duck typing for toDate() to avoid hard dep on cloud_firestore here.
    if (value != null) {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (e) {
        AppLogger.warning(
          'unsupported value $value ($e)',
          tag: 'TeamModel._parseDateTime',
        );
      }
    }
    return DateTime.now();
  }
}

class TeamMember {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final TeamRole role;
  final int xp;
  final int weeklyXp;
  final int streak;
  final int level;
  final DateTime joinedAt;

  const TeamMember({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    this.xp = 0,
    this.weeklyXp = 0,
    this.streak = 0,
    this.level = 1,
    required this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['userId'] as String? ?? json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? json['photoUrl'] as String?,
      role: json['role'] == 'leader' ? TeamRole.leader : TeamRole.member,
      xp: json['xp'] as int? ?? json['totalXp'] as int? ?? 0,
      weeklyXp: json['weeklyXp'] as int? ?? json['dailyXP'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      joinedAt: TeamModel._parseDateTime(json['joinedAt'] ?? json['createdAt']),
    );
  }

  bool get isLeader => role == TeamRole.leader;

  String get roleLabel => isLeader ? '팀장' : '팀원';
}

class TeamInvitation {
  final String id;
  final String teamId;
  final String teamName;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  const TeamInvitation({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    this.status = 'pending',
    required this.createdAt,
  });

  factory TeamInvitation.fromJson(Map<String, dynamic> json) {
    return TeamInvitation(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String? ?? '',
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String? ?? '',
      toUserId: json['toUserId'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: TeamModel._parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'teamName': teamName,
        'fromUserId': fromUserId,
        'fromUserName': fromUserName,
        'toUserId': toUserId,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  bool get isPending => status == 'pending';

  String getTimeAgo() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}개월 전';
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금 전';
  }
}

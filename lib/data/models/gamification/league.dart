/// 리그 뱃지 종류
enum LeagueBadge {
  streak, // 연속 학습 스트릭
  perfect, // 완벽한 주간
  topScorer, // 최다 득점
  rising, // 급상승
  veteran, // 베테랑
}

/// 리그 뱃지 확장 메서드
extension LeagueBadgeExtension on LeagueBadge {
  String get displayName {
    switch (this) {
      case LeagueBadge.streak:
        return '🔥 스트릭';
      case LeagueBadge.perfect:
        return '⭐ 완벽';
      case LeagueBadge.topScorer:
        return '👑 득점왕';
      case LeagueBadge.rising:
        return '🚀 급상승';
      case LeagueBadge.veteran:
        return '🏆 베테랑';
    }
  }

  String get description {
    switch (this) {
      case LeagueBadge.streak:
        return '7일 연속 학습';
      case LeagueBadge.perfect:
        return '모든 목표 달성';
      case LeagueBadge.topScorer:
        return '주간 1위';
      case LeagueBadge.rising:
        return '순위 5단계 상승';
      case LeagueBadge.veteran:
        return '30일 이상 활동';
    }
  }

  String get icon {
    switch (this) {
      case LeagueBadge.streak:
        return '🔥';
      case LeagueBadge.perfect:
        return '⭐';
      case LeagueBadge.topScorer:
        return '👑';
      case LeagueBadge.rising:
        return '🚀';
      case LeagueBadge.veteran:
        return '🏆';
    }
  }
}

/// 리그 등급 (하위부터 상위 순)
enum LeagueTier {
  bronze, // 브론즈
  silver, // 실버
  gold, // 골드
  platinum, // 플래티넘
  diamond, // 다이아몬드
  champion, // 챔피언
}

/// 리그 티어 확장 메서드
extension LeagueTierExtension on LeagueTier {
  String get displayName {
    switch (this) {
      case LeagueTier.bronze:
        return '브론즈 리그';
      case LeagueTier.silver:
        return '실버 리그';
      case LeagueTier.gold:
        return '골드 리그';
      case LeagueTier.platinum:
        return '플래티넘 리그';
      case LeagueTier.diamond:
        return '다이아몬드 리그';
      case LeagueTier.champion:
        return '챔피언 리그';
    }
  }

  String get iconPath {
    switch (this) {
      case LeagueTier.bronze:
        return 'assets/images/league/bronze.png';
      case LeagueTier.silver:
        return 'assets/images/league/silver.png';
      case LeagueTier.gold:
        return 'assets/images/league/gold.png';
      case LeagueTier.platinum:
        return 'assets/images/league/platinum.png';
      case LeagueTier.diamond:
        return 'assets/images/league/diamond.png';
      case LeagueTier.champion:
        return 'assets/images/league/champion.png';
    }
  }

  /// 리그 이모지 아이콘 (이미지 대체용)
  String get iconEmoji {
    switch (this) {
      case LeagueTier.bronze:
        return '🥉'; // 브론즈 메달
      case LeagueTier.silver:
        return '🥈'; // 실버 메달
      case LeagueTier.gold:
        return '🥇'; // 골드 메달
      case LeagueTier.platinum:
        return '💎'; // 플래티넘 (다이아몬드)
      case LeagueTier.diamond:
        return '💠'; // 다이아몬드
      case LeagueTier.champion:
        return '👑'; // 챔피언 왕관
    }
  }

  int get color {
    switch (this) {
      case LeagueTier.bronze:
        return 0xFFCD7F32; // 브론즈 색상
      case LeagueTier.silver:
        return 0xFFC0C0C0; // 실버 색상
      case LeagueTier.gold:
        return 0xFFFFD700; // 골드 색상
      case LeagueTier.platinum:
        return 0xFFE5E4E2; // 플래티넘 색상
      case LeagueTier.diamond:
        return 0xFFB9F2FF; // 다이아몬드 색상
      case LeagueTier.champion:
        return 0xFFFF6B6B; // 챔피언 색상 (레드)
    }
  }
}

/// 리그 참가자 정보
class LeagueParticipant {
  final String userId;
  final String userName;
  final int weeklyXp;
  final int rank;
  final String? avatarUrl;
  final List<LeagueBadge> badges;

  const LeagueParticipant({
    required this.userId,
    required this.userName,
    required this.weeklyXp,
    required this.rank,
    this.avatarUrl,
    this.badges = const [],
  });

  factory LeagueParticipant.fromJson(Map<String, dynamic> json) {
    final badgesList = (json['badges'] as List<dynamic>?)
            ?.map((e) => LeagueBadge.values.firstWhere(
                  (badge) => badge.toString() == e,
                  orElse: () => LeagueBadge.streak,
                ))
            .toList() ??
        [];

    return LeagueParticipant(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      weeklyXp: json['weeklyXp'] as int,
      rank: json['rank'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      badges: badgesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'weeklyXp': weeklyXp,
      'rank': rank,
      'avatarUrl': avatarUrl,
      'badges': badges.map((b) => b.toString()).toList(),
    };
  }
}

/// 리그 정보
class League {
  final String id;
  final LeagueTier tier;
  final List<LeagueParticipant> participants;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const League({
    required this.id,
    required this.tier,
    required this.participants,
    required this.weekStartDate,
    required this.weekEndDate,
    this.createdAt,
    this.updatedAt,
  });

  /// 사용자가 리그에 참가 중인지 확인
  bool isUserParticipant(String userId) {
    return participants.any((p) => p.userId == userId);
  }

  /// 현재 사용자의 순위 찾기
  int? getUserRank(String userId) {
    final participant = participants.firstWhere(
      (p) => p.userId == userId,
      orElse: () => const LeagueParticipant(
        userId: '',
        userName: '',
        weeklyXp: 0,
        rank: 0,
      ),
    );
    return participant.userId.isEmpty ? null : participant.rank;
  }

  /// 승급 가능 여부 (상위 10위 안에 들면 승급)
  bool canPromote(String userId) {
    final rank = getUserRank(userId);
    return rank != null && rank <= 10 && tier != LeagueTier.champion;
  }

  /// 강등 위험 여부 (하위 5명 안에 들면 강등)
  bool isRelegationZone(String userId) {
    final rank = getUserRank(userId);
    if (rank == null || tier == LeagueTier.bronze) return false;
    return rank > participants.length - 5;
  }

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] as String? ?? '',
      tier: LeagueTier.values.firstWhere(
        (t) => t.toString() == json['tier'],
        orElse: () => LeagueTier.bronze,
      ),
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((p) => LeagueParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Firestore DocumentSnapshot에서 League 생성
  factory League.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('League document data is null');
    }

    // Firestore Timestamp를 DateTime으로 변환
    final Map<String, dynamic> jsonData = {
      'id': doc.id,
      'tier': data['tier'],
      'participants': data['participants'] ?? [],
      'weekStartDate': _timestampToString(data['weekStartDate']),
      'weekEndDate': _timestampToString(data['weekEndDate']),
      'createdAt': data['createdAt'] != null
          ? _timestampToString(data['createdAt'])
          : null,
      'updatedAt': data['updatedAt'] != null
          ? _timestampToString(data['updatedAt'])
          : null,
    };

    return League.fromJson(jsonData);
  }

  /// Firestore Timestamp를 ISO 8601 문자열로 변환
  static String _timestampToString(dynamic timestamp) {
    if (timestamp == null) return DateTime.now().toIso8601String();
    if (timestamp is String) return timestamp;

    // Firestore Timestamp인 경우
    try {
      return (timestamp as dynamic).toDate().toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tier': tier.toString(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'weekStartDate': weekStartDate.toIso8601String(),
      'weekEndDate': weekEndDate.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'tier': tier.toString(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'weekStartDate': weekStartDate,
      'weekEndDate': weekEndDate,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  /// copyWith 메서드
  League copyWith({
    String? id,
    LeagueTier? tier,
    List<LeagueParticipant>? participants,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return League(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      participants: participants ?? this.participants,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

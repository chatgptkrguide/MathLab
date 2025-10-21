/// 리더보드 엔트리 모델
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int rank;
  final int xp;
  final int level;
  final int streakDays;
  final String grade; // 학년 (중1, 중2, 고1 등)
  final bool isCurrentUser; // 현재 사용자인지 여부
  final DateTime lastActiveAt;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.rank,
    required this.xp,
    required this.level,
    required this.streakDays,
    required this.grade,
    this.isCurrentUser = false,
    required this.lastActiveAt,
  });

  /// JSON으로부터 LeaderboardEntry 객체 생성
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      rank: json['rank'] as int,
      xp: json['xp'] as int,
      level: json['level'] as int,
      streakDays: json['streakDays'] as int,
      grade: json['grade'] as String,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    );
  }

  /// LeaderboardEntry 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'rank': rank,
      'xp': xp,
      'level': level,
      'streakDays': streakDays,
      'grade': grade,
      'isCurrentUser': isCurrentUser,
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  /// LeaderboardEntry 객체 복사
  LeaderboardEntry copyWith({
    String? userId,
    String? userName,
    String? avatarUrl,
    int? rank,
    int? xp,
    int? level,
    int? streakDays,
    String? grade,
    bool? isCurrentUser,
    DateTime? lastActiveAt,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      grade: grade ?? this.grade,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// 순위 변화 아이콘
  String get rankChangeIcon {
    // 나중에 이전 순위 데이터와 비교하여 상승/하락 표시
    return '—';
  }

  /// 순위별 메달 이모지
  String? get medalEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }

  /// 레벨 티어 (Bronze, Silver, Gold, Diamond)
  String get tier {
    if (level >= 30) return 'Diamond';
    if (level >= 20) return 'Gold';
    if (level >= 10) return 'Silver';
    return 'Bronze';
  }

  /// 티어별 색상 (헥스 코드)
  String get tierColor {
    switch (tier) {
      case 'Diamond':
        return '#B9F2FF';
      case 'Gold':
        return '#FFD700';
      case 'Silver':
        return '#C0C0C0';
      case 'Bronze':
        return '#CD7F32';
      default:
        return '#CCCCCC';
    }
  }

  @override
  String toString() {
    return 'LeaderboardEntry{rank: $rank, userName: $userName, xp: $xp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// 리더보드 기간 타입
enum LeaderboardPeriod {
  weekly('주간', 7),
  monthly('월간', 30),
  allTime('전체', 0);

  final String displayName;
  final int days; // 0은 전체 기간

  const LeaderboardPeriod(this.displayName, this.days);
}

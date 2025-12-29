// 리그 티어 관리 시스템 모델
// 7일 비활동 강등, 10문제 복구 시스템

/// 티어 레벨
enum TierLevel {
  bronze('브론즈'),
  silver('실버'),
  gold('골드'),
  platinum('플래티넘'),
  diamond('다이아몬드');

  final String label;
  const TierLevel(this.label);

  /// 다음 티어
  TierLevel? get next {
    final index = values.indexOf(this);
    if (index < values.length - 1) {
      return values[index + 1];
    }
    return null;
  }

  /// 이전 티어
  TierLevel? get previous {
    final index = values.indexOf(this);
    if (index > 0) {
      return values[index - 1];
    }
    return null;
  }
}

/// 티어 정보
class TierInfo {
  final String userId;
  final TierLevel currentTier;
  final int points;
  final int rank;
  final DateTime lastActiveDate;
  final int consecutiveInactiveDays;
  final bool canRecover; // 강등 후 복구 가능 여부
  final int problemsSolvedSinceDemotion; // 강등 후 풀은 문제 수

  TierInfo({
    required this.userId,
    required this.currentTier,
    required this.points,
    required this.rank,
    required this.lastActiveDate,
    this.consecutiveInactiveDays = 0,
    this.canRecover = false,
    this.problemsSolvedSinceDemotion = 0,
  });

  /// 강등 대상 여부 (7일 이상 비활동)
  bool get isDemotionTarget => consecutiveInactiveDays >= 7;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentTier': currentTier.name,
      'points': points,
      'rank': rank,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'consecutiveInactiveDays': consecutiveInactiveDays,
      'canRecover': canRecover,
      'problemsSolvedSinceDemotion': problemsSolvedSinceDemotion,
    };
  }

  /// JSON에서 생성
  factory TierInfo.fromJson(Map<String, dynamic> json) {
    return TierInfo(
      userId: json['userId'] as String,
      currentTier: TierLevel.values.firstWhere(
        (e) => e.name == json['currentTier'],
        orElse: () => TierLevel.bronze,
      ),
      points: json['points'] as int,
      rank: json['rank'] as int,
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
      consecutiveInactiveDays: json['consecutiveInactiveDays'] as int? ?? 0,
      canRecover: json['canRecover'] as bool? ?? false,
      problemsSolvedSinceDemotion: json['problemsSolvedSinceDemotion'] as int? ?? 0,
    );
  }

  /// 복사 (업데이트용)
  TierInfo copyWith({
    String? userId,
    TierLevel? currentTier,
    int? points,
    int? rank,
    DateTime? lastActiveDate,
    int? consecutiveInactiveDays,
    bool? canRecover,
    int? problemsSolvedSinceDemotion,
  }) {
    return TierInfo(
      userId: userId ?? this.userId,
      currentTier: currentTier ?? this.currentTier,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      consecutiveInactiveDays: consecutiveInactiveDays ?? this.consecutiveInactiveDays,
      canRecover: canRecover ?? this.canRecover,
      problemsSolvedSinceDemotion:
          problemsSolvedSinceDemotion ?? this.problemsSolvedSinceDemotion,
    );
  }
}

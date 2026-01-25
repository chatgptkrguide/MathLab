/// 🏆 League Model
///
/// Represents a league/tier in the gamification system

class LeagueTier {
  static const String bronze = 'Bronze';
  static const String silver = 'Silver';
  static const String gold = 'Gold';
  static const String diamond = 'Diamond';
  static const String master = 'Master';

  static List<String> get all => [bronze, silver, gold, diamond, master];

  static String getDisplayName(String tier) {
    switch (tier) {
      case bronze:
        return '브론즈';
      case silver:
        return '실버';
      case gold:
        return '골드';
      case diamond:
        return '다이아몬드';
      case master:
        return '마스터';
      default:
        return tier;
    }
  }

  static String getIcon(String tier) {
    switch (tier) {
      case bronze:
        return '🥉';
      case silver:
        return '🥈';
      case gold:
        return '🥇';
      case diamond:
        return '💎';
      case master:
        return '👑';
      default:
        return '🏆';
    }
  }
}

class LeagueModel {
  final String id;
  final String name;
  final String tier;
  final int minRank;
  final int maxRank;
  final DateTime startDate;
  final DateTime endDate;
  final int participantCount;
  final int promotionCount;
  final int relegationCount;
  final Map<String, dynamic>? rewards;

  const LeagueModel({
    required this.id,
    required this.name,
    required this.tier,
    required this.minRank,
    required this.maxRank,
    required this.startDate,
    required this.endDate,
    required this.participantCount,
    this.promotionCount = 5,
    this.relegationCount = 5,
    this.rewards,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: json['tier'] as String,
      minRank: json['minRank'] as int,
      maxRank: json['maxRank'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantCount: json['participantCount'] as int,
      promotionCount: json['promotionCount'] as int? ?? 5,
      relegationCount: json['relegationCount'] as int? ?? 5,
      rewards: json['rewards'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tier': tier,
        'minRank': minRank,
        'maxRank': maxRank,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'participantCount': participantCount,
        'promotionCount': promotionCount,
        'relegationCount': relegationCount,
        'rewards': rewards,
      };

  Duration get timeRemaining => endDate.difference(DateTime.now());

  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  String get displayTier => LeagueTier.getDisplayName(tier);

  String get tierIcon => LeagueTier.getIcon(tier);
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? profileImageUrl;
  final int rank;
  final int xp;
  final int problemsSolved;
  final double accuracy;
  final String tier;
  final bool isCurrentUser;
  final int? rankChange; // Positive for up, negative for down

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.rank,
    required this.xp,
    required this.problemsSolved,
    required this.accuracy,
    required this.tier,
    this.isCurrentUser = false,
    this.rankChange,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      rank: json['rank'] as int,
      xp: json['xp'] as int,
      problemsSolved: json['problemsSolved'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      tier: json['tier'] as String,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      rankChange: json['rankChange'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'profileImageUrl': profileImageUrl,
        'rank': rank,
        'xp': xp,
        'problemsSolved': problemsSolved,
        'accuracy': accuracy,
        'tier': tier,
        'isCurrentUser': isCurrentUser,
        'rankChange': rankChange,
      };

  bool get isPromotion => rankChange != null && rankChange! > 0;
  bool get isRelegation => rankChange != null && rankChange! < 0;

  String get displayTier => LeagueTier.getDisplayName(tier);
  String get tierIcon => LeagueTier.getIcon(tier);
}

class UserLeagueStatus {
  final LeagueModel league;
  final LeaderboardEntry userEntry;
  final bool isPromotionZone;
  final bool isRelegationZone;
  final bool isSafeZone;
  final int xpToNextRank;
  final int xpToPromotion;

  const UserLeagueStatus({
    required this.league,
    required this.userEntry,
    required this.isPromotionZone,
    required this.isRelegationZone,
    required this.isSafeZone,
    required this.xpToNextRank,
    required this.xpToPromotion,
  });

  factory UserLeagueStatus.fromJson(Map<String, dynamic> json) {
    return UserLeagueStatus(
      league: LeagueModel.fromJson(json['league'] as Map<String, dynamic>),
      userEntry: LeaderboardEntry.fromJson(
        json['userEntry'] as Map<String, dynamic>,
      ),
      isPromotionZone: json['isPromotionZone'] as bool,
      isRelegationZone: json['isRelegationZone'] as bool,
      isSafeZone: json['isSafeZone'] as bool,
      xpToNextRank: json['xpToNextRank'] as int,
      xpToPromotion: json['xpToPromotion'] as int,
    );
  }

  String get statusMessage {
    if (isPromotionZone) {
      return '승급권! 계속 노력하세요! 🎉';
    } else if (isRelegationZone) {
      return '강등 위험! 조심하세요! ⚠️';
    } else {
      return '안정권입니다 👍';
    }
  }

  String get zoneColor {
    if (isPromotionZone) return '#4CAF50'; // Green
    if (isRelegationZone) return '#F44336'; // Red
    return '#2196F3'; // Blue
  }
}

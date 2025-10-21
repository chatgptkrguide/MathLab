import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';

/// 리그 티어
enum LeagueTier {
  bronze('브론즈', '🥉', AppColors.mathOrange, 0),
  silver('실버', '🥈', Color(0xFFC0C0C0), 100),
  gold('골드', '🥇', AppColors.mathYellow, 500),
  diamond('다이아', '💎', Color(0xFF00BCD4), 1000);

  const LeagueTier(this.displayName, this.emoji, this.color, this.xpThreshold);

  final String displayName;
  final String emoji;
  final Color color;
  final int xpThreshold; // 해당 리그 진입에 필요한 XP

  /// XP로부터 리그 티어 계산
  static LeagueTier fromXP(int xp) {
    if (xp >= LeagueTier.diamond.xpThreshold) {
      return LeagueTier.diamond;
    } else if (xp >= LeagueTier.gold.xpThreshold) {
      return LeagueTier.gold;
    } else if (xp >= LeagueTier.silver.xpThreshold) {
      return LeagueTier.silver;
    } else {
      return LeagueTier.bronze;
    }
  }

  /// 다음 티어
  LeagueTier? get nextTier {
    final currentIndex = LeagueTier.values.indexOf(this);
    if (currentIndex < LeagueTier.values.length - 1) {
      return LeagueTier.values[currentIndex + 1];
    }
    return null; // 이미 최고 티어
  }

  /// 다음 티어까지 필요한 XP
  int xpToNextTier(int currentXP) {
    final next = nextTier;
    if (next == null) return 0; // 이미 최고 티어
    return next.xpThreshold - currentXP;
  }

  /// 현재 티어 내 진행률 (0.0 ~ 1.0)
  double progressInTier(int currentXP) {
    final next = nextTier;
    if (next == null) return 1.0; // 최고 티어는 항상 100%

    final tierStart = xpThreshold;
    final tierEnd = next.xpThreshold;
    final progress = (currentXP - tierStart) / (tierEnd - tierStart);

    return progress.clamp(0.0, 1.0);
  }

  /// 그라디언트 색상
  List<Color> get gradientColors {
    switch (this) {
      case LeagueTier.bronze:
        return [Color(0xFFCD7F32), Color(0xFFB8692D)];
      case LeagueTier.silver:
        return [Color(0xFFC0C0C0), Color(0xFFA8A8A8)];
      case LeagueTier.gold:
        return [Color(0xFFFFD700), Color(0xFFFFA500)];
      case LeagueTier.diamond:
        return [Color(0xFF00BCD4), Color(0xFF0097A7)];
    }
  }
}

/// 리그 정보
class LeagueInfo {
  final LeagueTier tier;
  final int currentXP;
  final int rank; // 리그 내 순위
  final int totalPlayers; // 리그 내 총 플레이어 수

  const LeagueInfo({
    required this.tier,
    required this.currentXP,
    required this.rank,
    required this.totalPlayers,
  });

  /// 다음 티어까지 남은 XP
  int get xpToNextTier => tier.xpToNextTier(currentXP);

  /// 현재 티어 내 진행률
  double get progressInTier => tier.progressInTier(currentXP);

  /// 상위 % 계산
  double get topPercentage => (rank / totalPlayers) * 100;

  /// 승급 가능 여부 (상위 20% 이내)
  bool get canPromote => topPercentage <= 20.0;

  /// 강등 위험 여부 (하위 20% 이내)
  bool get relegationRisk => topPercentage >= 80.0;

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      tier: LeagueTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => LeagueTier.bronze,
      ),
      currentXP: json['currentXP'] as int,
      rank: json['rank'] as int,
      totalPlayers: json['totalPlayers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier.name,
      'currentXP': currentXP,
      'rank': rank,
      'totalPlayers': totalPlayers,
    };
  }

  LeagueInfo copyWith({
    LeagueTier? tier,
    int? currentXP,
    int? rank,
    int? totalPlayers,
  }) {
    return LeagueInfo(
      tier: tier ?? this.tier,
      currentXP: currentXP ?? this.currentXP,
      rank: rank ?? this.rank,
      totalPlayers: totalPlayers ?? this.totalPlayers,
    );
  }
}

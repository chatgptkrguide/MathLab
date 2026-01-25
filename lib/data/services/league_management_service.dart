/// 🏆 League Management Service
///
/// Manages weekly league cycles, promotions, and relegations

import 'package:logger/logger.dart';
import '../models/league_model.dart';

enum LeagueAction {
  promotion,
  relegation,
  stay,
}

class LeagueManagementService {
  final Logger _logger = Logger();

  /// Calculate league action based on rank and league settings
  LeagueAction calculateLeagueAction({
    required int rank,
    required int totalParticipants,
    required int promotionCount,
    required int relegationCount,
  }) {
    if (rank <= promotionCount) {
      return LeagueAction.promotion;
    } else if (rank > totalParticipants - relegationCount) {
      return LeagueAction.relegation;
    }
    return LeagueAction.stay;
  }

  /// Get next tier based on current tier and action
  String? getNextTier({
    required String currentTier,
    required LeagueAction action,
  }) {
    final tiers = LeagueTier.all;
    final currentIndex = tiers.indexOf(currentTier);

    if (currentIndex == -1) return null;

    switch (action) {
      case LeagueAction.promotion:
        // Can't promote from highest tier
        if (currentIndex >= tiers.length - 1) return currentTier;
        return tiers[currentIndex + 1];

      case LeagueAction.relegation:
        // Can't relegate from lowest tier
        if (currentIndex <= 0) return currentTier;
        return tiers[currentIndex - 1];

      case LeagueAction.stay:
        return currentTier;
    }
  }

  /// Calculate rewards based on rank and tier
  Map<String, dynamic> calculateRewards({
    required int rank,
    required String tier,
    required int totalParticipants,
    required int promotionCount,
  }) {
    final action = calculateLeagueAction(
      rank: rank,
      totalParticipants: totalParticipants,
      promotionCount: promotionCount,
      relegationCount: promotionCount, // Usually same as promotion count
    );

    // Base rewards by tier
    final tierMultipliers = {
      LeagueTier.bronze: 1.0,
      LeagueTier.silver: 1.5,
      LeagueTier.gold: 2.0,
      LeagueTier.diamond: 3.0,
      LeagueTier.master: 5.0,
    };

    final baseXP = 100;
    final tierMultiplier = tierMultipliers[tier] ?? 1.0;

    // Rank-based multiplier
    double rankMultiplier;
    if (rank == 1) {
      rankMultiplier = 3.0;
    } else if (rank <= 3) {
      rankMultiplier = 2.0;
    } else if (rank <= promotionCount) {
      rankMultiplier = 1.5;
    } else {
      rankMultiplier = 1.0;
    }

    final xpReward = (baseXP * tierMultiplier * rankMultiplier).round();

    // Gems for top performers
    int gemReward = 0;
    if (rank == 1) {
      gemReward = 50;
    } else if (rank <= 3) {
      gemReward = 30;
    } else if (rank <= promotionCount) {
      gemReward = 20;
    }

    // Badges for achievements
    final badges = <String>[];
    if (rank == 1) {
      badges.add('first_place_${tier.toLowerCase()}');
    }
    if (action == LeagueAction.promotion) {
      badges.add('promotion_${tier.toLowerCase()}');
    }

    return {
      'xp': xpReward,
      'gems': gemReward,
      'badges': badges,
      'action': action.name,
      'nextTier': getNextTier(currentTier: tier, action: action),
    };
  }

  /// Calculate XP needed for promotion
  int calculateXPForPromotion({
    required int currentRank,
    required int currentXP,
    required List<LeaderboardEntry> leaderboard,
    required int promotionCount,
  }) {
    if (currentRank <= promotionCount) {
      // Already in promotion zone
      return 0;
    }

    // Get XP of the user at promotion boundary
    if (promotionCount < leaderboard.length) {
      final promotionBoundaryXP = leaderboard[promotionCount - 1].xp;
      final xpNeeded = promotionBoundaryXP - currentXP + 1;
      return xpNeeded > 0 ? xpNeeded : 0;
    }

    return 0;
  }

  /// Calculate XP needed for next rank
  int calculateXPForNextRank({
    required int currentRank,
    required int currentXP,
    required List<LeaderboardEntry> leaderboard,
  }) {
    if (currentRank <= 1) {
      // Already first place
      return 0;
    }

    // Get XP of the user one rank above
    final targetRank = currentRank - 1;
    if (targetRank - 1 < leaderboard.length) {
      final targetXP = leaderboard[targetRank - 1].xp;
      final xpNeeded = targetXP - currentXP + 1;
      return xpNeeded > 0 ? xpNeeded : 0;
    }

    return 0;
  }

  /// Check if league week has ended
  bool hasLeagueEnded(DateTime endDate) {
    return DateTime.now().isAfter(endDate);
  }

  /// Calculate time remaining in league
  Duration getTimeRemaining(DateTime endDate) {
    final remaining = endDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Validate league transition
  bool canTransition({
    required String currentTier,
    required LeagueAction action,
  }) {
    final tiers = LeagueTier.all;
    final currentIndex = tiers.indexOf(currentTier);

    if (currentIndex == -1) return false;

    switch (action) {
      case LeagueAction.promotion:
        return currentIndex < tiers.length - 1;
      case LeagueAction.relegation:
        return currentIndex > 0;
      case LeagueAction.stay:
        return true;
    }
  }

  /// Generate league notification message
  String getLeagueResultMessage({
    required LeagueAction action,
    required String currentTier,
    required int rank,
    required Map<String, dynamic> rewards,
  }) {
    final tierName = LeagueTier.getDisplayName(currentTier);

    switch (action) {
      case LeagueAction.promotion:
        final nextTier = rewards['nextTier'] as String?;
        final nextTierName = nextTier != null
            ? LeagueTier.getDisplayName(nextTier)
            : tierName;
        return '축하합니다! $tierName 리그 #$rank로 $nextTierName 리그로 승급했습니다! 🎉';

      case LeagueAction.relegation:
        final nextTier = rewards['nextTier'] as String?;
        final nextTierName = nextTier != null
            ? LeagueTier.getDisplayName(nextTier)
            : tierName;
        return '$tierName 리그 #$rank로 $nextTierName 리그로 강등되었습니다. 다음 주에 다시 도전하세요! 💪';

      case LeagueAction.stay:
        return '$tierName 리그 #$rank를 기록했습니다. 계속 노력하세요! 👍';
    }
  }

  /// Calculate league statistics
  Map<String, dynamic> calculateLeagueStats({
    required List<LeaderboardEntry> leaderboard,
    required String userId,
  }) {
    final userEntry = leaderboard.firstWhere(
      (entry) => entry.userId == userId,
      orElse: () => leaderboard.first,
    );

    final totalUsers = leaderboard.length;
    final percentile = ((totalUsers - userEntry.rank + 1) / totalUsers * 100);

    return {
      'rank': userEntry.rank,
      'totalUsers': totalUsers,
      'percentile': percentile.toStringAsFixed(1),
      'xp': userEntry.xp,
      'problemsSolved': userEntry.problemsSolved,
      'accuracy': userEntry.accuracy,
    };
  }
}

// 🏆 League Provider
//
// Manages league and leaderboard state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/league_model.dart';
import '../../services/league_management_service.dart';
import '../api_provider.dart';

/// League Management Service Provider
final leagueManagementServiceProvider = Provider<LeagueManagementService>((ref) {
  return LeagueManagementService();
});

/// League State
class LeagueState {
  final UserLeagueStatus? userLeagueStatus;
  final List<LeaderboardEntry> leaderboard;
  final bool isLoading;
  final String? error;

  const LeagueState({
    this.userLeagueStatus,
    this.leaderboard = const [],
    this.isLoading = false,
    this.error,
  });

  LeagueState copyWith({
    UserLeagueStatus? userLeagueStatus,
    List<LeaderboardEntry>? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return LeagueState(
      userLeagueStatus: userLeagueStatus ?? this.userLeagueStatus,
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// League Notifier
class LeagueNotifier extends StateNotifier<LeagueState> {
  final Ref _ref;
  final String userId;

  LeagueNotifier(this._ref, this.userId) : super(const LeagueState()) {
    loadUserLeague();
  }

  Future<void> loadUserLeague() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final leagueAPI = _ref.read(leagueAPIProvider);

      // Get user's current league
      final leagueData = await leagueAPI.getUserLeague(userId: userId);
      final userLeagueStatus = UserLeagueStatus.fromJson(leagueData);

      // Get leaderboard
      final leaderboardData = await leagueAPI.getLeaderboard(
        leagueId: userLeagueStatus.league.id,
      );

      final leaderboard = leaderboardData
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList();

      state = state.copyWith(
        userLeagueStatus: userLeagueStatus,
        leaderboard: leaderboard,
        isLoading: false,
      );

      AppLogger.info('Loaded league: ${userLeagueStatus.league.name}');
    } catch (e, stackTrace) {
      final appError = AppErrorHandler.handle(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: appError.userMessage,
      );
    }
  }

  Future<void> refreshLeaderboard() async {
    if (state.userLeagueStatus == null) return;

    try {
      final leagueAPI = _ref.read(leagueAPIProvider);

      final leaderboardData = await leagueAPI.getLeaderboard(
        leagueId: state.userLeagueStatus!.league.id,
      );

      final leaderboard = leaderboardData
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList();

      state = state.copyWith(leaderboard: leaderboard);

      AppLogger.info('Refreshed leaderboard');
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
    }
  }

  Future<void> claimRewards() async {
    if (state.userLeagueStatus == null) return;

    try {
      final leagueAPI = _ref.read(leagueAPIProvider);

      await leagueAPI.claimRewards(
        userId: userId,
        leagueId: state.userLeagueStatus!.league.id,
      );

      AppLogger.info('Claimed rewards');

      // Reload league status
      await loadUserLeague();
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
    }
  }

  /// Calculate weekly results and rewards
  Future<Map<String, dynamic>> calculateWeeklyResults() async {
    if (state.userLeagueStatus == null || state.leaderboard.isEmpty) {
      return {};
    }

    final managementService = _ref.read(leagueManagementServiceProvider);
    final status = state.userLeagueStatus!;

    // Calculate league action (promotion/stay/relegation)
    final action = managementService.calculateLeagueAction(
      rank: status.userEntry.rank,
      totalParticipants: state.leaderboard.length,
      promotionCount: status.league.promotionCount,
      relegationCount: status.league.relegationCount,
    );

    // Calculate rewards
    final rewards = managementService.calculateRewards(
      rank: status.userEntry.rank,
      tier: status.league.tier,
      totalParticipants: state.leaderboard.length,
      promotionCount: status.league.promotionCount,
    );

    // Generate result message
    final message = managementService.getLeagueResultMessage(
      action: action,
      currentTier: status.league.tier,
      rank: status.userEntry.rank,
      rewards: rewards,
    );

    // Calculate stats
    final stats = managementService.calculateLeagueStats(
      leaderboard: state.leaderboard,
      userId: userId,
    );

    return {
      'action': action.name,
      'rewards': rewards,
      'message': message,
      'stats': stats,
    };
  }

  /// Check if league has ended
  bool hasLeagueEnded() {
    if (state.userLeagueStatus == null) return false;

    final managementService = _ref.read(leagueManagementServiceProvider);
    return managementService.hasLeagueEnded(
      state.userLeagueStatus!.league.endDate,
    );
  }

  /// Get XP needed for promotion
  int getXPForPromotion() {
    if (state.userLeagueStatus == null || state.leaderboard.isEmpty) {
      return 0;
    }

    final managementService = _ref.read(leagueManagementServiceProvider);
    return managementService.calculateXPForPromotion(
      currentRank: state.userLeagueStatus!.userEntry.rank,
      currentXP: state.userLeagueStatus!.userEntry.xp,
      leaderboard: state.leaderboard,
      promotionCount: state.userLeagueStatus!.league.promotionCount,
    );
  }

  /// Get XP needed for next rank
  int getXPForNextRank() {
    if (state.userLeagueStatus == null || state.leaderboard.isEmpty) {
      return 0;
    }

    final managementService = _ref.read(leagueManagementServiceProvider);
    return managementService.calculateXPForNextRank(
      currentRank: state.userLeagueStatus!.userEntry.rank,
      currentXP: state.userLeagueStatus!.userEntry.xp,
      leaderboard: state.leaderboard,
    );
  }
}

/// League Provider
final leagueProvider =
    StateNotifierProvider.family<LeagueNotifier, LeagueState, String>(
  (ref, userId) => LeagueNotifier(ref, userId),
);

/// League History Provider
final leagueHistoryProvider = FutureProvider.family<List<LeagueModel>, String>(
  (ref, userId) async {
    final leagueAPI = ref.watch(leagueAPIProvider);

    try {
      final historyData = await leagueAPI.getLeagueHistory(userId: userId);

      return historyData
          .map((league) => LeagueModel.fromJson(league))
          .toList();
    } catch (e, stackTrace) {
      AppErrorHandler.handle(e, stackTrace);
      return [];
    }
  },
);

/// All League Tiers Provider
final leagueTiersProvider = FutureProvider<List<LeagueModel>>((ref) async {
  final leagueAPI = ref.watch(leagueAPIProvider);

  try {
    final tiersData = await leagueAPI.getLeagueTiers();

    return tiersData
        .map((tier) => LeagueModel.fromJson(tier))
        .toList();
  } catch (e, stackTrace) {
    AppErrorHandler.handle(e, stackTrace);
    return [];
  }
});

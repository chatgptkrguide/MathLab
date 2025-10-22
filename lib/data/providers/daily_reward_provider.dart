import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_reward.dart';
import '../models/user.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../../shared/services/local_storage_service.dart';

/// 데일리 리워드 상태
class DailyRewardState {
  final List<DailyReward> rewards;
  final DateTime? lastClaimDate;
  final int currentDay;
  final bool canClaimToday;

  const DailyRewardState({
    required this.rewards,
    this.lastClaimDate,
    required this.currentDay,
    required this.canClaimToday,
  });

  DailyRewardState copyWith({
    List<DailyReward>? rewards,
    DateTime? lastClaimDate,
    int? currentDay,
    bool? canClaimToday,
  }) {
    return DailyRewardState(
      rewards: rewards ?? this.rewards,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      currentDay: currentDay ?? this.currentDay,
      canClaimToday: canClaimToday ?? this.canClaimToday,
    );
  }
}

/// 데일리 리워드 Provider
class DailyRewardProvider extends StateNotifier<DailyRewardState> {
  final UserProvider _userProvider;
  final LocalStorageService _storage = LocalStorageService();

  static const String _storageKey = 'daily_rewards_state';

  DailyRewardProvider(this._userProvider)
      : super(const DailyRewardState(
          rewards: [],
          currentDay: 1,
          canClaimToday: true,
        )) {
    _initializeRewards();
    _loadState();
  }

  /// 7일 보상 초기화
  void _initializeRewards() {
    final rewards = [
      DailyReward(
        day: 1,
        xpReward: 10,
        heartsReward: 0,
        isClaimed: false,
      ),
      DailyReward(
        day: 2,
        xpReward: 15,
        heartsReward: 0,
        isClaimed: false,
      ),
      DailyReward(
        day: 3,
        xpReward: 20,
        heartsReward: 1,
        isClaimed: false,
      ),
      DailyReward(
        day: 4,
        xpReward: 25,
        heartsReward: 0,
        isClaimed: false,
      ),
      DailyReward(
        day: 5,
        xpReward: 30,
        heartsReward: 1,
        isClaimed: false,
      ),
      DailyReward(
        day: 6,
        xpReward: 40,
        heartsReward: 0,
        isClaimed: false,
      ),
      DailyReward(
        day: 7,
        xpReward: 50,
        heartsReward: 2,
        isClaimed: false,
        isStreakBonus: true,
      ),
    ];

    state = state.copyWith(rewards: rewards);
    Logger.info('Daily rewards initialized: 7 days');
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadObject(_storageKey);
      if (data != null) {
        final lastClaimDate = data['lastClaimDate'] != null
            ? DateTime.parse(data['lastClaimDate'])
            : null;
        final currentDay = data['currentDay'] ?? 1;
        final claimedDays = List<int>.from(data['claimedDays'] ?? []);

        // 보상 상태 복원
        final updatedRewards = state.rewards.map((reward) {
          return DailyReward(
            day: reward.day,
            xpReward: reward.xpReward,
            heartsReward: reward.heartsReward,
            isClaimed: claimedDays.contains(reward.day),
            isStreakBonus: reward.isStreakBonus,
          );
        }).toList();

        state = state.copyWith(
          rewards: updatedRewards,
          lastClaimDate: lastClaimDate,
          currentDay: currentDay,
          canClaimToday: _checkCanClaimToday(lastClaimDate),
        );

        Logger.info(
            'Daily reward state loaded: day $currentDay, can claim: ${state.canClaimToday}');
      }
    } catch (e) {
      Logger.error('Failed to load daily reward state', error: e);
    }
  }

  /// 상태 저장
  Future<void> _saveState() async {
    try {
      final claimedDays =
          state.rewards.where((r) => r.isClaimed).map((r) => r.day).toList();

      await _storage.saveObject(_storageKey, {
        'lastClaimDate': state.lastClaimDate?.toIso8601String(),
        'currentDay': state.currentDay,
        'claimedDays': claimedDays,
      });

      Logger.info('Daily reward state saved');
    } catch (e) {
      Logger.error('Failed to save daily reward state', error: e);
    }
  }

  /// 오늘 클레임 가능 여부 확인
  bool _checkCanClaimToday(DateTime? lastClaimDate) {
    if (lastClaimDate == null) return true;

    final now = DateTime.now();
    final lastClaim = DateTime(
      lastClaimDate.year,
      lastClaimDate.month,
      lastClaimDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    return today.isAfter(lastClaim);
  }

  /// 데일리 리워드 클레임
  Future<bool> claimDailyReward() async {
    if (!state.canClaimToday) {
      Logger.warning('Cannot claim reward: already claimed today');
      return false;
    }

    try {
      final currentReward = state.rewards[state.currentDay - 1];

      // 보상 지급
      _userProvider.addXP(currentReward.xpReward);
      if (currentReward.heartsReward > 0) {
        _userProvider.addHearts(currentReward.heartsReward);
      }

      // 상태 업데이트
      final updatedRewards = state.rewards.map((reward) {
        if (reward.day == state.currentDay) {
          return DailyReward(
            day: reward.day,
            xpReward: reward.xpReward,
            heartsReward: reward.heartsReward,
            isClaimed: true,
            isStreakBonus: reward.isStreakBonus,
          );
        }
        return reward;
      }).toList();

      // 다음 날로 이동 (7일 주기)
      final nextDay = state.currentDay >= 7 ? 1 : state.currentDay + 1;

      // 7일 완료 시 모든 보상 초기화
      final finalRewards = nextDay == 1
          ? updatedRewards.map((r) => DailyReward(
                day: r.day,
                xpReward: r.xpReward,
                heartsReward: r.heartsReward,
                isClaimed: false,
                isStreakBonus: r.isStreakBonus,
              )).toList()
          : updatedRewards;

      state = state.copyWith(
        rewards: finalRewards,
        lastClaimDate: DateTime.now(),
        currentDay: nextDay,
        canClaimToday: false,
      );

      await _saveState();

      Logger.info(
        'Daily reward claimed: day ${currentReward.day}, XP: ${currentReward.xpReward}, Hearts: ${currentReward.heartsReward}',
      );

      return true;
    } catch (e) {
      Logger.error('Failed to claim daily reward', error: e);
      return false;
    }
  }

  /// 상태 새로고침 (날짜 변경 체크)
  void refreshState() {
    final canClaim = _checkCanClaimToday(state.lastClaimDate);
    if (canClaim != state.canClaimToday) {
      state = state.copyWith(canClaimToday: canClaim);
      Logger.info('Daily reward state refreshed: can claim = $canClaim');
    }
  }

  /// 현재 보상 가져오기
  DailyReward get currentReward => state.rewards[state.currentDay - 1];

  /// 다음 보상 가져오기
  DailyReward get nextReward {
    final nextDay = state.currentDay >= 7 ? 1 : state.currentDay + 1;
    return state.rewards[nextDay - 1];
  }
}

/// Provider 정의
final dailyRewardProvider =
    StateNotifierProvider<DailyRewardProvider, DailyRewardState>((ref) {
  final userProvider = ref.watch(userProvider.notifier);
  return DailyRewardProvider(userProvider);
});

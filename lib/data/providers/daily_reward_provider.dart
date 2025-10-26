import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_reward.dart';
import 'user_provider.dart';
import '../../shared/utils/logger.dart';
import '../../data/services/local_storage_service.dart';

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
  final Ref _ref;
  final LocalStorageService _storage = LocalStorageService();

  static const String _storageKey = 'daily_rewards_state';

  DailyRewardProvider(this._ref)
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
    // DailyReward 모델에서 정의된 weeklyRewards 사용
    final rewards = DailyReward.weeklyRewards;

    state = state.copyWith(rewards: rewards);
    Logger.info('Daily rewards initialized: 7 days');
  }

  /// 상태 로드
  Future<void> _loadState() async {
    try {
      final data = await _storage.loadMap(_storageKey);
      if (data != null) {
        final lastClaimDate = data['lastClaimDate'] != null
            ? DateTime.parse(data['lastClaimDate'])
            : null;
        final currentDay = data['currentDay'] ?? 1;

        state = state.copyWith(
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
      await _storage.saveMap(_storageKey, {
        'lastClaimDate': state.lastClaimDate?.toIso8601String(),
        'currentDay': state.currentDay,
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

      // 보상 지급 (타입에 따라 처리)
      if (currentReward.type == RewardType.xp) {
        await _ref.read(userProvider.notifier).addXP(currentReward.amount);
      } else if (currentReward.type == RewardType.hearts) {
        await _ref.read(userProvider.notifier).addHearts(currentReward.amount);
      }

      // 다음 날로 이동 (7일 주기)
      final nextDay = state.currentDay >= 7 ? 1 : state.currentDay + 1;

      state = state.copyWith(
        lastClaimDate: DateTime.now(),
        currentDay: nextDay,
        canClaimToday: false,
      );

      await _saveState();

      Logger.info(
        'Daily reward claimed: day ${currentReward.day}, type: ${currentReward.type.name}, amount: ${currentReward.amount}',
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
  return DailyRewardProvider(ref);
});

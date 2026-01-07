import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gamification/daily_reward.dart';
import '../user/user_provider.dart';
import '../base/base_notifier.dart';

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

  Map<String, dynamic> toJson() => {
        'lastClaimDate': lastClaimDate?.toIso8601String(),
        'currentDay': currentDay,
      };

  factory DailyRewardState.fromJson(
    Map<String, dynamic> json,
    List<DailyReward> rewards,
  ) {
    final lastClaimDate = json['lastClaimDate'] != null
        ? DateTime.parse(json['lastClaimDate'])
        : null;
    final currentDay = json['currentDay'] ?? 1;

    return DailyRewardState(
      rewards: rewards,
      lastClaimDate: lastClaimDate,
      currentDay: currentDay,
      canClaimToday: _checkCanClaimToday(lastClaimDate),
    );
  }

  static bool _checkCanClaimToday(DateTime? lastClaimDate) {
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
}

/// 데일리 리워드 Provider (BaseNotifier 최적화 버전)
///
/// **개선사항:**
/// - BaseNotifier 상속으로 중복 로깅 제거
/// - executeWithErrorHandling로 try-catch 자동화
/// - updateAndSave로 상태 업데이트 + 저장 단순화
class DailyRewardProvider extends BaseNotifier<DailyRewardState> {
  final Ref _ref;

  static const String _storageKey = 'daily_rewards_state';

  DailyRewardProvider(this._ref)
      : super(
          const DailyRewardState(
            rewards: [],
            currentDay: 1,
            canClaimToday: true,
          ),
          'DailyRewardProvider',
        ) {
    _initializeRewards();
    _loadState();
  }

  /// 7일 보상 초기화
  void _initializeRewards() {
    final rewards = DailyReward.weeklyRewards;
    state = state.copyWith(rewards: rewards);
    logInfo('Daily rewards initialized: 7 days');
  }

  /// 상태 로드
  Future<void> _loadState() async {
    final data = await loadFromStorage(_storageKey);
    if (data != null) {
      state = DailyRewardState.fromJson(data, state.rewards);
      logInfo(
          'Daily reward state loaded: day ${state.currentDay}, can claim: ${state.canClaimToday}');
    }
  }

  /// 데일리 리워드 클레임
  Future<bool> claimDailyReward() async {
    return await executeWithErrorHandling(
          () async {
            if (!state.canClaimToday) {
              logWarning('Cannot claim reward: already claimed today');
              return false;
            }

            final currentReward = state.rewards[state.currentDay - 1];

            // 보상 지급 (타입에 따라 처리)
            if (currentReward.type == RewardType.xp) {
              await _ref
                  .read(userProvider.notifier)
                  .addXP(currentReward.amount);
            } else if (currentReward.type == RewardType.hearts) {
              await _ref
                  .read(userProvider.notifier)
                  .addHearts(currentReward.amount);
            }

            // 다음 날로 이동 (7일 주기)
            final nextDay = state.currentDay >= 7 ? 1 : state.currentDay + 1;

            await updateAndSave(
              state.copyWith(
                lastClaimDate: DateTime.now(),
                currentDay: nextDay,
                canClaimToday: false,
              ),
              saveKey: _storageKey,
              toJson: (s) => s.toJson(),
            );

            logInfo(
              'Daily reward claimed: day ${currentReward.day}, type: ${currentReward.type.name}, amount: ${currentReward.amount}',
            );

            return true;
          },
          errorMessage: 'Failed to claim daily reward',
          fallback: () => false,
        ) ??
        false;
  }

  /// 상태 새로고침 (날짜 변경 체크)
  void refreshState() {
    final canClaim = DailyRewardState._checkCanClaimToday(state.lastClaimDate);
    if (canClaim != state.canClaimToday) {
      state = state.copyWith(canClaimToday: canClaim);
      logInfo('Daily reward state refreshed: can claim = $canClaim');
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

// 🎁 Daily Reward Provider
//
// 일일 보상 시스템 상태 관리.
// Firestore와 연동하여 7일 주기 보상 사이클을 관리합니다.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../infrastructure/firebase_providers.dart';
import '../user/user_provider.dart';
import '../../models/daily_reward_model.dart';

// ========================================
// State
// ========================================

/// 일일 보상 상태
class DailyRewardState {
  final int currentDay; // 1~7
  final bool hasClaimedToday;
  final DateTime? lastClaimDate;
  final List<DailyRewardModel> rewards;
  final bool isLoading;
  final bool isClaiming;

  const DailyRewardState({
    this.currentDay = 1,
    this.hasClaimedToday = false,
    this.lastClaimDate,
    this.rewards = const [],
    this.isLoading = true,
    this.isClaiming = false,
  });

  /// 다이얼로그를 표시해야 하는지 여부
  bool get shouldShowDialog => !isLoading && !hasClaimedToday;

  /// 보상 수령 가능 여부
  bool get canClaim => !isLoading && !hasClaimedToday && !isClaiming && rewards.isNotEmpty;

  DailyRewardState copyWith({
    int? currentDay,
    bool? hasClaimedToday,
    DateTime? lastClaimDate,
    List<DailyRewardModel>? rewards,
    bool? isLoading,
    bool? isClaiming,
  }) {
    return DailyRewardState(
      currentDay: currentDay ?? this.currentDay,
      hasClaimedToday: hasClaimedToday ?? this.hasClaimedToday,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      rewards: rewards ?? this.rewards,
      isLoading: isLoading ?? this.isLoading,
      isClaiming: isClaiming ?? this.isClaiming,
    );
  }
}

// ========================================
// Notifier
// ========================================

/// 일일 보상 상태 관리 Notifier
class DailyRewardNotifier extends StateNotifier<DailyRewardState> {
  final Ref ref;

  DailyRewardNotifier(this.ref) : super(const DailyRewardState()) {
    _checkDailyReward();
  }

  /// Firestore에서 일일 보상 상태를 확인하고 초기화
  Future<void> _checkDailyReward() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        AppLogger.warning('No user logged in, skipping daily reward check', tag: 'DailyReward');
        state = state.copyWith(isLoading: false);
        return;
      }

      final uid = currentUser.uid;
      final firestore = ref.read(firestoreProvider);

      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('dailyReward')
          .doc('current')
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (!doc.exists || doc.data() == null) {
        // 보상 기록이 없으면 Day 1부터 시작
        AppLogger.info('No daily reward record found, starting from Day 1', tag: 'DailyReward');
        _updateStateWithRewards(currentDay: 1, hasClaimedToday: false, lastClaimDate: null);
        return;
      }

      final data = doc.data()!;
      final lastClaimTimestamp = data['lastClaimDate'] as Timestamp?;
      final savedDay = (data['currentDay'] as int?) ?? 1;

      if (lastClaimTimestamp == null) {
        // 마지막 수령일이 없으면 첫 수령
        _updateStateWithRewards(currentDay: savedDay, hasClaimedToday: false, lastClaimDate: null);
        return;
      }

      final lastClaimDate = lastClaimTimestamp.toDate();
      final lastClaimDay = DateTime(lastClaimDate.year, lastClaimDate.month, lastClaimDate.day);
      final dayDifference = today.difference(lastClaimDay).inDays;

      if (dayDifference == 0) {
        // 오늘 이미 수령함
        _updateStateWithRewards(
          currentDay: savedDay,
          hasClaimedToday: true,
          lastClaimDate: lastClaimDate,
        );
      } else if (dayDifference == 1) {
        // 어제 수령함 -> 연속 출석, 다음 날로 진행
        final nextDay = savedDay >= 7 ? 1 : savedDay + 1;
        _updateStateWithRewards(
          currentDay: nextDay,
          hasClaimedToday: false,
          lastClaimDate: lastClaimDate,
        );
      } else {
        // 2일 이상 빠짐 -> Day 1로 초기화
        AppLogger.info('Streak broken, resetting to Day 1', tag: 'DailyReward');
        _updateStateWithRewards(
          currentDay: 1,
          hasClaimedToday: false,
          lastClaimDate: lastClaimDate,
        );
      }
    } catch (e, st) {
      AppLogger.error('Failed to check daily reward', tag: 'DailyReward', error: e, stackTrace: st);
      // 오류 시에도 기본 보상 목록은 표시
      _updateStateWithRewards(currentDay: 1, hasClaimedToday: false, lastClaimDate: null);
    }
  }

  /// 수동 새로고침 (사용자 로그인 후 호출용)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _checkDailyReward();
  }

  /// 보상 목록과 함께 상태 업데이트
  void _updateStateWithRewards({
    required int currentDay,
    required bool hasClaimedToday,
    required DateTime? lastClaimDate,
  }) {
    final weeklyRewards = DailyRewardModel.getWeeklyRewards();

    // 이미 수령한 날은 isClaimed = true 처리
    final rewards = weeklyRewards.map((reward) {
      if (hasClaimedToday) {
        // 오늘 수령한 경우: currentDay까지 claimed
        return reward.copyWith(isClaimed: reward.day <= currentDay);
      } else {
        // 오늘 아직 수령 안 한 경우: currentDay 이전까지 claimed
        return reward.copyWith(isClaimed: reward.day < currentDay);
      }
    }).toList();

    state = DailyRewardState(
      currentDay: currentDay,
      hasClaimedToday: hasClaimedToday,
      lastClaimDate: lastClaimDate,
      rewards: rewards,
      isLoading: false,
    );
  }

  /// 보상 수령
  Future<bool> claimReward() async {
    if (state.hasClaimedToday || state.isClaiming) {
      AppLogger.warning('Already claimed today or claiming in progress', tag: 'DailyReward');
      return false;
    }

    state = state.copyWith(isClaiming: true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        AppLogger.error('No user logged in for claim', tag: 'DailyReward');
        state = state.copyWith(isClaiming: false);
        return false;
      }

      final uid = currentUser.uid;
      final firestore = ref.read(firestoreProvider);
      final currentDay = state.currentDay;

      // 현재 날의 보상 가져오기
      final weeklyRewards = DailyRewardModel.getWeeklyRewards();
      final todayReward = weeklyRewards.firstWhere((r) => r.day == currentDay);

      AppLogger.info(
        'Claiming daily reward',
        tag: 'DailyReward',
        data: {'day': currentDay, 'type': todayReward.rewardType.name, 'amount': todayReward.amount},
      );

      // 보상 지급
      switch (todayReward.rewardType) {
        case RewardType.gems:
          await ref.read(userProvider.notifier).addGems(todayReward.amount);
          break;
        case RewardType.xp:
          await ref.read(userProvider.notifier).addXp(todayReward.amount);
          break;
        case RewardType.hearts:
          // 하트 추가: 현재 하트 + 보상 수량
          final user = ref.read(userProvider);
          if (user != null) {
            final newHearts = user.hearts + todayReward.amount;
            final maxHearts = user.maxHearts;
            final clampedHearts = newHearts > maxHearts ? maxHearts : newHearts;

            await firestore.collection('users').doc(uid).update({
              'hearts': clampedHearts,
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });

            // UserProvider 상태도 업데이트를 위해 다시 로드
            await ref.read(userProvider.notifier).loadUser(uid);
          }
          break;
      }

      // Firestore에 수령 기록 저장
      final now = DateTime.now();
      await firestore
          .collection('users')
          .doc(uid)
          .collection('dailyReward')
          .doc('current')
          .set({
        'currentDay': currentDay,
        'lastClaimDate': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      // 상태 업데이트
      final updatedRewards = state.rewards.map((reward) {
        if (reward.day == currentDay) {
          return reward.copyWith(isClaimed: true);
        }
        return reward;
      }).toList();

      state = state.copyWith(
        hasClaimedToday: true,
        lastClaimDate: now,
        rewards: updatedRewards,
        isClaiming: false,
      );

      AppLogger.info('Daily reward claimed successfully', tag: 'DailyReward');
      return true;
    } catch (e, st) {
      AppLogger.error('Failed to claim daily reward', tag: 'DailyReward', error: e, stackTrace: st);
      state = state.copyWith(isClaiming: false);
      return false;
    }
  }
}

// ========================================
// Provider
// ========================================

/// 일일 보상 Provider
final dailyRewardProvider = StateNotifierProvider<DailyRewardNotifier, DailyRewardState>(
  (ref) => DailyRewardNotifier(ref),
);

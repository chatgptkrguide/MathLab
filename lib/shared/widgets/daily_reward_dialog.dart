// 🎁 Daily Reward Dialog
//
// 일일 보상 다이얼로그 위젯.
// 7일 보상 캘린더와 보상 수령 버튼을 표시합니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/daily_reward_model.dart';
import '../../data/providers/gamification/daily_reward_provider.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_text_styles.dart';

/// 일일 보상 다이얼로그
class DailyRewardDialog extends ConsumerWidget {
  const DailyRewardDialog({super.key});

  /// 다이얼로그 표시
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DailyRewardDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardState = ref.watch(dailyRewardProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius24),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀 + 진행 — 왼쪽 정렬 (균일 가운데 배치 탈피)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '일일 보상',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${rewardState.currentDay}/7일째',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing20),

                // 7일 보상 그리드
                _buildRewardGrid(rewardState),

                const SizedBox(height: AppDimensions.spacing24),

                // 보상 받기 버튼
                _buildClaimButton(context, ref, rewardState),

                const SizedBox(height: AppDimensions.spacing12),

                // 닫기 버튼 (항상 표시)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    rewardState.hasClaimedToday ? '닫기' : '나중에 받기',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 7일 보상 — 위 3개 + 가운데 3개 + 맨 아래 Day 7 가로 wide 카드.
  /// (4×2 균일 grid 대신 의도적 비대칭 — Day 7 보상이 시각적으로 도드라짐)
  Widget _buildRewardGrid(DailyRewardState rewardState) {
    final rewards = rewardState.rewards;
    if (rewards.isEmpty) {
      return const SizedBox(height: 200);
    }

    Widget cell(int dayIndex) {
      final reward = rewards[dayIndex];
      final isCurrentDay = reward.day == rewardState.currentDay;
      final isClaimed = reward.isClaimed;
      final isFuture = reward.day > rewardState.currentDay && !isClaimed;
      return _buildRewardDay(
        reward: reward,
        isCurrentDay: isCurrentDay,
        isClaimed: isClaimed,
        isFuture: isFuture,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1~3일 — 첫 줄 3개
        SizedBox(
          height: 92,
          child: Row(
            children: [
              Expanded(child: cell(0)),
              const SizedBox(width: 8),
              Expanded(child: cell(1)),
              const SizedBox(width: 8),
              Expanded(child: cell(2)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 4~6일 — 둘째 줄 3개
        SizedBox(
          height: 92,
          child: Row(
            children: [
              Expanded(child: cell(3)),
              const SizedBox(width: 8),
              Expanded(child: cell(4)),
              const SizedBox(width: 8),
              Expanded(child: cell(5)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 7일 — 가로 wide 카드 (특별 보상)
        SizedBox(
          height: 88,
          child: cell(6),
        ),
      ],
    );
  }

  /// 개별 보상 날짜 카드.
  /// border-left accent 패턴 통일 (앱 전반 디자인 언어와 같이).
  /// 그라데이션 제거 — 단색 배경 + 강조선만으로 상태 표현.
  Widget _buildRewardDay({
    required DailyRewardModel reward,
    required bool isCurrentDay,
    required bool isClaimed,
    required bool isFuture,
  }) {
    final isSpecialDay = reward.day == 7;

    // 상태별 색·강조선
    final Color accentColor;
    final Color bgColor;
    if (isCurrentDay) {
      accentColor = AppColors.gold;
      bgColor = AppColors.gold.withValues(alpha: 0.06);
    } else if (isClaimed) {
      accentColor = AppColors.tealGreen;
      bgColor = AppColors.tealGreen.withValues(alpha: 0.06);
    } else {
      accentColor = Colors.grey.shade300;
      bgColor = Colors.grey.shade50;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: isCurrentDay ? 4 : 3,
          ),
        ),
        boxShadow: isCurrentDay
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: isFuture ? 0.45 : 1.0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isSpecialDay ? 16 : 8,
                isSpecialDay ? 12 : 8,
                isSpecialDay ? 16 : 8,
                isSpecialDay ? 12 : 8,
              ),
              child: isSpecialDay
                  ? _specialDayContent(reward, isCurrentDay)
                  : _regularDayContent(reward, isCurrentDay),
            ),
          ),
          // 수령 완료 체크마크
          if (isClaimed)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.tealGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _regularDayContent(DailyRewardModel reward, bool isCurrentDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Day ${reward.day}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isCurrentDay ? AppColors.gold : AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
        Text(reward.emoji, style: const TextStyle(fontSize: 22)),
        Text(
          reward.label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Day 7 특별 보상 — 가로 wide + 큰 이모지 + 강조 텍스트
  Widget _specialDayContent(DailyRewardModel reward, bool isCurrentDay) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(reward.emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Day 7 · 특별 보상',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCurrentDay
                      ? AppColors.gold
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reward.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 보상 받기 / 수령 완료 버튼
  Widget _buildClaimButton(
    BuildContext context,
    WidgetRef ref,
    DailyRewardState rewardState,
  ) {
    if (rewardState.hasClaimedToday) {
      // 이미 수령 완료
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: Text(
          '오늘의 보상을 받았습니다!',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    if (rewardState.isLoading) {
      // 로딩 중
      return const SizedBox(
        width: double.infinity,
        height: 52,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 수령 가능
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: rewardState.canClaim
            ? () async {
                final success = await ref
                    .read(dailyRewardProvider.notifier)
                    .claimReward();

                if (success && context.mounted) {
                  // 인위적 지연 제거 — claimReward 자체가 이미 1 RTT 대기.
                  // 사용자가 "보상 받고 화면 닫힘이 느리다"고 보고한 핵심 원인.
                  Navigator.of(context).pop();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          elevation: 2,
        ),
        child: rewardState.isClaiming
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '보상 받기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  if (rewardState.rewards.isNotEmpty)
                    Text(
                      rewardState.rewards
                          .firstWhere(
                            (r) => r.day == rewardState.currentDay,
                            orElse: () => rewardState.rewards.first,
                          )
                          .emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                ],
              ),
      ),
    );
  }
}

// 🎁 Daily Reward Dialog
//
// 일일 보상 다이얼로그 위젯.
// 7일 보상 캘린더와 보상 수령 버튼을 표시합니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/daily_reward_model.dart';
import '../../data/providers/daily_reward_provider.dart';
import '../../shared/constants/figma_colors.dart';

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
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀
            const Text(
              '🔥 일일 보상',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: FigmaColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Day ${rewardState.currentDay} / 7',
              style: const TextStyle(
                fontSize: 14,
                color: FigmaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 7일 보상 그리드
            _buildRewardGrid(rewardState),

            const SizedBox(height: 24),

            // 보상 받기 버튼
            _buildClaimButton(context, ref, rewardState),

            const SizedBox(height: 12),

            // 닫기 버튼 (이미 수령한 경우)
            if (rewardState.hasClaimedToday)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '닫기',
                  style: TextStyle(
                    color: FigmaColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 7일 보상 그리드
  Widget _buildRewardGrid(DailyRewardState rewardState) {
    final rewards = rewardState.rewards;
    if (rewards.isEmpty) {
      // 로딩 중이면 기본 보상 표시
      return const SizedBox(height: 200);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final isCurrentDay = reward.day == rewardState.currentDay;
        final isClaimed = reward.isClaimed;
        final isFuture = reward.day > rewardState.currentDay && !isClaimed;

        return _buildRewardDay(
          reward: reward,
          isCurrentDay: isCurrentDay,
          isClaimed: isClaimed,
          isFuture: isFuture,
        );
      },
    );
  }

  /// 개별 보상 날짜 카드
  Widget _buildRewardDay({
    required DailyRewardModel reward,
    required bool isCurrentDay,
    required bool isClaimed,
    required bool isFuture,
  }) {
    // 7일차는 특별 보상 (큰 보상)
    final isSpecialDay = reward.day == 7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isClaimed
            ? FigmaColors.tealGreen.withValues(alpha: 0.1)
            : isCurrentDay
                ? FigmaColors.gold.withValues(alpha: 0.15)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentDay
              ? FigmaColors.gold
              : isClaimed
                  ? FigmaColors.tealGreen
                  : Colors.grey.shade200,
          width: isCurrentDay ? 2.5 : 1,
        ),
        boxShadow: isCurrentDay
            ? [
                BoxShadow(
                  color: FigmaColors.gold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 메인 콘텐츠
          Positioned.fill(
            child: Opacity(
              opacity: isFuture ? 0.4 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 날짜
                      Text(
                        'Day ${reward.day}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCurrentDay
                              ? FigmaColors.gold
                              : FigmaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 보상 이모지
                      Text(
                        reward.emoji,
                        style: TextStyle(
                          fontSize: isSpecialDay ? 24 : 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 보상 라벨
                      Text(
                        reward.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: FigmaColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 수령 완료 체크마크 오버레이
          if (isClaimed)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: FigmaColors.tealGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '오늘의 보상을 받았습니다!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FigmaColors.textSecondary,
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
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: FigmaColors.gold,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(width: 8),
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

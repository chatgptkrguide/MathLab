import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_reward.dart';
import '../../data/providers/daily_reward_provider.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../shared/widgets/buttons/duolingo_button.dart';

/// 데일리 리워드 화면
class DailyRewardScreen extends ConsumerStatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  ConsumerState<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends ConsumerState<DailyRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  bool _isClaimingReward = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 상태 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyRewardProvider.notifier).refreshState();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_isClaimingReward) return;

    setState(() {
      _isClaimingReward = true;
    });

    await AppHapticFeedback.success();

    final success = await ref.read(dailyRewardProvider.notifier).claimDailyReward();

    if (success && mounted) {
      _confettiController.forward();

      // 성공 다이얼로그 표시
      await _showSuccessDialog();
    }

    if (mounted) {
      setState(() {
        _isClaimingReward = false;
      });
    }
  }

  Future<void> _showSuccessDialog() async {
    final currentReward = ref.read(dailyRewardProvider.notifier).currentReward;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        backgroundColor: AppColors.background,
        title: const Text(
          '🎉 보상 획득!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentReward.type == RewardType.xp) ...[
              _buildRewardItem(
                icon: '⭐',
                label: 'XP',
                value: '+${currentReward.amount}',
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.spacingS),
            ],
            if (currentReward.type == RewardType.hearts) ...[
              _buildRewardItem(
                icon: '❤️',
                label: '하트',
                value: '+${currentReward.amount}',
                color: AppColors.error,
              ),
            ],
            if (currentReward.day == 7) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.goldGradient,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Text(
                  '🔥 7일 연속 보너스!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: DuolingoButton(
              text: '확인',
              onPressed: () {
                Navigator.of(context).pop();
              },
              gradientColors: AppColors.greenGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyRewardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '데일리 리워드',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () async {
            await AppHapticFeedback.lightImpact();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '매일 접속하고 보상을 받으세요!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    '${state.currentDay}일차',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 보상 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                itemCount: state.rewards.length,
                itemBuilder: (context, index) {
                  final reward = state.rewards[index];
                  final isCurrentDay = reward.day == state.currentDay;
                  final isClaimed = reward.day < state.currentDay ||
                                    (reward.day == state.currentDay && !state.canClaimToday);
                  final isLocked = reward.day > state.currentDay;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                    child: _DayRewardCard(
                      reward: reward,
                      isCurrentDay: isCurrentDay,
                      isClaimed: isClaimed,
                      isLocked: isLocked,
                    ),
                  );
                },
              ),
            ),

            // 클레임 버튼
            if (state.canClaimToday)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: DuolingoButton(
                  text: _isClaimingReward ? '받는 중...' : '오늘의 보상 받기',
                  onPressed: _isClaimingReward ? null : _claimReward,
                  isEnabled: !_isClaimingReward,
                  gradientColors: AppColors.greenGradient,
                  icon: Icons.card_giftcard,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.disabled.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Text(
                        '오늘의 보상을 이미 받았어요!',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 일별 보상 카드
class _DayRewardCard extends StatelessWidget {
  final dynamic reward;
  final bool isCurrentDay;
  final bool isClaimed;
  final bool isLocked;

  const _DayRewardCard({
    required this.reward,
    required this.isCurrentDay,
    required this.isClaimed,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isCurrentDay ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isCurrentDay
              ? AppColors.primary
              : isClaimed
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.borderLight,
          width: isCurrentDay ? 2 : 1,
        ),
        boxShadow: [
          if (isCurrentDay)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Day 번호
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isClaimed
                  ? AppColors.success
                  : isLocked
                      ? AppColors.disabled
                      : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isClaimed
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      '${reward.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppDimensions.spacingM),

          // 보상 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reward.day}일차',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isClaimed || isLocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Row(
                  children: [
                    Text(reward.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      reward.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (reward.day == 7) ...[
                  const SizedBox(height: AppDimensions.spacingXS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.goldGradient,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: const Text(
                      '🔥 보너스',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 상태 아이콘
          if (isCurrentDay && !isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: const Text(
                '오늘',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else if (isClaimed)
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 32,
            )
          else if (isLocked)
            const Icon(
              Icons.lock_outline,
              color: AppColors.disabled,
              size: 32,
            ),
        ],
      ),
    );
  }
}

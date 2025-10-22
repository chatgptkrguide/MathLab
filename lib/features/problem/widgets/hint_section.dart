import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/problem.dart';
import '../../../data/providers/hint_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/utils/haptic_feedback.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';

/// 힌트 섹션 위젯
/// 문제 풀이 중 힌트를 표시하고 잠금 해제하는 UI
class HintSection extends ConsumerWidget {
  final Problem problem;

  const HintSection({
    super.key,
    required this.problem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 힌트가 없으면 표시하지 않음
    if (problem.hints == null || problem.hints!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hintState = ref.watch(hintProvider);
    final user = ref.watch(userProvider);
    final userXP = user?.xp ?? 0;

    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(top: AppDimensions.spacingL),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.mathPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: AppColors.mathPurple.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.mathPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: const Text(
                    '💡',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '힌트',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mathPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getUnlockedCount(ref)}/${problem.hints!.length} 잠금 해제',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 현재 XP 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mathOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔶', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$userXP XP',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mathOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // 힌트 리스트
            ...List.generate(
              problem.hints!.length,
              (index) => _HintItem(
                problem: problem,
                hintIndex: index,
                hintText: problem.hints![index],
                isUnlocked: ref
                    .read(hintProvider.notifier)
                    .isHintUnlocked(problem.id, index),
                canUnlock: userXP >= HintProvider.hintCost,
                onUnlock: () => _unlockHint(context, ref, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getUnlockedCount(WidgetRef ref) {
    int count = 0;
    for (int i = 0; i < problem.hints!.length; i++) {
      if (ref.read(hintProvider.notifier).isHintUnlocked(problem.id, i)) {
        count++;
      }
    }
    return count;
  }

  Future<void> _unlockHint(
    BuildContext context,
    WidgetRef ref,
    int hintIndex,
  ) async {
    final success = await ref
        .read(hintProvider.notifier)
        .unlockHint(problem, hintIndex);

    if (success) {
      await AppHapticFeedback.success();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  '힌트가 잠금 해제되었습니다! (-${HintProvider.hintCost} XP)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await AppHapticFeedback.error();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('❌', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  'XP가 부족합니다 (필요: ${HintProvider.hintCost} XP)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// 개별 힌트 아이템
class _HintItem extends StatelessWidget {
  final Problem problem;
  final int hintIndex;
  final String hintText;
  final bool isUnlocked;
  final bool canUnlock;
  final VoidCallback onUnlock;

  const _HintItem({
    required this.problem,
    required this.hintIndex,
    required this.hintText,
    required this.isUnlocked,
    required this.canUnlock,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.white
            : AppColors.disabled.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: isUnlocked
              ? AppColors.mathPurple.withOpacity(0.3)
              : AppColors.borderLight,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: isUnlocked ? _buildUnlockedHint() : _buildLockedHint(),
    );
  }

  Widget _buildUnlockedHint() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 힌트 번호
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '힌트 ${hintIndex + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        // 힌트 내용
        Text(
          hintText,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedHint() {
    return Row(
      children: [
        // 자물쇠 아이콘
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.disabled.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: const Icon(
            Icons.lock,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        // 힌트 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '힌트 ${hintIndex + 1}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '잠금 해제하려면 ${HintProvider.hintCost} XP가 필요합니다',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        // 잠금 해제 버튼
        ElevatedButton(
          onPressed: canUnlock ? onUnlock : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canUnlock
                ? AppColors.mathPurple
                : AppColors.disabled,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔶', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${HintProvider.hintCost}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

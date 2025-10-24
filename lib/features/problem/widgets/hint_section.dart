import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/problem.dart';
import '../../../data/providers/hint_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/utils/haptic_feedback.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';

/// 힌트 섹션 위젯
/// 문제 풀이 중 힌트를 표시하고 잠금 해제하는 UI (접기/펼치기 가능)
class HintSection extends ConsumerStatefulWidget {
  final Problem problem;

  const HintSection({
    super.key,
    required this.problem,
  });

  @override
  ConsumerState<HintSection> createState() => _HintSectionState();
}

class _HintSectionState extends ConsumerState<HintSection> {
  bool _isExpanded = false; // 기본적으로 접혀있음

  @override
  Widget build(BuildContext context) {
    // 힌트가 없으면 표시하지 않음
    if (widget.problem.hints == null || widget.problem.hints!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hintState = ref.watch(hintProvider);
    final user = ref.watch(userProvider);
    final userXP = user?.xp ?? 0;

    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(top: AppDimensions.spacingM),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (클릭 가능)
            InkWell(
              onTap: () async {
                await AppHapticFeedback.selectionClick();
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '힌트',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_getUnlockedCount()}/${widget.problem.hints!.length} 사용',
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
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mathOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('🔶', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$userXP',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mathOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  // 펼침/접기 아이콘
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 힌트 리스트 (애니메이션)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: AppDimensions.spacingM),
                        ...List.generate(
                          widget.problem.hints!.length,
                          (index) {
                            // hintState를 통해 unlock 여부 확인
                            final hintKey = '${widget.problem.id}_$index';
                            final isUnlocked = hintState.unlockedHints.contains(hintKey);

                            return _HintItem(
                              problem: widget.problem,
                              hintIndex: index,
                              hintText: widget.problem.hints![index],
                              isUnlocked: isUnlocked,
                              canUnlock: userXP >= HintProvider.hintCost,
                              onUnlock: () => _unlockHint(context, index),
                            );
                          },
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  int _getUnlockedCount() {
    final hintState = ref.watch(hintProvider);
    int count = 0;
    for (int i = 0; i < widget.problem.hints!.length; i++) {
      // hintState를 통해 unlock 여부 확인
      final hintKey = '${widget.problem.id}_$i';
      if (hintState.unlockedHints.contains(hintKey)) {
        count++;
      }
    }
    return count;
  }

  Future<void> _unlockHint(
    BuildContext context,
    int hintIndex,
  ) async {
    final success = await ref
        .read(hintProvider.notifier)
        .unlockHint(widget.problem, hintIndex);

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
                    color: AppColors.surface,
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
                    color: AppColors.surface,
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
            ? AppColors.surface
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 체크 아이콘
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.successGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.surface,
            size: 16,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        // 힌트 내용
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '힌트 ${hintIndex + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hintText,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedHint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 자물쇠 아이콘
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary,
            size: 14,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        // 힌트 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '힌트 ${hintIndex + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${HintProvider.hintCost} XP 필요',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // 잠금 해제 버튼
        ElevatedButton(
          onPressed: canUnlock ? onUnlock : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canUnlock
                ? AppColors.mathOrange
                : AppColors.disabled,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔶', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                '${HintProvider.hintCost}',
                style: const TextStyle(
                  fontSize: 13,
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

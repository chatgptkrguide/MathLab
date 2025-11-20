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

class _HintSectionState extends ConsumerState<HintSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false; // 기본적으로 접혀있음
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 힌트가 없으면 표시하지 않음
    if (widget.problem.hints.isEmpty) {
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
                  // 펄스 애니메이션이 적용된 lightbulb 아이콘
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.mathOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.mathOrange,
                        size: 24,
                      ),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_getUnlockedCount()}/${widget.problem.hints.length} 사용됨',
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
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mathOrange.withValues(alpha: 0.1),
                          AppColors.mathOrange.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mathOrange.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.diamond_outlined,
                          color: AppColors.mathOrange,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$userXP',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mathOrange,
                            fontSize: 15,
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
                          widget.problem.hints.length,
                          (index) {
                            // hintState를 통해 unlock 여부 확인
                            final hintKey = '${widget.problem.id}_$index';
                            final isUnlocked = hintState.unlockedHints.contains(hintKey);

                            return _HintItem(
                              problem: widget.problem,
                              hintIndex: index,
                              hintText: widget.problem.hints[index],
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
    for (int i = 0; i < widget.problem.hints.length; i++) {
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
                const Icon(
                  Icons.lightbulb,
                  color: AppColors.surface,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    '힌트가 잠금 해제되었습니다! (-${HintProvider.hintCost} XP)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
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
                const Icon(
                  Icons.error_outline,
                  color: AppColors.surface,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    'XP가 부족합니다 (필요: ${HintProvider.hintCost} XP)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
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
class _HintItem extends StatefulWidget {
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
  State<_HintItem> createState() => _HintItemState();
}

class _HintItemState extends State<_HintItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: widget.isUnlocked
            ? AppColors.surface
            : AppColors.disabled.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: widget.isUnlocked
              ? AppColors.mathPurple.withValues(alpha: 0.3)
              : AppColors.borderLight,
          width: widget.isUnlocked ? 2 : 1,
        ),
      ),
      child: widget.isUnlocked ? _buildUnlockedHint() : _buildLockedHint(),
    );
  }

  Widget _buildUnlockedHint() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
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
                  '힌트 ${widget.hintIndex + 1}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.hintText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedHint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 자물쇠 아이콘
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.disabled.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        // 힌트 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '힌트 ${widget.hintIndex + 1}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.diamond_outlined,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${HintProvider.hintCost} XP 필요',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 잠금 해제 버튼 (Duolingo 스타일 3D 버튼)
        ScaleTransition(
          scale: _buttonAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 3D 그림자
              if (widget.canUnlock)
                Positioned(
                  top: 3,
                  left: 0,
                  right: 0,
                  bottom: -3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.mathOrangeDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              // 메인 버튼
              Container(
                decoration: BoxDecoration(
                  color: widget.canUnlock
                      ? AppColors.mathOrange
                      : AppColors.disabled,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.canUnlock
                        ? AppColors.mathOrangeDark
                        : AppColors.disabled.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.canUnlock ? () async {
                      await _buttonController.forward();
                      await _buttonController.reverse();
                      widget.onUnlock();
                    } : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond,
                            color: AppColors.surface,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${HintProvider.hintCost}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/learning/problem.dart';
import '../../../data/providers/learning/hint_provider_optimized.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/utils/haptic_feedback.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import 'hint/widgets.dart';

/// 힌트 섹션 위젯 - 대폭 개편된 UX
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
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.35).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
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

    final hintState = ref.watch(hintProviderOptimized);
    final user = ref.watch(userProvider);
    final userXP = user?.xp ?? 0;
    final unlockedCount = _getUnlockedCount();
    final totalHints = widget.problem.hints.length;
    final hasUnlockedHints = unlockedCount > 0;

    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.mathOrange.withValues(alpha: 0.04),
              AppColors.mathOrange.withValues(alpha: 0.015),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.mathOrange.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mathOrange.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (클릭 가능) - 대폭 개선
            InkWell(
              onTap: () async {
                await AppHapticFeedback.selectionClick();
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 펄스 애니메이션이 적용된 lightbulb 아이콘 - 적절한 크기로 조정
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.mathOrange.withValues(alpha: _glowAnimation.value),
                                AppColors.mathOrange.withValues(alpha: _glowAnimation.value * 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mathOrange.withValues(alpha: _glowAnimation.value),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: const Icon(
                              Icons.lightbulb,
                              color: AppColors.mathOrange,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // 힌트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '💡 힌트',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (hasUnlockedHints)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unlockedCount개 사용중',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // 진행률 바
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.borderLight.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: unlockedCount / totalHints,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.mathOrange,
                                            AppColors.mathOrange.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$unlockedCount/$totalHints',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // XP 표시 - 더 크고 눈에 띄게
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.mathOrange.withValues(alpha: 0.15),
                            AppColors.mathOrange.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mathOrange.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond,
                            color: AppColors.mathOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$userXP',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.mathOrange,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 펼침/접기 아이콘 - 더 크게
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.mathOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.mathOrange,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 힌트 리스트 (애니메이션)
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          const Divider(
                            color: AppColors.mathOrange,
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            widget.problem.hints.length,
                            (index) {
                              final hintKey = '${widget.problem.id}_$index';
                              final isUnlocked =
                                  hintState.unlockedHints.contains(hintKey);

                              return HintItem(
                                problem: widget.problem,
                                hintIndex: index,
                                hintText: widget.problem.hints[index],
                                isUnlocked: isUnlocked,
                                canUnlock:
                                    userXP >= HintProviderOptimized.hintCost,
                                onUnlock: () => _unlockHint(context, index),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  int _getUnlockedCount() {
    final hintState = ref.watch(hintProviderOptimized);
    int count = 0;
    for (int i = 0; i < widget.problem.hints.length; i++) {
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
        .read(hintProviderOptimized.notifier)
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
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '힌트 잠금 해제!',
                        style: TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '-${HintProviderOptimized.hintCost} XP',
                        style: TextStyle(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
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
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'XP가 부족합니다',
                        style: TextStyle(
                          color: AppColors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${HintProviderOptimized.hintCost} XP 필요',
                        style: TextStyle(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}


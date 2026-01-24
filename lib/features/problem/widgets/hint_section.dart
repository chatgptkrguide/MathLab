import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/learning/problem.dart';
import '../../../data/providers/learning/hint_provider_optimized.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../logic/hint_unlock_handler.dart';
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
            // 헤더 (클릭 가능)
            HintHeader(
              pulseAnimation: _pulseAnimation,
              glowAnimation: _glowAnimation,
              unlockedCount: unlockedCount,
              totalHints: totalHints,
              userXP: userXP,
              isExpanded: _isExpanded,
              onToggle: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
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
                                onUnlock: () => HintUnlockHandler.unlockHint(
                                  context: context,
                                  ref: ref,
                                  problem: widget.problem,
                                  hintIndex: index,
                                ),
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
}


// Hearts Indicator Widget
//
// Displays animated hearts (with explicit count + recovery hint) and hint button.

import 'package:flutter/material.dart';
import '../../../data/models/problem/problem_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import 'hint_button.dart';

class HeartsIndicator extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;
  final int previousHearts;
  final bool isAnswerChecked;
  final AnimationController heartAnimController;
  final Animation<double> heartScaleAnim;

  // Hint-related
  final ProblemModel? currentProblem;
  final int unlockedHintCount;
  final int totalHints;
  final VoidCallback onHintTap;

  const HeartsIndicator({
    super.key,
    required this.currentHearts,
    this.maxHearts = 5,
    required this.previousHearts,
    required this.isAnswerChecked,
    required this.heartAnimController,
    required this.heartScaleAnim,
    required this.currentProblem,
    required this.unlockedHintCount,
    required this.totalHints,
    required this.onHintTap,
  });

  @override
  Widget build(BuildContext context) {
    final hints = currentProblem?.allHints ?? [];
    final missing = (maxHearts - currentHearts).clamp(0, maxHearts);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Hint button (only shown when hints exist)
              if (hints.isNotEmpty)
                HintButton(
                  unlockedCount: unlockedHintCount,
                  totalHints: totalHints,
                  xpCost: 0,
                  isEnabled: !isAnswerChecked,
                  onTap: onHintTap,
                )
              else
                const SizedBox(width: AppDimensions.spacing16),
              // Hearts row + count badge
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...List.generate(
                      maxHearts,
                      (index) {
                        final isFilled = index < currentHearts;
                        final isLostHeart = !isFilled &&
                            index == currentHearts &&
                            currentHearts < previousHearts;

                        Widget heartIcon = Icon(
                          isFilled
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFilled
                              ? AppColors.mathRed
                              : AppColors.borderDark,
                          size: 22,
                        );

                        if (isFilled) {
                          heartIcon = Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mathRed
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: heartIcon,
                          );
                        }

                        if (isLostHeart) {
                          heartIcon = AnimatedBuilder(
                            animation: heartAnimController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: heartScaleAnim.value,
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Color.lerp(
                                    AppColors.mathRed,
                                    AppColors.borderDark,
                                    heartAnimController.value,
                                  ),
                                  size: AppDimensions.iconMedium,
                                ),
                              );
                            },
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: heartIcon,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Numeric count badge — 한눈에 X/N 인지
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.mathRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$currentHearts/$maxHearts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mathRed,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 자동 회복 안내 — 하트가 부족할 때만 노출
          if (missing > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentHearts == 0
                        ? '30분 후 1개 자동 회복'
                        : '$missing개 부족 · 30분마다 1개 회복',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

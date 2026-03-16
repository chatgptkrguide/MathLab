// Hearts Indicator Widget
//
// Displays animated hearts and hint button.

import 'package:flutter/material.dart';
import '../../../data/models/problem/problem_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import 'hint_button.dart';

class HeartsIndicator extends StatelessWidget {
  final int currentHearts;
  final int previousHearts;
  final bool isAnswerChecked;
  final AnimationController heartAnimController;
  final Animation<double> heartScaleAnim;

  // Hint-related
  final ProblemModel? currentProblem;
  final int unlockedHintCount;
  final int totalHints;
  final int hintXpCost;
  final VoidCallback onHintTap;

  const HeartsIndicator({
    super.key,
    required this.currentHearts,
    required this.previousHearts,
    required this.isAnswerChecked,
    required this.heartAnimController,
    required this.heartScaleAnim,
    required this.currentProblem,
    required this.unlockedHintCount,
    required this.totalHints,
    required this.hintXpCost,
    required this.onHintTap,
  });

  @override
  Widget build(BuildContext context) {
    final hints = currentProblem?.allHints ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.spacing8,
      ),
      child: Row(
        children: [
          // Hint button (only shown when hints exist)
          if (hints.isNotEmpty)
            HintButton(
              unlockedCount: unlockedHintCount,
              totalHints: totalHints,
              xpCost: hintXpCost,
              isEnabled: !isAnswerChecked,
              onTap: onHintTap,
            )
          else
            const SizedBox(width: AppDimensions.spacing16),
          // Animated hearts display
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) {
                  final isFilled = index < currentHearts;
                  final isLostHeart = !isFilled &&
                      index == currentHearts &&
                      currentHearts < previousHearts;

                  Widget heartIcon = Icon(
                    isFilled ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFilled ? AppColors.mathRed : AppColors.borderDark,
                    size: AppDimensions.iconMedium,
                  );

                  if (isFilled) {
                    heartIcon = Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mathRed.withValues(alpha: 0.3),
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
            ),
          ),
        ],
      ),
    );
  }
}

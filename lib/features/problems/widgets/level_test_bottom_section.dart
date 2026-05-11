// Level test bottom section — either the "정답 확인" CTA before checking,
// or the correct/incorrect feedback bar with a "계속하기" button after
// the answer is checked.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

class LevelTestBottomSection extends StatelessWidget {
  final bool isAnswerChecked;
  final bool isCorrect;
  final bool hasSelection;
  final VoidCallback onCheckAnswer;
  final VoidCallback onNextProblem;

  const LevelTestBottomSection({
    super.key,
    required this.isAnswerChecked,
    required this.isCorrect,
    required this.hasSelection,
    required this.onCheckAnswer,
    required this.onNextProblem,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnswerChecked) {
      return _FeedbackBar(
        isCorrect: isCorrect,
        onNextProblem: onNextProblem,
      );
    }

    return Container(
      // Anti-AI: varied padding
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing14,
        AppDimensions.spacing24,
        AppDimensions.spacing20,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeightLarge,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: hasSelection ? AppColors.deepBlueCTA : null,
            color: hasSelection ? null : AppColors.nodeLockedBg,
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ElevatedButton(
            onPressed: hasSelection ? onCheckAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
              ),
            ),
            child: Text(
              '정답 확인',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: hasSelection ? Colors.white : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onNextProblem;

  const _FeedbackBar({
    required this.isCorrect,
    required this.onNextProblem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing16,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
      ),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.mathGreen.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radius20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? AppColors.mathGreen : Colors.red,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Text(
                  isCorrect ? '정답입니다!' : '틀렸습니다',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 18,
                    color: isCorrect ? AppColors.mathGreen : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightMedium,
            child: ElevatedButton(
              onPressed: onNextProblem,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? AppColors.mathGreen : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                ),
              ),
              child: Text(
                '계속하기',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

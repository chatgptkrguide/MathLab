// Wrong Answer Card
//
// Redesigned card with left status stripe, type badge, and clean layout

import 'package:flutter/material.dart';
import '../../../data/models/wrong_answer_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/math/math_renderer.dart';

class WrongAnswerCard extends StatelessWidget {
  final WrongAnswerModel wrongAnswer;
  final VoidCallback onRetry;
  final VoidCallback onMarkResolved;

  const WrongAnswerCard({
    super.key,
    required this.wrongAnswer,
    required this.onRetry,
    required this.onMarkResolved,
  });

  Color get _statusColor =>
      wrongAnswer.isResolved ? AppColors.mathGreen : AppColors.mathRed;

  Color get _typeBadgeColor {
    switch (wrongAnswer.problemType) {
      case 'multipleChoice':
      case 'trueFalse':
        return AppColors.primary;
      case 'fillInBlank':
        return AppColors.mathPurple;
      case 'dragAndDrop':
      case 'matching':
        return AppColors.mathOrange;
      default:
        return AppColors.primary;
    }
  }

  String get _typeLabel {
    switch (wrongAnswer.problemType) {
      case 'multipleChoice':
        return '객관식';
      case 'trueFalse':
        return '참/거짓';
      case 'fillInBlank':
        return '주관식';
      case 'dragAndDrop':
        return '드래그&드롭';
      case 'matching':
        return '매칭';
      default:
        return '문제';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status stripe
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radius16),
                    bottomLeft: Radius.circular(AppDimensions.radius16),
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: type badge + status + difficulty
                      _buildTopRow(),
                      const SizedBox(height: AppDimensions.spacing12),
                      // Problem text preview (with math rendering)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 48),
                        child: ClipRect(
                          child: MathRichText(
                            text: wrongAnswer.problemText,
                            textStyle: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            mathFontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing12),
                      // Answer comparison (compact)
                      _buildAnswerComparison(),
                      // Explanation
                      if (wrongAnswer.explanation != null) ...[
                        const SizedBox(height: 10),
                        _buildExplanation(),
                      ],
                      const SizedBox(height: 14),
                      // Bottom row: date + actions
                      _buildBottomRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        // Problem type badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppDimensions.spacing4),
          decoration: BoxDecoration(
            color: _typeBadgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radius10),
          ),
          child: Text(
            _typeLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: _typeBadgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        // Status badge
        if (wrongAnswer.isResolved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: AppColors.mathGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 12,
                  color: AppColors.mathGreen,
                ),
                const SizedBox(width: 3),
                Text(
                  '해결',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mathGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else if (wrongAnswer.shouldReview())
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing4),
            decoration: BoxDecoration(
              color: AppColors.mathOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  size: 12,
                  color: AppColors.mathOrange,
                ),
                const SizedBox(width: 3),
                Text(
                  '복습',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mathOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        // Attempt count
        if (wrongAnswer.attemptCount > 1)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.replay_rounded,
                size: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 3),
              Text(
                '${wrongAnswer.attemptCount}회',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAnswerComparison() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppDimensions.spacing8),
            decoration: BoxDecoration(
              color: AppColors.mathRed.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimensions.radius10),
              border: Border.all(
                color: AppColors.mathRed.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: AppColors.mathRed.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MathRichText(
                    text: wrongAnswer.userAnswer,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathRed,
                      fontWeight: FontWeight.w500,
                    ),
                    mathFontSize: 14.0,
                    mathColor: AppColors.mathRed,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppDimensions.spacing8),
            decoration: BoxDecoration(
              color: AppColors.mathGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimensions.radius10),
              border: Border.all(
                color: AppColors.mathGreen.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: AppColors.mathGreen.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MathRichText(
                    text: wrongAnswer.correctAnswer,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathGreen,
                      fontWeight: FontWeight.w500,
                    ),
                    mathFontSize: 14.0,
                    mathColor: AppColors.mathGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppDimensions.radius10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 60),
              child: ClipRect(
                child: MathRichText(
                  text: wrongAnswer.explanation!,
                  textStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  mathFontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Date label
        Text(
          wrongAnswer.daysSinceAttempt == 0
              ? '오늘'
              : '${wrongAnswer.daysSinceAttempt}일 전',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        // Action buttons
        if (!wrongAnswer.isResolved) ...[
          // Retry button
          SizedBox(
            height: 34,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('다시 풀기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius10),
                ),
                textStyle: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing8),
          // Resolve button
          SizedBox(
            height: 34,
            child: ElevatedButton.icon(
              onPressed: onMarkResolved,
              icon: const Icon(Icons.check_rounded, size: 15),
              label: const Text('해결'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mathGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius10),
                ),
                textStyle: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

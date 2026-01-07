import 'package:flutter/material.dart';
import '../../../data/models/learning/wrong_answer.dart';
import '../../../shared/constants/constants.dart';

/// 오답 카드 위젯
class WrongAnswerCard extends StatelessWidget {
  final WrongAnswer wrongAnswer;
  final bool showUrgency;
  final bool showReviewInfo;
  final bool isMastered;
  final VoidCallback onTap;

  const WrongAnswerCard({
    super.key,
    required this.wrongAnswer,
    this.showUrgency = false,
    this.showReviewInfo = false,
    this.isMastered = false,
    required this.onTap,
  });

  Color _getUrgencyColor() {
    switch (wrongAnswer.urgency) {
      case 2:
        return AppColors.mathRed;
      case 1:
        return AppColors.mathOrange;
      default:
        return AppColors.successGreen;
    }
  }

  String _getUrgencyText() {
    switch (wrongAnswer.urgency) {
      case 2:
        return '긴급';
      case 1:
        return '복습 시기';
      default:
        return '여유';
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isMastered
        ? AppColors.successGreen
        : showUrgency && wrongAnswer.urgency > 0
            ? _getUrgencyColor()
            : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: borderColor.withOpacity(0.1),
          highlightColor: borderColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 카테고리
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mathBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.mathBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        wrongAnswer.problem.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mathBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppDimensions.spacingS),

                    // 난이도
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.disabled.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        wrongAnswer.problem.difficulty.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 긴급도 또는 완료 표시
                    if (isMastered)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_rounded,
                                color: AppColors.surface, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '완료',
                              style: TextStyle(
                                color: AppColors.surface,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (showUrgency && wrongAnswer.urgency > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getUrgencyText(),
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // 문제
                Text(
                  wrongAnswer.problem.question,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // 정보
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        showReviewInfo
                            ? '복습 ${wrongAnswer.reviewCount}/3회 • ${wrongAnswer.daysUntilReview}일 후'
                            : isMastered
                                ? '완료일: ${_formatDate(wrongAnswer.lastReviewDate)}'
                                : '틀린 날짜: ${_formatDate(wrongAnswer.timestamp)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    if (diff < 7) return '$diff일 전';

    return '${date.year}.${date.month}.${date.day}';
  }
}

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../data/models/models.dart';

/// 문제 해설 표시 위젯
///
/// 답안 제출 후 표시되는 해설:
/// - 정답/오답 아이콘 및 메시지
/// - 문제 해설
class ProblemExplanation extends StatelessWidget {
  /// 문제 정보
  final Problem problem;

  /// 정답 여부
  final bool isCorrect;

  const ProblemExplanation({
    super.key,
    required this.problem,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.successGreen.withValues(alpha: 0.1)
              : AppColors.warningOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isCorrect
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : AppColors.warningOrange.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정답/오답 헤더
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.lightbulb,
                  color: isCorrect
                      ? AppColors.successGreen
                      : AppColors.warningOrange,
                  size: 24,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  isCorrect ? '정답입니다!' : '다시 한번 확인해보세요',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isCorrect
                        ? AppColors.successGreen
                        : AppColors.warningOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // 해설
            Text(
              problem.explanation ?? '풀이 설명이 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

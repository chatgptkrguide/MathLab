// Level test question area — shows the problem card plus multiple-choice
// options with selection / correctness styling.
import 'package:flutter/material.dart';

import '../../../data/models/problem/problem_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/math/math_renderer.dart';

class LevelTestQuestionArea extends StatelessWidget {
  final ProblemModel problem;
  final int problemIndex;
  final String? selectedAnswer;
  final bool isAnswerChecked;
  final bool isCorrect;
  final ValueChanged<String> onSelectAnswer;

  const LevelTestQuestionArea({
    super.key,
    required this.problem,
    required this.problemIndex,
    required this.selectedAnswer,
    required this.isAnswerChecked,
    required this.isCorrect,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    // Anti-AI: index-based spacing variation
    const optionSpacing = [12.0, 10.0, 14.0, 10.0, 12.0];
    // Anti-AI: slight radius variation per option
    const optionRadii = [
      AppDimensions.radius24,
      AppDimensions.radius20,
      AppDimensions.radius24,
      AppDimensions.radius20,
    ];

    return SingleChildScrollView(
      // Anti-AI: asymmetric padding
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing20,
        AppDimensions.spacing24,
        AppDimensions.spacing24,
        AppDimensions.spacing20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문제 ${problemIndex + 1}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                MathRenderer(
                  latex: problem.question,
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing20),

          // 선택지 (chip 스타일) — Anti-AI: index-based variation
          if (problem.type == ProblemType.multipleChoice)
            ...problem.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == option;
              final isFirst = index == 0;
              final isLast = index == problem.options.length - 1;
              Color bgColor = AppColors.chipBg;
              Color textColor = AppColors.textDark;
              Color borderColor = Colors.transparent;

              if (isAnswerChecked && isSelected) {
                if (isCorrect) {
                  bgColor = AppColors.mathGreen.withValues(alpha: 0.15);
                  textColor = AppColors.mathGreen;
                  borderColor = AppColors.mathGreen;
                } else {
                  bgColor = Colors.red.withValues(alpha: 0.1);
                  textColor = Colors.red;
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                bgColor = AppColors.skyBlue.withValues(alpha: 0.12);
                textColor = AppColors.skyBlue;
                borderColor = AppColors.skyBlue;
              }

              final radius = optionRadii[index % optionRadii.length];
              final bottomSpacing =
                  optionSpacing[index % optionSpacing.length];

              return Padding(
                padding: EdgeInsets.only(bottom: bottomSpacing),
                child: GestureDetector(
                  onTap: isAnswerChecked ? null : () => onSelectAnswer(option),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing20,
                        vertical: AppDimensions.spacing16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(radius),
                      border: isFirst && !isSelected && !isAnswerChecked
                          // Anti-AI: first option gets subtle left accent
                          ? Border(
                              left: BorderSide(
                                  color: AppColors.skyBlue
                                      .withValues(alpha: 0.35),
                                  width: 3),
                              top: BorderSide(
                                  color: borderColor,
                                  width: isSelected ? 2 : 0),
                              right: BorderSide(
                                  color: borderColor,
                                  width: isSelected ? 2 : 0),
                              bottom: BorderSide(
                                  color: borderColor,
                                  width: isSelected ? 2 : 0),
                            )
                          : isLast && !isSelected && !isAnswerChecked
                              // Anti-AI: last option gets slightly different radius (already handled via optionRadii)
                              ? Border.all(
                                  color: borderColor,
                                  width: isSelected ? 2 : 0)
                              : Border.all(
                                  color: borderColor,
                                  width: isSelected ? 2 : 0),
                    ),
                    child: MathRenderer(
                      latex: option,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../data/models/models.dart';

/// 주관식 문제 답안 입력 위젯
///
/// 포함 내용:
/// - 텍스트 입력 필드
/// - 숫자/텍스트 키보드 타입 자동 선택
/// - 정답/오답 테두리 색상
/// - 오답 시 정답 표시
class ProblemAnswerInput extends StatelessWidget {
  /// 문제 정보
  final Problem problem;

  /// 텍스트 컨트롤러
  final TextEditingController controller;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 답안 제출 여부
  final bool isAnswerSubmitted;

  /// 정답 여부
  final bool isCorrect;

  /// 정답 텍스트
  final String? correctAnswerText;

  /// 입력 변경 콜백
  final VoidCallback? onChanged;

  /// 제출 콜백 (Enter 키)
  final VoidCallback? onSubmitted;

  const ProblemAnswerInput({
    super.key,
    required this.problem,
    required this.controller,
    this.focusNode,
    this.isAnswerSubmitted = false,
    this.isCorrect = false,
    this.correctAnswerText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isAnswerSubmitted
                ? (isCorrect ? AppColors.successGreen : AppColors.errorRed)
                : AppColors.borderLight,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레이블
            Text(
              '정답을 입력하세요',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),

            // 입력 필드
            TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isAnswerSubmitted,
              keyboardType: problem.type == ProblemType.calculation
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              style: AppTextStyles.titleLarge,
              decoration: InputDecoration(
                hintText: problem.type == ProblemType.calculation
                    ? '숫자를 입력하세요'
                    : '답을 입력하세요',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide:
                      const BorderSide(color: AppColors.mathPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) {
                onChanged?.call();
              },
              onSubmitted: (_) {
                if (controller.text.isNotEmpty && !isAnswerSubmitted) {
                  onSubmitted?.call();
                }
              },
            ),

            // 오답 시 정답 표시
            if (isAnswerSubmitted &&
                !isCorrect &&
                correctAnswerText != null) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                '정답: $correctAnswerText',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

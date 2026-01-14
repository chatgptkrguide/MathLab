import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_dimensions.dart';

/// 오답 노트 카드 위젯
///
/// errors_screen과 wrong_answer_screen에서 공통으로 사용
/// - Duolingo flat style 디자인
/// - 상태 뱃지 포함
/// - 복습 필요 경고 표시
class ErrorNoteCard extends StatelessWidget {
  final ErrorNote errorNote;
  final VoidCallback onTap;

  const ErrorNoteCard({
    super.key,
    required this.errorNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderLight.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      errorNote.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  _ErrorStatusBadge(status: errorNote.status),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                errorNote.category,
                style: const TextStyle(
                  color: AppColors.mathBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '복습 ${errorNote.reviewCount}회',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${errorNote.daysSinceCreated}일 전',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (errorNote.needsReview) ...[
                const SizedBox(height: AppDimensions.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingS,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    '복습이 필요한 문제입니다',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.warningOrange,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 오답 상태 뱃지
///
/// ErrorStatus에 따라 색상과 텍스트가 변경됨
class _ErrorStatusBadge extends StatelessWidget {
  final ErrorStatus status;

  const _ErrorStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case ErrorStatus.newError:
        color = AppColors.errorRed;
        text = '신규';
        break;
      case ErrorStatus.reviewing:
        color = AppColors.mathOrange;
        text = '복습중';
        break;
      case ErrorStatus.improving:
        color = AppColors.mathBlue;
        text = '향상중';
        break;
      case ErrorStatus.mastered:
        color = AppColors.successGreen;
        text = '완료';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.surface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

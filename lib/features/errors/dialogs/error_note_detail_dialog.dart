import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';
import '../../../data/models/models.dart';

/// 오답 노트 상세 다이얼로그
class ErrorNoteDetailDialog extends StatelessWidget {
  final ErrorNote errorNote;
  final VoidCallback onReview;

  const ErrorNoteDetailDialog({
    super.key,
    required this.errorNote,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      title: Row(
        children: [
          const Text('📝', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              '오답 노트 상세',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('문제', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(errorNote.question, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('내 답', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        errorNote.userAnswer,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('정답', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        errorNote.correctAnswer,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.successGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),

            Text('해설', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(errorNote.explanation, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.spacingM),

            Wrap(
              spacing: AppDimensions.spacingM,
              runSpacing: AppDimensions.spacingS,
              children: [
                _buildInfoChip('카테고리', errorNote.category, AppColors.mathBlue),
                _buildInfoChip('난이도', errorNote.difficultyText, AppColors.mathOrange),
                _buildInfoChip('복습', '${errorNote.reviewCount}회', AppColors.mathTeal),
                _buildInfoChip('상태', errorNote.statusText, _getStatusColor(errorNote.status)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '닫기',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onReview();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mathButtonBlue,
          ),
          child: const Text('이 문제 복습하기'),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ErrorStatus status) {
    switch (status) {
      case ErrorStatus.newError:
        return AppColors.errorRed;
      case ErrorStatus.reviewing:
        return AppColors.warningOrange;
      case ErrorStatus.improving:
        return AppColors.mathBlue;
      case ErrorStatus.mastered:
        return AppColors.successGreen;
    }
  }
}

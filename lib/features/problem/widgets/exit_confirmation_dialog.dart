import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 학습 중단 확인 다이얼로그
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.warningOrange, size: 24),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            '학습 중단',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        '정말 나가시겠습니까?\n\n현재까지의 진행 상황은 저장되지 않습니다.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '계속하기',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mathButtonBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            Navigator.of(context).pop(); // ProblemScreen 닫기
          },
          child: Text(
            '나가기',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.errorRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

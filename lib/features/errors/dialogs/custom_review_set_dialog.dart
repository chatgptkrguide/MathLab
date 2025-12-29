import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 맞춤 복습 세트 생성 다이얼로그
class CustomReviewSetDialog extends StatelessWidget {
  final VoidCallback onCreateByCategory;
  final VoidCallback onCreateByDifficulty;

  const CustomReviewSetDialog({
    super.key,
    required this.onCreateByCategory,
    required this.onCreateByDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      title: Row(
        children: [
          const Icon(Icons.menu_book, color: AppColors.primary, size: 24),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            '맞춤 복습 세트',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        '어떤 기준으로 복습 세트를 만드시겠습니까?',
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '취소',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCreateByCategory();
          },
          child: Text(
            '카테고리별',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mathButtonBlue,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCreateByDifficulty();
          },
          child: Text(
            '난이도별',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.mathButtonBlue,
            ),
          ),
        ),
      ],
    );
  }
}

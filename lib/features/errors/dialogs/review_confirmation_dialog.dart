import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 선택 문제 복습 확인 다이얼로그
class ReviewConfirmationDialog extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onConfirm;

  const ReviewConfirmationDialog({
    super.key,
    required this.selectedCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      title: Row(
        children: [
          const Text('🔄', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            '선택 문제 복습',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        '$selectedCount개의 문제를 복습하시겠습니까?',
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
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mathButtonBlue,
          ),
          child: const Text('복습 시작'),
        ),
      ],
    );
  }
}

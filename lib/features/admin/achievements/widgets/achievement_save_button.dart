// Achievement save button — full-width primary action with spinner.
import 'package:flutter/material.dart';

import '../../../../shared/constants/constants.dart';

class AchievementSaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;

  const AchievementSaveButton({
    super.key,
    required this.isSaving,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.spacing48,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mathGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                isEditing ? '수정하기' : '저장하기',
                style:
                    AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}

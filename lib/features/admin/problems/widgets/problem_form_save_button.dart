// Problem form save button — shows a spinner while saving and toggles
// between "저장하기" and "수정하기" depending on edit mode.
import 'package:flutter/material.dart';

import '../../../../shared/constants/constants.dart';

class ProblemFormSaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onSave;

  const ProblemFormSaveButton({
    super.key,
    required this.isSaving,
    required this.isEditing,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.spacing48,
      child: ElevatedButton(
        onPressed: isSaving ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mathGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: AppDimensions.spacing24,
                height: AppDimensions.spacing24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                isEditing ? '수정하기' : '저장하기',
                style: AppTextStyles.titleMedium,
              ),
      ),
    );
  }
}

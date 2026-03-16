// Problem Action Button Widget
//
// Bottom button for checking answer or continuing to next problem.

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class ProblemActionButton extends StatelessWidget {
  final bool hasAnswer;
  final bool isAnswerChecked;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const ProblemActionButton({
    super.key,
    required this.hasAnswer,
    required this.isAnswerChecked,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canCheck = hasAnswer && !isAnswerChecked;
    final canContinue = isAnswerChecked;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: const Color(0xFFFAFAFA),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: canCheck
              ? onCheck
              : canContinue
                  ? onNext
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: (canCheck || canContinue)
                ? AppColors.skyBlue
                : const Color(0xFFE0E0E0),
            foregroundColor: (canCheck || canContinue)
                ? Colors.white
                : const Color(0xFFAAAAAA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Text(
            canContinue ? '계속' : '정답 확인',
            style: AppTextStyles.button.copyWith(
              color: (canCheck || canContinue)
                  ? Colors.white
                  : const Color(0xFFAAAAAA),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// Lesson not ready dialog — shown when the requested lesson contains only
// placeholder problems (empty / sample fallback), so we should bail out of
// the solving screen instead of presenting fake content.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

/// Displays the "lesson not ready" modal dialog.
///
/// Tapping the action button dismisses the dialog and then pops the host
/// screen back to the lessons list (via [onDismiss]). [onDismiss] runs only
/// if the host is still `mounted`.
void showLessonNotReadyDialog({
  required BuildContext context,
  required VoidCallback onDismiss,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.skyBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '레슨 준비 중',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: const Text(
        '이 레슨의 문제는 아직 추가되지 않았어요.\n곧 준비될 예정이니 다른 레슨을 먼저 풀어보세요!',
        style: TextStyle(fontSize: 14, height: 1.5),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onDismiss();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          ),
          child: const Text(
            '다른 레슨 보기',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

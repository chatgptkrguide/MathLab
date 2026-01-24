import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/learning/problem.dart';
import '../../../data/providers/learning/hint_provider_optimized.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/haptic_feedback.dart';

/// 힌트 잠금 해제 로직 핸들러
class HintUnlockHandler {
  /// 힌트 잠금 해제 처리
  static Future<void> unlockHint({
    required BuildContext context,
    required WidgetRef ref,
    required Problem problem,
    required int hintIndex,
  }) async {
    final success = await ref
        .read(hintProviderOptimized.notifier)
        .unlockHint(problem, hintIndex);

    if (success) {
      await AppHapticFeedback.success();

      if (context.mounted) {
        _showSuccessSnackBar(context);
      }
    } else {
      await AppHapticFeedback.error();

      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    }
  }

  /// 성공 스낵바 표시
  static void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.lightbulb,
              color: AppColors.surface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '힌트 잠금 해제!',
                    style: TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '-${HintProviderOptimized.hintCost} XP',
                    style: TextStyle(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 에러 스낵바 표시
  static void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.surface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'XP가 부족합니다',
                    style: TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${HintProviderOptimized.hintCost} XP 필요',
                    style: TextStyle(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

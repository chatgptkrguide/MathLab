import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/providers/lesson/lesson_progress_provider.dart';
import '../../../data/providers/wrong_answer/wrong_answer_provider.dart';

/// 학습 초기화 확인 다이얼로그
class ResetProgressDialog extends ConsumerStatefulWidget {
  const ResetProgressDialog({super.key});

  @override
  ConsumerState<ResetProgressDialog> createState() => _ResetProgressDialogState();
}

class _ResetProgressDialogState extends ConsumerState<ResetProgressDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '학습 초기화',
              style: AppTextStyles.headlineSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정말로 모든 학습 진행 상태를 초기화하시겠습니까?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '초기화되는 항목:',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '- 모든 레슨 진행 상태\n- XP 및 레벨\n- 연속 학습 기록\n- 업적 및 뱃지\n- 오답 노트',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            '이 작업은 되돌릴 수 없습니다.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mathRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('초기화'),
        ),
      ],
    );
  }

  Future<void> _handleReset() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider);
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      // Reset user progress
      await ref.read(userProvider.notifier).resetProgress();

      // Invalidate lesson progress provider to refresh
      ref.invalidate(lessonProgressProvider(user.uid));

      // Invalidate wrong answer provider to refresh
      ref.invalidate(wrongAnswerProvider(user.uid));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('학습 진행 상태가 초기화되었습니다.'),
            backgroundColor: AppColors.mathGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('초기화 실패: $e'),
            backgroundColor: AppColors.mathRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

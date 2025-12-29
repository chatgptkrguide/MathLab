import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/constants.dart';
import '../../../data/providers/learning/lesson_progress_provider.dart';
import '../../../data/providers/user/user_provider.dart';

/// 학습 초기화 확인 다이얼로그
class ResetProgressDialog extends ConsumerWidget {
  const ResetProgressDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          SizedBox(width: 8),
          Text('학습 초기화'),
        ],
      ),
      content: const Text(
        '모든 학습 진행 상태가 초기화됩니다.\n'
        '이 작업은 되돌릴 수 없습니다.\n\n'
        '정말 진행하시겠습니까?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            // Context를 미리 저장
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);

            // 진행 상태 초기화
            await ref.read(lessonProgressProvider.notifier).resetProgress();
            await ref.read(userProvider.notifier).resetUser();

            navigator.pop(); // 다이얼로그 닫기

            // 성공 메시지
            messenger.showSnackBar(
              const SnackBar(
                content: Text('학습 진행 상태가 초기화되었습니다.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            '초기화',
            style: TextStyle(color: AppColors.warning),
          ),
        ),
      ],
    );
  }
}

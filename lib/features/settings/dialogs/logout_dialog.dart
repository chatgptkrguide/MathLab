import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../data/providers/auth/auth_provider.dart';

/// 로그아웃 확인 다이얼로그
class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: const Text(
        '로그아웃',
        style: AppTextStyles.headlineSmall,
      ),
      content: Text(
        '정말 로그아웃하시겠습니까?\n학습 데이터는 저장됩니다.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            await ref.read(authProvider.notifier).signOut();
            // 로그아웃 후 네비게이션 스택 정리 → AuthWrapper가 AuthScreen 표시
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mathRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          child: const Text('로그아웃'),
        ),
      ],
    );
  }
}

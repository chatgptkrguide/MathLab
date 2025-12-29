import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/constants.dart';
import '../../../data/providers/auth/auth_provider.dart';
import '../../auth/auth_screen.dart';

/// 로그아웃 확인 다이얼로그
class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('로그아웃'),
      content: const Text('정말 로그아웃 하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            // Context를 미리 저장
            final navigator = Navigator.of(context);

            // 로그아웃 실행
            await ref.read(authProvider.notifier).signOut();

            // 로그인 화면으로 이동하고 네비게이션 스택 전체 클리어
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          },
          child: const Text(
            '로그아웃',
            style: TextStyle(color: AppColors.mathRed),
          ),
        ),
      ],
    );
  }
}

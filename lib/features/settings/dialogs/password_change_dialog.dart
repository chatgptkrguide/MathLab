import 'package:flutter/material.dart';

/// 비밀번호 변경 다이얼로그
class PasswordChangeDialog extends StatelessWidget {
  const PasswordChangeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return AlertDialog(
      title: const Text('비밀번호 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentPasswordController,
            decoration: const InputDecoration(
              labelText: '현재 비밀번호',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: newPasswordController,
            decoration: const InputDecoration(
              labelText: '새 비밀번호',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(
              labelText: '새 비밀번호 확인',
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (newPasswordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('새 비밀번호가 일치하지 않습니다'),
                ),
              );
              return;
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('비밀번호가 변경되었습니다'),
              ),
            );
          },
          child: const Text('변경'),
        ),
      ],
    );
  }
}

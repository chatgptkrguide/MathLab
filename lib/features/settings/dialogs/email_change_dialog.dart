import 'package:flutter/material.dart';

/// 이메일 변경 다이얼로그
class EmailChangeDialog extends StatelessWidget {
  const EmailChangeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return AlertDialog(
      title: const Text('이메일 변경'),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: '새 이메일',
          hintText: 'example@email.com',
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이메일이 변경되었습니다'),
              ),
            );
          },
          child: const Text('변경'),
        ),
      ],
    );
  }
}

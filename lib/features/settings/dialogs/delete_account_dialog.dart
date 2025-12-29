import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 계정 탈퇴 확인 다이얼로그
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('계정 탈퇴'),
      content: const Text(
        '계정을 탈퇴하면 모든 데이터가 삭제됩니다.\n정말 탈퇴하시겠습니까?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            // TODO: 계정 탈퇴 로직 구현
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('계정 탈퇴 기능은 준비 중입니다'),
              ),
            );
          },
          child: const Text(
            '탈퇴',
            style: TextStyle(color: AppColors.mathRed),
          ),
        ),
      ],
    );
  }
}

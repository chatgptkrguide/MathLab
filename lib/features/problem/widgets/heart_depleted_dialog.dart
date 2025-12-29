import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';

/// 하트 소진 알림 다이얼로그
class HeartDepletedDialog extends StatelessWidget {
  const HeartDepletedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.favorite_border,
            color: AppColors.error,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Text('하트가 모두 소진되었습니다'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '더 이상 문제를 풀 수 없습니다.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            '• 하트는 30분마다 1개씩 재생됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '• 프리미엄 구독으로 무제한 하트를 사용하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 다이얼로그 닫기
            Navigator.pop(context); // 문제 화면 닫기
          },
          child: const Text('확인'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            // TODO: 프리미엄 구독 화면으로 이동
            // Navigator.pushNamed(context, '/premium');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text(
            '프리미엄 구독',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// 프리미엄 화면 헤더 위젯 (닫기 버튼)
class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 48), // 대칭을 위한 빈 공간
        ],
      ),
    );
  }
}

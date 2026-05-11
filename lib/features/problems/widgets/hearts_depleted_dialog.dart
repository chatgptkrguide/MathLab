// Hearts depleted dialog — shown after the user runs out of hearts mid-lesson.
// Offers the option to wait for auto-recovery or visit the shop.
import 'package:flutter/material.dart';

import '../../shop/shop_screen.dart';

/// Displays the hearts-depleted modal dialog.
///
/// Both buttons dismiss the dialog and pop the host screen. The shop button
/// additionally pushes [ShopScreen] onto the underlying navigator.
void showHeartsDepletedDialog({
  required BuildContext context,
  required int gems,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.favorite, color: Color(0xFFFF4B6E), size: 24),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              '하트가 모두 소진되었습니다',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '하트가 없으면 문제를 풀 수 없어요.\n상점에서 젬으로 충전하거나 30분 후 자동 회복을 기다려보세요.',
            style: TextStyle(
                fontSize: 14, color: Color(0xFF777777), height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diamond_rounded,
                  color: Color(0xFFFFB800), size: 16),
              const SizedBox(width: 4),
              Text(
                '보유 젬: $gems',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
          child: const Text(
            '기다리기',
            style: TextStyle(color: Color(0xFF777777)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ShopScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B5CE7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            '상점에서 충전하기',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

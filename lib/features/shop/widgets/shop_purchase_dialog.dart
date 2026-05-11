// Shop purchase confirmation dialog — shows item summary and triggers purchase via callback.
import 'package:flutter/material.dart';

import '../../../data/models/shop_item_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';

/// Shows the purchase confirmation dialog for [item].
///
/// If the user has insufficient gems, a snackbar is shown instead and the
/// dialog is not displayed. The [onPurchase] callback is invoked when the user
/// confirms the purchase; it should perform the actual purchase and return
/// whether it succeeded.
void showShopPurchaseDialog({
  required BuildContext context,
  required ShopItem item,
  required int currentGems,
  required Future<bool> Function() onPurchase,
}) {
  if (currentGems < item.gemCost) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('젬이 부족합니다'),
        backgroundColor: AppColors.error,
      ),
    );
    return;
  }

  final isPurchasing = ValueNotifier<bool>(false);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
      ),
      title: Text(
        '${item.name} 구매',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.diamond_rounded,
                color: Color(0xFFFFB800),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.gemCost}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(잔액: $currentGems)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isPurchasing,
          builder: (innerContext, purchasing, _) => ElevatedButton(
            onPressed: purchasing
                ? null
                : () async {
                    isPurchasing.value = true;
                    Navigator.of(dialogContext).pop();
                    final success = await onPurchase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '${item.name} 구매 완료!'
                                : '구매에 실패했습니다',
                          ),
                          backgroundColor: success
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5CE7),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF6B5CE7).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: purchasing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '구매하기',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    ),
  );
}

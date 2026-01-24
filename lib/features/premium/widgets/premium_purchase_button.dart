import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 프리미엄 구매 버튼 위젯
class PremiumPurchaseButton extends StatelessWidget {
  final bool isPurchasing;
  final VoidCallback onPressed;

  const PremiumPurchaseButton({
    super.key,
    required this.isPurchasing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isPurchasing ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.premiumGold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: isPurchasing
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '지금 구매하기',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

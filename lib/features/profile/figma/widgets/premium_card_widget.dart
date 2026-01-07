import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/subscription/premium_providers.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/premium/premium_badge.dart';
import '../../../premium/premium_upgrade_screen.dart';
import '../../../premium/subscription_management_screen.dart';

/// 프리미엄 구독 카드 위젯
class PremiumCardWidget extends ConsumerWidget {
  const PremiumCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumActive = ref.watch(isPremiumActiveProvider);
    final premiumStatusText = ref.watch(premiumStatusTextProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremiumActive
              ? AppColors.premiumGradient
                  .map((c) => c.withOpacity(0.2))
                  .toList()
              : [
                  const Color(0xFFE3F2FD),
                  const Color(0xFFBBDEFB).withOpacity(0.5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isPremiumActive
                ? AppColors.premiumGold.withOpacity(0.2)
                : AppColors.mathBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPremiumActive ? '프리미엄 회원' : 'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPremiumActive
                            ? AppColors.premiumGold
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isPremiumActive) ...[
                      const SizedBox(width: 8),
                      const PremiumBadge(
                        size: PremiumBadgeSize.small,
                        style: PremiumBadgeStyle.iconOnly,
                        showTooltip: false,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isPremiumActive
                      ? premiumStatusText
                      : 'Get benefit from our premium',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                if (isPremiumActive) {
                  // Premium user: Navigate to subscription management
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const SubscriptionManagementScreen(),
                    ),
                  );
                } else {
                  // Free user: Navigate to premium upgrade
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PremiumUpgradeScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremiumActive
                    ? AppColors.premiumGold
                    : AppColors.mathBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Text(
                isPremiumActive ? '관리' : 'Upgrade',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

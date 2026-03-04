import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../data/models/subscription/premium_tier.dart';

/// 프리미엄 가격 플랜 위젯
class PremiumPricingPlans extends StatelessWidget {
  final PremiumTier selectedTier;
  final ValueChanged<PremiumTier> onTierSelected;

  const PremiumPricingPlans({
    super.key,
    required this.selectedTier,
    required this.onTierSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '플랜 선택',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 월간 플랜
          _PricingCard(
            tier: PremiumTier.monthly,
            title: '월간',
            price: PremiumTier.monthly.formattedPrice,
            period: '/월',
            description: '언제든지 취소 가능',
            isSelected: selectedTier == PremiumTier.monthly,
            onTap: () => onTierSelected(PremiumTier.monthly),
          ),

          const SizedBox(height: 12),

          // 연간 플랜 (추천) - visually larger card
          Stack(
            clipBehavior: Clip.none,
            children: [
              _PricingCard(
                tier: PremiumTier.yearly,
                title: '연간',
                price: PremiumTier.yearly.formattedPrice,
                period: '/년',
                description:
                    '${PremiumTier.yearly.formattedMonthlyEquivalent}/월 (${PremiumTier.yearly.discountPercentage.toStringAsFixed(0)}% 절약)',
                isSelected: selectedTier == PremiumTier.yearly,
                isRecommended: true,
                onTap: () => onTierSelected(PremiumTier.yearly),
              ),

              // 추천 뱃지
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mathOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '최고 절약',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 평생 플랜
          _PricingCard(
            tier: PremiumTier.lifetime,
            title: '평생',
            price: PremiumTier.lifetime.formattedPrice,
            period: '',
            description: '단 한 번만 결제하고 영구 사용',
            isSelected: selectedTier == PremiumTier.lifetime,
            onTap: () => onTierSelected(PremiumTier.lifetime),
          ),
        ],
      ),
    );
  }
}

/// 개별 가격 카드 위젯
/// isRecommended: makes the card visually larger with accent styling
class _PricingCard extends StatelessWidget {
  final PremiumTier tier;
  final String title;
  final String price;
  final String period;
  final String description;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PricingCard({
    required this.tier,
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isRecommended ? 20 : 16),
          border: Border.all(
            color: isSelected ? AppColors.premiumGold : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.premiumGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : isRecommended
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
        ),
        // Recommended plan gets more padding for larger visual weight
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isRecommended ? 24 : 16,
        ),
        child: Row(
          children: [
            // 선택 라디오
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.premiumGold
                      : AppColors.borderLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.premiumGold : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // 플랜 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: isRecommended
                        ? AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          )
                        : AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isRecommended
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isRecommended ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // 가격
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: (isRecommended
                              ? AppTextStyles.headlineMedium
                              : AppTextStyles.headlineSmall)
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.premiumGold
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (period.isNotEmpty)
                      Text(
                        period,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../data/services/premium_feature_service.dart';

/// 프리미엄 기능 비교표 위젯
class PremiumFeatureComparison extends StatelessWidget {
  const PremiumFeatureComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final featureService = PremiumFeatureService();
    final features = featureService.getFeatureComparisons();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '무료 vs 프리미엄',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 헤더 행
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(''),
                ),
                Expanded(
                  child: Text(
                    '무료',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '프리미엄',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.premiumGold,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // 기능 행들
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // 아이콘 & 이름
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(
                              feature.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 무료 값
                      Expanded(
                        child: Text(
                          feature.freeValue,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // 프리미엄 값
                      Expanded(
                        child: Text(
                          feature.premiumValue,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.premiumGold,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

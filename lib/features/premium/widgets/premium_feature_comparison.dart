import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../data/services/premium_feature_service.dart';

/// 프리미엄 기능 비교표 위젯
/// Clean two-column layout (Free vs Premium) with checkmarks/X marks
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                '무료 vs 프리미엄',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Column header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '무료',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '프리미엄',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Feature rows
            ...features.asMap().entries.map((entry) {
              final idx = entry.key;
              final feature = entry.value;
              final isLast = idx == features.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        // Feature icon & name
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Text(
                                feature.icon,
                                style: const TextStyle(fontSize: 18),
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

                        // Free value with visual indicator
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: _buildValueIndicator(
                                feature.freeValue, false),
                          ),
                        ),

                        // Premium value with visual indicator
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: _buildValueIndicator(
                                feature.premiumValue, true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 24,
                      endIndent: 24,
                      color: AppColors.borderLight.withValues(alpha: 0.5),
                    ),
                ],
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildValueIndicator(String value, bool isPremium) {
    final lowerVal = value.toLowerCase().trim();

    // Check/X for boolean-like values
    if (lowerVal == 'x' || lowerVal == '-' || lowerVal == 'no') {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.mathRed.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 16, color: AppColors.mathRed),
      );
    }

    if (lowerVal == 'o' || lowerVal == 'yes' || lowerVal.contains('무제한')) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isPremium
              ? AppColors.premiumGold.withValues(alpha: 0.15)
              : AppColors.mathGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: 16,
          color: isPremium ? AppColors.premiumGold : AppColors.mathGreen,
        ),
      );
    }

    // Text value
    return Text(
      value,
      style: AppTextStyles.bodySmall.copyWith(
        color: isPremium ? AppColors.premiumGold : AppColors.textSecondary,
        fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }
}

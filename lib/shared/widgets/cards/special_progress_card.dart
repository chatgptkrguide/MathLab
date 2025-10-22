import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';

/// 특별한 진행률 카드 (파란색 테두리)
/// 새 디자인의 "레벨 2" 카드와 같은 스타일
class SpecialProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentValue;
  final int targetValue;
  final String unit;
  final String emoji;
  final VoidCallback? onTap;

  const SpecialProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.emoji,
    this.onTap,
  });

  double get progress => targetValue > 0 ? currentValue / targetValue : 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: AppColors.accentCyan,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              blurRadius: AppDimensions.cardElevation * 4,
              offset: const Offset(0, AppDimensions.cardElevation),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$title $emoji',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$currentValue/$targetValue $unit',
                  style: AppTextStyles.progressText.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.progressBackground,
              valueColor: AlwaysStoppedAnimation(AppColors.progressActiveBlue),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              minHeight: AppDimensions.progressBarHeight,
            ),
          ],
        ),
      ),
    );
  }
}
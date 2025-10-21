import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 진행률 카드 위젯
/// 오늘의 목표, 레슨 진행률 등을 표시하는데 사용
class ProgressCard extends StatelessWidget {
  final String title;
  final int currentValue;
  final int targetValue;
  final String unit;
  final String? subtitle;
  final VoidCallback? onTap;

  const ProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    this.subtitle,
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
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.08),
              blurRadius: AppDimensions.cardElevation * 3,
              offset: const Offset(0, AppDimensions.cardElevation),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    '$currentValue/$targetValue $unit',
                    style: AppTextStyles.progressText,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.progressBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.progressActive),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              minHeight: AppDimensions.progressBarHeight,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
              ),
            ] else ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                '목표까지 ${targetValue - currentValue} $unit 남았습니다!',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
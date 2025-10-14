import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 업적 카드 위젯
/// 프로필 화면에서 업적을 표시하는데 사용
class AchievementCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.secondaryBlue
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isUnlocked
                ? AppColors.primaryBlue
                : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: AppTextStyles.emojiLarge.copyWith(
                color: isUnlocked ? null : AppColors.disabled,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.disabled,
                fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
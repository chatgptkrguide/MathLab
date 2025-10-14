import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// 통계 카드 위젯
/// XP, 레벨, 연속 등의 통계 정보를 표시하는데 사용
class StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              color: AppColors.cardShadow.withOpacity(0.08),
              blurRadius: AppDimensions.cardElevation * 3,
              offset: const Offset(0, AppDimensions.cardElevation),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isVerySmall = constraints.maxHeight < 80 || constraints.maxWidth < 80;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    icon,
                    style: AppTextStyles.emojiLarge.copyWith(
                      color: iconColor,
                      fontSize: isVerySmall ? 16 : 24,
                    ),
                  ),
                ),
                SizedBox(height: isVerySmall ? 2 : AppDimensions.spacingXS),
                Flexible(
                  child: Text(
                    label,
                    style: (isVerySmall ? AppTextStyles.labelSmall : AppTextStyles.statLabel),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: isVerySmall ? 1 : 2,
                  ),
                ),
                SizedBox(height: isVerySmall ? 2 : AppDimensions.spacingXS),
                Flexible(
                  child: Text(
                    value,
                    style: (isVerySmall
                        ? AppTextStyles.titleSmall
                        : AppTextStyles.statValue),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
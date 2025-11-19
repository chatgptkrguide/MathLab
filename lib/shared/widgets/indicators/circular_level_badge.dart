import 'package:flutter/material.dart';
import '../../constants/figma_colors.dart';
import '../../constants/app_text_styles.dart';

/// Figma 디자인 원형 레벨 배지
/// 크기: 117x117
/// 순수 디자인만 구현
class CircularLevelBadge extends StatelessWidget {
  final int level;
  final Color backgroundColor;
  final Color textColor;

  const CircularLevelBadge({
    super.key,
    required this.level,
    this.backgroundColor = FigmaColors.cardDefault,
    this.textColor = FigmaColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FigmaSizes.circularBadgeSize,
      height: FigmaSizes.circularBadgeSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [FigmaColors.cardShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$level',
            style: AppTextStyles.displaySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
          Text(
            '레벨',
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma 디자인 원형 XP 배지
/// 크기: 117x117
/// 순수 디자인만 구현
class CircularXPBadge extends StatelessWidget {
  final int currentXP;
  final int maxXP;
  final Color backgroundColor;
  final Color textColor;

  const CircularXPBadge({
    super.key,
    required this.currentXP,
    required this.maxXP,
    this.backgroundColor = FigmaColors.cardDefault,
    this.textColor = FigmaColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FigmaSizes.circularBadgeSize,
      height: FigmaSizes.circularBadgeSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [FigmaColors.cardShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$currentXP',
            style: AppTextStyles.displaySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'XP',
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lifetime XP 배지
/// 크기: 78x43
/// 순수 디자인만 구현
class LifetimeXPBadge extends StatelessWidget {
  final int totalXP;

  const LifetimeXPBadge({
    super.key,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FigmaColors.cardDefault,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [FigmaColors.smallShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lifetime XP',
            style: AppTextStyles.bodySmall.copyWith(
              color: FigmaColors.textSecondary,
              fontSize: 9,
            ),
          ),
          Text(
            totalXP.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: FigmaColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

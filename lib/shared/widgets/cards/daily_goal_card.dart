import 'package:flutter/material.dart';
import '../../constants/figma_colors.dart';
import '../../constants/app_text_styles.dart';

/// Figma 디자인 "오늘의 목표" 카드
/// 크기: 366x88
/// 순수 디자인만 구현 (기능 없음)
class DailyGoalCard extends StatelessWidget {
  final String icon;
  final String title;
  final double progress;
  final int current;
  final int total;

  const DailyGoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.progress,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 366,
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FigmaColors.cardDefault,
        borderRadius: BorderRadius.circular(FigmaSizes.cardBorderRadius),
        boxShadow: [FigmaColors.cardShadow],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: FigmaSizes.iconMedium,
            height: FigmaSizes.iconMedium,
            decoration: BoxDecoration(
              color: FigmaColors.cardInfo,
              borderRadius: BorderRadius.circular(FigmaSizes.smallBorderRadius),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: FigmaColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // 진행률 바
                Stack(
                  children: [
                    // 배경
                    Container(
                      height: FigmaSizes.progressBarHeightGoal,
                      decoration: BoxDecoration(
                        color: FigmaColors.progressBackground,
                        borderRadius: BorderRadius.circular(
                          FigmaSizes.progressBorderRadius,
                        ),
                      ),
                    ),
                    // 진행률
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: FigmaSizes.progressBarHeightGoal,
                        decoration: BoxDecoration(
                          color: FigmaColors.progressTeal,
                          borderRadius: BorderRadius.circular(
                            FigmaSizes.progressBorderRadius,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // 진행 텍스트
                Text(
                  '$current / $total ${title.contains('문제') ? '완료' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: FigmaColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

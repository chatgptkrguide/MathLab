import 'package:flutter/material.dart';
import '../../constants/constants.dart';

/// 일일 목표 카드 위젯
class DailyGoalCard extends StatelessWidget {
  final int currentXP;
  final int goalXP;
  final VoidCallback? onTap;

  const DailyGoalCard({
    super.key,
    required this.currentXP,
    required this.goalXP,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXP / goalXP).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: const Border(
          left: BorderSide(color: AppColors.mathBlue, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.mathYellow,
                      size: 24,
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Text(
                        '일일 목표',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$currentXP / $goalXP XP',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.mathBlue.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mathBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

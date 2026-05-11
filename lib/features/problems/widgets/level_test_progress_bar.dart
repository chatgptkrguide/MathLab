// Level test progress bar — current / total label + progress percentage and
// a linear progress indicator.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

class LevelTestProgressBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final double progress;

  const LevelTestProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Anti-AI: slightly varied padding
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing20,
        AppDimensions.spacing14,
        AppDimensions.spacing20,
        AppDimensions.spacing8,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentIndex + 1} / $total',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.skyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.nodeLockedBg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.skyBlue),
            ),
          ),
        ],
      ),
    );
  }
}

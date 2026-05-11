// Level test header — gradient bar with close button, title, and a heart
// indicator. Used on the level test screen.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

class LevelTestHeader extends StatelessWidget {
  final int hearts;
  final VoidCallback onClose;

  const LevelTestHeader({
    super.key,
    required this.hearts,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing16,
        AppDimensions.spacing12,
        AppDimensions.spacing16,
        AppDimensions.spacing12,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.skyBlueGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radius10),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Text(
              '레벨테스트',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          // 하트
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.red, size: 18),
                const SizedBox(width: AppDimensions.spacing4),
                Text(
                  '$hearts',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

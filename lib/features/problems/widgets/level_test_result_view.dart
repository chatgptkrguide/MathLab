// Level test result view — shown after the user has answered all problems
// or run out of hearts. Displays the percentage, assigned rank, and a CTA
// to return home.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

class LevelTestResultView extends StatelessWidget {
  final int correctCount;
  final int total;
  final VoidCallback onClose;

  const LevelTestResultView({
    super.key,
    required this.correctCount,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (correctCount / total * 100).toInt() : 0;

    String rankResult;
    Color rankColor;
    if (percentage >= 90) {
      rankResult = 'GT Lv1';
      rankColor = AppColors.adminPurple;
    } else if (percentage >= 70) {
      rankResult = 'H Lv1';
      rankColor = const Color(0xFF2196F3);
    } else {
      rankResult = 'A Lv1';
      rankColor = const Color(0xFF4CAF50);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.skyBlueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 80, color: Colors.white),
                const SizedBox(height: AppDimensions.spacing24),
                Text(
                  '레벨테스트 완료!',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  '$correctCount / $total 정답 ($percentage%)',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing32),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing32,
                      vertical: AppDimensions.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '당신의 랭크',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        rankResult,
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: rankColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing40),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightLarge,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.skyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radius16),
                        ),
                      ),
                      child: Text(
                        '홈으로 돌아가기',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

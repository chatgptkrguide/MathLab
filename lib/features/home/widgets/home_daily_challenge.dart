import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 피그마 골드 배경(#F3C283) 데일리 챌린지 카드
class HomeDailyChallenge extends StatelessWidget {
  const HomeDailyChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽: 아이콘
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: AppDimensions.iconLarge,
              ),
            ),

            const SizedBox(width: AppDimensions.spacing16),

            // 중앙: 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 챌린지',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    '5문제 연속 정답 달성하기!',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  // 진행률 바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radius4),
                    child: LinearProgressIndicator(
                      value: 0.4,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    '2/5 완료',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppDimensions.spacing12),

            // 보상 표시
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
              ),
              child: Column(
                children: [
                  Text(
                    '+30',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'XP',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

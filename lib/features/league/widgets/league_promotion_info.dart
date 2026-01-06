import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 리그 승급/강등 안내 위젯
///
/// 승급 및 강등 기준을 시각적으로 표시
/// - 승급: 상위 10명 (초록색)
/// - 강등: 하위 5명 (빨간색)
/// - Duolingo 스타일 그라디언트 카드
class LeaguePromotionInfo extends StatelessWidget {
  const LeaguePromotionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 승급 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mathGreen.withOpacity(0.15),
                    AppColors.mathGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.mathGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mathGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: AppColors.mathGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '승급',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '상위 10명',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.mathGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 강등 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mathRed.withOpacity(0.15),
                    AppColors.mathRed.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.mathRed.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mathRed.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.mathRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '강등',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '하위 5명',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.mathRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

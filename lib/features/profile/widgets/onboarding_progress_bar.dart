import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 온보딩 프로그레스 바 위젯
///
/// 듀오링고 스타일의 XP 프로그레스 바로 현재 진행률을 표시합니다.
class OnboardingProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / totalPages;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(
          left: AppDimensions.spacing24,
          right: AppDimensions.spacing24,
          top: AppDimensions.spacing16, // 노치 아래 추가 여백
          bottom: AppDimensions.spacing20,
        ),
        child: Column(
          children: [
            // XP 스타일 프로그레스 바
            Row(
              children: [
                // 레벨 아이콘 (듀오링고 녹색)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.mathGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mathGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${currentPage + 1}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                // 프로그레스 바
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                    child: Stack(
                      children: [
                        // 배경 그라디언트
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.borderLight.withValues(alpha: 0.3),
                                AppColors.borderLight.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppDimensions.radius12),
                          ),
                        ),
                        // 진행률 (듀오링고 녹색 그라디언트)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: (MediaQuery.of(context).size.width - 120) *
                              progress,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.mathGreenLight, // 밝은 녹색
                                AppColors.mathGreen, // 듀오링고 녹색
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppDimensions.radius12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mathGreen.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                // 퍼센트 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mathBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mathBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            // 단계 텍스트
            Text(
              '${currentPage + 1} / $totalPages 단계',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

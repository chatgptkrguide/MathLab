import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
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
    // 듀오링고 녹색
    const duolingoGreen = Color(0xFF58CC02);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16, // 노치 아래 추가 여백
          bottom: 20,
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
                    color: duolingoGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: duolingoGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${currentPage + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 프로그레스 바
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
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
                            borderRadius: BorderRadius.circular(12),
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
                                Color(0xFF89E219), // 밝은 녹색
                                Color(0xFF58CC02), // 듀오링고 녹색
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: duolingoGreen.withValues(alpha: 0.4),
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
                const SizedBox(width: 12),
                // 퍼센트 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mathBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 8),
            // 단계 텍스트
            Text(
              '${currentPage + 1} / $totalPages 단계',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

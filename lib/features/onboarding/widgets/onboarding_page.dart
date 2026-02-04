import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../onboarding_screen.dart';

/// 온보딩 개별 페이지 위젯
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int pageNumber;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.pageNumber,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 아이콘
              Icon(
                data.icon,
                size: 120,
                color: AppColors.surface,
              ),
              const SizedBox(height: AppDimensions.spacingXL),
              // 제목
              Text(
                data.title,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              // 설명
              Text(
                data.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              // 기능 목록
              if (data.features != null) ...[
                const SizedBox(height: AppDimensions.spacingL),
                ...data.features!.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.surface,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

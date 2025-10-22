import 'package:flutter/material.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../onboarding_screen.dart';

/// 온보딩 개별 페이지
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 이모지 아이콘
              FadeInWidget(
                delay: const Duration(milliseconds: 100),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      data.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXXL),

              // 타이틀
              FadeInWidget(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  data.title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // 설명
              FadeInWidget(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  data.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 기능 리스트 (있는 경우)
              if (data.features != null && data.features!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingXXL),
                ...List.generate(
                  data.features!.length,
                  (index) => FadeInWidget(
                    delay: Duration(milliseconds: 400 + (index * 100)),
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacingM,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.features![index],
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

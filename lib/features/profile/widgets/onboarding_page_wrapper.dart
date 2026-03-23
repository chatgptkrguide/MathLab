import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 온보딩 페이지 래퍼 위젯
///
/// 각 온보딩 페이지의 공통 레이아웃을 제공합니다.
/// 한 화면에 모든 콘텐츠가 보이도록 스크롤 없이 구성합니다.
class OnboardingPageWrapper extends StatelessWidget {
  final String question;
  final String subtitle;
  final Widget content;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool canProceed;
  final VoidCallback onContinue;
  final bool isLastPage;
  final bool isLoading;
  final String? skipButtonText;
  final VoidCallback? onSkip;

  const OnboardingPageWrapper({
    super.key,
    required this.question,
    required this.subtitle,
    required this.content,
    this.showBackButton = false,
    this.onBack,
    required this.canProceed,
    required this.onContinue,
    this.isLastPage = false,
    this.isLoading = false,
    this.skipButtonText,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 뒤로가기 버튼
            if (showBackButton)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              )
            else
              const SizedBox(height: 16),

            const SizedBox(height: 12),

            // 질문 텍스트
            Text(
              question,
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // 부제목
            Text(
              subtitle,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            // 컨텐츠 (남은 공간 차지)
            Expanded(child: content),

            // 하단 고정 버튼 영역
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 계속하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canProceed ? onContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canProceed
                            ? AppColors.mathGreen
                            : AppColors.borderLight,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.borderLight,
                        disabledForegroundColor: AppColors.textTertiary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              isLastPage ? '시작하기' : '계속하기',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // 건너뛰기 버튼
                  if (onSkip != null || skipButtonText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: onSkip,
                        child: Text(
                          skipButtonText ?? '건너뛰기',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
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

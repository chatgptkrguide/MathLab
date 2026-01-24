import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

/// 온보딩 페이지 래퍼 위젯
///
/// 각 온보딩 페이지의 공통 레이아웃을 제공합니다.
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
      child: Column(
        children: [
          // 스크롤 가능한 컨텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 뒤로가기 버튼
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(height: 24),

                  // 질문 텍스트
                  Text(
                    question,
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 부제목
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 컨텐츠
                  content,

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼 영역 (스크롤 밖)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 계속하기 버튼 (듀오링고 스타일)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: canProceed ? onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed
                          ? const Color(0xFF58CC02) // 듀오링고 녹색
                          : const Color(0xFFE5E5E5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE5E5E5),
                      disabledForegroundColor: AppColors.textTertiary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: canProceed
                            ? const BorderSide(
                                color: Color(0xFF46A302),
                                width: 0,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLastPage ? '🚀 시작하기' : '계속하기',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (canProceed) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),

                // 건너뛰기 버튼
                if (onSkip != null || skipButtonText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
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
    );
  }
}

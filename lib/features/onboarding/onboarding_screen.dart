import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/analytics_service.dart';
import '../../core/utils/app_logger.dart';
import 'widgets/onboarding_page.dart';

/// 온보딩 화면
/// 새로운 사용자를 위한 앱 기능 소개
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  static const String _onboardingCompleteKey = 'onboarding_completed';

  /// 온보딩 완료 여부 확인
  static Future<bool> isOnboardingCompleted() async {
    try {
      final storage = LocalStorageService();
      final data = await storage.loadMap(_onboardingCompleteKey);
      return data?['completed'] == true;
    } catch (e) {
      AppLogger.error('Failed to check onboarding status', error: e);
      return false;
    }
  }

  /// 온보딩 상태 초기화 (테스트용)
  static Future<void> resetOnboarding() async {
    try {
      final storage = LocalStorageService();
      await storage.remove(_onboardingCompleteKey);
      AppLogger.info('Onboarding reset');
    } catch (e) {
      AppLogger.error('Failed to reset onboarding', error: e);
    }
  }

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final LocalStorageService _storage = LocalStorageService();

  int _currentPage = 0;
  static const int _totalPages = 3;

  // 온보딩 페이지 데이터 (6개 → 3개로 축소)
  final List<OnboardingPageData> _pages = const [
    // 페이지 1: 환영 + 핵심 가치 제안
    OnboardingPageData(
      icon: Icons.menu_book,
      title: 'MathLab에 오신 것을\n환영합니다!',
      description: '매일 5분, 수학이 쉬워지는\n게임처럼 즐거운 학습 여정',
      gradient: [AppColors.skyBlue, AppColors.mathBlue],
      features: [
        '듀오링고 스타일 게임 학습',
        '단계별 맞춤 커리큘럼',
        '재미있는 성취 시스템',
      ],
    ),
    // 페이지 2: 통합 게이미피케이션 (XP + 스트릭 + 리그)
    OnboardingPageData(
      icon: Icons.emoji_events,
      title: '함께 성장하는\n학습 경험',
      description: 'XP를 쌓고, 연속 학습하며\n친구들과 경쟁해보세요',
      gradient: [
        AppColors.mathYellow,
        AppColors.mathOrange,
      ],
      features: [
        '📊 XP & 레벨: Bronze → Diamond',
        '🔥 스트릭: 매일 학습 동기부여',
        '🏆 주간 리그: 50명과 경쟁',
        '💡 힌트 & 오답노트로 복습',
      ],
    ),
    // 페이지 3: 시작하기
    OnboardingPageData(
      icon: Icons.flag,
      title: '지금 바로\n시작하세요!',
      description: '3분이면 설정 완료!\n오늘부터 수학 실력을 쌓아가요',
      gradient: [AppColors.skyBlue, AppColors.mathBlue],
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle grain texture
          const NoiseTexture(opacity: 0.02),
          // 페이지 뷰
          PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: (index) async {
              await AppHapticFeedback.selectionClick();
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _pages[index],
                pageNumber: index + 1,
                totalPages: _totalPages,
              );
            },
          ),

          // 상단 건너뛰기 버튼
          if (_currentPage < _totalPages - 1)
            Positioned(
              top: AppDimensions.paddingL,
              right: AppDimensions.paddingL,
              child: SafeArea(
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    '건너뛰기',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // 하단 네비게이션
          Positioned(
            bottom: AppDimensions.paddingXL,
            left: AppDimensions.paddingXL,
            right: AppDimensions.paddingXL,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXL),

                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.mathBlue,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusL),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentPage == _totalPages - 1 ? '시작하기' : '다음',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXS),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color:
            isActive ? AppColors.surface : AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
    );
  }

  Future<void> _nextPage() async {
    await AppHapticFeedback.lightImpact();

    if (_currentPage < _totalPages - 1) {
      // 다음 페이지로 이동
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // 온보딩 완료
      await _completeOnboarding();
    }
  }

  Future<void> _skipOnboarding() async {
    await AppHapticFeedback.lightImpact();

    if (!mounted) return;

    // 확인 다이얼로그
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.warningOrange, size: 24),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              '튜토리얼 건너뛰기',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '앱 사용법을 나중에 다시 확인할 수 있습니다.\n정말 건너뛰시겠습니까?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '취소',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              '건너뛰기',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.mathBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldSkip == true && mounted) {
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // 온보딩 완료 상태 저장
      await _storage.saveMap(OnboardingScreen._onboardingCompleteKey, {
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
      });

      // Analytics: 온보딩 완료 기록
      await AnalyticsService().logEvent(
        name: 'onboarding_complete',
        parameters: {
          'completed_at': DateTime.now().toIso8601String(),
        },
      );

      AppLogger.info('Onboarding completed');

      if (mounted) {
        // AuthWrapper의 콜백이 있으면 사용, 없으면 직접 네비게이션
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      AppLogger.error('Failed to complete onboarding', error: e);
    }
  }
}

/// 온보딩 페이지 데이터
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final List<String>? features;
  final bool isLast;

  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    this.features,
    this.isLast = false,
  });
}

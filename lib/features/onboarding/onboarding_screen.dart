import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/constants.dart';
import '../../shared/utils/haptic_feedback.dart';
import '../../data/services/local_storage_service.dart';
import '../../shared/utils/logger.dart';
import 'widgets/onboarding_page.dart';

/// 온보딩 화면
/// 새로운 사용자를 위한 앱 기능 소개
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingCompleteKey = 'onboarding_completed';

  /// 온보딩 완료 여부 확인
  static Future<bool> isOnboardingCompleted() async {
    try {
      final storage = LocalStorageService();
      final data = await storage.loadMap(_onboardingCompleteKey);
      return data?['completed'] == true;
    } catch (e) {
      Logger.error('Failed to check onboarding status', error: e);
      return false;
    }
  }

  /// 온보딩 상태 초기화 (테스트용)
  static Future<void> resetOnboarding() async {
    try {
      final storage = LocalStorageService();
      await storage.remove(_onboardingCompleteKey);
      Logger.info('Onboarding reset');
    } catch (e) {
      Logger.error('Failed to reset onboarding', error: e);
    }
  }

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final LocalStorageService _storage = LocalStorageService();

  int _currentPage = 0;
  static const int _totalPages = 6;

  // 온보딩 페이지 데이터
  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.menu_book,
      title: 'GoMath에 오신 것을\n환영합니다!',
      description: '매일 5분, 수학이 쉬워지는\n즐거운 학습 여정을 시작해요',
      gradient: AppColors.mathBlueGradient,
    ),
    OnboardingPageData(
      icon: Icons.diamond_outlined,
      title: 'XP와 레벨 시스템',
      description: '문제를 풀면서 XP를 획득하고\nBronze부터 Diamond까지 레벨업하세요',
      gradient: AppColors.mathOrangeGradient,
      features: [
        '문제당 최대 15 XP 획득',
        '5개 레벨: Bronze → Diamond',
        '꾸준한 성장 추적',
      ],
    ),
    OnboardingPageData(
      icon: Icons.local_fire_department,
      title: '스트릭과 하트',
      description: '매일 학습하며 스트릭을 유지하고\n하트를 관리하세요',
      gradient: AppColors.mathPurpleGradient,
      features: [
        '연속 학습 스트릭 추적',
        '하트 5개로 시작',
        '30분마다 하트 1개 재생',
      ],
    ),
    OnboardingPageData(
      icon: Icons.emoji_events,
      title: '주간 리그 경쟁',
      description: '50명과 함께 주간 리그에서\n경쟁하며 승급을 노리세요',
      gradient: [
        AppColors.mathYellow, // GoMath 골드
        AppColors.mathOrange, // GoMath 오렌지
      ],
      features: [
        '상위 20% 승급',
        '하위 20% 강등',
        '매주 월요일 초기화',
      ],
    ),
    OnboardingPageData(
      icon: Icons.lightbulb,
      title: '힌트와 오답 노트',
      description: '막힐 때는 힌트를 사용하고\n틀린 문제는 복습하세요',
      gradient: AppColors.mathPurpleGradient,
      features: [
        '힌트 1개당 10 XP',
        '오답 자동 저장',
        '망각 곡선 기반 복습',
      ],
    ),
    OnboardingPageData(
      icon: Icons.flag,
      title: '지금 바로 시작하세요!',
      description: '매일 5분으로 수학 실력을\n쌓아가는 여정을 시작해보세요',
      gradient: AppColors.mathBlueGradient,
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
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
        color: isActive
            ? AppColors.surface
            : AppColors.surface.withOpacity(0.3),
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

      Logger.info('Onboarding completed');

      if (mounted) {
        // 메인 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      Logger.error('Failed to complete onboarding', error: e);
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

import 'package:flutter/material.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../shared/constants/constants.dart';

/// 스플래시 화면
/// 앱 초기화 및 온보딩 상태 확인
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 설정
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // 초기화 및 라우팅
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 최소 스플래시 표시 시간 보장
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2000)),
      _checkOnboardingStatus(),
    ]);

    if (mounted) {
      final isOnboardingCompleted =
          await OnboardingScreen.isOnboardingCompleted();

      if (isOnboardingCompleted) {
        // 온보딩 완료 → 홈 화면
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // 온보딩 미완료 → 온보딩 화면
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  Future<void> _checkOnboardingStatus() async {
    // 추가 초기화 작업이 있다면 여기서 수행
    // 예: 사용자 데이터 로드, 설정 로드 등
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 - 수학 기호와 주판
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 배경 원형
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1), // Indigo
                              Color(0xFF8B5CF6), // Purple
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // 주판 이모지
                      const Text(
                        '🧮',
                        style: TextStyle(fontSize: 90),
                      ),
                      // 수학 기호들
                      Positioned(
                        top: 10,
                        right: 20,
                        child: Text(
                          '➕',
                          style: TextStyle(
                            fontSize: 30,
                            shadows: [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Text(
                          '✖️',
                          style: TextStyle(
                            fontSize: 28,
                            shadows: [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15,
                        left: 25,
                        child: Text(
                          '➗',
                          style: TextStyle(
                            fontSize: 26,
                            shadows: [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  // 앱 이름 with shadow
                  Text(
                    'MathLab',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontSize: 48,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingM),

                  // 서브 타이틀 with gradient effect
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '매일 성장하는 수학 학습',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL * 2),

                  // 로딩 인디케이터
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

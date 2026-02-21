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

    if (!mounted) return;

    final isOnboardingCompleted =
        await OnboardingScreen.isOnboardingCompleted();

    if (!mounted) return;

    if (isOnboardingCompleted) {
      // 온보딩 완료 → 홈 화면
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // 온보딩 미완료 → 온보딩 화면
      Navigator.of(context).pushReplacementNamed('/onboarding');
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

  /// 로고 이미지 위젯 (로드 실패 시 π 심볼 폴백)
  Widget _buildLogo() {
    return Image.asset(
      'assets/icons/logo_main.png',
      width: 160,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 기존 π 심볼 폴백
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.3),
                AppColors.surface.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              'π',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
                shadows: [
                  Shadow(
                    color: AppColors.mathButtonBlue.withValues(alpha: 0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 이미지 (실패 시 π 폴백)
                  _buildLogo(),

                  const SizedBox(height: AppDimensions.spacingXXL),

                  // 앱 이름
                  Text(
                    'MathLab',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingS),

                  // 서브 타이틀
                  Text(
                    '매일 5분, 수학이 쉬워진다',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXXL * 2),

                  // 로딩 인디케이터
                  const SizedBox(
                    width: AppDimensions.spacing40,
                    height: AppDimensions.spacing40,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.surface),
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

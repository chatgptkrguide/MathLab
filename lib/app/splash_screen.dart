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

  /// "Math is Fun!!!" 텍스트 위젯
  Widget _buildMathIsFunText() {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "Math is" - 회전된 이탤릭 텍스트
          Positioned(
            top: 0,
            left: 40,
            child: Transform.rotate(
              angle: -0.15,
              child: Text(
                'Math is',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  fontSize: 28,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          // "Fun!!!" - 굵은 텍스트
          Positioned(
            bottom: 0,
            child: Text(
              'Fun!!!',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.mathYellow,
                fontWeight: FontWeight.w900,
                fontSize: 48,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: AppColors.mathYellow.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로봇 캐릭터 이미지 위젯
  Widget _buildRobotImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 로봇 이미지
        Image.asset(
          'assets/images/robot_3d.png',
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // 이미지 로드 실패 시 폴백
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 120,
                color: Colors.white70,
              ),
            );
          },
        ),
        // 말풍선 아이콘
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 44,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.mathYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: AppColors.darkNavy,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  /// GoMath Lab 텍스트
  Widget _buildGoMathLabText() {
    return Text(
      'GoMath Lab',
      style: AppTextStyles.displayLarge.copyWith(
        color: AppColors.surface,
        fontWeight: FontWeight.w900,
        fontSize: 32,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  /// GoMath 로고 위젯
  Widget _buildBottomLogo() {
    return Image.asset(
      'assets/icons/gomath_logo.png',
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // 로고 로드 실패 시 텍스트 폴백
        return Text(
          'GoMath',
          style: AppTextStyles.titleSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.darkNavy,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // "Math is Fun!!!" 텍스트
                  _buildMathIsFunText(),

                  const Spacer(),

                  // 로봇 캐릭터
                  _buildRobotImage(),

                  const SizedBox(height: AppDimensions.spacingXL),

                  // "GoMath Lab" 텍스트
                  _buildGoMathLabText(),

                  const Spacer(),

                  // 로딩 인디케이터
                  const SizedBox(
                    width: AppDimensions.spacing40,
                    height: AppDimensions.spacing40,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXL),

                  // GoMath 로고
                  _buildBottomLogo(),

                  const SizedBox(height: AppDimensions.spacingXXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../data/providers/auth/auth_provider.dart';
import '../../data/services/temp_profile_storage.dart';
import '../profile/onboarding_profile_setup_screen.dart';
import 'email_login_screen.dart';

/// 피그마 "00 홈1" 디자인 기반 로그인 화면
/// 다크 퍼플 배경 + Chatbot 캐릭터 + 로그인 버튼들
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGuestStart() async {
    if (_isLoading) return;

    try {
      // 1. 프로필 설정 화면으로 이동하여 정보 입력
      final profileResult = await Navigator.of(context).push<TempProfileData>(
        MaterialPageRoute(
          builder: (context) => const OnboardingProfileSetupScreen(),
        ),
      );

      if (profileResult == null || !mounted) return;

      setState(() => _isLoading = true);

      // 2. 게스트 계정 생성
      final success = await ref.read(authProvider.notifier).signInAsGuest();

      if (!mounted) return;

      if (success) {
        // 3. 프로필 정보를 게스트 계정에 적용
        await ref.read(authProvider.notifier).applyTempProfileToAccount(profileResult);

        // Success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${profileResult.name}님, 환영합니다! 🎉'),
                ],
              ),
              backgroundColor: const Color(0xFF58CC02),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError('게스트 계정 생성에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      if (mounted) _showError('예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;

    try {
      // 1. 프로필 설정 화면으로 이동하여 정보 입력
      final profileResult = await Navigator.of(context).push<TempProfileData>(
        MaterialPageRoute(
          builder: (context) => const OnboardingProfileSetupScreen(),
        ),
      );

      if (profileResult == null || !mounted) return;

      // 2. 프로필 정보를 임시 저장
      final tempStorage = ref.read(tempProfileStorageProvider);
      await tempStorage.saveTempProfile(profileResult);

      setState(() => _isLoading = true);

      // 3. 구글 로그인 실행 (프로필 정보 함께 전달)
      final success = await ref.read(authProvider.notifier).signInWithGoogle(
        tempProfile: profileResult,
      );

      if (!mounted) return;

      if (success) {
        // 4. 임시 프로필 정보 삭제
        await tempStorage.clearTempProfile();

        // Success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${profileResult.name}님, 환영합니다! 🎉'),
                ],
              ),
              backgroundColor: const Color(0xFF58CC02),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError('Google 로그인에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      if (mounted) _showError('Google 로그인 중 문제가 발생했습니다. 네트워크를 확인해주세요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInWithKakao();
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError('Kakao 로그인에 실패했습니다');
      }
    } catch (e) {
      if (mounted) _showError('Kakao 로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailLogin() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const EmailLoginScreen(),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.mathRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // 피그마 디자인의 다크 퍼플 배경색 (#211E41)
      backgroundColor: const Color(0xFF211E41),
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 컨텐츠
            SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // 상단 영역: Math is + Fun!!! + Chatbot (겹침)
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // 배경 텍스트들 (뒤쪽 레이어)
                        Column(
                          children: [
                            const SizedBox(height: 60), // Math is를 아래로 이동
                            // "Math is" (회전됨, 약간 기울어짐)
                            Transform.rotate(
                              angle: -0.0098, // -0.56도를 라디안으로: -0.56 * pi/180
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Image.asset(
                                  'assets/images/login/math_is_text.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30), // Math is → Fun 간격 줄임
                            // "Fun!!!"
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Image.asset(
                                'assets/images/login/fun_text.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        // Chatbot 캐릭터 (앞쪽 레이어, 텍스트 위에)
                        Positioned(
                          top: 130, // Math is 위치 조정에 따라 Chatbot도 조정
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Image.asset(
                              'assets/images/login/chatbot.png',
                              width: 206,
                              height: 206,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20), // Stack과 GoMath Lab 사이 간격

                    // "GoMath Lab" 텍스트 (Chatbot 바로 아래)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/images/login/gomath_lab_text.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 120), // GoMath Lab과 버튼 사이 간격 줄임

                    // 버튼들 (애니메이션)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // 시작하기 버튼 (메인) - 더 크고 눈에 띄게
                            _buildMainButton(
                              text: '시작하기',
                              onPressed: _handleGuestStart,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF58CC02),
                                  Color(0xFF46A302),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 구분선
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '또는',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Google 로그인
                            _buildSocialButton(
                              text: 'Google로 계속하기',
                              icon: Icons.g_mobiledata,
                              backgroundColor: Colors.white,
                              textColor: const Color(0xFF211E41),
                              onPressed: _handleGoogleLogin,
                            ),

                            const SizedBox(height: 12),

                            // Kakao 로그인
                            _buildSocialButton(
                              text: 'Kakao로 계속하기',
                              icon: Icons.chat_bubble,
                              backgroundColor: AppColors.kakaoYellow,
                              textColor: AppColors.kakaoBrown,
                              onPressed: _handleKakaoLogin,
                            ),

                            const SizedBox(height: 12),

                            // Email 로그인
                            _buildSocialButton(
                              text: '이메일로 계속하기',
                              icon: Icons.email,
                              backgroundColor: const Color(0xFF2D2A4A),
                              textColor: Colors.white,
                              onPressed: _handleEmailLogin,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 버튼 아래 공간 (로고까지)
                    SizedBox(height: size.height * 0.06),

                    // 로고 (맨 아래)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/images/login/logo.png',
                        width: 170,
                        height: 66,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // 로딩 오버레이
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 메인 버튼 (시작하기)
  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF58CC02).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'NexonGothic',
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 소셜 로그인 버튼
  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: backgroundColor == Colors.white
                ? Colors.grey.withOpacity(0.3)
                : backgroundColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 26),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  fontFamily: 'NexonGothic',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

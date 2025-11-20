import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';

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
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInAsGuest();
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError('게스트 로그인에 실패했습니다');
      }
    } catch (e) {
      if (mounted) _showError('로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError('Google 로그인에 실패했습니다');
      }
    } catch (e) {
      if (mounted) _showError('Google 로그인 실패: $e');
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

                    const SizedBox(height: 60), // GoMath Lab과 버튼 사이 간격

                    // 버튼들 (애니메이션)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // 시작하기 버튼 (메인)
                            _buildMainButton(
                              text: '시작하기',
                              onPressed: _handleGuestStart,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF58CC02),
                                  Color(0xFF4CAF50),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 구분선
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '또는',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
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
                          ],
                        ),
                      ),
                    ),

                    // 버튼 아래 공간 (로고까지)
                    SizedBox(height: size.height * 0.24),

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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'NexonGothic',
                letterSpacing: 1.0,
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: backgroundColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'NexonGothic',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_durations.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import 'email_login_screen.dart';
import 'logic/auth_handler.dart';

/// 피그마 디자인 기반 로그인 화면
/// 파란 배경 + 로봇 캐릭터 + 로그인 버튼들
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
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
      duration: AppDurations.authAnimation,
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

    await AuthHandler.handleGuestStart(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await AuthHandler.handleGoogleLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await AuthHandler.handleKakaoLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await AuthHandler.handleAppleLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailLogin() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const EmailLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // 피그마 디자인의 파란 배경색 (figma_home_reference.png 참고)
      backgroundColor: const Color(0xFF5BA4E6),
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 컨텐츠
            SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenHorizontalPadding,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // 로봇 캐릭터 (피그마 디자인)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/images/login/chatbot.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              size: 100,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // "오늘의 목표" 카드 (피그마 스타일)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5BA4E6).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.flag_rounded,
                                    color: Color(0xFF5BA4E6),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '수학 학습을 시작하세요!',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '매일 조금씩, 재미있게 배워요',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 진행바
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: 0.0,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF58CC02),
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 버튼들 (애니메이션)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // 시작하기 버튼 (메인 - 초록색)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleGuestStart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF58CC02),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: const Color(0xFF58CC02).withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  '학습 시작하기',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 구분선
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '또는',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Google 로그인
                            _buildSocialButton(
                              text: 'Google로 계속하기',
                              icon: 'assets/icons/google_icon.png',
                              fallbackIcon: Icons.g_mobiledata,
                              backgroundColor: Colors.white,
                              textColor: const Color(0xFF1A1A2E),
                              onPressed: _handleGoogleLogin,
                            ),

                            const SizedBox(height: 12),

                            // Apple 로그인 (iOS만 표시)
                            if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                              _buildSocialButton(
                                text: 'Apple로 계속하기',
                                icon: null,
                                fallbackIcon: Icons.apple,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                onPressed: _handleAppleLogin,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Kakao 로그인
                            _buildSocialButton(
                              text: 'Kakao로 계속하기',
                              icon: 'assets/icons/kakao_icon.png',
                              fallbackIcon: Icons.chat_bubble,
                              backgroundColor: AppColors.kakaoYellow,
                              textColor: AppColors.kakaoBrown,
                              onPressed: _handleKakaoLogin,
                            ),

                            const SizedBox(height: 12),

                            // Email 로그인
                            _buildSocialButton(
                              text: '이메일로 계속하기',
                              icon: null,
                              fallbackIcon: Icons.email_outlined,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              textColor: Colors.white,
                              onPressed: _handleEmailLogin,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 하단 로고
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/images/login/logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'MathLab',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    // 약관 및 개인정보처리방침 링크
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: '계속 진행하면 '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                                  ),
                                  child: Text(
                                    '이용약관',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' 및 '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                                  ),
                                  child: Text(
                                    '개인정보처리방침',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '에 동의하게 됩니다.'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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

  Widget _buildSocialButton({
    required String text,
    required String? icon,
    required IconData fallbackIcon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Image.asset(
                icon,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, size: 24, color: textColor);
                },
              )
            else
              Icon(fallbackIcon, size: 24, color: textColor),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

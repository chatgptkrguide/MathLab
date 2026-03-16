import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_durations.dart';
import 'email_login_screen.dart';
import 'logic/auth_handler.dart';
import '../../shared/widgets/effects/noise_texture.dart';
import '../onboarding/demo_lesson_screen.dart';

/// Auth screen based on Figma design
/// Blue background + robot character + login buttons
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _showMoreLogin = false;
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

  // Kakao 로그인: SDK 호환성 문제로 비활성화 (Phase 2 예정)
  Future<void> _handleKakaoLogin() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kakao 로그인은 준비 중입니다')),
    );
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
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const NoiseTexture(opacity: 0.02, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Robot character - fills available space
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final imageSize = (constraints.maxHeight * 0.8).clamp(100.0, 220.0);
                            return Image.asset(
                              'assets/images/login/chatbot.png',
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                child: const Icon(Icons.smart_toy_rounded, size: 60, color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Buttons
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Primary CTA
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _handleGuestStart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mathGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Google (primary social)
                          _buildSocialButton(
                            text: 'Google로 계속하기',
                            fallbackIcon: Icons.g_mobiledata,
                            backgroundColor: Colors.white,
                            textColor: AppColors.textDark,
                            onPressed: _handleGoogleLogin,
                          ),
                          // Apple (iOS only, primary social)
                          if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                            const SizedBox(height: 6),
                            _buildSocialButton(
                              text: 'Apple로 계속하기',
                              fallbackIcon: Icons.apple,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              onPressed: _handleAppleLogin,
                            ),
                          ],
                          // More login options (collapsed)
                          if (!_showMoreLogin) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => setState(() => _showMoreLogin = true),
                              child: Text(
                                '다른 방법으로 로그인',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 6),
                            _buildSocialButton(
                              text: 'Kakao로 계속하기',
                              fallbackIcon: Icons.chat_bubble,
                              backgroundColor: AppColors.kakaoYellow,
                              textColor: AppColors.kakaoBrown,
                              onPressed: _handleKakaoLogin,
                            ),
                            const SizedBox(height: 6),
                            _buildSocialButton(
                              text: '이메일로 계속하기',
                              fallbackIcon: Icons.email_outlined,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              textColor: Colors.white,
                              onPressed: _handleEmailLogin,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Demo + Terms combined
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DemoLessonScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '먼저 체험해보기',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData fallbackIcon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(fallbackIcon, size: 22, color: textColor),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_durations.dart';
import '../../shared/constants/app_text_styles.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import 'email_login_screen.dart';
import 'logic/auth_handler.dart';
import '../../shared/widgets/effects/noise_texture.dart';

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
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        child: Stack(
          children: [
            const NoiseTexture(opacity: 0.02, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenHorizontalPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Robot character - fills available space
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final imageSize = constraints.maxHeight * 0.85;
                            return Image.asset(
                              'assets/images/login/chatbot.png',
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy_rounded,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Buttons with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Main start button (green)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _handleGuestStart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mathGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: AppColors.mathGreen.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                                ),
                              ),
                              child: Text(
                                '학습 시작하기',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
                                child: Text(
                                  '또는',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
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

                          const SizedBox(height: 12),

                          // Google login
                          _buildSocialButton(
                            text: 'Google로 계속하기',
                            icon: null,
                            fallbackIcon: Icons.g_mobiledata,
                            backgroundColor: Colors.white,
                            textColor: AppColors.textDark,
                            onPressed: _handleGoogleLogin,
                          ),

                          const SizedBox(height: 8),

                          // Apple login (iOS only)
                          if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                            _buildSocialButton(
                              text: 'Apple로 계속하기',
                              icon: null,
                              fallbackIcon: Icons.apple,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              onPressed: _handleAppleLogin,
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Kakao login
                          _buildSocialButton(
                            text: 'Kakao로 계속하기',
                            icon: null,
                            fallbackIcon: Icons.chat_bubble,
                            backgroundColor: AppColors.kakaoYellow,
                            textColor: AppColors.kakaoBrown,
                            onPressed: _handleKakaoLogin,
                          ),

                          const SizedBox(height: 8),

                          // Email login
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

                  const SizedBox(height: 12),

                  // Terms & privacy
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
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
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
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
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
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

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Loading overlay
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
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Image.asset(
                icon,
                width: AppDimensions.iconMedium,
                height: AppDimensions.iconMedium,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, size: AppDimensions.iconMedium, color: textColor);
                },
              )
            else
              Icon(fallbackIcon, size: AppDimensions.iconMedium, color: textColor),
            const SizedBox(width: AppDimensions.spacing12),
            Text(
              text,
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

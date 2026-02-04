import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../shared/constants/app_durations.dart';
import 'email_login_screen.dart';
import 'logic/auth_handler.dart';
import 'widgets/widgets.dart';

/// 피그마 "00 홈1" 디자인 기반 로그인 화면
/// 다크 퍼플 배경 + Chatbot 캐릭터 + 로그인 버튼들
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

    final success = await AuthHandler.handleGuestStart(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await AuthHandler.handleGoogleLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await AuthHandler.handleKakaoLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
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

  Widget _buildAssetImageOrFallback(
    String assetPath, {
    double? width,
    double? height,
    String? fallbackText,
    TextStyle? style,
    Widget? fallbackWidget,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (fallbackWidget != null) return fallbackWidget;
        return Text(
          fallbackText ?? '',
          style: style,
          textAlign: TextAlign.center,
        );
      },
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
                constraints: BoxConstraints(
                    minHeight:
                        size.height - MediaQuery.of(context).padding.top),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenHorizontalPadding),
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
                            SizedBox(
                                height: AppDimensions.authMathIsTopSpacing),
                            // "Math is" (회전됨, 약간 기울어짐)
                            Transform.rotate(
                              angle: -0.0098,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildAssetImageOrFallback(
                                  'assets/images/login/math_is_text.png',
                                  fallbackWidget: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Colors.white, Color(0xFFB8C4FF)],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Math is',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: AppDimensions.authMathIsFunSpacing),
                            // "Fun!!!"
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildAssetImageOrFallback(
                                'assets/images/login/fun_text.png',
                                fallbackWidget: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFF58CC02), Color(0xFF7BE834)],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Fun!!!',
                                    style: TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Chatbot 캐릭터 (앞쪽 레이어, 텍스트 위에)
                        Positioned(
                          top: AppDimensions.authChatbotTopPosition,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildAssetImageOrFallback(
                              'assets/images/login/chatbot.png',
                              width: AppDimensions.chatbotImageSize,
                              height: AppDimensions.chatbotImageSize,
                              fallbackWidget: Container(
                                width: AppDimensions.chatbotImageSize * 0.7,
                                height: AppDimensions.chatbotImageSize * 0.7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF58CC02), Color(0xFF7BE834)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF58CC02).withOpacity(0.4),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.smart_toy_rounded,
                                  size: AppDimensions.chatbotImageSize * 0.35,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20), // Stack과 GoMath Lab 사이 간격

                    // "GoMath Lab" 텍스트 (Chatbot 바로 아래)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAssetImageOrFallback(
                        'assets/images/login/gomath_lab_text.png',
                        fallbackWidget: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFD0D8FF)],
                              ).createShader(bounds),
                              child: const Text(
                                'GoMath Lab',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '수학을 재미있게, 매일 조금씩',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                        height: AppDimensions
                            .authGomathButtonSpacing), // GoMath Lab과 버튼 사이 간격

                    // 버튼들 (애니메이션)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // 시작하기 버튼 (메인) - 더 크고 눈에 띄게
                            AuthMainButton(
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

                            SizedBox(height: AppDimensions.authButtonSpacing),

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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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

                            SizedBox(
                                height: AppDimensions.authDividerButtonSpacing),

                            // Google 로그인
                            AuthSocialButton(
                              text: 'Google로 계속하기',
                              icon: Icons.g_mobiledata,
                              backgroundColor: Colors.white,
                              textColor: const Color(0xFF211E41),
                              onPressed: _handleGoogleLogin,
                            ),

                            SizedBox(
                                height: AppDimensions.authButtonSmallSpacing),

                            // Kakao 로그인
                            AuthSocialButton(
                              text: 'Kakao로 계속하기',
                              icon: Icons.chat_bubble,
                              backgroundColor: AppColors.kakaoYellow,
                              textColor: AppColors.kakaoBrown,
                              onPressed: _handleKakaoLogin,
                            ),

                            SizedBox(
                                height: AppDimensions.authButtonSmallSpacing),

                            // Email 로그인
                            AuthSocialButton(
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
                      child: _buildAssetImageOrFallback(
                        'assets/images/login/logo.png',
                        width: AppDimensions.logoWidth,
                        height: AppDimensions.logoHeight,
                        fallbackWidget: Icon(
                          Icons.calculate_rounded,
                          size: AppDimensions.logoHeight,
                          color: Colors.white54,
                        ),
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
}

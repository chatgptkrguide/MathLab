import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_durations.dart';
import 'logic/auth_handler.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.authAnimation,
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
    await AuthHandler.handleGuestStart(context: context, ref: ref, mounted: mounted);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await AuthHandler.handleGoogleLogin(context: context, ref: ref, mounted: mounted);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleAppleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await AuthHandler.handleAppleLogin(context: context, ref: ref, mounted: mounted);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 피그마 배경색: #211E41 (darkNavy)
        color: const Color(0xFF211E41),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28, 0, 28, bottom + 16),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // "Math is Fun!!!" 텍스트 (Inter 영문 디스플레이, 매우 굵게)
                      Transform.rotate(
                        angle: -0.06,
                        child: const Text(
                          'Math is\nFun!!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3D 로봇 캐릭터 (피그마에서 추출)
                      Image.asset(
                        'assets/images/login/chatbot.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy_rounded, size: 100, color: Colors.white54,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // "GoMath Lab" 타이틀 (Inter, 살짝 가벼운 weight로 위계)
                      const Text(
                        'GoMath Lab',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // 시작 버튼 (피그마 스타일)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleGuestStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B6EF5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Google 로그인 — 메인 채움 버튼 (최우선 소셜 옵션)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleGoogleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF3C3C3C),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata, size: 22, color: AppColors.googleBlue),
                              const SizedBox(width: 8),
                              const Text('Google로 계속하기',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3C3C3C))),
                            ],
                          ),
                        ),
                      ),

                      // Apple 로그인 (iOS 전용) — 짙은 채움 버튼 (2순위)
                      if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: _handleAppleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.apple, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text('Apple로 계속하기',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                            ]),
                          ),
                        ),
                      ],

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                Container(color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}

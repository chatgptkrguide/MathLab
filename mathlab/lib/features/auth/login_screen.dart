import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/fade_in_widget.dart';
import '../../data/providers/auth_provider.dart';
import '../../app/main_navigation.dart';

/// Login Screen (로그인 화면)
/// 구글과 카카오 간편 로그인
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.mathBlueGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 40 : 60),

                  // GoMATH 로고
                  FadeInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: _buildLogo(isMobile),
                  ),

                  SizedBox(height: isMobile ? 40 : 80),

                  // 환영 메시지
                  FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        Text(
                          '수학 학습의 새로운 시작',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '간편하게 로그인하고\n재미있는 수학 학습을 시작하세요',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isMobile ? 40 : 80),

                  // 구글 로그인 버튼
                  FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: _buildGoogleLoginButton(context, ref),
                  ),

                  const SizedBox(height: 16),

                  // 카카오 로그인 버튼
                  FadeInWidget(
                    delay: const Duration(milliseconds: 400),
                    child: _buildKakaoLoginButton(context, ref),
                  ),

                  SizedBox(height: isMobile ? 24 : 40),

                  // 이용약관 및 개인정보처리방침
                  FadeInWidget(
                    delay: const Duration(milliseconds: 500),
                    child: _buildTermsText(),
                  ),

                  SizedBox(height: isMobile ? 24 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// GoMATH 로고
  Widget _buildLogo(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: isMobile ? 20 : 30,
            offset: Offset(0, isMobile ? 6 : 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 로고 이모지
          Text(
            '🎓',
            style: TextStyle(fontSize: isMobile ? 48 : 60),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // GoMATH 텍스트
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Go',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF61A1D8),
                  ),
                ),
                TextSpan(
                  text: 'MATH',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B5BFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 구글 로그인 버튼
  Widget _buildGoogleLoginButton(BuildContext context, WidgetRef ref) {
    return _LoginButton(
      onPressed: () => _handleGoogleLogin(context, ref),
      backgroundColor: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 구글 아이콘
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4285F4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Google로 계속하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 카카오 로그인 버튼
  Widget _buildKakaoLoginButton(BuildContext context, WidgetRef ref) {
    return _LoginButton(
      onPressed: () => _handleKakaoLogin(context, ref),
      backgroundColor: const Color(0xFFFEE500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 카카오 아이콘
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF3C1E1E),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFEE500),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '카카오로 계속하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C1E1E),
            ),
          ),
        ],
      ),
    );
  }

  /// 이용약관 텍스트
  Widget _buildTermsText() {
    return Text(
      '계속 진행하면 GoMATH의\n이용약관 및 개인정보처리방침에 동의하게 됩니다',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 구글 로그인 처리
  Future<void> _handleGoogleLogin(BuildContext context, WidgetRef ref) async {
    try {
      // auth provider에서 구글 로그인 호출
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithGoogle();

      if (success && context.mounted) {
        // 로그인 성공 - 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      } else if (context.mounted) {
        // 로그인 실패
        final error = ref.read(authProvider).error ?? '로그인에 실패했습니다';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 카카오 로그인 처리
  Future<void> _handleKakaoLogin(BuildContext context, WidgetRef ref) async {
    try {
      // auth provider에서 카카오 로그인 호출
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithKakao();

      if (success && context.mounted) {
        // 로그인 성공 - 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      } else if (context.mounted) {
        // 로그인 실패
        final error = ref.read(authProvider).error ?? '로그인에 실패했습니다';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// 로그인 버튼 위젯 (애니메이션 포함)
class _LoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  const _LoginButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.child,
  });

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

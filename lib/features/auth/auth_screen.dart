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
  bool _showGuestRoles = false;
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
    await AuthHandler.handleGuestStart(
      context: context,
      ref: ref,
      mounted: mounted,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  void _openGuestRoleSelection() {
    if (_isLoading) return;
    setState(() => _showGuestRoles = true);
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await AuthHandler.handleGoogleLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleAppleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await AuthHandler.handleAppleLogin(
      context: context,
      ref: ref,
      mounted: mounted,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB0E8), Color(0xFFFFB8EA), Color(0xFFFFD7F3)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeIn,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _showGuestRoles
                      ? _GuestRoleSelection(
                          key: const ValueKey('guest-roles'),
                          bottomPadding: bottom,
                          onBack: () => setState(() => _showGuestRoles = false),
                          onRoleSelected: _handleGuestStart,
                        )
                      : _WelcomeContent(
                          key: const ValueKey('welcome'),
                          onGuestStart: _openGuestRoleSelection,
                          onGoogleLogin: _handleGoogleLogin,
                          onAppleLogin: _handleAppleLogin,
                        ),
                ),
              ),
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
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent({
    super.key,
    required this.onGuestStart,
    required this.onGoogleLogin,
    required this.onAppleLogin,
  });

  final VoidCallback onGuestStart;
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _AuthPatternPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final visualHeight = constraints.maxHeight;
                  final characterSize = (visualHeight * 0.31).clamp(
                    160.0,
                    230.0,
                  );

                  return Column(
                    children: [
                      SizedBox(height: visualHeight * 0.08),
                      Image.asset(
                        'assets/images/login/math_is_fun_wordmark.png',
                        width: 240,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const Text(
                          'Math is\nFun!!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(height: visualHeight * 0.05),
                      Image.asset(
                        'assets/images/login/chatbot.png',
                        width: characterSize,
                        height: characterSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.smart_toy_rounded,
                          size: characterSize * 0.55,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      const _MathLabLogo(),
                      SizedBox(height: visualHeight * 0.05),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onGuestStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF526DFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'GUEST로 들어가기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onGoogleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3C3C3C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: AppColors.googleBlue,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Google로 계속하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (defaultTargetPlatform == TargetPlatform.iOS) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onAppleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF211E41),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Apple로 계속하기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MathLabLogo extends StatelessWidget {
  const _MathLabLogo({this.width = 272});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/login/mathlab_wordmark.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const Text(
        'MATHLAB',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Color(0xFF421A48),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AuthPatternPainter extends CustomPainter {
  const _AuthPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    void oval(double left, double top, double width, double height) {
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * left,
          size.height * top,
          size.width * width,
          size.height * height,
        ),
        paint,
      );
    }

    oval(-0.38, -0.05, 1.08, 0.38);
    oval(0.18, -0.06, 0.92, 0.43);
    oval(-0.06, 0.27, 1.04, 0.34);
    oval(0.42, 0.35, 0.84, 0.32);
    oval(-0.22, 0.66, 1.18, 0.34);
    oval(0.18, 0.77, 1.12, 0.33);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * -0.1, size.height * 0.18)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.06,
        size.width * 0.72,
        size.height * 0.28,
        size.width * 1.1,
        size.height * 0.12,
      )
      ..moveTo(size.width * -0.1, size.height * 0.53)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.44,
        size.width * 0.58,
        size.height * 0.67,
        size.width * 1.1,
        size.height * 0.57,
      )
      ..moveTo(size.width * -0.1, size.height * 0.86)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.72,
        size.width * 0.73,
        size.height * 0.96,
        size.width * 1.1,
        size.height * 0.82,
      );

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GuestRoleSelection extends StatelessWidget {
  const _GuestRoleSelection({
    super.key,
    required this.bottomPadding,
    required this.onBack,
    required this.onRoleSelected,
  });

  final double bottomPadding;
  final VoidCallback onBack;
  final VoidCallback onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF46D7D),
      child: CustomPaint(
        painter: const _RoleBackgroundPainter(),
        child: Column(
          children: [
            SizedBox(
              height: 166,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFE9829B),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(34),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 10,
                      child: IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Color(0xFF2F1742),
                      ),
                    ),
                    const Positioned(
                      left: 34,
                      top: 42,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요!',
                            style: TextStyle(
                              fontFamily: 'NexonLv1Gothic',
                              color: Color(0xFF2F1742),
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'MathDesigner의 수학 학습',
                            style: TextStyle(
                              fontFamily: 'NexonLv1Gothic',
                              color: Color(0xFF4E2857),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '수학공부가\n습관이 되도록 만드는\n게임형 학습 루프',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NexonLv1Gothic',
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w700,
                  height: 1.46,
                  shadows: [
                    Shadow(
                      color: Color(0xDDE9829B),
                      blurRadius: 0,
                      offset: Offset(3, 0),
                    ),
                    Shadow(
                      color: Color(0xFFFFFFFF),
                      blurRadius: 0,
                      offset: Offset(-1.2, 0),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 92),
              child: Column(
                children: [
                  _RoleButton(label: '학부모', onPressed: onRoleSelected),
                  const SizedBox(height: 14),
                  _RoleButton(label: '학생', onPressed: onRoleSelected),
                  const SizedBox(height: 14),
                  _RoleButton(label: '교사 및 멘토', onPressed: onRoleSelected),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.only(bottom: bottomPadding + 28),
              child: const _MathLabLogo(width: 292),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBackgroundPainter extends CustomPainter {
  const _RoleBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    for (var i = -5; i <= 12; i++) {
      final x = size.width * (i / 9);
      final path = Path()
        ..moveTo(x, size.height * 0.17)
        ..cubicTo(
          x + size.width * 0.12,
          size.height * 0.42,
          x - size.width * 0.10,
          size.height * 0.68,
          x + size.width * 0.03,
          size.height * 0.88,
        );
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < 14; i++) {
      final y = size.height * (0.19 + i * 0.055);
      final path = Path()
        ..moveTo(-size.width * 0.1, y)
        ..cubicTo(
          size.width * 0.25,
          y - size.height * 0.035,
          size.width * 0.64,
          y + size.height * 0.03,
          size.width * 1.1,
          y - size.height * 0.005,
        );
      canvas.drawPath(path, gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: Material(
        color: const Color(0xFFD7E1FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 34,
                color: const Color(0xFF7D83FF),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 28,
                  color: Color(0xFF111111),
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'NexonLv1Gothic',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
    );
  }
}

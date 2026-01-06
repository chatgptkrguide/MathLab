import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../lessons/figma/lessons_screen_figma.dart';

/// 홈 화면 학습 시작하기 버튼
///
/// Figma 디자인의 파란색 그라디언트 버튼
/// 클릭 시 레슨 선택 화면으로 이동
/// 향상된 애니메이션 및 햅틱 피드백 포함
class HomeStartButton extends StatefulWidget {
  const HomeStartButton({super.key});

  @override
  State<HomeStartButton> createState() => _HomeStartButtonState();
}

class _HomeStartButtonState extends State<HomeStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LessonsScreenFigma(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed
                  ? [const Color(0xFF0000CC), const Color(0xFF000099)]
                  : [const Color(0xFF0000FF), const Color(0xFF0000CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0000FF).withOpacity(_isPressed ? 0.5 : 0.3),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 4 : 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: _isPressed ? 26 : 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '학습 시작하기',
                  style: TextStyle(
                    fontSize: _isPressed ? 17 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

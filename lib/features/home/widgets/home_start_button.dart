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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // 하단 어두운 그림자 (3D 효과 - 듀오링고 스타일)
              BoxShadow(
                color: const Color(0xFF46A302),
                offset: Offset(0, _isPressed ? 2 : 4),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              // 주변 부드러운 그림자
              BoxShadow(
                color:
                    const Color(0xFF58CC02).withValues(alpha: _isPressed ? 0.3 : 0.4),
                blurRadius: _isPressed ? 8 : 12,
                offset: Offset(0, _isPressed ? 3 : 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              // 듀오링고 그린 그라디언트
              gradient: LinearGradient(
                colors: _isPressed
                    ? [const Color(0xFF46A302), const Color(0xFF3A8502)]
                    : [const Color(0xFF58CC02), const Color(0xFF46A302)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF70D820),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 상단 하이라이트 (3D 효과)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: _isPressed ? 0.1 : 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
                // 버튼 내용
                _buildButtonContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
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
            fontSize: _isPressed ? 19 : 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

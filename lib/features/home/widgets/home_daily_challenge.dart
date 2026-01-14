import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../daily_reward/daily_reward_screen.dart';

/// 홈 화면 데일리 챌린지 배너
///
/// 포함 내용:
/// - 데일리 챌린지 타이틀
/// - 설명 텍스트
/// - 미션 버튼
/// - 챌린지 이모지
/// 향상된 애니메이션 및 햅틱 피드백 포함
class HomeDailyChallenge extends StatefulWidget {
  const HomeDailyChallenge({super.key});

  @override
  State<HomeDailyChallenge> createState() => _HomeDailyChallengeState();
}

class _HomeDailyChallengeState extends State<HomeDailyChallenge>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
        builder: (context) => const DailyRewardScreen(),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed
                  ? [const Color(0xFFFF9800), const Color(0xFFEF6C00)]
                  : [const Color(0xFFFFA726), const Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFFFF9800).withValues(alpha: _isPressed ? 0.4 : 0.3),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '데일리 챌린지',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '오늘의 챌린지 미션을 완료해 보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '미션 시작',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 챌린지 이미지 with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _isPressed ? -0.1 : 0.0),
                duration: const Duration(milliseconds: 150),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value,
                    child: child,
                  );
                },
                child: const Text('🎬', style: TextStyle(fontSize: 60)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

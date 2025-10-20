import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_text_styles.dart';
import '../../shared/constants/app_dimensions.dart';
import '../../data/providers/user_provider.dart';
import '../../shared/widgets/fade_in_widget.dart';

/// Figma Screen 02: HomeScreen (메인 화면)
/// 정확한 Figma 디자인 구현
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.mathBlue,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // 헤더: "안녕하세요!" + 스트릭
                  FadeInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: _buildHeader(user),
                  ),
                  const SizedBox(height: 40),
                  // 중앙 UFO 일러스트 + 진행 원
                  FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: _buildCenterIllustration(),
                  ),
                  const SizedBox(height: 40),
                  // 오늘의 목표 카드
                  FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: _buildDailyGoalCard(),
                  ),
                  const SizedBox(height: 24),
                  // 학습 시작하기 버튼
                  FadeInWidget(
                    delay: const Duration(milliseconds: 400),
                    child: _buildStartButton(context),
                  ),
                  const SizedBox(height: 24),
                  // 통계 카드 3개
                  FadeInWidget(
                    delay: const Duration(milliseconds: 500),
                    child: _buildStatsCards(user),
                  ),
                  const SizedBox(height: 40),
                  // GoMATH 로고
                  FadeInWidget(
                    delay: const Duration(milliseconds: 600),
                    child: _buildLogo(),
                  ),
                  const SizedBox(height: 100), // 하단 네비게이션 바 공간 확보
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더: 안녕하세요! + 스트릭
  Widget _buildHeader(user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 좌측: 인사말
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '안녕하세요!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MathDesigner의 수학 학습',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        // 우측: 스트릭
        Row(
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 4),
            Text(
              '${user?.streak ?? 6}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 중앙 UFO 일러스트 + 진행 점들
  Widget _buildCenterIllustration() {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 진행 점들 (원형 배치)
          ...List.generate(12, (index) {
            final angle = (index * 30) * 3.14159 / 180;
            final radius = 110.0;
            final x = radius * math.cos(angle);
            final y = radius * math.sin(angle);
            final isActive = index < 6; // 6개 활성화

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.mathOrange
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            );
          }),
          // UFO 일러스트 (원형)
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🛸',
                    style: TextStyle(fontSize: 64),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘의 목표 카드
  Widget _buildDailyGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 책 아이콘
          const Text(
            '📖',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          // 목표 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 목표',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '80 / 100 XP',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                // 진행 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.8,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.mathTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 학습 시작하기 버튼
  Widget _buildStartButton(BuildContext context) {
    return _AnimatedButton(
      onPressed: () {
        // 학습 화면으로 이동
        Navigator.pushNamed(context, '/lessons');
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B5BFF), Color(0xFF2A45CC)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B5BFF).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              '학습 시작하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 카드 3개
  Widget _buildStatsCards(user) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('🔶', 'XP', '${user?.xp ?? 549}')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('⭐', '레벨', '${user?.level ?? 1}')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('🔥', '연속', '${user?.streak ?? 6}일')),
      ],
    );
  }

  /// 개별 통계 카드
  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// GoMATH 로고
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // GoMATH 로고 텍스트 (실제로는 이미지를 사용해야 함)
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'G',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'MATH',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B5BFF),
                  ),
                ),
                TextSpan(
                  text: 'H',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Design Deriven Mathematics',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

}

/// 애니메이션 버튼 위젯 (스케일 효과)
class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
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
        child: widget.child,
      ),
    );
  }
}

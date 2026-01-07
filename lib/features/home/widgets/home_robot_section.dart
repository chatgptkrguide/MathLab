import 'package:flutter/material.dart';
import '../../../shared/widgets/indicators/circular_progress_ring.dart';

/// 홈 화면 로봇 섹션
///
/// 포함 내용:
/// - 로봇 캐릭터 이미지
/// - 원형 진행률 링 (Figma 디자인)
/// - 탭하면 응원 메시지 표시
class HomeRobotSection extends StatelessWidget {
  const HomeRobotSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Image.asset(
                  'assets/icons/robot_character.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('🤖', style: TextStyle(fontSize: 24));
                  },
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '안녕! 나는 GoMath 로봇이야. 오늘도 열심히 공부하자! 💪',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4A90E2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 크기에 따라 동적으로 크기 조절
          final screenWidth = MediaQuery.of(context).size.width;
          final maxWidth = screenWidth * 0.8; // 화면의 80%
          final containerSize = maxWidth > 300 ? 300.0 : maxWidth;
          final ringSize = containerSize * 0.93; // 280/300
          final characterContainerSize = containerSize * 0.67; // 200/300
          final characterSize = containerSize * 0.6; // 180/300

          return SizedBox(
            width: containerSize,
            height: containerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Figma 원형 진행률 링
                CircularProgressRing(
                  progress: 0.8,
                  centerText: '80%',
                  subtitle: '완료',
                  size: ringSize,
                  strokeWidth: 16,
                ),

                // 로봇 캐릭터 (중앙에 오버레이)
                Container(
                  width: characterContainerSize,
                  height: characterContainerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/robot_character.png',
                      width: characterSize,
                      height: characterSize,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/icons/character_design.png',
                          width: characterSize,
                          height: characterSize,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              '🤖',
                              style: TextStyle(fontSize: containerSize * 0.33),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

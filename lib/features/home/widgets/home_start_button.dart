import 'package:flutter/material.dart';
import '../../lessons/figma/lessons_screen_figma.dart';

/// 홈 화면 학습 시작하기 버튼
///
/// Figma 디자인의 파란색 그라디언트 버튼
/// 클릭 시 레슨 선택 화면으로 이동
class HomeStartButton extends StatelessWidget {
  const HomeStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0000FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LessonsScreenFigma(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 28),
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
        ),
      ),
    );
  }
}

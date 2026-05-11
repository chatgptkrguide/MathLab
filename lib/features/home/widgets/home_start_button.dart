// Home start button — primary CTA that launches the lessons flow.
import 'package:flutter/material.dart';

import '../home_screen.dart';

class HomeStartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeStartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: HomeScreenFigma.startButtonKey,
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF0015F8),
          borderRadius: BorderRadius.circular(26.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0015F8).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              '학습 시작하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

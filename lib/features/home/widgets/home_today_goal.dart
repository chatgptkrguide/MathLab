// Home today's goal card — book icon, XP label, and linear progress bar.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../home_screen.dart';

class HomeTodayGoal extends StatelessWidget {
  final int dailyXP;
  final int dailyGoal;
  final double progress;

  const HomeTodayGoal({
    super.key,
    required this.dailyXP,
    required this.dailyGoal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: HomeScreenFigma.todayGoalKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Book icon
          Image.asset(
            'assets/icons/book_pencil.png',
            width: 58,
            height: 58,
            errorBuilder: (_, __, ___) => Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 32, color: AppColors.royalBlue),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 목표',
                  style: TextStyle(
                    color: Color(0xFF0D061F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dailyXP / $dailyGoal XP',
                  style: const TextStyle(
                    color: Color(0xFF18181B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

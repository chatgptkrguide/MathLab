// Home top bar — greeting (display name) and streak badge that opens settings.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../home_screen.dart';

class HomeTopBar extends StatelessWidget {
  final String? name;
  final int streak;
  final VoidCallback onStreakTap;

  const HomeTopBar({
    super.key,
    required this.name,
    required this.streak,
    required this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '안녕하세요!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${name ?? '학습자'}의 수학 학습',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Right: streak badge
        GestureDetector(
          key: HomeScreenFigma.streakBadgeKey,
          onTap: onStreakTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.mathOrange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  streak.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Color(0xFF0D061F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

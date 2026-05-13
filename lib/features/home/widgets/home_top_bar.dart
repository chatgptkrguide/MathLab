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
        // Left: greeting — 학습자명을 메인(fs16/w800), 인사말을 서브(fs11/w500)로 위계 명확화
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, ${name ?? '학습자'}님',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Text(
                '오늘도 수학 한 걸음',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.3,
                  letterSpacing: 0.6,
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

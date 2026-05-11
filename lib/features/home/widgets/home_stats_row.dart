// Home stats row — three square cards showing XP, level, and streak.
import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../home_screen.dart';

class HomeStatsRow extends StatelessWidget {
  final int xp;
  final int level;
  final int streak;

  const HomeStatsRow({
    super.key,
    required this.xp,
    required this.level,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: HomeScreenFigma.statsRowKey,
      children: [
        _StatSquare(
          icon: 'assets/icons/xp_icon.png',
          fallbackIcon: Icons.bolt_rounded,
          fallbackColor: AppColors.xpGold,
          label: 'XP',
          value: '$xp',
        ),
        const SizedBox(width: 10),
        _StatSquare(
          icon: 'assets/icons/level_icon.png',
          fallbackIcon: Icons.shield_rounded,
          fallbackColor: AppColors.royalBlue,
          label: '레벨',
          value: 'Lv.$level',
        ),
        const SizedBox(width: 10),
        _StatSquare(
          icon: 'assets/icons/streak_icon.png',
          fallbackIcon: Icons.local_fire_department_rounded,
          fallbackColor: AppColors.streakOrange,
          label: '연속',
          value: '$streak일',
        ),
      ],
    );
  }
}

class _StatSquare extends StatelessWidget {
  final String icon;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final String label;
  final String value;

  const _StatSquare({
    required this.icon,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              icon,
              width: 42,
              height: 42,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                color: fallbackColor,
                size: 42,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

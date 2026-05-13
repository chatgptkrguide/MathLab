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
    // 비대칭 레이아웃: XP 칸(flex:2, featured) + 레벨(flex:1) + 연속(flex:1)
    return Row(
      key: HomeScreenFigma.statsRowKey,
      children: [
        Expanded(
          flex: 2,
          child: _StatSquare(
            icon: 'assets/icons/xp_icon.png',
            fallbackIcon: Icons.bolt_rounded,
            fallbackColor: AppColors.xpGold,
            label: 'XP',
            value: '$xp',
            featured: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatSquare(
            icon: 'assets/icons/level_icon.png',
            fallbackIcon: Icons.shield_rounded,
            fallbackColor: AppColors.royalBlue,
            label: '레벨',
            value: 'Lv.$level',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatSquare(
            icon: 'assets/icons/streak_icon.png',
            fallbackIcon: Icons.local_fire_department_rounded,
            fallbackColor: AppColors.streakOrange,
            label: '연속',
            value: '$streak일',
          ),
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
  final bool featured;

  const _StatSquare({
    required this.icon,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.label,
    required this.value,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: featured ? 16 : 14),
      decoration: BoxDecoration(
        color: featured ? AppColors.beigOrange : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: featured
            ? Border.all(
                color: AppColors.xpGold.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: featured ? 0.08 : 0.06,
            ),
            blurRadius: featured ? 8 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            icon,
            width: featured ? 58 : 36,
            height: featured ? 58 : 36,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              color: fallbackColor,
              size: featured ? 58 : 36,
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
            style: TextStyle(
              color: Colors.black,
              fontSize: featured ? 18 : 12,
              fontWeight: featured ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

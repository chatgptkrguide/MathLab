// Profile stats row — three chips: longest streak, total XP, gems
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';

class ProfileStatsRow extends StatelessWidget {
  final UserModel user;

  const ProfileStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFFF6B35),
          bgColor: const Color(0xFFFFF3ED),
          label: '최장 스트릭',
          value: '${user.longestStreak}일',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFFFFB300),
          bgColor: const Color(0xFFFFF8E1),
          label: '총 XP',
          value: _formatNumber(user.totalXp),
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.diamond_rounded,
          iconColor: const Color(0xFF42A5F5),
          bgColor: const Color(0xFFE3F2FD),
          label: '보유 젬',
          value: _formatNumber(user.gems),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: iconColor.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(int number) {
  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k'
        .replaceAll('.0k', 'k');
  }
  return number.toString();
}

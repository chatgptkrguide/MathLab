import 'package:flutter/material.dart';
import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

class HomeStatsCards extends StatelessWidget {
  final UserModel? user;

  const HomeStatsCards({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.xpGold,
              iconBg: AppColors.beigOrange,
              label: 'XP',
              value: '${user?.xp ?? 0}',
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: _StatCard(
              icon: Icons.shield_rounded,
              iconColor: AppColors.royalBlue,
              iconBg: AppColors.beigBlue,
              label: '레벨',
              value: '${user?.level ?? 1}',
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: _StatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.streakOrange,
              iconBg: AppColors.beigOrange,
              label: '연속',
              value: '${user?.streak ?? 0}일',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing16,
        horizontal: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Icon(icon, color: iconColor, size: AppDimensions.iconMedium),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

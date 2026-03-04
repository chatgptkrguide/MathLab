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
          // XP card: takes more space with horizontal layout
          Expanded(
            flex: 2,
            child: _XpStatCard(
              icon: Icons.bolt_rounded,
              iconColor: AppColors.xpGold,
              iconBg: AppColors.beigOrange,
              label: 'XP',
              value: '${user?.xp ?? 0}',
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          // Level card: vertical with left border accent
          Expanded(
            flex: 1,
            child: _LevelStatCard(
              icon: Icons.shield_rounded,
              iconColor: AppColors.royalBlue,
              iconBg: AppColors.beigBlue,
              label: '레벨',
              value: '${user?.level ?? 1}',
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          // Streak card: vertical with different radius
          Expanded(
            flex: 1,
            child: _StreakStatCard(
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

/// XP card with horizontal layout (icon left, text right) and larger flex
class _XpStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _XpStatCard({
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
        horizontal: AppDimensions.spacing16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
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
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          ),
        ],
      ),
    );
  }
}

/// Level card with subtle left border accent
class _LevelStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _LevelStatCard({
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
        border: const Border(
          left: BorderSide(
            color: AppColors.royalBlue,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
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

/// Streak card with different border radius for visual variation
class _StreakStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _StreakStatCard({
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
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
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

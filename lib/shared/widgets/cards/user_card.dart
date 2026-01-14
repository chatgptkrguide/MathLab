import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/level_badge_mapper.dart';

/// 사용자 정보를 표시하는 공통 카드 위젯
///
/// 친구 목록, 리더보드, 검색 결과 등에서 재사용
class UserCard extends StatelessWidget {
  final String name;
  final int level;
  final int xp;
  final String? photoUrl;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showLevelBadge;
  final bool showXp;

  const UserCard({
    super.key,
    required this.name,
    required this.level,
    required this.xp,
    this.photoUrl,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.showLevelBadge = true,
    this.showXp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: backgroundColor,
      child: ListTile(
        onTap: onTap,
        leading: _buildAvatar(),
        title: Text(
          name,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTextStyles.bodySmall)
            : _buildStats(),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(photoUrl!),
        onBackgroundImageError: (_, __) {},
        child: const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      backgroundColor: AppColors.accentCyan.withValues(alpha: 0.1),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.accentCyan,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        // 레벨 배지
        if (showLevelBadge) ...[
          Image.asset(
            LevelBadgeMapper.getBadgeImagePath(level),
            width: 18,
            height: 18,
            errorBuilder: (context, error, stackTrace) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 14,
                    color: AppColors.mathGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lv.$level',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
        ],

        // XP
        if (showXp) ...[
          Icon(Icons.star, size: 14, color: AppColors.mathYellow),
          const SizedBox(width: 4),
          Text(
            '$xp XP',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// 랭크가 있는 사용자 카드 (리더보드용)
class RankedUserCard extends StatelessWidget {
  final int rank;
  final String name;
  final int level;
  final int xp;
  final String? photoUrl;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const RankedUserCard({
    super.key,
    required this.rank,
    required this.name,
    required this.level,
    required this.xp,
    this.photoUrl,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isCurrentUser
          ? AppColors.primary.withValues(alpha: 0.1)
          : null,
      elevation: isCurrentUser ? 2 : 1,
      child: ListTile(
        onTap: onTap,
        leading: _buildRankBadge(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'YOU',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.workspace_premium, size: 14, color: AppColors.mathGold),
            const SizedBox(width: 4),
            Text('Lv.$level', style: AppTextStyles.bodySmall),
            const SizedBox(width: 12),
            Icon(Icons.star, size: 14, color: AppColors.mathYellow),
            const SizedBox(width: 4),
            Text('$xp XP', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    Color badgeColor;
    IconData? icon;

    if (rank == 1) {
      badgeColor = AppColors.mathGold;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      badgeColor = Colors.grey[400]!;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      badgeColor = Colors.brown[400]!;
      icon = Icons.emoji_events;
    } else {
      badgeColor = AppColors.textSecondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: badgeColor, size: 20)
            : Text(
                '$rank',
                style: AppTextStyles.titleSmall.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/models/team_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMember member;
  final int rank;
  final bool isCurrentUser;
  final bool showActions;
  final VoidCallback? onRemove;
  final VoidCallback? onTransferLeader;

  const TeamMemberCard({
    super.key,
    required this.member,
    required this.rank,
    this.isCurrentUser = false,
    this.showActions = false,
    this.onRemove,
    this.onTransferLeader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.beigBlue
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppColors.royalBlue.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              _rankDisplay,
              style: TextStyle(
                fontSize: rank <= 3 ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? null : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _avatarColor,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.displayName.isNotEmpty
                        ? member.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.displayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(나)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.royalBlue,
                        ),
                      ),
                    ],
                    if (member.isLeader) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.xpGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '팀장',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.mathOrangeDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Lv.${member.level}  |  연속 ${member.streak}일',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member.xp} XP',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.xpGold,
                ),
              ),
              if (member.weeklyXp > 0)
                Text(
                  '+${member.weeklyXp} 이번 주',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mathGreen,
                  ),
                ),
            ],
          ),

          // Actions menu
          if (showActions && !member.isLeader)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textTertiary,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'remove') onRemove?.call();
                if (value == 'transfer') onTransferLeader?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'transfer',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 18),
                      SizedBox(width: 8),
                      Text('팀장 위임'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('내보내기', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String get _rankDisplay {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  Color get _avatarColor {
    final colors = [
      AppColors.royalBlue,
      AppColors.mathGreen,
      AppColors.mathPurple,
      AppColors.tealGreen,
      AppColors.mathOrange,
    ];
    return colors[member.displayName.length % colors.length];
  }
}

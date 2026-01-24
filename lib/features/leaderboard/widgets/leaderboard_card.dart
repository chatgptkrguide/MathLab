import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/utils/level_badge_mapper.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/user/friend_provider.dart';
import '../../../data/providers/user/all_users_provider.dart';

/// 리더보드 카드 위젯 (Duolingo flat style)
class LeaderboardCard extends ConsumerWidget {
  final LeaderboardEntry entry;
  final bool isTopThree;

  const LeaderboardCard({
    super.key,
    required this.entry,
    required this.isTopThree,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.successGreen.withValues(alpha: 0.2) // Light green highlight
            : AppColors.surface,
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.successGreen // GoMath green border for current user
              : AppColors.borderLight, // Light gray border
          width: entry.isCurrentUser ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: entry.isCurrentUser
                ? AppColors.successGreen.withValues(alpha: 0.15)
                : AppColors.borderLight.withValues(alpha: 0.1),
            blurRadius: entry.isCurrentUser ? 8 : 4,
            offset: Offset(0, entry.isCurrentUser ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 순위
          _RankBadge(entry: entry),
          const SizedBox(width: AppDimensions.spacingM),
          // 사용자 정보
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '나',
                          style: TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      entry.grade,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 레벨 배지
                    Image.asset(
                      LevelBadgeMapper.getBadgeImagePath(entry.level),
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'Lv.${entry.level}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.mathRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.streakDays}일',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp}',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTopThree
                      ? _getRankColor(entry.rank)
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // 친구 추가 버튼 (자기 자신이 아닌 경우만)
          if (!entry.isCurrentUser) ...[
            const SizedBox(width: 8),
            _FriendButton(entry: entry),
          ],
        ],
      ),
    );
  }

  /// 순위별 색상 (GoMath)
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.mathYellow; // 금 (GoMath)
      case 2:
        return AppColors.levelSilver; // 은 (표준 메달 색상)
      case 3:
        return AppColors.levelBronze; // 동 (표준 메달 색상)
      default:
        return AppColors.textSecondary;
    }
  }
}

/// 순위 배지 위젯 (Duolingo flat style)
class _RankBadge extends StatelessWidget {
  final LeaderboardEntry entry;

  const _RankBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    final medal = entry.medalEmoji;

    if (medal != null) {
      // Top 3는 메달 표시 with flat color and border
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _getRankColor(entry.rank),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: _getDarkerRankColor(entry.rank),
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            medal,
            style: const TextStyle(fontSize: 26),
          ),
        ),
      );
    }

    // 나머지는 순위 숫자 with GoMath style
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${entry.rank}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 순위별 색상 (GoMath)
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.mathYellow;
      case 2:
        return AppColors.levelSilver;
      case 3:
        return AppColors.levelBronze;
      default:
        return AppColors.textSecondary;
    }
  }

  /// 순위별 어두운 색상 (테두리용)
  Color _getDarkerRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.levelGoldDark;
      case 2:
        return AppColors.levelSilverDark;
      case 3:
        return AppColors.levelBronzeDark;
      default:
        return AppColors.borderLight;
    }
  }
}

/// 친구 추가 버튼 위젯
class _FriendButton extends ConsumerWidget {
  final LeaderboardEntry entry;

  const _FriendButton({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);

    // 이미 친구인지 확인
    final isFriend = friends.any(
      (f) =>
          f.userId == entry.userId && f.status == FriendRequestStatus.accepted,
    );

    // 대기 중인 요청이 있는지 확인
    final hasPendingRequest = friends.any(
      (f) =>
          f.userId == entry.userId && f.status == FriendRequestStatus.pending,
    );

    if (isFriend) {
      return const SizedBox.shrink();
    }

    if (hasPendingRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '대기중',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // 친구 추가 버튼
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () => _sendFriendRequest(context, ref),
        icon: const Icon(
          Icons.person_add,
          color: AppColors.primary,
          size: 20,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        tooltip: '친구 추가',
      ),
    );
  }

  /// 친구 요청 보내기
  Future<void> _sendFriendRequest(BuildContext context, WidgetRef ref) async {
    try {
      // AllUsersProvider에서 실제 사용자 정보 가져오기
      final allUsers = ref.read(allUsersProvider);
      final targetUser = allUsers.firstWhere(
        (u) => u.id == entry.userId,
        orElse: () => User(
          id: entry.userId,
          name: entry.userName,
          email: '${entry.userId}@example.com',
          joinDate: DateTime.now(),
          level: entry.level,
          xp: entry.xp,
          streakDays: entry.streakDays,
          currentGrade: entry.grade,
          avatarUrl: '👤',
          hearts: 5,
          dailyXP: 0,
          lastXPResetDate: DateTime.now(),
        ),
      );

      await ref.read(friendsProvider.notifier).sendFriendRequest(
            userId: targetUser.id,
            name: targetUser.name,
            level: targetUser.level,
            xp: targetUser.xp,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${targetUser.name}님에게 친구 요청을 보냈습니다'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('친구 요청을 보내는데 실패했습니다'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

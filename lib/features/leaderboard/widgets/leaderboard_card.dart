import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/utils/level_badge_mapper.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/user/friend_provider.dart';
import '../../../data/providers/user/all_users_provider.dart';

/// 리더보드 카드 위젯 (Duolingo flat style)
/// Top 3: gold/silver/bronze gradient, larger avatars
/// Current user: blue border/tint highlight
/// Ranks 4+: clean list with alternating backgrounds
class LeaderboardCard extends ConsumerWidget {
  final LeaderboardEntry entry;
  final bool isTopThree;
  final int index;

  const LeaderboardCard({
    super.key,
    required this.entry,
    required this.isTopThree,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrentUser = entry.isCurrentUser;
    final hasAlternatingBg = !isTopThree && index.isOdd;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isTopThree ? AppDimensions.paddingL : 14),
      decoration: BoxDecoration(
        gradient: isTopThree ? _getTopThreeGradient(entry.rank) : null,
        color: isTopThree
            ? null
            : isCurrentUser
                ? AppColors.mathBlue.withValues(alpha: 0.08)
                : hasAlternatingBg
                    ? AppColors.backgroundLight
                    : AppColors.surface,
        border: Border.all(
          color: isCurrentUser
              ? AppColors.mathBlue
              : isTopThree
                  ? _getRankBorderColor(entry.rank)
                  : AppColors.borderLight,
          width: isCurrentUser ? 2.5 : isTopThree ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _getRankColor(entry.rank).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : isCurrentUser
                ? [
                    BoxShadow(
                      color: AppColors.mathBlue.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
      ),
      child: Row(
        children: [
          // Rank badge with size based on rank
          _RankBadge(entry: entry),
          SizedBox(width: isTopThree ? 14 : 12),
          // User info
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTopThree ? 17 : 15,
                          color: isTopThree
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isTopThree
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.mathBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '나',
                          style: TextStyle(
                            color: isTopThree
                                ? Colors.white
                                : AppColors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      entry.grade,
                      style: TextStyle(
                        color: isTopThree
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 6),
                    // Level badge
                    Image.asset(
                      LevelBadgeMapper.getBadgeImagePath(entry.level),
                      width: 14,
                      height: 14,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'Lv.${entry.level}',
                          style: TextStyle(
                            color: isTopThree
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.local_fire_department,
                      color: isTopThree
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.mathRed,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${entry.streakDays}',
                      style: TextStyle(
                        color: isTopThree
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // XP score right-aligned
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTopThree ? 20 : 17,
                  color: isTopThree
                      ? Colors.white
                      : isCurrentUser
                          ? AppColors.mathBlue
                          : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'XP',
                style: TextStyle(
                  color: isTopThree
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Friend button (non-self only)
          if (!entry.isCurrentUser) ...[
            const SizedBox(width: 8),
            _FriendButton(entry: entry),
          ],
        ],
      ),
    );
  }

  /// Top 3 gradient backgrounds
  LinearGradient _getTopThreeGradient(int rank) {
    switch (rank) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFB8691A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(colors: [Colors.transparent, Colors.transparent]);
    }
  }

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

  Color _getRankBorderColor(int rank) {
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

/// Rank badge with different sizes for top 3
class _RankBadge extends StatelessWidget {
  final LeaderboardEntry entry;

  const _RankBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    final medal = entry.medalEmoji;

    // Different avatar sizes for podium
    final double size;
    switch (entry.rank) {
      case 1:
        size = 64;
        break;
      case 2:
        size = 56;
        break;
      case 3:
        size = 48;
        break;
      default:
        size = 40;
    }

    if (medal.isNotEmpty) {
      // Top 3: medal with crown for 1st
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(size / 2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Text(
                  medal,
                  style: TextStyle(fontSize: size * 0.45),
                ),
              ),
            ),
            if (entry.rank == 1)
              Positioned(
                top: -8,
                child: Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: size * 0.35,
                ),
              ),
          ],
        ),
      );
    }

    // Regular rank number
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${entry.rank}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
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
      final allUsersAsync = ref.read(allUsersProvider);
      final allUsers = allUsersAsync.valueOrNull ?? [];
      final targetUser = allUsers.isNotEmpty
          ? allUsers.firstWhere(
              (u) => u.id == entry.userId,
              orElse: () => User(
                id: entry.userId,
                name: entry.userName,
                email: '',
                joinDate: DateTime.now(),
                level: entry.level,
                xp: entry.xp,
                streakDays: entry.streakDays,
                currentGrade: entry.grade,
              ),
            )
          : User(
              id: entry.userId,
              name: entry.userName,
              email: '',
              joinDate: DateTime.now(),
              level: entry.level,
              xp: entry.xp,
              streakDays: entry.streakDays,
              currentGrade: entry.grade,
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

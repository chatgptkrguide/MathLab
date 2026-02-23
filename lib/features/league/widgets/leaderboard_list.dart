// Leaderboard List Widget for League screen
//
// Displays ranked list of users with promotion/relegation zones
// Top N = green highlight (promotion), bottom N = red highlight (demotion)
// with up/down arrow indicators

import 'package:flutter/material.dart';
import '../../../data/models/league_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_text_styles.dart';

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final int promotionCount;
  final int relegationCount;

  const LeaderboardList({
    super.key,
    required this.entries,
    required this.promotionCount,
    required this.relegationCount,
  });

  _ZoneType _getZoneType(int index) {
    if (index < promotionCount) return _ZoneType.promotion;
    if (entries.isNotEmpty && index >= entries.length - relegationCount) {
      return _ZoneType.relegation;
    }
    return _ZoneType.safe;
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing32),
            child: Text('순위표가 비어있습니다'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          final zoneType = _getZoneType(index);

          return _LeagueEntryTile(
            entry: entry,
            zoneType: zoneType,
            index: index,
          );
        },
        childCount: entries.length,
      ),
    );
  }
}

enum _ZoneType { promotion, safe, relegation }

class _LeagueEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final _ZoneType zoneType;
  final int index;

  const _LeagueEntryTile({
    required this.entry,
    required this.zoneType,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = entry.isCurrentUser;
    final isPromotion = zoneType == _ZoneType.promotion;
    final isRelegation = zoneType == _ZoneType.relegation;

    final Color bgColor;
    if (isCurrentUser) {
      bgColor = AppColors.mathBlue.withValues(alpha: 0.08);
    } else if (isPromotion) {
      bgColor = Colors.green.withValues(alpha: 0.06);
    } else if (isRelegation) {
      bgColor = Colors.red.withValues(alpha: 0.06);
    } else {
      bgColor = index.isOdd ? AppColors.backgroundLight : Colors.white;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: isCurrentUser
            ? Border.all(color: AppColors.mathBlue, width: 2)
            : isPromotion
                ? Border.all(
                    color: Colors.green.withValues(alpha: 0.25), width: 1)
                : isRelegation
                    ? Border.all(
                        color: Colors.red.withValues(alpha: 0.25), width: 1)
                    : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12, vertical: AppDimensions.spacing12),
        child: Row(
          children: [
            // Zone indicator (arrow)
            SizedBox(
              width: 20,
              child: isPromotion
                  ? const Icon(Icons.arrow_upward_rounded,
                      size: 16, color: Colors.green)
                  : isRelegation
                      ? const Icon(Icons.arrow_downward_rounded,
                          size: 16, color: Colors.red)
                      : const SizedBox.shrink(),
            ),

            // Rank number
            SizedBox(
              width: 36,
              child: Text(
                '#${entry.rank}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight:
                      isCurrentUser ? FontWeight.bold : FontWeight.w600,
                  color: entry.rank <= 3
                      ? _getRankColor(entry.rank)
                      : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Profile Image
            CircleAvatar(
              radius: entry.rank <= 3 ? 22 : 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: entry.profileImageUrl != null
                  ? NetworkImage(entry.profileImageUrl!)
                  : null,
              child: entry.profileImageUrl == null
                  ? Text(
                      entry.username[0].toUpperCase(),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: entry.rank <= 3 ? 16 : 14,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: AppDimensions.spacing12),

            // Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.username,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: AppDimensions.spacing2),
                          decoration: BoxDecoration(
                            color: AppColors.mathBlue,
                            borderRadius: BorderRadius.circular(AppDimensions.radius6),
                          ),
                          child: const Text(
                            '나',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isPromotion || isRelegation)
                    Text(
                      isPromotion ? '승급권' : '강등권',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isPromotion ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
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
                  '${entry.xp}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser
                        ? AppColors.mathBlue
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'XP',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Rank change indicator
            if (entry.rankChange != null) ...[
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.isPromotion
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 12,
                    color: entry.isPromotion ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${entry.rankChange!.abs()}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: entry.isPromotion ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
}

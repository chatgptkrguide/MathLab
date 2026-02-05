// 📊 Leaderboard List Widget
//
// Displays ranked list of users with promotion/relegation zones

import 'package:flutter/material.dart';
import '../../../data/models/league_model.dart';
import '../../../shared/constants/app_colors.dart';
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

  Color _getZoneColor(int index) {
    if (index < promotionCount) {
      return Colors.green.withValues(alpha: 0.1);
    } else if (index >= entries.length - relegationCount) {
      return Colors.red.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }

  Widget _getZoneIndicator(int index) {
    if (index < promotionCount) {
      return Container(
        width: 4,
        color: Colors.green,
      );
    } else if (index >= entries.length - relegationCount) {
      return Container(
        width: 4,
        color: Colors.red,
      );
    }
    return const SizedBox(width: 4);
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('순위표가 비어있습니다'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          final zoneColor = _getZoneColor(index);

          return Container(
            color: entry.isCurrentUser 
                ? AppColors.primary.withValues(alpha: 0.1)
                : zoneColor,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                _getZoneIndicator(index),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 40,
                          child: Text(
                            '#${entry.rank}',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: entry.isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: entry.rank <= 3 
                                  ? AppColors.primary 
                                  : Colors.grey[800],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Profile Image
                        CircleAvatar(
                          radius: 20,
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
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        // Username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.username,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: entry.isCurrentUser
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (entry.isCurrentUser)
                                Text(
                                  '나',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
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
                              '${entry.xp} XP',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (entry.rankChange != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    entry.isPromotion
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 14,
                                    color: entry.isPromotion
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${entry.rankChange!.abs()}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: entry.isPromotion
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        childCount: entries.length,
      ),
    );
  }
}

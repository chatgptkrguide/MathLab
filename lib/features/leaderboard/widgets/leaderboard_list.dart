import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../data/models/models.dart';
import 'leaderboard_card.dart';

/// 리더보드 목록 위젯
class LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardList({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isTopThree = entry.rank <= 3;

          return FadeInWidget(
            delay: Duration(milliseconds: 50 * index),
            child: LeaderboardCard(
              entry: entry,
              isTopThree: isTopThree,
            ),
          );
        },
      ),
    );
  }
}

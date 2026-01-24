import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../league/league_screen.dart';

/// 리더보드 헤더 위젯
class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Balance for league button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                '리더보드',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeagueScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.emoji_events,
              color: AppColors.mathYellow,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

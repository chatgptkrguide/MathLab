import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../shared/utils/level_badge_mapper.dart';
import '../../../shared/constants/duolingo_styles.dart';
import '../../../shared/widgets/styled/duolingo_stat_card.dart';
import '../../profile/figma/profile_detail_screen.dart';
import '../../leaderboard/leaderboard_screen.dart';

/// 홈 화면 스탯 카드들
///
/// 포함 내용:
/// - XP 카드 (프로필 상세 화면으로 이동)
/// - 레벨 카드 (리더보드 화면으로 이동)
/// - 연속 일수 카드 (프로필 상세 화면으로 이동)
class HomeStatsCards extends StatelessWidget {
  final User? user;

  const HomeStatsCards({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DuolingoStyles.spacing24),
      child: Row(
        children: [
          // XP 카드 - 프로필 상세 화면으로 이동
          DuolingoStatCard(
            icon: 'assets/icons/xp_icon.png',
            label: 'XP',
            value: '${user?.xp ?? 549}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: DuolingoStyles.spacing16),
          // 레벨 카드 - 리더보드 화면으로 이동
          DuolingoStatCard(
            icon: LevelBadgeMapper.getBadgeImagePath(user?.level ?? 1),
            label: '레벨',
            value: 'H Lv${user?.level ?? 1}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: DuolingoStyles.spacing16),
          // 연속 일수 카드 - 프로필 상세 화면으로 이동
          DuolingoStatCard(
            icon: 'assets/icons/streak_fire.png',
            label: '연속',
            value: '${user?.streakDays ?? 0}일',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

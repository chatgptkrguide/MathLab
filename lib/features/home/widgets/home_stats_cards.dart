import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../shared/utils/level_badge_mapper.dart';
import '../../profile/figma/profile_detail_screen_v3_new.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // XP 카드 - 프로필 상세 화면으로 이동
          _buildStatCard(
            'assets/icons/xp_icon.png',
            'XP',
            '${user?.xp ?? 549}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // 레벨 카드 - 리더보드 화면으로 이동
          _buildStatCard(
            LevelBadgeMapper.getBadgeImagePath(user?.level ?? 1),
            '레벨',
            'H Lv${user?.level ?? 1}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // 연속 일수 카드 - 프로필 상세 화면으로 이동
          _buildStatCard(
            'assets/icons/streak_fire.png',
            '연속',
            '${user?.streakDays ?? 0}일',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreenV3New(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 개별 스탯 카드 빌더
  Widget _buildStatCard(
    String iconPath,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.star,
                      size: 28,
                      color: Colors.grey[400],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

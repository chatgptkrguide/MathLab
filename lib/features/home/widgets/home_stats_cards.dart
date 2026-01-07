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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.star,
                          size: 24,
                          color: Colors.blue.shade400,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.3,
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

// Profile header — gradient top bar with avatar, level badge, and XP progress
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/game_constants.dart';
import '../../../shared/utils/number_format.dart';
import '../edit_profile_screen.dart';
import '../../settings/settings_screen.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  /// Coachmark key for the profile card row (avatar + name).
  final Key? profileCardKey;

  const ProfileHeader({
    super.key,
    required this.user,
    this.profileCardKey,
  });

  @override
  Widget build(BuildContext context) {
    final league = user.league.toLowerCase();

    // League display info
    final leagueInfo = _getLeagueInfo(league);

    // Level progress — league-tier based
    final t = GameConstants.leagueRange(league);
    final xpInTier = user.totalXp - t[0];
    final xpNeeded = t[1] - t[0];
    final progress =
        xpNeeded > 0 ? (xpInTier / xpNeeded).clamp(0.0, 1.0) : 1.0;

    // XP remaining to next league
    final xpRemaining = (t[1] - user.totalXp).clamp(0, xpNeeded);

    return Container(
      decoration: BoxDecoration(
        color: leagueInfo.color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '프로필',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Avatar + Name row
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                ),
                child: Row(
                  key: profileCardKey,
                  children: [
                    // Avatar — no level badge here (shown in card below)
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2.5,
                          ),
                        ),
                        child: user.photoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      CircleAvatar(
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.2),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + username + level inline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? '사용자',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // email + Lv badge inline — single source of level display in header
                          Row(
                            children: [
                              Text(
                                user.email != null
                                    ? '@${user.email!.split('@').first}'
                                    : '@guest',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: leagueInfo.color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      width: 1),
                                ),
                                child: Text(
                                  'Lv.${user.level}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Edit icon (subtle)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // XP progress card — asymmetric layout, not a uniform stat card
              _XpProgressCard(
                leagueInfo: leagueInfo,
                user: user,
                xpInTier: xpInTier,
                xpNeeded: xpNeeded,
                xpRemaining: xpRemaining,
                progress: progress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _LeagueDisplayInfo _getLeagueInfo(String league) {
    switch (league) {
      case 'silver':
        return const _LeagueDisplayInfo(
          name: '실버',
          color: AppColors.leagueSilver,
          gradientEnd: AppColors.leagueSilverLight,
        );
      case 'gold':
        return const _LeagueDisplayInfo(
          name: '골드',
          color: AppColors.leagueGold,
          gradientEnd: AppColors.leagueGoldLight,
        );
      case 'diamond':
        return const _LeagueDisplayInfo(
          name: '다이아몬드',
          color: AppColors.leagueDiamond,
          gradientEnd: AppColors.leagueDiamondLight,
        );
      case 'master':
        return const _LeagueDisplayInfo(
          name: '마스터',
          color: AppColors.leagueMaster,
          gradientEnd: AppColors.leagueMasterLight,
        );
      default: // bronze
        return const _LeagueDisplayInfo(
          name: '브론즈',
          color: AppColors.leagueBronze,
          gradientEnd: AppColors.leagueBronzeLight,
        );
    }
  }
}

/// XP 진행 카드 — 리그 뱃지(좌) + 진행률 트랙(우) 비대칭 구성
class _XpProgressCard extends StatelessWidget {
  final _LeagueDisplayInfo leagueInfo;
  final UserModel user;
  final int xpInTier;
  final int xpNeeded;
  final int xpRemaining;
  final double progress;

  const _XpProgressCard({
    required this.leagueInfo,
    required this.user,
    required this.xpInTier,
    required this.xpNeeded,
    required this.xpRemaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: leagueInfo.color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT — league icon + total XP (compact, ~36% width)
            _LeagueBadgeColumn(leagueInfo: leagueInfo, user: user),

            const SizedBox(width: 14),

            // Vertical divider
            Container(
              width: 1,
              height: 72,
              color: AppColors.borderLight,
            ),

            const SizedBox(width: 14),

            // RIGHT — progress track (wider, ~64% width)
            Expanded(
              child: _ProgressTrack(
                leagueInfo: leagueInfo,
                xpInTier: xpInTier,
                xpNeeded: xpNeeded,
                xpRemaining: xpRemaining,
                progress: progress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 좌측: 리그 배지 + 누적 XP 숫자 (크게)
class _LeagueBadgeColumn extends StatelessWidget {
  final _LeagueDisplayInfo leagueInfo;
  final UserModel user;

  const _LeagueBadgeColumn({
    required this.leagueInfo,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // League name chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: leagueInfo.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            leagueInfo.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: leagueInfo.color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Total XP — large, dominant
        Text(
          formatCompact(user.totalXp),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            height: 1.0,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'XP 누적',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// 우측: XP 진행 트랙 — 굵은 막대 + 마커 + 인라인 레이블
class _ProgressTrack extends StatelessWidget {
  final _LeagueDisplayInfo leagueInfo;
  final int xpInTier;
  final int xpNeeded;
  final int xpRemaining;
  final double progress;

  const _ProgressTrack({
    required this.leagueInfo,
    required this.xpInTier,
    required this.xpNeeded,
    required this.xpRemaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: "이번 리그 진행률" label + remaining XP on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '이번 리그',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (!isComplete)
              Text(
                '${formatCompact(xpRemaining)} XP 남음',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: leagueInfo.color.withValues(alpha: 0.8),
                ),
              )
            else
              Text(
                '완료!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: leagueInfo.color,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar — thick track with end notch marker
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final fillWidth = (barWidth * progress).clamp(0.0, barWidth);
            return SizedBox(
              height: 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track background
                  Container(
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    width: fillWidth.clamp(12.0, barWidth),
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: leagueInfo.color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: leagueInfo.color.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // Notch marker at fill edge (手作り detail)
                  if (progress > 0.05 && !isComplete)
                    Positioned(
                      left: fillWidth - 5,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: leagueInfo.color,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // Inline XP label: "현재 / 목표"
        Row(
          children: [
            Text(
              formatCompact(xpInTier),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: leagueInfo.color,
              ),
            ),
            Text(
              ' / ${formatCompact(xpNeeded)} XP',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: leagueInfo.color.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeagueDisplayInfo {
  final String name;
  final Color color;
  final Color gradientEnd;

  const _LeagueDisplayInfo({
    required this.name,
    required this.color,
    required this.gradientEnd,
  });
}

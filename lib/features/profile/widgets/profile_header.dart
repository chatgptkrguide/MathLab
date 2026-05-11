// Profile header — gradient top bar with avatar, level badge, and XP progress
import 'package:flutter/material.dart';

import '../../../data/models/user/user_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/game_constants.dart';
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

    // Level progress calculation
    final t = GameConstants.leagueRange(league);
    final xpInTier = user.totalXp - t[0];
    final xpNeeded = t[1] - t[0];
    final progress =
        xpNeeded > 0 ? (xpInTier / xpNeeded).clamp(0.0, 1.0) : 1.0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyBlue,
            AppColors.skyBlue.withValues(alpha: 0.85),
          ],
        ),
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
                    // Avatar with level badge
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
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
                          // Level badge
                          Positioned(
                            bottom: -4,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: leagueInfo.color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: leagueInfo.color
                                          .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + username
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
                          const SizedBox(height: 3),
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

              const SizedBox(height: 12),

              // Level progress card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(
                        color: leagueInfo.color,
                        width: 3.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // League + Level info row
                      Row(
                        children: [
                          // League icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: leagueInfo.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: leagueInfo.color.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              'assets/icons/level_icon.png',
                              width: 32,
                              height: 32,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.shield_rounded,
                                color: leagueInfo.color,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  leagueInfo.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: leagueInfo.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: leagueInfo.color
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Lv.${user.level}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: leagueInfo.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // XP display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatNumber(user.totalXp),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Text(
                                'XP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // XP progress labels (above bar)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatNumber(xpInTier),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: leagueInfo.color,
                              ),
                            ),
                            Text(
                              '${_formatNumber(xpNeeded)} XP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress bar with percentage
                      SizedBox(
                        height: 26,
                        child: Stack(
                          children: [
                            Container(
                              height: 26,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5E5),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    width: constraints.maxWidth * progress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          leagueInfo.color,
                                          leagueInfo.gradientEnd,
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      boxShadow: [
                                        BoxShadow(
                                          color: leagueInfo.color
                                              .withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Percentage text centered on bar
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: progress > 0.4
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
        return _LeagueDisplayInfo(
          name: '실버',
          color: const Color(0xFF78909C),
          gradientEnd: const Color(0xFFB0BEC5),
        );
      case 'gold':
        return _LeagueDisplayInfo(
          name: '골드',
          color: const Color(0xFFFF9800),
          gradientEnd: const Color(0xFFFFB74D),
        );
      case 'diamond':
        return _LeagueDisplayInfo(
          name: '다이아몬드',
          color: const Color(0xFF42A5F5),
          gradientEnd: const Color(0xFF90CAF9),
        );
      case 'master':
        return _LeagueDisplayInfo(
          name: '마스터',
          color: const Color(0xFF7E57C2),
          gradientEnd: const Color(0xFFB39DDB),
        );
      default: // bronze
        return _LeagueDisplayInfo(
          name: '브론즈',
          color: const Color(0xFFCD7F32),
          gradientEnd: const Color(0xFFDEA05E),
        );
    }
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

String _formatNumber(int number) {
  if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k'
        .replaceAll('.0k', 'k');
  }
  return number.toString();
}
